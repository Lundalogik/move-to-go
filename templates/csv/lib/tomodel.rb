require 'go_import'

class Exporter
    # turns a row from the organization cssv file into
    # a go_import model that is used to generate xml
    # Uses rootmodel to locate other related stuff such
    # coworker
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

        # Tags are set and defined at the same place
        # Setting a tag: Imported is useful for the user
        organization.set_tag("Imported")

        # When imported from web based ERP or similair that
        # client will continue to use it can be useful to be
        # able to link from Go to the same record in the ERP
        # FOr instance Lime links
        organization.set_custom_value("external_url", "http://something.com?key=#{row['id']}")

        return organization
    end

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

    def configure(model)
        # add custom field to your model here. Custom fields can be
        # added to organization, deal and person. Valid types are
        # :String and :Link. If no type is specified :String is used
        # as default.
        model.settings.with_organization do |organization|
            organization.set_custom_field( { :integrationid => 'external_url', :title => 'Link to external system', :type => :Link } )
        end

        model.settings.with_deal do |deal|
            deal.add_status({:label => "1. Kvalificering", :integration_id => "qualification"})
            deal.add_status({:label => "Vunnen", :integration_id => "won",
                                :assessment => GoImport::DealState::PositiveEndState })
            deal.add_status({:label => "Lost", :integration_id => "Lost",
                                :assessment => GoImport::DealState::NegativeEndState })
        end
    end

    def process_rows(file_name)
        data = File.open(file_name, 'r').read.encode('UTF-8',"ISO-8859-1")
        rows = GoImport::CsvHelper::text_to_hashes(data)
        rows.each do |row|
            yield row
        end
    end

    def to_model(coworkers_filename, organization_filename, persons_filename, deals_filename)
        # A rootmodel is used to represent all entitite/models
        # that is exported
        rootmodel = GoImport::RootModel.new

        configure rootmodel

        # coworkers
        # start with these since they are referenced
        # from everywhere....
        if coworkers_filename != nil
            process_rows coworkers_filename do |row|
                rootmodel.add_coworker(to_coworker(row))
            end
        end

        # organizations
        if organization_filename != nil
            process_rows organization_filename do |row|
                rootmodel.organizations.push(to_organization(row, rootmodel))
            end
        end

        # persons
        # depends on organizations
        if persons_filename != nil
            process_rows persons_filename do |row|
                # adds it self to the employer
                to_person(row, rootmodel)
            end
        end

        # deals
        # deals can reference coworkers (responsible), organizations
        # and persons (contact)
        if deals_filename != nil
            process_rows deals_filename do |row|
                rootmodel.deals.push(to_deal(row, rootmodel))
            end
        end

        return rootmodel
    end

    def save_xml(file)
        File.open(file,'w') do |f|
            f.write(GoImport::SerializeHelper::serialize(to_xml_model))
        end
    end
end

require "thor"
require "fileutils"
require 'pathname'

class Cli < Thor
    desc "to_go", "Generates a Go XML file"
    method_option :output, :desc => "Path to file where xml will be output", :default => "export.xml", :type => :string
    method_option :organizations, :desc => "Path to organization csv file", :type => :string
    method_option :persons, :desc => "Path to persons csv file", :type => :string
    method_option :coworkers, :desc => "Path to coworkers csv file", :type => :string
    method_option :deals, :desc => "Path to deals csv file", :type => :string
    def to_go
        output = options.output
        exporter = Exporter.new()
        model = exporter.to_model(options.coworkers, options.organizations, options.persons, options.deals)
        error = model.sanity_check
        if error.empty?
            validation_errors = model.validate

            if validation_errors.empty?
                model.serialize_to_file(output)
                puts "Generated Go XML file: '#{output}'."
            else
                puts "Could not generate file due to"
                puts validation_errors
            end
        else
            puts "Could not generate file due to"
            puts error
        end
    end
end
