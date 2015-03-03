# encoding: UTF-8

require 'go_import'
require 'tiny_tds'
require_relative("../converter")


def convert_source
    puts "Trying to convert LIME Pro source to LIME Go..."
    begin
      print 'Password:'
      # We hide the entered characters before to ask for the password
      system 'stty -echo'
      sql_server_password = $stdin.gets.chomp
      system 'stty echo'
      puts ""
    rescue NoMethodError, Interrupt
      # When the process is exited, we display the characters again
      # And we exit
      system 'stty echo'
      exit
    end

    begin
        db_con = TinyTds::Client.new( username: SQL_SERVER_USER,
                              password: sql_server_password,
                              dataserver: SQL_SERVER_URI,
                              database: SQL_SERVER_DATABASE)
    rescue Exception => e
        puts "ERROR: Failed to connect to SQL-server"
        puts e.message
        exit
    end

    con = LIMEProConnection.new db_con
    converter = Converter.new
    rootmodel = GoImport::RootModel.new

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
        coworker = init_coworker(row)
        rootmodel.add_coworker(
                converter.to_coworker(coworker, row)
            )
    end


    # organizations
    con.fetch_data "company" do |row|
        organization = init_organization(row, rootmodel)
        rootmodel.add_organization(
            converter.to_organization(organization, row))
    end

   
    # persons
    # depends on organizations
    con.fetch_data "person" do |row|
        # init method also adds the person to the employer
        person = init_person(row, rootmodel)
        converter.to_person(person, row)
    end


        # deals
        # deals can reference coworkers (responsible), organizations
        # and persons (contact)
    if IMPORT_DEALS
        con.fetch_data 'business' do |row|
            deal = init_deal(row, rootmodel)
            rootmodel.add_deal(converter.to_deal(deal, row))
        end
    end

    if IMPORT_NOTES
        con.fetch_data 'history' do |row|
            note = init_note(row, rootmodel)
            rootmodel.add_deal(converter.to_note(note, row))
        end
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

def init_coworker(row)
    coworker = GoImport::Coworker.new
    # integration_id is typically the idcoworker in Pro
    # Must be set to be able to import the same file more
    # than once without creating duplicates
    coworker.integration_id = row['idcoworker'].to_s
    return coworker
end

def init_organization(row, rootmodel)
    organization = GoImport::Organization.new
    # integration_id is typically the company Id in Easy
    # Must be set to be able to import the same file more
    # than once without creating duplicates
    organization.integration_id = row['idcompany'].to_s
    organization.set_custom_value("limelink", build_lime_link("company", row['idcompany']))
    

    if defined?(ORGANIZATION_RESPONSIBLE_FIELD) && !ORGANIZATION_RESPONSIBLE_FIELD.nil? && !ORGANIZATION_RESPONSIBLE_FIELD.empty?
        # Responsible coworker for the organization.
        # For instance responsible sales rep.
        coworker_id = row[ORGANIZATION_RESPONSIBLE_FIELD].to_s
        organization.responsible_coworker = rootmodel.find_coworker_by_integration_id(coworker_id)
    end

    return organization
end

def init_person(row, rootmodel)
    person = GoImport::Person.new

    # Easy standard fields created in configure method Easy
    # persons don't have a globally unique Id, they are only
    # unique within the scope of the company, so we combine the
    # referenceId and the companyId to make a globally unique
    # integration_id
    person.integration_id = row['idperson'].to_s
    person.set_custom_value("limelink", build_lime_link("person", row['idperson']))
    # set employer connection
    employer = rootmodel.find_organization_by_integration_id(row['company'].to_s)
    employer.add_employee(person) if employer

    return person
end

def init_deal(row, rootmodel)
    deal = GoImport::Deal.new

    deal.integration_id = row['idbusiness'].to_s
    deal.set_custom_value("limelink", build_lime_link("person", row['idbusiness']))

    coworker = rootmodel.find_coworker_by_integration_id(row[DEAL_RESPONSIBLE_FIELD])
    deal.responsible_coworker = coworker if coworker  

    organization = rootmodel.find_organization_by_integration_id(row[DEAL_COMPANY_FIELD])
    deal.customer = organization if organization

    return deal
end

def init_note(row, rootmodel)
    note = GoImport::Note.new

    note.integration_id = row['idhistory'].to_s

    coworker = rootmodel.find_coworker_by_integration_id(row[NOTE_COWORKER_FIELD])
    note.created_by = coworker if coworker
 
    organization = rootmodel.find_organization_by_integration_id(row[NOTE_COMPANY_FIELD])
    note.organization = organization if organization
   

    person = rootmodel.find_person_by_integration_id(row[NOTE_PERSON_FIELD])
    note.person = person if person
   

    deal = rootmodel.find_deal_by_integration_id(row[NOTE_DEAL_FIELD])
    note.deal = deal if deal

    return note
end


############################################################################
## Helper functions and classes
############################################################################

class LIMEProConnection

    def initialize(db_con)
        @db_con = db_con
        @tablestructure = get_table_structure().map{|proClass| proClass}
    end

    def fetch_data(table_name)
        table = @tablestructure.find{|tbl| tbl.name == table_name}
        sql = build_sql_query(table)
        puts sql
        dataQuery = @db_con.execute sql

        dataQuery.each do |row|
            yield row
        end
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
            case field.fieldType
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

        sql = "SELECT #{sqlForFields} FROM [#{table.name}]"
        return sql
    end

    private
    class LIMEProClass

        def initialize(name, id, db_con)
            @name = name
            @id = id
            @db_con = db_con
            @fields = get_fields()
            @descriptive = get_desc().first
        end

        def name
            @name
        end

        def id
            @id
        end

        def descriptive
            @descriptive
        end

        def fields
            @fields
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
                SELECT field.idtable, field.name, field.idfield, fieldtype.name as 'fieldtypename'
                FROM field
                INNER JOIN 
                fieldtype ON
                field.fieldtype = fieldtype.idfieldtype
                WHERE field.idtable = #{@id}
                """
            )

            fields = avaialableFieldsQuery.map{ |field|
                if field["fieldtypename"] != "relation"
                     LIMEProField.new(field["name"], field["fieldtypename"])
                else
                    relationFieldMetadata = metadataForRelationFields.find {|relField| relField["idfield"] == field["idfield"]} 
                    if relationFieldMetadata
                      LIMEProRelationField.new(field["name"], field["fieldtypename"], relationFieldMetadata)
                    end
                end
            }.compact

            # Add hardcoded fields
            fields.push LIMEProField.new "id#{@name}", "int"
            fields.push LIMEProField.new "status", "int"
            fields.push LIMEProField.new "createdtime", "datetime"
            fields.push LIMEProField.new "createduser", "int"
            fields.push LIMEProField.new "updateduser", "int"
            fields.push LIMEProField.new "timestamp", "datetime"

            return fields
        
        end

    end

    private
    class LIMEProField

        def initialize(name, fieldtype)
            @name = name
            @fieldType = fieldtype

        end

        def name
            @name
        end

        def fieldType
            @fieldType
        end


    end

    class LIMEProRelationField < LIMEProField

        def initialize(name, fieldtype, relationFieldMetadata)
            super(name,fieldtype)
            @relatedTable = relationFieldMetadata["relatedtable"]
        end

        def relatedTable
            @relatedTable
        end

    end

end

def build_lime_link(limeClassName, id)
    return "limecrm:#{limeClassName}.#{LIME_DATABASE_NAME}.#{LIME_SERVER_NAME}?idrecord=#{id}"
end



