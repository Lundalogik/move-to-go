# encoding: UTF-8
require 'go_import'
require 'roo'

# This Converter will convert an Excel file to a XML file that can be
# imported into LIME Go.
#
# You need to customize this script to suit your Excel file.

# First set the name of the Excel file to convert. It is a filename
# relative to this folder.
EXCEL_FILE = "template.xlsx"

# Then you need to modify the script below according to the TODO
# comments.

# To generate the xml-file that should be sent to LIME Go with the
# command:
# go-import run

class Converter
    def to_go()
        # *** TODO:
        #
        # Modify the name of the sheets. Or add/remove sheets based on
        # your Excel file.

        # First we read each sheet from the excel file into separate
        # variables
        excel_workbook = GoImport::ExcelHelper.Open(EXCEL_FILE)
        organization_rows = excel_workbook.rows_for_sheet 'Företag'
        person_rows = excel_workbook.rows_for_sheet 'Kontaktperson'
        note_rows = excel_workbook.rows_for_sheet 'Anteckningar'
        coworker_rows = excel_workbook.rows_for_sheet 'Medarbetare'

        # You should NOT have to modify this method below this line.
        # BUT you MUST modify the other methods below.

        # Then we create a rootmodel that will contain all data that
        # should be exported to LIME Go.
        @rootmodel = GoImport::RootModel.new

        # And configure the model if we have any custom fields
        configure @rootmodel

        # Now start to read data from the excel file and add to the
        # rootmodel. We begin with coworkers since they are referenced
        # from everywhere (orgs, deals, notes)
        coworker_rows.each do |row|
            @rootmodel.add_coworker(to_coworker(row))
        end

        # Then create organizations, they are only referenced by
        # coworkers.
        organization_rows.each do |row|
            @rootmodel.add_organization(to_organization(row))
        end

        # Add people and link them to their organizations
        person_rows.each do |row|
            # People are special since they are not added directly to
            # the root model
            import_person_to_organization(row)
        end

        # Deals can connected to coworkers, organizations and people.
        # deal_rows.each do |row|
        #     @rootmodel.add_deal(to_deal(row))
        # end

        # Notes must be owned by a coworker and the be added to
        # organizations and notes and might refernce a person
        note_rows.each do |row|
            @rootmodel.add_note(to_note(row))
        end

        return @rootmodel
    end

    def configure(model)
        # *** TODO: Add custom field to your model here. Custom fields
        # can be added to organization, deal and person. Valid types
        # are :String and :Link. If no type is specified :String is
        # used as default.

        # model.settings.with_organization do |organization|
        #     organization.set_custom_field( { :integrationid => 'source', :title => 'Källa', :type => :Link } )
        # end
    end

    def import_person_to_organization(row)
        person = to_person(row)
        organization = @rootmodel.find_organization_by_integration_id(row['ID'])

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

    def to_deal(row)
        deal = GoImport::Deal.new()

        # *** TODO:
        #
        # Set deal properties from the row.

        return deal
    end

    def to_organization(row)
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

    def to_person(row)
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

    def to_note(row)
        note = GoImport::Note.new()

        # *** TODO:
        #
        # Set note properties from the row.

        note.organization = @rootmodel.find_organization_by_integration_id(row['ID'])
        note.created_by = @rootmodel.find_coworker_by_integration_id(row['Skapad av'])
        note.text = row['Text']
        note.date = row['Skapad den']

        return note
    end
end
