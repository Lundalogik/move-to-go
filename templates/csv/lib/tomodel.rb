require 'fruit_to_lime'

class Exporter
    # turns a row from the organization cssv file into
    # a fruit_to_lime model that is used to generate xml
    # Uses rootmodel to locate other related stuff such
    # coworker
    def to_organization(row, rootmodel)
        organization = FruitToLime::Organization.new
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

        # Tags are set and defined at the same place
        # Setting a tag: Imported is useful for the user
        organization.set_tag("Imported")

        # When imported from web based ERP or similair that
        # client will continue to use it can be useful to be
        # able to link from Go to the same record in the ERP
        # FOr instance Lime links
        organization.set_custom_value("http://something.com?key=#{row['id']}", "external_url")

        return organization
    end

    def to_coworker(row)
        coworker = FruitToLime::Coworker.new
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

    def to_person(row, rootmodel)
        person = FruitToLime::Person.new
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

    def to_deal(row, rootmodel)
        deal = FruitToLime::Deal.new
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
        deal.offer_date = '2013-12-01'  # Format ?

        # status, how do we set this ?

        return deal
    end

    def configure(model)
        # add custom field to your model here. Custom fields can be
        # added to organization, deal and person. Valid types are
        # :String and :Link. If no type is specified :String is used
        # as default.
        model.settings.with_organization do |organization|
            organization.set_custom_field( { :integrationid => 'external_url', :title => 'Link to external system', :type => :Link } )
        end
    end

    def process_rows(file_name)
        data = File.open(file_name, 'r').read.encode('UTF-8',"ISO-8859-1")
        rows = FruitToLime::CsvHelper::text_to_hashes(data)
        rows.each do |row|
            yield row
        end
    end

    def to_model(coworkers_filename, organization_filename, persons_filename, deals_filename)
        # A rootmodel is used to represent all entitite/models
        # that is exported
        rootmodel = FruitToLime::RootModel.new

        configure rootmodel

        # coworkers
        # start with these since they are referenced
        # from everywhere....
        process_rows coworkers_filename do |row|
            rootmodel.add_coworker(to_coworker(row))
        end

        # organizations
        process_rows organization_filename do |row|
            rootmodel.organizations.push(to_organization(row, rootmodel))
        end

        # persons
        # depends on organizations
        process_rows persons_filename do |row|
            # adds it self to the employer
            to_person(row, rootmodel)
        end

        # deals
        # deals can reference coworkers (responsible), organizations
        # and persons (contact)
        process_rows deals_filename do |row|
            rootmodel.deals.push(to_deal(row, rootmodel))
        end

        return rootmodel
    end

    def save_xml(file)
        File.open(file,'w') do |f|
            f.write(FruitToLime::SerializeHelper::serialize(to_xml_model))
        end
    end
end

require "thor"
require "fileutils"
require 'pathname'

class Cli < Thor
    desc "to_go COWORKERS ORGANIZATIONS PERSONS DEALS OUTPUT", "Exports xml to OUTPUT using csv files COWORKERS, ORGANIZATIONS, PERSONS, DEALS."
    def to_go( coworkers, organizations, persons, deals, output = nil)
        output = 'export.xml' if output == nil
        exporter = Exporter.new()
        model = exporter.to_model(coworkers, organizations, persons, deals)
        error = model.sanity_check
        if error.empty?
            validation_errors = model.validate

            if validation_errors.empty?
                model.serialize_to_file(output)
                puts "'#{organizations}' has been converted into '#{output}'."
            else
                puts "'#{organizations}' could not be converted due to"
                puts validation_errors
            end
        else
            puts "'#{organizations}' could not be converted due to"
            puts error
        end
    end
end
