require 'go_import'
require_relative("../converter")

REPORT_RESULT = true
COWORKER_FILE = "data/coworkers.csv"
ORGANIZATION_FILE = "data/contacts.csv"
LEADS_FILE = "data/leads.csv"
PERSON_FILE = "data/contacts.csv"
DEAL_FILE = "data/deals.csv"
HISTORY_FILE = "data/histories.csv"
SOURCE_ENCODING = "utf-8"



def process_rows(file_name, source_encoding)
    data = File.read(file_name, :encoding => source_encoding)
    rows = GoImport::CsvHelper::text_to_hashes(data)
    rows.each do |row|
        yield row
    end
end

def convert_source
    puts "Trying to convert Base CRM source to LIME Go..."

    converter = Converter.new
    ignored_histories = 0
    ignored_persons = 0

    # A rootmodel is used to represent all entitite/models that is
    # exported
    rootmodel = GoImport::RootModel.new

    converter.configure(rootmodel)
    source_encoding = defined?(SOURCE_ENCODING) ? SOURCE_ENCODING : 'ISO-8859-1'

    # coworkers
    # start with these since they are referenced
    # from everywhere....
    if defined?(COWORKER_FILE) && !COWORKER_FILE.nil? && !COWORKER_FILE.empty?
        process_rows(COWORKER_FILE, source_encoding) do |row|
          coworker = converter.to_coworker(row)
          coworker.integration_id = "#{row['first_name']} #{row['last_name']}"
          coworker.first_name = row['first_name']
          coworker.last_name = row['last_name']
          coworker.email = row['email']
          rootmodel.add_coworker(coworker)
        end
    end

    # organizations
    if defined?(ORGANIZATION_FILE) && !ORGANIZATION_FILE.nil? && !ORGANIZATION_FILE.empty?
        process_rows(ORGANIZATION_FILE, source_encoding) do |row|
            next if row["is_organisation"] == "false"
            organization = converter.to_organization(row, rootmodel)
            organization = GoImport::Organization.new
            organization.integration_id = row['id']
        	  organization.name = row['name']
            organization.email = row['email']
            organization.web_site = row['website']
            organization.central_phone_number = GoImport::PhoneHelper.parse_numbers(row['phone']) if not row['phone'].nil?

            organization.with_visit_address do |address|
                address.street = row['address']
                address.zip_code = row['zip']
                address.city = row['city']
            end

            organization.with_postal_address do |address|
              address.street = row['address']
        	    address.zip_code = row['zip']
        	    address.city = row['city']
            end

            case row['prospect_status']
            when "current"
              organization.relation = GoImport::Relation::WorkingOnIt
            else
              organization.relation = GoImport::Relation::BeenInTouch
            end

            case row['customer_status']
            when "current"
              organization.relation = GoImport::Relation::IsACustomer
            when "past"
              organization.relation = GoImport::Relation::WasACustomer
            else
              organization.relation = GoImport::Relation::BeenInTouch
            end

            coworker = rootmodel.find_coworker_by_integration_id row['owner']
            organization.responsible_coworker = coworker
        		tags = row['tags'].split(",")
        		tags.each do |tag|
        			organization.set_tag(tag)
        		end

            rootmodel.add_organization(organization)
        end
    end

    # persons
    # depends on organizations
    if defined?(PERSON_FILE) && !PERSON_FILE.nil? && !PERSON_FILE.empty?
        process_rows(PERSON_FILE, source_encoding) do |row|
            # adds it self to the employer
            next if row["is_organisation"] == "true"
            person = converter.to_person(row, rootmodel)

            person.integration_id = row['id']

            person.first_name = row['first_name']
            person.last_name = row['last_name']

            person.direct_phone_number = GoImport::PhoneHelper.parse_numbers(row['phone'])
            person.mobile_phone_number = GoImport::PhoneHelper.parse_numbers(row['mobile'])
            person.email = row['email']

            organization = rootmodel.find_organization {|org|
               org.name == row["organisation_name"]
             }
            if not organization.nil?
              organization.add_employee(person)
            else
              puts "No organization for person '#{person.first_name} #{person.last_name}, #{person.integration_id}' could be found. Person will not be imported!"
              ignored_persons += 1
            end
        end
    end

    # leads
    if defined?(LEADS_FILE) && !LEADS_FILE.nil? && !LEADS_FILE.empty?
      process_rows(LEADS_FILE, source_encoding) do |row|
            organization = converter.to_organization_from_lead(row, rootmodel)

            organization.integration_id = "l#{row['id']}"
            organization.name = row['company_name']
            organization.relation = GoImport::Relation::WorkingOnIt

            organization.central_phone_number = GoImport::PhoneHelper.parse_numbers(row['phone']) if not row['phone'].nil?

            organization.with_visit_address do |address|
                address.street = row['street']
                address.city = row['city']
            end

            coworker = rootmodel.find_coworker_by_integration_id row['owner']
            organization.responsible_coworker = coworker

            if not row['tags'].nil?
              tags = row['tags'].split(",")
              tags.each do |tag|
                organization.set_tag(tag)
              end
            end

            person = GoImport::Person.new

            person.integration_id = "p#{row['id']}"
            person.first_name = row['first_name']
            person.last_name = row['last_name']
            person.direct_phone_number = GoImport::PhoneHelper.parse_numbers(row['phone']) if not row['phone'].nil?
            person.mobile_phone_number = GoImport::PhoneHelper.parse_numbers(row['mobile']) if not row['mobile'].nil?
            person.email = row['email']

            organization.add_employee(person)

            if row['description']
              comment = GoImport::Comment.new()

              comment.text = row['description']
              comment.person = person
              comment.organization = organization
              comment.created_by = coworker

              rootmodel.add_comment(comment)
            end
            rootmodel.add_organization(organization)
      end
    end

    # deals
    if defined?(DEAL_FILE) && !DEAL_FILE.nil? && !DEAL_FILE.empty?
        process_rows(DEAL_FILE, source_encoding) do |row|
            deal = converter.to_deal(row, rootmodel)
            deal.integration_id = row['id']
            deal.name = row['name']

            deal.value = row['scope']
            deal.customer = rootmodel.find_organization_by_integration_id(row['company_id'])
            deal.customer_contact = rootmodel.find_person_by_integration_id(row['main_contact_id'])
            deal.responsible_coworker = rootmodel.find_coworker_by_integration_id(row['owner'])

        		values = row['tags'].split(",")
        		values.each do |value|
        			deal.set_tag(value)
        		end
            rootmodel.add_deal(deal)
        end
    end

    # historys
    if defined?(HISTORY_FILE) && !HISTORY_FILE.nil? && !HISTORY_FILE.empty?
        process_rows(HISTORY_FILE, source_encoding) do |row|
            history = converter.to_history(row, rootmodel)
            history.integration_id = row['id']
            history.text = row['content']
            history.created_by = rootmodel.find_coworker_by_integration_id(row["owner"])
            notable_id = row['noteable_id']
            case row["noteable_type"]
            when "Deal"
              deal = rootmodel.find_deal_by_integration_id(notable_id)
              history.deal = deal
            when "Lead"
              history.person = rootmodel.find_person_by_integration_id("p#{notable_id}")
              history.organization = rootmodel.find_organization_by_integration_id("l#{notable_id}")
            when "Contact"
              puts "Ignoreing history for unbound person: #{row['owner']}"
              ignored_histories += 1
              next
            else
              org = rootmodel.find_organization_by_integration_id(notable_id)
              if org.nil?
                person = rootmodel.find_person_by_integration_id(notable_id)
                org = person.organization
                history.person = person
              end
              history.organization = org
            end
            rootmodel.add_history(history)
        end
    end
    puts "Ignored #{ignored_persons} persons and #{ignored_histories} histories"
    return rootmodel
end
