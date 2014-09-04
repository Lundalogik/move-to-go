require 'go_import'
require 'roo'

# Customize this file to suit your input (excel) file.
#
# Documentation go_import can be found at
# http://rubygems.org/gems/go_import
#
# go_import contains all objects in LIME Go such as organization,
# people, deals, etc. What properties each object has is described in
# the documentation.

# *** TODO:
#
# This template will convert the file template.xlsx to LIME Go. You
# should modify the Converted class suit your input file.
#
# Try this template with the template.xlsx file to generate a go.xml
#file:
# ruby convert.rb to_go template.xlsx lime-go.xml

class Converter
    def configure(model)
        # Add custom field to your model here. Custom fields can be
        # added to organization, deal and person. Valid types are
        # :String and :Link. If no type is specified :String is used
        # as default.

        # model.settings.with_deal do |deal|
        #     deal.set_custom_field( { :integrationid => 'discount_url', :title => 'Rabatt url', :type => :Link } )
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

    def to_model(in_data_filename)
        # *** TODO:
        #
        # Modify the name of the sheets. Or add/remove sheets based on
        # your file.

        # First we read each sheet from the excel file into separate
        # variables
        excel_workbook = GoImport::ExcelHelper.Open(in_data_filename)
        organization_rows = excel_workbook.rows_for_sheet 'Foretag'
        person_rows = excel_workbook.rows_for_sheet 'Kontaktperson'
        note_rows = excel_workbook.rows_for_sheet 'Anteckningar'
        coworker_rows = excel_workbook.rows_for_sheet 'Medarbetare'

        # Then we create a rootmodel that should contain all data that
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
end

# You don't need to change anything below this line.

require "thor"
require "fileutils"
require 'pathname'

class Cli < Thor
    desc "to_go IN_DATA_FILENAME GO_DATA_FILENAME", "Converts excel file to Go xml format. IN_DATA_FILENAME is path to input file. GO_DATA_FILENAME is output file where Go xml will go."
    def to_go(in_data_filename, go_data_filename = nil)
        go_data_filename = 'go-data.xml' if go_data_filename == nil
        converter = Converter.new()
        model = converter.to_model(in_data_filename)
        error = model.sanity_check
        if error.empty?
            validation_errors = model.validate

            if validation_errors.empty?
                model.serialize_to_file(go_data_filename)
                puts "'#{in_data_filename}' has been converted into '#{go_data_filename}'."
            else
                puts "'#{in_data_filename}' could not be converted due to"
                puts validation_errors
            end
        else
            puts "'#{in_data_filename}' could not be converted due to"
            puts error
        end
    end
end
