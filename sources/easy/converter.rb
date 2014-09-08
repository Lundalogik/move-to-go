# encoding: UTF-8
require 'go_import'

# Customize this file to suit your input files.
#
# Documentation go_import can be found at
# http://rubygems.org/gems/go_import
#
# go_import contains all objects in LIME Go such as organization,
# people, deals, etc. What properties each object has is described in
# the documentation.

# *** TODO:
#
# You must customize this template so it works with your LIME Easy
# database. Modify each to_* method and set properties on the LIME Go
# objects.
#
# Follow these steps:
#
# 1) Export all data from KONTAKT.mdb to a folder named Export located
# in the folder created by go_import unpack_template. Export data
# using the magical tool called PowerSellMigrationExport.exe that can
# be found in K:\Lundalogik\LIME Easy\Tillbehör\Migrationsexport.
#
# 2) Modify this file (the to_* methods) according to your customer's
# KONTAKT.mdb and wishes.
#
# 3) Run easy-to-go.bat in a command prompt.
#
# 4) Upload go.xml to LIME Go. First test your import on staging and
# when your customer has approved the import, run it on production.
class Exporter
    # Turns a user from the User.txt Easy Export file into
    # a go_import coworker.
    def to_coworker(row)
        coworker = GoImport::Coworker.new
        # integration_id is typically the userId in Easy
        # Must be set to be able to import the same file more
        # than once without creating duplicates

        # NOTE: You shouldn't have to modify this method

        coworker.integration_id = row['PowerSellUserID']
        coworker.parse_name_to_firstname_lastname_se(row['Name'])

        return coworker
    end

    # Turns a row from the Easy exported Company.txt file into a
    # go_import organization.
    def to_organization(row, coworkers)
        organization = GoImport::Organization.new
        # integration_id is typically the company Id in Easy
        # Must be set to be able to import the same file more
        # than once without creating duplicates

        # Easy standard fields
        organization.integration_id = row['PowerSellCompanyID']
        organization.name = row['Company name']
        organization.central_phone_number = row['Telephone']

        # *** TODO: Customize below this line (address, superfield,
        # relation, etc)

        # NOTE!! if a bisnode-id is present maybe you want to consider
        # not setting this (because if you set the address LIME Go
        # will NOT automagically update the address from PAR)
        # Addresses consists of several parts in Go. Lots of other
        # systems have the address all in one line, to be able to
        # match when importing it is way better to split the addresses
        organization.with_postal_address do |address|
            address.street = row['street']
            address.zip_code = row['zip']
            address.city = row['city']
            address.location = row['location']
        end

        # Easy superfields

        # Same as postal address
        organization.with_visit_address do |addr|
            addr.street = row['visit street']
            addr.zip_code = row['visit zip']
            addr.city = row['visit city']
        end

        organization.email = row['e-mail']
        organization.organization_number = row['orgnr']

        # Set Bisnode Id if present
        bisnode_id = row['Bisnode-id']

        if bisnode_id && !bisnode_id.empty?
            organization.with_source do |source|
                source.par_se(bisnode_id)
            end
        end

        # Only set other Bisnode fields if the Bisnode Id is empty
        if bisnode_id.empty?
            organization.web_site = row['website']
        end

        # Responsible coworker for the organization.
        # For instance responsible sales rep.
        coworker_id = coworkers[row['idUser-Responsible']]
        organization.responsible_coworker = @rootmodel.find_coworker_by_integration_id(coworker_id)

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
            organization.relation = GoImport::Relation::IsACustomer
        elsif row['Customer relation'] == '3.Partner'
            # We have made a deal with this organization.
            organization.relation = GoImport::Relation::IsACustomer
        elsif row['Customer relation'] == '2.Prospect'
            # Something is happening with this organization, we might have
            # booked a meeting with them or created a deal, etc.
            organization.relation = GoImport::Relation::WorkingOnIt
        elsif row['Customer relation'] == '4.Lost customer'
            # We had something going with this organization but we
            # couldn't close the deal and we don't think they will be a
            # customer to us in the foreseeable future.
            organization.relation = GoImport::Relation::BeenInTouch
        else
            organization.relation = GoImport::Relation::NoRelation
        end

        return organization
    end

    # Turns a row from the Easy exported Company-Person.txt file into
    # a go_import model that is used to generate xml
    def to_person(row)
        person = GoImport::Person.new

        # Easy standard fields created in configure method Easy
        # persons don't have a globally unique Id, they are only
        # unique within the scope of the company, so we combine the
        # referenceId and the companyId to make a globally unique
        # integration_id
        person.integration_id = "#{row['PowerSellReferenceID']}-#{row['PowerSellCompanyID']}"
        person.first_name = row['First name']
        person.last_name = row['Last name']

        # set employer connection
        employer = @rootmodel.find_organization_by_integration_id(row['PowerSellCompanyID'])
        if employer
            employer.add_employee person
        end

        # *** TODO: Customize below this line (superfields, tags, etc)

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
        if row['intrests']
            intrests = row['intrests'].split(';')
            intrests.each do |intrest|
                person.set_tag(intrest)
            end
        end
    end

    # Turns a row from the Easy exported Project.txt file into
    # a go_import model that is used to generate xml.
    # Uses includes hash to lookup organizations to connect
    # Uses coworkers hash to lookup coworkers to connect
    def to_deal(row, includes, coworkers)
        deal = GoImport::Deal.new
        # Easy standard fields
        deal.integration_id = row['PowerSellProjectID']
        deal.name = row['Name']
        deal.description = row['Description']

        # Easy superfields
        deal.order_date = row['order date']

        coworker_id = coworkers[row['isUser-Ansvarig']]
        deal.responsible_coworker = @rootmodel.find_coworker_by_integration_id(coworker_id)

        # Should be integer
        # The currency used in Easy should match the one used in Go
        deal.value = row['value']

        # should be between 0 - 100
        # remove everything that is not an intiger
        deal.probability = row['probability'].gsub(/[^\d]/,"").to_i unless row['probability'].nil?

        # Sets the deal's status to the value of the Easy field. This
        # assumes that the status is already created in LIME Go. To
        # create statuses during import add them to the settings
        # during configure.
        if !row['Status'].empty?
            deal.status = row['Status']
        end

        # Tags
        deal.set_tag("Imported")

        # Make the deal - organization connection
        if includes
            organization_id = includes[row['PowerSellProjectID']]
            organization = @rootmodel.find_organization_by_integration_id(organization_id)
            if organization
                deal.customer = organization
            end
        end

        return deal
    end

    # Turns a row from the Easy exported Company-History.txt file into
    # a go_import model that is used to generate xml.
    # Uses coworkers hash to lookup coworkers to connect
    # Uses people hash to lookup persons to connect
    def to_organization_note(row, coworkers, people)
        organization = @rootmodel.find_organization_by_integration_id(row['PowerSellCompanyID'])

        coworker_id = coworkers[row['idUser']]
        coworker = @rootmodel.find_coworker_by_integration_id(coworker_id)

        if organization && coworker
            note = GoImport::Note.new()
            note.organization = organization
            note.created_by = coworker
            note.person = organization.find_employee_by_integration_id(people[row['idPerson']])
            note.date = row['Date']
            note.text = "#{row['Category']}: #{row['History']}"

            return note.text.empty? ? nil : note
        end

        return nil
    end

    # Turns a row from the Easy exported Project-History.txt file into
    # a go_import model that is used to generate xml
    # Uses coworkers hash to lookup coworkers to connect
    def to_deal_note(row, coworkers)
        # TODO: This could be improved to read a person from an
        # organization connected to this deal if any, but since it is
        # a many to many connection between organizations and deals
        # it's not a straight forward task
        deal = @rootmodel.find_deal_by_integration_id(row['PowerSellProjectID'])

        coworker_id = coworkers[row['idUser']]
        coworker = @rootmodel.find_coworker_by_integration_id(coworker_id)

        if deal && coworker
            note = GoImport::Note.new()
            note.deal = deal
            note.created_by = coworker
            note.date = row['Date']
            # Raw history looks like this <category>: <person>: <text>
            note.text = row['RawHistory']

            return note.text.empty? ? nil : note
        end

        return nil
    end

    def configure(model)
        # add custom field to your model here. Custom fields can be
        # added to organization, deal and person. Valid types are
        # :String and :Link. If no type is specified :String is used
        # as default.
        model.settings.with_person  do |person|
            person.set_custom_field( { :integration_id => 'shoe_size', :title => 'Shoe size', :type => :String} )
        end

        model.settings.with_deal do |deal|
            # assessment is default DealState::NoEndState
            deal.add_status( {:label => '1. Kvalificering' })
            deal.add_status( {:label => '2. Deal closed', :assessment => GoImport::DealState::PositiveEndState })
            deal.add_status( {:label => '4. Deal lost', :assessment => GoImport::DealState::NegativeEndState })
        end
    end

    def process_rows(file_name)
        data = File.open(file_name, 'r').read.encode('UTF-8',"ISO-8859-1").strip().gsub('"', '')
        data = '"' + data.gsub("\t", "\"\t\"") + '"'
        data = data.gsub("\n", "\"\n\"")

        rows = GoImport::CsvHelper::text_to_hashes(data, "\t", "\n", '"')
        rows.each do |row|
            yield row
        end
    end

    def to_model(coworkers_filename, organization_filename, persons_filename, orgnotes_filename, includes_filename, deals_filename, dealnotes_filename)
        # A rootmodel is used to represent all entitite/models
        # that is exported
        @rootmodel = GoImport::RootModel.new
        coworkers = Hash.new
        includes = Hash.new
        people = Hash.new

        configure @rootmodel

        # coworkers
        # start with these since they are referenced
        # from everywhere....
        if coworkers_filename && !coworkers_filename.empty?
            process_rows coworkers_filename do |row|
                coworkers[row['userIndex']] = row['userId']
                @rootmodel.add_coworker(to_coworker(row))
            end
        end

        # organizations
        if organization_filename && !organization_filename.empty?
            process_rows organization_filename do |row|
                @rootmodel.add_organization(to_organization(row, coworkers))
            end
        end

        # persons
        # depends on organizations
        if persons_filename && !persons_filename.empty?
            process_rows persons_filename do |row|
                people[row['personIndex']] = "#{row['PowerSellReferenceID']}-#{row['PowerSellCompanyID']}"
                # adds it self to the employer
                to_person(row)
            end
        end

        # organization notes
        if orgnotes_filename && !orgnotes_filename.empty?
            process_rows orgnotes_filename do |row|
                # adds itself if applicable
                @rootmodel.add_note(to_organization_note(row, coworkers, people))
            end
        end

        # Organization - Deal connection
        # Reads the includes.txt and creats a hash
        # that connect organizations to deals
        if includes_filename && !includes_filename.empty?
            process_rows includes_filename do |row|
                includes[row['PowerSellProjectID']] = row['PowerSellCompanyID']
            end
        end

        # deals
        # deals can reference coworkers (responsible), organizations
        # and persons (contact)
        if deals_filename && !deals_filename.empty?
            process_rows deals_filename do |row|
                @rootmodel.add_deal(to_deal(row, includes, coworkers))
            end
        end

        # deal notes
        if dealnotes_filename && !dealnotes_filename.empty?
            process_rows dealnotes_filename do |row|
                # adds itself if applicable
                @rootmodel.add_note(to_deal_note(row, coworkers))
            end
        end

        return @rootmodel
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
    method_option :output, :desc => "Path to file where xml will be output", :default => "export.xml", :type => :string, :required => true
    method_option :coworkers, :desc => "Path to coworkers csv file", :type => :string, :required => true
    method_option :organizations, :desc => "Path to organization csv file", :type => :string, :required => true
    method_option :persons, :desc => "Path to persons csv file", :type => :string, :required => true
    method_option :orgnotes, :desc => "Path to organization notes file", :type => :string, :required => true
    method_option :includes, :desc => "Path to include file", :type => :string, :required => true
    method_option :deals, :desc => "Path to deals csv file", :type => :string, :required => true
    method_option :dealnotes, :desc => "Path to deal notes file", :type => :string, :required => true
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
