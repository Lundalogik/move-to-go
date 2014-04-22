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

        return organization
    end

    def to_coworker(row)
        coworker = FruitToLime::Coworker.new
        coworker.integration_id = row['id']
        coworker.first_name = row['first_name']
        coworker.last_name = row['last_name']
        
        return coworker
    end

    def configure(model)
        # add custom field to your model here. Custom fields can be
        # added to organization, deal and person. Valid types are
        # :String and :Link. If no type is specified :String is used
        # as default.

        model.settings.with_deal do |deal|
            deal.set_custom_field( { :integrationid => 'discount_url', :title => 'Rabatt url', :type => :Link } )
        end
    end

    def process_rows(file_name)
        data = File.open(file_name, 'r').read.encode('UTF-8',"ISO-8859-1")
        rows = FruitToLime::CsvHelper::text_to_hashes(data)
        rows.each do |row|
            yield row
        end
    end

    def to_model(coworkers_filename, organization_filename)
        # A rootmodel is used to represent all entitite/models
        # that is exported
        rootmodel = FruitToLime::RootModel.new

        configure rootmodel

        # coworkers
        # start with these since they are references
        # from everywhere....
        process_rows coworkers_filename do |row|
            rootmodel.add_coworker(to_coworker(row))
        end

        # organizations
        process_rows organization_filename do |row|
            rootmodel.organizations.push(to_organization(row, rootmodel))
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
    desc "to_go COWORKERS ORGANIZATIONS OUTPUT", "Exports xml to OUTPUT using csv files COWORKERS, ORGANIZATIONS."
    def to_go( coworkers, organizations, output = nil)
        output = 'export.xml' if output == nil
        exporter = Exporter.new()
        model = exporter.to_model(coworkers, organizations)
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
