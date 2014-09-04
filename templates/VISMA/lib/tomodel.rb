require 'go_import'
require 'roo'
require 'dbf'

# Customize this file to suit your input for a VISMA database.
# You'll need KUND.DBS and KONTAKTER.DBS
#
# Documentation go_import can be found at
# http://rubygems.org/gems/go_import
#
# go_import contains all objects in LIME Go such as organization,
# people, deals, etc. What properties each object has is described in
# the documentation.

# *** TODO:
#
# This template will convert the files KUNDER.dbs and KONTAKTER.DBS to LIME Go. You
# should modify the Converted class suit your input file.
#
# Try this template with the template.xlsx file to generate a go.xml
#file:
# ruby convert.rb to_go lime-go.xml

class Converter
    def configure(model)
        # Add custom field to your model here. Custom fields can be
        # added to organization, deal and person. Valid types are
        # :String and :Link. If no type is specified :String is used
        # as default.

        #Creates a custom field to add invoicing data
        model.settings.with_organization do |org|
            org.set_custom_field( { :integrationid => 'ackoms', :title => 'Fakturerat', :type => :String } )
        end
    end

    def import_person_to_organization(row)
        person = to_person(row)
        organization = @rootmodel.find_organization_by_integration_id(row['KUNDNR'])

        if !organization.nil?
            organization.add_employee(person)
        end
    end

    def to_organization(row)
        organization = GoImport::Organization.new()

        #Add tags:
        organization.set_tag "Importerad"
        organization.set_tag "Kund"

        organization.name = row['NAMN']
        # Integrationid is typically the id in the system that we are
        # getting the csv from. Must be set to be able to import the
        # same file more than once without creating duplicates
        organization.integration_id = row['KUNDNR']

        #address
        organization.with_postal_address do |address|
            address.street = row['POSTADR']
            address.zip_code = row['POSTNR']
            address.city = row['ORT']
        end

        organization.email = row['EPOST']
        organization.organization_number = row['ORGNR']
        organization.central_phone_number = row['TEL']

        # Sets the organization's relation. Relation must be a value
        # from GoImport::Relation.
        organization.relation = GoImport::Relation::IsACustomer

        #Fill data to custom fields
        organization.set_custom_field({:integration_id=>"ackoms", :value=>row["ACKOMS"]})

        return organization
    end

    def to_note(row)
        note = GoImport::Note.new()

        # *** TODO:
        #
        # Set note properties from the row.
        organization = @rootmodel.find_organization_by_integration_id(row['KUNDNR'])
        unless organization.nil?
            note.organization = organization
        end
        note.created_by = @rootmodel.import_coworker
        note.text = row['ANTECK_1']

        return note
    end

    def to_person(row)
        person = GoImport::Person.new()

        # *** TODO:
        #
        # Set person properties from the row.

        person.parse_name_to_firstname_lastname_se(row['NAMN'])
        if GoImport::EmailHelper.is_valid?(row['EPOST'])
            person.email = row['EPOST']
        end
        person.mobile_phone_number = GoImport::PhoneHelper.parse_numbers(row['MBTEL'], [",", "/", "\\"])
        person.direct_phone_number = GoImport::PhoneHelper.parse_numbers(row['TEL'], [",", "/", "\\"])

        return person
    end

    def to_model()
        # First we read each database into separate variables
        puts "Reading data from './Databas/'"
        organization_rows = DBF::Table.new("./Databas/KUND.DBF")
        person_rows = DBF::Table.new("./Databas/KONTAKT.DBF")

        # Then we create a rootmodel that should contain all data that
        # should be exported to LIME Go.
        @rootmodel = GoImport::RootModel.new

        # And configure the model if we have any custom fields
        puts "Adding custom fields to model"
        configure @rootmodel

        # Then create organizations, they are only referenced by
        # coworkers.
        puts "Importing Organization..."
        organization_rows.each do |row|
            if not row.nil?
                if not row["NAMN"] == ""
                    @rootmodel.add_organization(to_organization(row))
                end
            end
        end
        puts "Imported #{@rootmodel.organizations.length} Organization"

        # Add people and link them to their organizations
        puts "Importing Persons..."
        imported_person_count = 0
        person_rows.each do |row|
            # People are special since they are not added directly to
            # the root model
            if not row.nil?
                if not row["KUNDNR"] == "" and not row["NAMN"] == ""
                    import_person_to_organization(row)
                    imported_person_count = nbrPersons + 1
                end
            end
        end
        puts "Imported #{imported_person_count} Persons"

        # Deals can connected to coworkers, organizations and people.
        # deal_rows.each do |row|
        #     @rootmodel.add_deal(to_deal(row))
        # end

        # Notes must be owned by a coworker and the be added to
        # organizations and notes and might refernce a person
        puts "Importing Notes..."
        organization_rows.each do |row|
            if not row.nil?
                if row['ANTECK_1'].length > 0
                    @rootmodel.add_note(to_note(row))
                end
            end
        end

        return @rootmodel
    end
end

# You don't need to change anything below this line.

require "thor"
require "fileutils"
require 'pathname'

class Cli < Thor
    desc "to_go GO_DATA_FILENAME", "Converts VISMA 'KUND.DBS' and 'KONTAKTER.DBS' to Go xml format. Place the DBS-files in the folder 'Databas'. GO_DATA_FILENAME is output file where Go xml will go."
    def to_go(go_data_filename = nil)
        go_data_filename = 'go-data.xml' if go_data_filename == nil
        converter = Converter.new()
        model = converter.to_model()
        error = model.sanity_check
        if error.empty?
            validation_errors = model.validate

            if validation_errors.empty?
                model.serialize_to_file(go_data_filename)
                puts "VISMA data has been converted into '#{go_data_filename}'."
            else
                puts "VISMA database could not be converted due to"
                puts validation_errors
            end
        else
            puts "VISMA database could not be converted due to"
            puts error
        end
    end
end
