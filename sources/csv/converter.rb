require 'go_import'

# This converter will convert one or more CVS files into a LIME Go XML
# file.

# You need to customize this script to suit your CVS file(s).

# First we set the file names of your CVS files. If you dont need to
# import all kind of objects, just leave the filename empty or remove
# the line.
COWORKER_FILE = "data/coworkers.csv"
ORGANIZATION_FILE = "data/organizations.csv"
PERSON_FILE = "data/persons.csv"
DEAL_FILE = "data/deals.csv"
# Ie if you dont want to import deals, set DEAL_FILE = ""

# Default encoding for files are 'ISO-8859-1' (aka latin1)
# If the file is in any other encoding this must be specified with 
# SOURCE_ENCODING set to correct value
# Ruby can handle lots of encodings, but common ones are:
# SOURCE_ENCODING = "UTF-8"
# SOURCE_ENCODING = "bom|UTF-8"
# SOURCE_ENCODING = "UTF-16"

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
    # Configure your root model, add custom fields and deal statuses.
    def configure(rootmodel)
        # add custom field to your model here. Custom fields can be
        # added to organization, deal and person. Valid types are
        # :String and :Link. If no type is specified :String is used
        # as default.
        rootmodel.settings.with_organization do |organization|
            organization.set_custom_field( { :integrationid => 'external_url', :title => 'Link to external system', :type => :Link } )
        end

        rootmodel.settings.with_deal do |deal|
            deal.add_status({:label => "1. Kvalificering", :integration_id => "qualification"})
            deal.add_status({:label => "Vunnen", :integration_id => "won",
                                :assessment => GoImport::DealState::PositiveEndState })
            deal.add_status({:label => "Lost", :integration_id => "Lost",
                                :assessment => GoImport::DealState::NegativeEndState })
        end
    end

    # Turns a row from the organization csv file into a
    # GoImport::Organization.
    # Use rootmodel to locate other related stuff such coworker
    def to_organization(row, rootmodel)
        organization = GoImport::Organization.new
        # Integrationid is typically the id in the system that
        # we are getting the csv from. Must be set to be able
        # to import the same file more than once without
        # creating duplicates
        organization.integration_id = row['id']
        organization.name = row['name']

        # Just setting all basic properties to show whats available
        # Remove or fix...
        organization.organization_number = 'a number'   # needs clean up, should have helpers for that in lib. Swedish format.
        organization.email = 'email to organizaiton, not the person'
        organization.web_site = 'www.whatever.com'
        organization.central_phone_number = '0000'      # needs clean up, should have helpers for that in lib. Default swedish format, convert to global format

        # Addresses consists of several parts in Go.
        # Lots of other systems have the address all in one
        # line, to be able to match when importing it is
        # way better to split the addresses
        organization.with_visit_address do |address|
            address.street = 'visit street'
            address.zip_code = 'visit zip'
            address.city = 'visit city'
        end

        # Another example of setting address using
        # helper to split '226 48 LUND' into zip and city
        organization.with_postal_address do |address|
            address.street = 'postal street'
            address.parse_zip_and_address_se '226 48 LUND'
        end

        # Responsible coworker is set by first locating
        # it in the root model and then setting a reference
        # to him/her
        # We need to be able handle missing coworkers here
        coworker = rootmodel.find_coworker_by_integration_id row['responsible_id']
        organization.responsible_coworker = coworker.to_reference

        # Set tags for the organization. All organizations will get
        # the tag "import" automagically
        organization.set_tag("Guldkund")

        # When imported from web based ERP or similair that
        # client will continue to use it can be useful to be
        # able to link from Go to the same record in the ERP
        # FOr instance Lime links
        organization.set_custom_value("external_url", "http://something.com?key=#{row['id']}")

        return organization
    end

    # Turns a row from the coworker csv file into a GoImport::Coworker.
    def to_coworker(row)
        coworker = GoImport::Coworker.new
        coworker.integration_id = row['id']
        coworker.first_name = row['first_name']
        coworker.last_name = row['last_name']

        # Other optional attributes
        coworker.email = 't@e.com'
        coworker.direct_phone_number = '+46121212'
        coworker.mobile_phone_number = '+46324234'
        coworker.home_phone_number = '+46234234'

        # Tags and custom fields are set the same
        # way as on organizations

        return coworker
    end

    # Turns a row from the person csv file into a GoImport::Person.
    #
    # You MUST add the new person to an existing organization. Use the
    # rootmodel to find the organization and then add the person with
    # organization.add_employee
    def to_person(row, rootmodel)
        person = GoImport::Person.new
        person.integration_id = row['id']
        # Note that Go has separate first and last names
        # Some splitting might be necessary
        person.first_name = row['first_name']
        person.last_name = row['last_name']
        # other optional attributes
        person.direct_phone_number = '+4611111'
        person.fax_phone_number = '+4623234234234'
        person.mobile_phone_number = '+462321212'
        person.email = 'x@y.com'
        person.alternative_email = 'y@x.com'
        person.with_postal_address do |address|
            address.street = 'postal street'
            address.parse_zip_and_address_se '226 48 LUND'
        end

        # Tags and custom fields are set the same
        # way as on organizations

        # set employer connection
        employer_id = row['employer_id']
        employer = rootmodel.find_organization_by_integration_id employer_id
        employer.add_employee person
    end

    # Turns a row form the deal csv file into a GoImport::Deal. Use
    # the rootmodel to find objects that should be linked to the new
    # deal.
    def to_deal(row, rootmodel)
        deal = GoImport::Deal.new
        deal.integration_id = row['id']
        deal.name = row['name']
        # should be integer, same currency should be used in
        # the system
        deal.value = row['value']

        # find stuff connected to deal
        responsible = rootmodel.find_coworker_by_integration_id row['responsible_id']
        organization = rootmodel.find_organization_by_integration_id row['customer_id']
        person = organization.find_employee_by_integration_id row['customer_contact_id']
        # connect the deal by references
        deal.responsible_coworker = responsible.to_reference
        deal.customer = organization.to_reference
        deal.customer_contact = person.to_reference

        # other optional attributes
        deal.probability = 50           # should be between 0 - 100
        deal.order_date = '2014-01-05'  # Format ?

        # status, set this by either label, id or integration_id (use
        # appropriate method to find status)
        deal.status = rootmodel.settings.deal.find_status_by_label row['status']

        # or set by existing status, search by label, integration_id
        # (if string) or id (if integer).
        # deal.status = "Won"

        return deal
    end

    # HOOKS
    #
    # Sometimes you need to add exra information to the rootmodel, this can be done
    # with hooks, below is an example of an organization hook that adds a history to
    # an organization if a field has a specific value
    #def organization_hook(row, organization, rootmodel)
    #    if not row['fieldname'].empty?
    #        comment = GoImport::Comment.new
    #        comment.text = row['fieldname']
    #        comment.organization = organization
    #        comment.created_by = rootmodel.import_coworker
    #        rootmodel.add_comment(comment)
    #    end
    #end

end
