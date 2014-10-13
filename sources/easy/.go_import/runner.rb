# encoding: UTF-8

require 'go_import'
require_relative("../converter")

EXPORT_FOLDER = 'export'
COWORKER_FILE = "#{EXPORT_FOLDER}/User.txt"
ORGANIZATION_FILE = "#{EXPORT_FOLDER}/Company.txt"
ORGANIZATION_NOTE_FILE = "#{EXPORT_FOLDER}/Company-History.txt"
ORGANIZATION_DOCUMENT_FILE = "#{EXPORT_FOLDER}/Company-Document.txt"
PERSON_FILE = "#{EXPORT_FOLDER}/Company-Person.txt"
INCLUDE_FILE = "#{EXPORT_FOLDER}/Project-Included.txt"
DEAL_FILE = "#{EXPORT_FOLDER}/Project.txt"
DEAL_NOTE_FILE = "#{EXPORT_FOLDER}/Project-History.txt"
PROJECT_DOCUMENT_FILE = "#{EXPORT_FOLDER}/Project-Document.txt"

def convert_source
    puts "Trying to convert LIME Easy source to LIME Go..."

    if !make_sure_database_has_been_exported
        puts "ERROR: You must export KONTAKT.mdb to the #{EXPORT_FOLDER} folder."
        raise
    end

    validate_constants()

    converter = Converter.new
    rootmodel = GoImport::RootModel.new

    converter.configure rootmodel

    includes = Hash.new

    # coworkers
    # start with these since they are referenced
    # from everywhere....
    process_rows COWORKER_FILE do |row|
        rootmodel.add_coworker(to_coworker(row))
    end

    # organizations
    process_rows ORGANIZATION_FILE do |row|
        organization = init_organization(row, rootmodel)
        rootmodel.add_organization(
            converter.to_organization(organization, row))
    end

    # persons
    # depends on organizations
    process_rows PERSON_FILE do |row|
        # init method also adds the person to the employer
        person = init_person(row, rootmodel)
        converter.to_person(person, row)
    end

    # organization notes
    process_rows ORGANIZATION_NOTE_FILE do |row|
        # adds itself if applicable
        rootmodel.add_note(to_organization_note(row, rootmodel))
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
        rootmodel.add_note(to_deal_note(row, rootmodel))
    end

    # company documents
    if defined?(IMPORT_DOCUMENTS) && !IMPORT_DOCUMENTS.nil? && IMPORT_DOCUMENTS
        process_rows ORGANIZATION_DOCUMENT_FILE do |row|
            rootmodel.add_file(to_organization_document(row, rootmodel))
        end

        process_rows PROJECT_DOCUMENT_FILE do |row|
            rootmodel.add_file(from_project_document_to_organization_document(row, includes, rootmodel))
        end
    end
    return rootmodel
end

def to_coworker(row)
    coworker = GoImport::Coworker.new
    # integration_id is typically the userId in Easy
    # Must be set to be able to import the same file more
    # than once without creating duplicates
    coworker.integration_id = row['idUser']
    coworker.parse_name_to_firstname_lastname_se(row['Name'])
    return coworker
end

def init_organization(row, rootmodel)
    organization = GoImport::Organization.new
    organization.set_tag "Imported"
    # integration_id is typically the company Id in Easy
    # Must be set to be able to import the same file more
    # than once without creating duplicates
    organization.integration_id = row['idCompany']

    # Easy standard fields
    organization.name = row['Company name']
    organization.central_phone_number = row['Telephone']

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
def to_organization_note(row, rootmodel)
    organization = rootmodel.find_organization_by_integration_id(row['idCompany'])
    coworker = rootmodel.find_coworker_by_integration_id(row['idUser'])

    if organization && coworker
        note = GoImport::Note.new()
        note.organization = organization
        note.created_by = coworker
        note.person = organization.find_employee_by_integration_id(row['idPerson'])
        note.date = row['Date']
        note.text = "#{row['Category']}: #{row['History']}"

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

    org = rootmodel.find_organization_by_integration_id(row['idCompany'])
    if org.nil?
        return nil
    end
    file.organization = org

    return file
end

def from_project_document_to_organization_document(row, includes, rootmodel)
    file = GoImport::File.new()

    file.integration_id = "d-#{row['idDocument']}"
    file.path = row['Path']
    file.name = row['Comment']

    file.created_by = rootmodel.find_coworker_by_integration_id(row['idUser-Created'])

    organization_id = includes[row['idProject']]
    org = rootmodel.find_organization_by_integration_id(organization_id)
    if org.nil?
        return nil
    end

    file.organization = org

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
def to_deal_note(row, rootmodel)
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

        return note.text.empty? ? nil : note
    end

    return nil
end


def validate_constants()
    if !defined?(ORGANIZATION_RESPONSIBLE_FIELD)
        puts "WARNING: You have not defined a resposible coworker field for organization.
        If you don't have such a field, you can just ignore this warning.
        Otherwise you should define 'ORGANIZATION_RESPONSIBLE_FIELD' in converter.rb
        with the value of the field name in Easy (e.g 'Ansvarig')."
    end

    if !defined?(DEAL_RESPONSIBLE_FIELD)
        puts "WARNING: You have not defined a resposible coworker field for deal.
        If you don't have such a field, you can just ignore this warning.
        Otherwise you should define 'DEAL_RESPONSIBLE_FIELD' in converter.rb
        with the value of the field name in Easy (e.g 'Ansvarig')."
    end

    if !defined?(IMPORT_DOCUMENTS) || IMPORT_DOCUMENTS.nil? || !IMPORT_DOCUMENTS
        puts "WARNING: You are about to run the import without documents.
        If that is your intention then you can ignore this warning.
        Otherwise you should define 'IMPORT_DOCUMENTS' in converter.rb
        with the value 'true'."
    end
end


def process_rows(file_name)
    data = File.open(file_name, 'r').read.encode('UTF-8',"ISO-8859-1").strip().gsub('"', '')
    data = '"' + data.gsub("\t", "\"\t\"") + '"'
    data = data.gsub("\n", "\"\n\"")

    rows = GoImport::CsvHelper::text_to_hashes(data, "\t", "\n", '"')
        rows.each do |row|
        yield row
    end
end

def make_sure_database_has_been_exported()
    return File.exists?(COWORKER_FILE) &&
        File.exists?(ORGANIZATION_FILE) &&
        File.exists?(ORGANIZATION_NOTE_FILE) &&
        File.exists?(ORGANIZATION_DOCUMENT_FILE) &&
        File.exists?(PERSON_FILE) &&
        File.exists?(INCLUDE_FILE) &&
        File.exists?(DEAL_FILE) &&
        File.exists?(DEAL_NOTE_FILE) &&
        File.exists?(PROJECT_DOCUMENT_FILE)
end
