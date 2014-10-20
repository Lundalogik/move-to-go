require 'go_import'
require 'dbf'

# Customize this file to suit your input for a VISMA database.
#
# You must put KUND.DBS and KONTAKTER.DBS in the database folder.
#
# Documentation go_import can be found at
# http://rubygems.org/gems/go_import
#
# go_import contains all objects in LIME Go such as organizations,
# people, deals, etc. What properties each object has is described in
# the documentation.
#
# Generate the xml-file that should be sent to LIME Go with the command:
# go-import run

# If you are importing files then you must set the FILES_FOLDER
# constant. FILES_FOLDER should point to the folder where the files
# are stored. FILES_FOLDER can be relative to the project directory
# or absolute. Note that you need to escape \ with a \ so in order to
# write \ use \\.
FILES_FOLDER = "./files"

# If you are importing files with an absolute path (eg
# m:\documents\readme.doc) then you probably wont have files at that
# location on the computer where "go-import run" is executed. Set
# FILES_FOLDER_AT_CUSTOMER to the folder where documents are stored at
# the customers site. Ie, in this example m:\documents.
# Note that you need to escape \ with a \ so in order to write \ use
# \\.
FILES_FOLDER_AT_CUSTOMER = "m:\\documents\\"

class Converter
    def configure(rootmodel)
        # Add custom field to your model here. Custom fields can be
        # added to organization, deal and person. Valid types are
        # :String and :Link. If no type is specified :String is used
        # as default.

        #Creates a custom field to add invoicing data
        rootmodel.settings.with_organization do |org|
            org.set_custom_field( { :integrationid => 'ackoms', :title => 'Fakturerat', :type => :String } )
        end
    end

    def import_person_to_organization(row, rootmodel)
        organization = rootmodel.find_organization_by_integration_id(row['KUNDNR'])

        if !organization.nil?
            organization.add_employee(to_person(row, rootmodel))
        end
    end

    def to_organization(row, rootmodel)
        organization = GoImport::Organization.new()

        #Add tags:
        organization.set_tag "Kund"

        organization.name = row['NAMN']
        # Integrationid must be set to be able to import the same file
        # more than once without creating duplicates
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
        organization.set_custom_field({:integration_id => "ackoms", :value => row["ACKOMS"]})

        return organization
    end

    def to_note(row, rootmodel)
        note = GoImport::Note.new()

        # *** TODO:
        #
        # Set note properties from the row.
        organization = rootmodel.find_organization_by_integration_id(row['KUNDNR'])
        unless organization.nil?
            note.organization = organization
        end
        note.created_by = rootmodel.import_coworker
        note.text = row['ANTECK_1']

        return note
    end

    def to_person(row, rootmodel)
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
end
