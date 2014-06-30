# encoding: UTF-8
require 'fruit_to_lime'

class Exporter
    # Turns a user from the User.txt Easy Export file into
    # a fruit_to_lime coworker-model that is used to generate xml
    def to_coworker(row)
        coworker = FruitToLime::Coworker.new
        # integration_id is typically the userId in Easy
        # Must be set to be able to import the same file more 
        # than once without creating duplicates
        coworker.integration_id = row['userId']
        coworker.parse_name_to_firstname_lastname_se(row['Name'])

        return coworker
    end

    # Turns a row from the Easy exported Company.txt file into
    # a fruit_to_lime model that is used to generate xml
    # Uses rootmodel to locate other related stuff such coworker
    def to_organization(row, rootmodel, coworkers)
        organization = FruitToLime::Organization.new
        # integration_id is typically the company Id in Easy
        # Must be set to be able to import the same file more 
        # than once without creating duplicates
        
        # Easy standard fields
        organization.integration_id = row['companyId']
        organization.name = row['company name']
        organization.central_phone_number = row['Telephone']

        # NOTE!! if a bisnode-id is present maybe you want to
        # consider not setting this.
        # Addresses consists of several parts in Go.
        # Lots of other systems have the address all in one
        # line, to be able to match when importing it is
        # way better to split the addresses
        organization.with_postal_address do |address|
            address.street = row['street']
            address.zip_code = row['zip']
            address.city = row['city']
            address.location = row['location']
        end

        # Easy superfields
        organization.email = row['e-mail']
        organization.web_site = row['website']

        # Same as postal address
        organization.with_visit_address do |addr|
            addr.street = row['visit street']
            addr.zip_code = row['visit zip']
            addr.city = row['visit city']
        end
        
        # Set Bisnode Id if present
        bisnode_id = row['Bisnode-id']
        
        if bisnode_id && !bisnode_id.empty?
            organization.with_source do |source|
                source.par_se(bisnode_id)
            end
        end

        # Only set other Bisnode fields if the Bisnode Id is empty
        if bisnode_id.empty?
            organization.organization_number = row['orgnr']
        end

        # Responsible coworker for the organization.
        # For instance responsible sales rep.
        coworker_id = coworkers[row['userIndex - our reference']]
        organization.responsible_coworker = rootmodel.find_coworker_by_integration_id(coworker_id)

        # Tags are set and defined at the same place
        # Setting a tag: Imported is useful for the user
        organization.set_tag("Imported")

        # Option fields are normally translated into tags
        # The option field customer category for instance,
        # has the options "A-customer", "B-customer", and "C-customer"
        organization.set_tag(row['customer category'])

        # Relation
        # let's say that there is a option field in Easy called 'Customer relation'
        # with the options '1.Customer', '2.Prospect' '3.Partner' and '4.Lost customer'
        if row['Customer relation'] == '1.Customer'
            # We have made a deal with this organization.
            organization.relation = Relation::IsACustomer
        end
        elsif row['Customer relation'] == '3.Partner'
            # We have made a deal with this organization.
            organization.relation = Relation::IsACustomer
        end
        elsif row['Customer relation'] == '2.Prospect'
            # Something is happening with this organization, we might have
            # booked a meeting with them or created a deal, etc.
            organization.relation = Relation::WorkingOnIt
        end
        elsif row['Customer relation'] == '4.Lost customer'
            # We had something going with this organization but we
            # couldn't close the deal and we don't think they will be a
            # customer to us in the foreseeable future.
            organization.relation = Relation::BeenInTouch
        end
        else
            organization.relation = Relation::NoRelation
        end

        return organization
    end

    # Turns a row from the Easy exported Company-Person.txt file into
    # a fruit_to_lime model that is used to generate xml
    # Uses rootmodel to locate employer organization
    def to_person(row, rootmodel)
        person = FruitToLime::Person.new
        
        # Easy standard fields created in configure method
        # Easy persons don't have a globally unique Id, they are only unique
        # within the scope of the company, so we combine the referencId and the companyId
        # to make a globally unique integration_id
        person.integration_id = "#{row['referenceId']}-#{row['companyId']}"
        person.first_name = row['First name']
        person.last_name = row['Last name']

        # Easy superfields
        person.direct_phone_number = row['Direktnummer']
        person.mobile_phone_number = row['Mobil']
        person.email = row['e-mail']
        person.position = row['position']

        # Populate a Go custom field
        person.set_custom_value("shoe_size", row['shoe size'])
        
        # Tags
        person.set_tag("Imported")

        # Checkbox fields
        # Xmas card field is a checkbox in Easy
        if row['Xmas card'] == "1"
            person.set_tag("Xmas card")
        end

        # Multioption fields or "Set"- fields
        intrests = row['intrests'].split(';')
        intrests.each do |intrest|
            person.set_tag(intrest)
        end

        # set employer connection
        employer = rootmodel.find_organization_by_integration_id(row['companyId'])
        if employer
            employer.add_employee person
        end
    end

    # Turns a row from the Easy exported Project.txt file into
    # a fruit_to_lime model that is used to generate xml
    # Uses includes hash to lookup organizations to connect
    # Uses coworkers hash to lookup coworkers to connect
    # Uses rootmodel to find coworkers and organizations objects
    def to_deal(row, rootmodel, includes, coworkers)
        deal = FruitToLime::Deal.new
        # Easy standard fields
        deal.integration_id = row['projectId']
        deal.name = row['Name']
        deal.description = row['Description']

        # Easy superfields        
        deal.order_date = row[' order date']

        coworker_id = coworkers[row['userIndex']]
        deal.responsible_coworker = rootmodel.find_coworker_by_integration_id coworker_id
        
        # Should be integer
        # The currency used in Easy should match the one used in Go
        deal.value = row['value']

        # should be between 0 - 100
        # remove everything that is not an intiger
        deal.probability = row['probability'].gsub(/[^\d]/,"").to_i

        # Create a status object and set it's label to the value of the Easy field
        deal.status = FruitToLime::DealStatus.new
            deal.status.label = row['Status']
        

        # Tags
        deal.set_tag("Imported")

        # Make the deal - organization connection
        if includes
            organization_id = includes[row['projectId']]
            organization = rootmodel.find_organization_by_integration_id(organization_id)
            if organization
                deal.customer = organization
            end
        end
        
        return deal
    end

    # Turns a row from the Easy exported Company-History.txt file into
    # a fruit_to_lime model that is used to generate xml
    # Uses coworkers hash to lookup coworkers to connect
    # Uses people hash to lookup persons to connect
    # Uses rootmodel to find coworkers and organizations objects
    def to_organization_note(row, rootmodel, coworkers, people)
        note = FruitToLime::Note.new()
        
        organization = rootmodel.find_organization_by_integration_id(row['companyId'])
        
        coworker_id = coworkers[row['userIndex']]
        coworker = rootmodel.find_coworker_by_integration_id(coworker_id)

        if organization && coworker
            note.organization = organization
            note.created_by = coworker
            note.person = organization.find_employee_by_integration_id(people[row['personIndex']])
            note.date = row['Date']
            note.text = "#{row['Category']}: #{row['History']}"

            rootmodel.add_note(note) unless note.text.empty?
        end

        return note
    end

    # TODO: This could be improved to read a person from an organization 
    # connected to this deal if any, but as it is a many to many connection
    # between organizations and deals it's not a straight forward task

    # Turns a row from the Easy exported Project-History.txt file into
    # a fruit_to_lime model that is used to generate xml
    # Uses coworkers hash to lookup coworkers to connect
    # Uses rootmodel to find coworkers and organizations objects
    def to_deal_note(row, rootmodel, coworkers)
        note = FruitToLime::Note.new()

        deal = rootmodel.find_deal_by_integration_id(row['projectId'])
        
        coworker_id = coworkers[row['userIndex']]
        coworker = rootmodel.find_coworker_by_integration_id(coworker_id)

        if deal && coworker
            note.deal = deal
            note.created_by = coworker
            note.date = row['Date']
            # Raw history looks like this <category>: <person>: <text>
            note.text = row['RawHistory']

            rootmodel.add_note(note) unless note.text.empty?
        end

        return note
    end

    def configure(model)
        # add custom field to your model here. Custom fields can be
        # added to organization, deal and person. Valid types are
        # :String and :Link. If no type is specified :String is used
        # as default.
        model.settings.with_person  do |person|
            person.set_custom_field( { :integration_id => 'shoe_size', :title => 'Shoe size', :type => :String} )
        end
    end

    def process_rows(file_name)
        data = File.open(file_name, 'r').read.encode('UTF-8',"ISO-8859-1").strip().gsub('"', '')
        data = '"' + data.gsub("\t", "\"\t\"") + '"'
        data = data.gsub("\n", "\"\n\"")

        rows = FruitToLime::CsvHelper::text_to_hashes(data, "\t", "\n", '"')
        rows.each do |row|
            yield row
        end
    end

    def to_model(coworkers_filename, organization_filename, persons_filename, orgnotes_filename, includes_filename, deals_filename, dealnotes_filename)
        # A rootmodel is used to represent all entitite/models
        # that is exported
        rootmodel = FruitToLime::RootModel.new
        coworkers = Hash.new
        includes = Hash.new
        people = Hash.new

        configure rootmodel

        # coworkers
        # start with these since they are referenced
        # from everywhere....
        if coworkers_filename && !coworkers_filename.empty?
            process_rows coworkers_filename do |row|
                coworkers[row['userIndex']] = row['userId']
                rootmodel.add_coworker(to_coworker(row))

            end
        end

        # organizations
        if organization_filename && !organization_filename.empty?
            process_rows organization_filename do |row|
                rootmodel.add_organization(to_organization(row, rootmodel, coworkers))
            end
        end

        # persons
        # depends on organizations
        if persons_filename && !persons_filename.empty?
            process_rows persons_filename do |row|
                people[row['personIndex']] = "#{row['referenceId']}-#{row['companyId']}"
                # adds it self to the employer
                to_person(row, rootmodel)
            end
        end

        # organization notes
        if orgnotes_filename && !orgnotes_filename.empty?
            process_rows orgnotes_filename do |row|
                # adds itself if applicable
                to_organization_note(row, rootmodel, coworkers, people)
            end
        end

        # Organization - Deal connection
        # Reads the includes.txt and creats a hash 
        # that connect organizations to deals
        if includes_filename && !includes_filename.empty?
            process_rows includes_filename do |row|
                includes[row['projectId']] = row['companyId']
            end
        end
        
        # deals
        # deals can reference coworkers (responsible), organizations
        # and persons (contact)
        if deals_filename && !deals_filename.empty?
            process_rows deals_filename do |row|
                rootmodel.add_deal(to_deal(row, rootmodel, includes, coworkers))    
            end
        end

        # deal notes
        if dealnotes_filename && !dealnotes_filename.empty?
            process_rows dealnotes_filename do |row|
                # adds itself if applicable
                to_deal_note(row, rootmodel, coworkers)
            end
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
    desc "to_go", "Generates a Go XML file"
    method_option :output, :desc => "Path to file where xml will be output", :default => "export.xml", :type => :string
    method_option :coworkers, :desc => "Path to coworkers csv file", :type => :string
    method_option :organizations, :desc => "Path to organization csv file", :type => :string
    method_option :persons, :desc => "Path to persons csv file", :type => :string
    method_option :orgnotes, :desc => "Path to organization notes file", :type => :string
    method_option :includes, :desc => "Path to include file", :type => :string
    method_option :deals, :desc => "Path to deals csv file", :type => :string
    method_option :dealnotes, :desc => "Path to deal notes file", :type => :string
    def to_go
        output = options.output
        exporter = Exporter.new()
        model = exporter.to_model(options.coworkers, options.organizations, options.persons, options.orgnotes, options.includes, options.deals,  options.dealnotes)
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
