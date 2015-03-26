# encoding: iso-8859-1

require 'go_import'
require 'tiny_tds'
require_relative("../converter")


def convert_source
    puts "Trying to convert LIME Pro source to LIME Go..."

    if !defined?(SQL_SERVER) || SQL_SERVER.empty?
        raise "SQL_SERVER must be set in converter.rb" 
    end

    if !defined?(SQL_SERVER_DATABASE) || SQL_SERVER_DATABASE.empty?
        raise "SQL_SERVER_DATABASE must be set in converter.rb" 
    end

    if !defined?(LIME_SERVER) || LIME_SERVER.empty?
        raise "LIME_SERVER must be set in converter.rb" 
    end
    
    if !defined?(LIME_DATABASE) || LIME_DATABASE.empty?
        raise "LIME_DATABASE must be set in converter.rb" 
    end

    if !defined?(LIME_LANGUAGE) || LIME_LANGUAGE.empty?
        raise "LIME_LANGUAGE must be set in converter.rb" 
    end
    
    windows_authentication = false
    if defined?(SQL_SERVER_USER) && !SQL_SERVER_USER.empty?
        begin
            print "Password for #{SQL_SERVER_USER}: "
            # We hide the entered characters before to ask for the password
            system 'stty -echo'
            sql_server_password = $stdin.gets.chomp
            system 'stty echo'
            puts ""
        rescue NoMethodError, Interrupt
            # When the process is exited, we display the characters
            # again And we exit
            system 'stty echo'
            exit
        end
    else
        puts "No user defined, using Windows authentication to connect to SQL Server. We will connect as the user that is running go-import. Set a value for SQL_SERVER_USER in converter.rb to change."
        windows_authentication = true
    end
    
    begin
        if windows_authentication
            db_con = TinyTds::Client.new(dataserver: SQL_SERVER,
                                         database: SQL_SERVER_DATABASE)
        else            
            db_con = TinyTds::Client.new(username: SQL_SERVER_USER,
                                         password: sql_server_password,
                                         dataserver: SQL_SERVER,
                                         database: SQL_SERVER_DATABASE)
        end

        puts "Connected to SQL Server."
    rescue Exception => e
        puts "ERROR: Failed to connect to SQL-server"
        puts e.message
        exit
    end

    con = LIMEProConnection.new db_con
    converter = Converter.new
    rootmodel = GoImport::RootModel.new


    # coworker_class = con.get_class_by_name("coworker")
    # puts "Coworker class: #{coworker_class}"
    # name_field = coworker_class.get_field_by_label(FieldLabel::Name)

    # puts "name field #{name_field}"
        

    # exit
    
    
    converter.configure rootmodel

    #Add custom fields for LIME-links
    rootmodel.settings.with_person  do |person|
        person.set_custom_field( { :integration_id => 'limelink', :title => 'Länk till LIME Pro', :type => :Link} )
    end

    rootmodel.settings.with_organization  do |org|
        org.set_custom_field( { :integration_id => 'limelink', :title => 'Länk till LIME Pro', :type => :Link} )
    end

    rootmodel.settings.with_deal  do |deal|
        deal.set_custom_field( { :integration_id => 'limelink', :title => 'Länk till LIME Pro', :type => :Link} )
    end

    # coworkers
    # start with these since they are referenced
    # from everywhere....
    con.fetch_data "coworker" do |row|
        coworker = init_coworker(row, con.get_class_by_name('coworker'))
        rootmodel.add_coworker(converter.to_coworker(coworker, row))
    end

    # organizations
    con.fetch_data "company" do |row|
        organization = init_organization(row, con.get_class_by_name('company'), rootmodel)
        rootmodel.add_organization(converter.to_organization(organization, row))
    end
   
    # persons
    # depends on organizations
    con.fetch_data "person" do |row|
        # init method also adds the person to the employer
        person = init_person(row, con.get_class_by_name('person'), rootmodel)
        converter.to_person(person, row)
    end

    # deals
    # deals can reference coworkers (responsible), organizations
    # and persons (contact)
    if defined?(IMPORT_DEALS) && IMPORT_DEALS == true
        puts "Trying to import deals..."
        con.fetch_data 'business' do |row|
            deal = init_deal(row, con.get_class_by_name('business'), rootmodel)
            rootmodel.add_deal(converter.to_deal(deal, row))
        end
    else
        puts "Deals are not imported. To enable set IMPORT_DEALS = true in converter.rb."
    end

    if defined?(IMPORT_NOTES) && IMPORT_NOTES == true
        con.fetch_data 'history' do |row|
            note = converter.to_note(init_note(row, con.get_class_by_name('history'), rootmodel), row)
            #if !note.organization.nil? || !note.person.nil?
                rootmodel.add_note(note)
            #end
        end
    else
        puts "Notes/history is not imported. To enable set IMPORT_NOTES = true in converter.rb."
    end

    """
    # documents
    if defined?(IMPORT_DOCUMENTS) && !IMPORT_DOCUMENTS.nil? && IMPORT_DOCUMENTS
        process_rows ORGANIZATION_DOCUMENT_FILE do |row|
            rootmodel.add_file(to_organization_document(row, rootmodel))
        end

        process_rows PROJECT_DOCUMENT_FILE do |row|
            rootmodel.add_file(to_deal_document(row, rootmodel))
        end
    end
    """

    return rootmodel
end


def init_coworker(row, table)
    coworker = GoImport::Coworker.new
    # integration_id is typically the idcoworker in Pro
    # Must be set to be able to import the same file more
    # than once without creating duplicates
    coworker.integration_id = row['idcoworker'].to_s

    coworker.parse_name_to_firstname_lastname_se table.get_value_for_field_with_label(row, FieldLabel::Name)
    coworker.email = table.get_value_for_field_with_label(row, FieldLabel::PrimaryEmailAddress)
    coworker.direct_phone_number = table.get_value_for_field_with_label(row, FieldLabel::BusinessTelephoneNumber)
    coworker.mobile_phone_number = table.get_value_for_field_with_label(row, FieldLabel::MobileTelephoneNumber)
    
    return coworker
end

def init_organization(row, table, rootmodel)
    organization = GoImport::Organization.new
    # integration_id is typically the company Id in Easy
    # Must be set to be able to import the same file more
    # than once without creating duplicates
    organization.integration_id = row['idcompany'].to_s
    organization.set_custom_value("limelink", build_lime_link("company", row['idcompany']))

    organization.name = table.get_value_for_field_with_label(row, FieldLabel::Name)

    organization.organization_number = table.get_value_for_field_with_label(row, FieldLabel::CompanyNumber)
    organization.email = table.get_value_for_field_with_label(row, FieldLabel::PrimaryEmailAddress)
    organization.web_site = table.get_value_for_field_with_label(row, FieldLabel::BusinessHomepage)
    organization.central_phone_number = table.get_value_for_field_with_label(row, FieldLabel::BusinessTelephoneNumber)

    organization.with_postal_address do |address|
        address.street = table.get_value_for_field_with_label(row, FieldLabel::StreetAddress) + " " +
                         table.get_value_for_field_with_label(row, FieldLabel::StreetAddress2)
        address.zip_code = table.get_value_for_field_with_label(row, FieldLabel::ZipCode)
        address.city = table.get_value_for_field_with_label(row, FieldLabel::City)
        address.country_name = table.get_value_for_field_with_label(row, FieldLabel::Country)
    end

    organization.with_visit_address do |address|
        address.street = table.get_value_for_field_with_label(row, FieldLabel::VisitingAddress_StreetAddress) + " " +
                         table.get_value_for_field_with_label(row, FieldLabel::VisitingAddress_StreetAddress2)
        address.zip_code = table.get_value_for_field_with_label(row, FieldLabel::VisitingAddress_ZipCode)
        address.city = table.get_value_for_field_with_label(row, FieldLabel::VisitingAddress_City)
        address.country_name = table.get_value_for_field_with_label(row, FieldLabel::VisitingAddress_Country)
    end

    if defined?(ORGANIZATION_RESPONSIBLE_FIELD) && !ORGANIZATION_RESPONSIBLE_FIELD.nil? && !ORGANIZATION_RESPONSIBLE_FIELD.empty?
        # Responsible coworker for the organization.
        # For instance responsible sales rep.
        coworker_id = row[ORGANIZATION_RESPONSIBLE_FIELD].to_s
        organization.responsible_coworker = rootmodel.find_coworker_by_integration_id(coworker_id)
    end

    return organization
end

def init_person(row, table, rootmodel)
    person = GoImport::Person.new

    person.integration_id = row['idperson'].to_s
    person.set_custom_value("limelink", build_lime_link("person", row['idperson']))

    # set employer connection
    employer = rootmodel.find_organization_by_integration_id(row['company'].to_s)
    employer.add_employee(person) if employer

    person.parse_name_to_firstname_lastname_se table.get_value_for_field_with_label(row, FieldLabel::Name)
    person.direct_phone_number = table.get_value_for_field_with_label(row, FieldLabel::BusinessTelephoneNumber)
    person.mobile_phone_number = table.get_value_for_field_with_label(row, FieldLabel::MobileTelephoneNumber)
    person.position = table.get_value_for_field_with_label(row, FieldLabel::JobTitle)
    person.email = table.get_value_for_field_with_label(row, FieldLabel::PrimaryEmailAddress)

    return person
end

def init_deal(row, table, rootmodel)
    deal = GoImport::Deal.new

    deal.integration_id = row['idbusiness'].to_s
    deal.set_custom_value("limelink", build_lime_link("person", row['idbusiness']))

    coworker = rootmodel.find_coworker_by_integration_id(row[DEAL_RESPONSIBLE_FIELD].to_s)
    deal.responsible_coworker = coworker if coworker  

    organization = rootmodel.find_organization_by_integration_id(row[DEAL_COMPANY_FIELD].to_s)
    deal.customer = organization if organization

    deal.name = table.get_value_for_field_with_name(row, "name")
    deal.description = table.get_value_for_field_with_name(row, "wonlostreason")
    deal.value = table.get_value_for_field_with_name(row, "businessvalue")

    if (deal.name.nil? || deal.name.empty?) && !organization.nil?
        deal.name = organization.name
    end
    
    return deal
end

def init_note(row, table, rootmodel)
    note = GoImport::Note.new

    note.integration_id = row['idhistory'].to_s

    coworker = rootmodel.find_coworker_by_integration_id(row[NOTE_COWORKER_FIELD].to_s)
    note.created_by = coworker if coworker
 
    organization = rootmodel.find_organization_by_integration_id(row[NOTE_COMPANY_FIELD].to_s)
    note.organization = organization if organization   

    person = rootmodel.find_person_by_integration_id(row[NOTE_PERSON_FIELD].to_s)
    note.person = person if person

    deal = rootmodel.find_deal_by_integration_id(row[NOTE_DEAL_FIELD].to_s)
    note.deal = deal if deal

    note.text = table.get_value_for_field_with_label(row, FieldLabel::Notes)
    note.date = table.get_value_for_field_with_label(row, FieldLabel::StartDate)

    return note
end


############################################################################
## Helper functions and classes
############################################################################

module FieldLabel
    None = 0
    Name = 1
    Key = 2
    Description = 3
    StartDate = 4
    DueDate = 5
    Category = 6
    Completed = 7
    Notes = 8
    Priority = 9
    ResponsibleCoworker = 10
    HomeTelephoneNumber = 13
    BusinessTelephoneNumber = 14
    MobileTelephoneNumber = 15
    HomeFaxNumber = 16
    BusinessFaxNumber = 17
    Birthday = 18
    HomeAddress = 19
    BusinessAddress = 20
    BusinessHomepage = 21
    PersonalHomepage = 22
    PrimaryEmailAddress = 23
    SecondaryEmailAddress = 24
    JobTitle = 25
    Nickname = 26
    ReceivedTime = 27
    SentTime = 28
    Location = 29
    FirstName = 30
    LastName = 31
    Table = 11
    IdDecord = 12
    Inactive = 32
    CompanyNumber = 33
    VisitingAddress = 34
    RecordImage = 35
    Signature = 36
    Screenshot = 37
    StreetAddress = 38
    ZipCode = 39
    City = 40
    Country = 41
    CustomerNumber = 42
    Geography = 43
    StreetAddress2 = 44
    VisitingAddress_StreetAddress = 45
    VisitingAddress_StreetAddress2 = 46
    VisitingAddress_ZipCode = 47
    VisitingAddress_City = 48
    VisitingAddress_Country = 49
    
end

class LIMEProConnection
    def initialize(db_con)
        @db_con = db_con
        @tablestructure = get_table_structure().map{|proClass| proClass}
    end

    def fetch_data(table_name)
        table = @tablestructure.find{|tbl| tbl.name == table_name}
        sql = build_sql_query(table)
        # puts sql
        dataQuery = @db_con.execute sql

        dataQuery.each do |row|
            yield row
        end
    end

    def get_class_by_name(name)
        table = @tablestructure.find{|tbl| tbl.name == name}

        return table
    end

    private
    def db_con
        @db_con
    end

    private
    def tablestructure
        @tablestructure
    end

    private
    def get_table_structure()
        tablesQuery = @db_con.execute("SELECT * FROM [table]")
        avaiblableProClasses = tablesQuery.map{|table| table}

        return avaiblableProClasses.map {|proClass| LIMEProClass.new(proClass["name"], proClass["idtable"], @db_con)}
    end

    private
    def build_sql_query(table)
        sqlForFields = table.fields.map{|field|
            case field.fieldtype
            when "relation"
                desc = @tablestructure.find{|tbl| tbl.name == field.relatedTable}.descriptive
                next "[#{table.name}].[#{field.name}],(SELECT #{desc} from [#{field.relatedTable}] WHERE [#{table.name}].[#{field.name}] = [#{field.relatedTable}].[id#{field.relatedTable}]) as #{field.name}_descriptive"
            when "set"
                next "dbo.lfn_getfieldsettext2([#{field.name}],';','#{LIME_LANGUAGE}')"
            when "option"
                next "(SELECT #{LIME_LANGUAGE} FROM string WHERE idstring = #{field.name}) as #{field.name}"
            else
                next "[#{table.name}].[#{field.name}]"
            end
        }.join(",")

        sql = "SELECT #{sqlForFields} FROM [#{table.name}] WHERE [#{table.name}].[status] = 0"
        return sql
    end

    private
    class LIMEProClass
        attr_reader :name, :id, :descriptive, :fields
        def initialize(name, id, db_con)
            @name = name
            @id = id
            @db_con = db_con
            @fields = get_fields()
            @descriptive = get_desc().first
        end

        def get_field_by_label(label)
            @fields.find{|field| field.label == label}
        end

        def get_field_by_name(name)
            @fields.find{|field| field.name == name}
        end

        def get_value_for_field_with_label(row, label)
            field = get_field_by_label(label)

            if field.nil?
                return nil
            end

            return row[field.name]
        end

        def get_value_for_field_with_name(row, name)
            field = get_field_by_name(name)

            if field.nil?
                return nil
            end

            return row[field.name]
        end

        private
        def get_desc()
            descriptive = @db_con.execute("SELECT dbo.lfn_getdescriptive(#{@id})")
            descriptive.each(:as => :array) {|desc| return desc}    
        end

        private
        def get_fields()
            metadataForRelationFieldsQuery = @db_con.execute(
                """
                SELECT * from relationfieldview
                WHERE relationsingle = 1 AND relationintable = 1 AND idtable = #{@id}
                """
            )
            metadataForRelationFields = metadataForRelationFieldsQuery.map {|relationField| relationField }
           
            avaialableFieldsQuery = @db_con.execute(
                """
                SELECT field.idtable, field.name, field.idfield, fieldtype.name as 'fieldtypename', 
                cast(isnull(ad.value, 0) as int) as 'fieldlabel'
                FROM field 
                INNER JOIN fieldtype ON field.fieldtype = fieldtype.idfieldtype
                LEFT OUTER JOIN attributedata ad on ad.idrecord = field.idfield and ad.owner = 'field' and ad.name = 'label'
                WHERE field.idtable = #{@id}
                """
            )

            fields = avaialableFieldsQuery.map{ |field|
                if field["fieldtypename"] != "relation"
                     LIMEProField.new(field["name"], field["fieldtypename"], field['fieldlabel'])
                else
                    relationFieldMetadata = metadataForRelationFields.find {|relField| relField["idfield"] == field["idfield"]} 
                    if relationFieldMetadata
                      LIMEProRelationField.new(field["name"], field["fieldtypename"], relationFieldMetadata)
                    end
                end
            }.compact

            # Add hardcoded fields
            fields.push LIMEProField.new "id#{@name}", "int", FieldLabel::None
            fields.push LIMEProField.new "status", "int", FieldLabel::None
            fields.push LIMEProField.new "createdtime", "datetime", FieldLabel::None
            fields.push LIMEProField.new "createduser", "int", FieldLabel::None
            fields.push LIMEProField.new "updateduser", "int", FieldLabel::None
            fields.push LIMEProField.new "timestamp", "datetime", FieldLabel::None

            # puts "Field for table: #{name}"
            # fields.each{|f| puts "Field: #{f.name}, type: #{f.fieldtype}, label: #{f.label} "}
            
            return fields
        end
    end

    private
    class LIMEProField
        attr_reader :name, :fieldtype, :label
        
        def initialize(name, fieldtype, label)
            @name = name
            @fieldtype = fieldtype
            @label = label
        end
    end

    class LIMEProRelationField < LIMEProField
        def initialize(name, fieldtype, relationFieldMetadata)
            super(name, fieldtype, FieldLabel::None)
            @relatedTable = relationFieldMetadata["relatedtable"]
        end

        def relatedTable
            @relatedTable
        end
    end
end

def build_lime_link(limeClassName, id)
    return "limecrm:#{limeClassName}.#{LIME_DATABASE}.#{LIME_SERVER}?idrecord=#{id}"
end



