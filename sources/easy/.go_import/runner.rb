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

def convert_source
    puts "Trying to convert LIME Easy source to LIME Go..."

    if !make_sure_database_has_been_exported
        puts "You must export KONTAKT.mdb to the #{EXPORT_FOLDER} folder."
        raise
    end

    converter = Converter.new
    rootmodel = GoImport::RootModel.new

    converter.configure rootmodel

    coworkers = Hash.new
    includes = Hash.new
    people = Hash.new

    # coworkers
    # start with these since they are referenced
    # from everywhere....
    process_rows COWORKER_FILE do |row|
        coworkers[row['userIndex']] = row['userId']
        rootmodel.add_coworker(converter.to_coworker(row))
    end

    # organizations
    process_rows ORGANIZATION_FILE do |row|
        rootmodel.add_organization(converter.to_organization(row, coworkers, rootmodel))
    end

    # persons
    # depends on organizations
    process_rows PERSON_FILE do |row|
        people[row['personIndex']] = "#{row['PowerSellReferenceID']}-#{row['PowerSellCompanyID']}"
        # adds it self to the employer
        converter.to_person(row, rootmodel)
    end

    # organization notes
    process_rows ORGANIZATION_NOTE_FILE do |row|
        # adds itself if applicable
        rootmodel.add_note(converter.to_organization_note(row, coworkers, people, rootmodel))
    end

    # Organization - Deal connection
    # Reads the includes.txt and creats a hash
    # that connect organizations to deals
    process_rows INCLUDE_FILE do |row|
        includes[row['PowerSellProjectID']] = row['PowerSellCompanyID']
    end

    # deals
    # deals can reference coworkers (responsible), organizations
    # and persons (contact)
    process_rows DEAL_FILE do |row|
        rootmodel.add_deal(converter.to_deal(row, includes, coworkers, rootmodel))
    end

    # deal notes
    process_rows DEAL_NOTE_FILE do |row|
        # adds itself if applicable
        rootmodel.add_note(converter.to_deal_note(row, coworkers, rootmodel))
    end

    return rootmodel
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
        File.exists?(DEAL_NOTE_FILE)
end
