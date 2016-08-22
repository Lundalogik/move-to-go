# encoding: UTF-8
require 'move-to-go'
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
HISTORY_SHEET = "Anteckningar"
FILE_SHEET = "Dokument"

# Then you need to modify the script below according to the TODO
# comments.

# To generate the xml-file that should be sent to LIME Go with the
# command:
# move-to-go run

# If you are importing files then you must set the FILES_FOLDER
# constant. FILES_FOLDER should point to the folder where the files
# are stored. FILES_FOLDER can be relative to the project directory
# or absolute. Note that you need to escape \ with a \ so in order to
# write \ use \\.
FILES_FOLDER = "./files"

# If you are importing files with an absolute path (eg
# m:\documents\readme.doc) then you probably wont have files at that
# location on the computer where "move-to-go run" is executed. Set
# FILES_FOLDER_AT_CUSTOMER to the folder where documents are stored at
# the customers site. Ie, in this example m:\documents.
# Note that you need to escape \ with a \ so in order to write \ use
# \\.
FILES_FOLDER_AT_CUSTOMER = "m:\\documents\\"

class Converter
    def configure(rootmodel)
        # *** TODO: Add custom field to your rootmodel here. Custom fields
        # can be added to organization, deal and person. Valid types
        # are :String and :Link. If no type is specified :String is
        # used as default.

        # rootmodel.settings.with_organization do |organization|
        #     organization.set_custom_field( { :integration_id => 'source', :title => 'Källa', :type => :Link } )
        # end

        # rootmodel.settings.with_person  do |person|
        #     person.set_custom_field( { :integration_id => 'shoe_size', :title => 'Shoe size', :type => :String} )
        # end

        # rootmodel.settings.with_deal do |deal|
        # assessment is default DealState::NoEndState
        #     deal.add_status( {:label => '1. Kvalificering' })
        #     deal.add_status( {:label => '2. Deal closed', :assessment => MoveToGo::DealState::PositiveEndState })
        #     deal.add_status( {:label => '4. Deal lost', :assessment => MoveToGo::DealState::NegativeEndState })
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
        coworker = MoveToGo::Coworker.new()

        # *** TODO:
        #
        # Set coworker properties from the row.

        coworker.parse_name_to_firstname_lastname_se row['Namn/Titel']
        coworker.integration_id = row['Namn/Titel']
        if MoveToGo::EmailHelper.is_valid?(row['Email'])
            coworker.email = row['Email']
        end

        return coworker
    end

    def to_deal(row, rootmodel)
        deal = MoveToGo::Deal.new()

        # *** TODO:
        #
        # Set deal properties from the row.

        return deal
    end

    def to_organization(row, rootmodel)
        organization = MoveToGo::Organization.new()

        # Integrationid is typically the id in the system that we are
        # getting the csv from. Must be set to be able to import the
        # same file more than once without creating duplicates
        organization.integration_id = row['ID']

        # Sets the organization's relation. Relation must be a value
        # from MoveToGo::Relation.
        organization.relation = MoveToGo::Relation::IsACustomer

        # *** TODO:
        #
        # Set organization properties from the row.

        organization.name = row['Namn']

        # Set responsible such as
        # organization.responsible_coworker = rootmodel.find_coworker_by_integration_id(row['Medarbetare'])

        # Custom fields should be set like this.
        # organization.set_custom_value("source", "internet")

        return organization
    end

    def to_person(row, rootmodel)
        person = MoveToGo::Person.new()

        # *** TODO:
        #
        # Set person properties from the row.

        person.parse_name_to_firstname_lastname_se(row['Namn'])
        if MoveToGo::EmailHelper.is_valid?(row['Email'])
            person.email = row['Email']
        end
        person.mobile_phone_number, person.direct_phone_number =
            MoveToGo::PhoneHelper.parse_numbers(row['Telefon'], [",", "/", "\\"])

        return person
    end

    def to_history(row, rootmodel)
        history = MoveToGo::History.new()

        # *** TODO:
        #
        # Set history properties from the row.

        history.organization = rootmodel.find_organization_by_integration_id(row['ID'])
        history.created_by = rootmodel.find_coworker_by_integration_id(row['Skapad av'])
        history.text = row['Text']
        history.date = row['Skapad den']

        return history
    end

    def to_file(row, rootmodel)
        file = MoveToGo::File.new()

        file.organization = rootmodel.find_organization_by_integration_id(row['Företag'])
        file.created_by = rootmodel.find_coworker_by_integration_id(row['Skapad Av'])
        file.name = row['Namn']
        file.description = row['Kommentar']
        file.path = row['Path']

        return file
    end

    # HOOKS
    #
    # Sometimes you need to add exra information to the rootmodel, this can be done
    # with hooks, below is an example of an organization hook that adds a comment to
    # an organization if a field has a specific value
    #def organization_hook(row, organization, rootmodel)
    #    if not row['fieldname'].empty?
    #        comment = MoveToGo::Comment.new
    #        comment.text = row['fieldname']
    #        comment.organization = organization
    #        comment.created_by = rootmodel.import_coworker
    #        rootmodel.add_comment(comment)
    #    end
    #end

end
