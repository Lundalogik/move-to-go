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

    """
    # organization notes
    process_rows ORGANIZATION_NOTE_FILE do |row|
        # adds itself if applicable
        rootmodel.add_note(to_organization_note(converter, row, rootmodel))
    end

    # Organization - Deal connection
    # Reads the includes.txt and creats a hash
    # that connect organizations to deals
    process_rows INCLUDE_FILE do |row|
        includes[row['idProject']] = row['idCompany']
    end

    # deals
    # deals can reference coworkers (responsible), organizations
    # and persons (contact)
    process_rows DEAL_FILE do |row|
        deal = init_deal(row, rootmodel, includes)
        rootmodel.add_deal(converter.to_deal(deal, row))
    end

    # deal notes
    process_rows DEAL_NOTE_FILE do |row|
        # adds itself if applicable
        rootmodel.add_note(to_deal_note(converter, row, rootmodel))
    end

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


    if defined?(ORGANIZATION_RESPONSIBLE_FIELD) && !ORGANIZATION_RESPONSIBLE_FIELD.nil? && !ORGANIZATION_RESPONSIBLE_FIELD.empty?
        # Responsible coworker for the organization.
        # For instance responsible sales rep.
        coworker_id = row["idUser-#{ORGANIZATION_RESPONSIBLE_FIELD}"]
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
    person.integration_id = row['idPerson']
    person.first_name = row['First name']
    person.last_name = row['Last name']

    # set employer connection
    employer = rootmodel.find_organization_by_integration_id(row['idCompany'])
    if employer
        employer.add_employee person
    end

    return person
end

# Turns a row from the Easy exported Company-History.txt file into
# a go_import model that is used to generate xml.
def to_organization_note(converter, row, rootmodel)
    organization = rootmodel.find_organization_by_integration_id(row['idCompany'])
    coworker = rootmodel.find_coworker_by_integration_id(row['idUser'])

    if organization && coworker
        note = GoImport::Note.new()
        note.organization = organization
        note.created_by = coworker
        note.person = organization.find_employee_by_integration_id(row['idPerson'])
        note.date = row['Date']
        
        if converter.respond_to?(:get_note_classification_for_activity_on_company)
            # we will get an InvalidNoteClassificationError if we are
            # setting and invalid classification. So no need to verify
            # return value from converter.
            classification =
                converter.get_note_classification_for_activity_on_company(row['Category'])

            if classification.nil?
                classification = GoImport::NoteClassification::Comment
            end
            
            note.classification = classification

            note.text = row['History']
        else
            note.classification = GoImport::NoteClassification::Comment
            note.text = "#{row['Category']}: #{row['History']}"            
        end

        return note.text.empty? ? nil : note
    end

    return nil
end

def to_organization_document(row, rootmodel)
    file = GoImport::File.new()

    file.integration_id = "o-#{row['idDocument']}"
    file.path = row['Path']
    file.name = row['Comment']

    file.created_by = rootmodel.find_coworker_by_integration_id(row['idUser-Created'])
    if file.created_by.nil?
        file.created_by = rootmodel.import_coworker
    end

    org = rootmodel.find_organization_by_integration_id(row['idCompany'])
    if org.nil?
        return nil
    end
    file.organization = org

    return file
end

def to_deal_document(row, rootmodel)
    file = GoImport::File.new()

    file.integration_id = "d-#{row['idDocument']}"
    file.path = row['Path']
    file.name = row['Comment']

    file.created_by = rootmodel.find_coworker_by_integration_id(row['idUser-Created'])
    if file.created_by.nil?
        file.created_by = rootmodel.import_coworker
    end

    deal = rootmodel.find_deal_by_integration_id(row['idProject'])
    if deal.nil?
        return nil
    end

    file.deal = deal

    return file
end

def init_deal(row, rootmodel, includes)
    deal = GoImport::Deal.new

    deal.integration_id = row['idProject']
    deal.name = row['Name']
    deal.description = row['Description']

    if defined?(DEAL_RESPONSIBLE_FIELD) && !DEAL_RESPONSIBLE_FIELD.nil? && !DEAL_RESPONSIBLE_FIELD.empty?
        coworker_id = row["isUser-#{DEAL_RESPONSIBLE_FIELD}"]
        deal.responsible_coworker = rootmodel.find_coworker_by_integration_id(coworker_id)
    end

    # Make the deal - organization connection
    if includes
        organization_id = includes[row['idProject']]
        organization = rootmodel.find_organization_by_integration_id(organization_id)
        if organization
            deal.customer = organization
        end
    end

    return deal
end

# Turns a row from the Easy exported Project-History.txt file into
# a go_import model that is used to generate xml
def to_deal_note(converter, row, rootmodel)
    # TODO: This could be improved to read a person from an
    # organization connected to this deal if any, but since it is
    # a many to many connection between organizations and deals
    # it's not a straight forward task
    deal = rootmodel.find_deal_by_integration_id(row['idProject'])
    coworker = rootmodel.find_coworker_by_integration_id(row['idUser'])

    if deal && coworker
        note = GoImport::Note.new()
        note.deal = deal
        note.created_by = coworker
        note.date = row['Date']
        # Raw history looks like this <category>: <person>: <text>
        note.text = row['RawHistory']

        if converter.respond_to?(:get_note_classification_for_activity_on_project)
            # we will get an InvalidNoteClassificationError if we are
            # setting and invalid classification. So no need to verify
            # return value from converter.

            classification =
                converter.get_note_classification_for_activity_on_project(row['Category'])

            if classification.nil?
                classification = GoImport::NoteClassification::Comment
            end
            
            note.classification = classification
            note.text = row['RawHistory'].to_s.sub("#{row['Category']}:", "")
        else
            note.classification = GoImport::NoteClassification::Comment
            note.text = row['RawHistory']
        end
        

        return note.text.empty? ? nil : note
    end

    return nil
end

class LIMEProConnection

    def initialize(db_con)
        @db_con = db_con
        @tablestructure = get_table_structure().map{|proClass| proClass}
    end

    def fetch_data(table_name)
        table = @tablestructure.find{|tbl| tbl.name == table_name}
        sql = build_sql_query(table)
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
                next field.name + ",(SELECT #{desc} from [#{field.relatedTable}] WHERE #{table.name}.#{field.name} = #{field.relatedTable}.id#{field.relatedTable}) as descriptive_#{field.name}"
            when "set", "option"
                next "(SELECT '#{DATABASE_LANGUAGE}' FROM string WHERE idstring = #{field.name}) as #{field.name}"
            else
                next field.name
            end
        }.join(",")

        sql = "SELECT #{sqlForFields} FROM [#{table.name}]"
        puts sql
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
                WHERE relationsingle = 1 AND idtable = #{@id}
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




