# encoding: UTF-8
require 'go_import'
require 'roo'

# This Converter will convert an Excel file to a XML file that can be
# imported into LIME Go.
#
# You need to customize this script to suit your Excel file.

# First set the name of the Excel file to convert. It is a filename
# relative to this folder.
EXCEL_FILE = "sample-data.xlsx"

COWORKER_SHEET = "Medarbetare"
ORGANIZATION_SHEET = "Företag"
PERSON_SHEET = "Kontaktperson"
DEAL_SHEET = "Affär"
NOTE_SHEET = "Anteckningar"
FILE_SHEET = "Dokument"

# Then you need to modify the script below according to the TODO
# comments.

# To generate the xml-file that should be sent to LIME Go with the
# command:
# go-import run

# If you want to include any file in the import.
FILES_FOLDER = "./files"

class Converter
    def configure(rootmodel)
        # *** TODO: Add custom field to your rootmodel here. Custom fields
        # can be added to organization, deal and person. Valid types
        # are :String and :Link. If no type is specified :String is
        # used as default.

        # rootmodel.settings.with_organization do |organization|
        #     organization.set_custom_field( { :integrationid => 'source', :title => 'Källa', :type => :Link } )
        # end
    end

    def import_person_to_organization(row, rootmodel)
        person = to_person(row, rootmodel)
        organization = rootmodel.find_organization_by_integration_id(row['ID'])

        if !organization.nil?
            organization.add_employee(person)
        end
    end

    def to_coworker(row)
        coworker = GoImport::Coworker.new()

        # *** TODO:
        #
        # Set coworker properties from the row.

        coworker.parse_name_to_firstname_lastname_se row['Namn/Titel']
        coworker.integration_id = row['Namn/Titel']
        if GoImport::EmailHelper.is_valid?(row['Email'])
            coworker.email = row['Email']
        end

        return coworker
    end

    def to_deal(row, rootmodel)
        deal = GoImport::Deal.new()

        # *** TODO:
        #
        # Set deal properties from the row.

        return deal
    end

    def to_organization(row, rootmodel)
        organization = GoImport::Organization.new()
        organization.set_tag "Importerad"

        # Integrationid is typically the id in the system that we are
        # getting the csv from. Must be set to be able to import the
        # same file more than once without creating duplicates
        organization.integration_id = row['ID']

        # Sets the organization's relation. Relation must be a value
        # from GoImport::Relation.
        organization.relation = GoImport::Relation::IsACustomer

        # *** TODO:
        #
        # Set organization properties from the row.

        organization.name = row['Namn']

        # Custom fields should be set like this.
        # organization.set_custom_value("source", "internet")

        return organization
    end

    def to_person(row, rootmodel)
        person = GoImport::Person.new()

        # *** TODO:
        #
        # Set person properties from the row.

        person.parse_name_to_firstname_lastname_se(row['Namn'])
        if GoImport::EmailHelper.is_valid?(row['Email'])
            person.email = row['Email']
        end
        person.mobile_phone_number, person.direct_phone_number =
            GoImport::PhoneHelper.parse_numbers(row['Telefon'], [",", "/", "\\"])

        return person
    end

    def to_note(row, rootmodel)
        note = GoImport::Note.new()

        # *** TODO:
        #
        # Set note properties from the row.

        note.organization = rootmodel.find_organization_by_integration_id(row['ID'])
        note.created_by = rootmodel.find_coworker_by_integration_id(row['Skapad av'])
        note.text = row['Text']
        note.date = row['Skapad den']

        return note
    end

    def to_file(row, rootmodel)
        file = GoImport::File.new()

        file.organization = rootmodel.find_organization_by_integration_id(row['Företag'])
        file.created_by = rootmodel.find_coworker_by_integration_id(row['Skapad Av'])
        file.name = row['Namn']
        file.description = row['Kommentar']
        file.path = row['Path']

        return file
    end
end
