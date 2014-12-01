
require 'zip'

require 'go_import'
require_relative("../converter")

# EXPORT_FOLDER and other constants should be defined ../converter.rb

USER_FILE = "User.csv"
ORGANIZATION_FILE = "Account.csv"
PERSON_FILE = "Contact.csv"
DEAL_FILE = "Opportunity.csv"
NOTE_FILE = "Note.csv"

def process_rows(filename)
    if !File.exists?(filename)
        puts "Error: Cant find the file '#{filename}'."
        raise
    end
    
    f = File.open(filename, 'r')
    data = f.read.encode("UTF-8", "ISO-8859-1")
    rows = GoImport::CsvHelper::text_to_hashes(data)
    rows.each do |row|
        yield row
    end
    f.close
end

def get_salesforce_export_zipfile()
    if defined?(EXPORT_FOLDER)
        if EXPORT_FOLDER.nil? || EXPORT_FOLDER.empty?
            puts "EXPORT_FOLDER is empty, using 'export' as default."
            export_folder = File.expand_path("export", Dir.pwd)
        else
            export_folder = File.expand_path(EXPORT_FOLDER, Dir.pwd)
        end
    else
        puts "EXPORT_FOLDER is not defined, using 'export' as default."
        export_folder = File.expand_path("export", Dir.pwd)
    end

    puts "Searching '#{export_folder}' for Salesforce export zip file..."

    if defined?(EXPORT_FILE)
        if EXPORT_FILE.nil? || EXPORT_FILE.empty?
            export_zip_files = Dir.glob(File.join(export_folder, "*.zip"))
        else
            export_zip_files = Dir.glob(File.join(export_folder, EXPORT_FILE))
        end
    else
        export_zip_files = Dir.glob(File.join(export_folder, "*.zip"))
    end

    if export_zip_files.length == 0
        puts "No zip file found, please copy your Salesforce export zipfile to '#{export_folder}'."
        return nil
    elsif export_zip_files.length > 1
        puts "More than one zip file found in '#{export_folder}', either remove all but one or set the EXPORT_FILE in converter.rb"
        return nil
    elsif export_zip_files.length == 1
        puts "Found zipfile to import from. Using: '#{export_zip_files[0]}'."
        return export_zip_files[0]
    end
end

def to_coworker(row)
    coworker = nil
    
    if row['IsActive'] == '1' && row['UserType'] == 'Standard'
        coworker = GoImport::Coworker.new

        coworker.id = row['Email']
        coworker.integration_id = row['Id']
        coworker.first_name = row['FirstName']
        coworker.last_name = row['LastName']
        coworker.direct_phone_number = row['Phone']
        coworker.mobile_phone_number = row['MobilePhone']
    end
    
    return coworker
end

def to_organization(row, rootmodel)
    if row['IsDeleted'] != '0'
        return nil
    end

    organization = GoImport::Organization.new

    organization.integration_id = row['Id']
    organization.name = row['Name']
    organization.set_tag(row['Type'])

    organization.central_phone_number = row['Phone']
    organization.web_site = row['Website']
    
    organization.with_postal_address do |address|
        address.street = row['BillingStreet']
        address.zip_code = row['BillingPostalCode']
        address.city = row['BillingCity']
        address.country_code = row['BillingCountry']
    end

    organization.with_visit_address do |address|
        address.street = row['ShippingStreet']
        address.zip_code = row['ShippingPostalCode']
        address.city = row['ShippingCity']
        address.country_code = row['ShippingCountry']
    end

    organization.responsible_coworker =
        rootmodel.find_coworker_by_integration_id(row['OwnerId'])

    return organization
end

def add_person_to_organization(row, rootmodel)
    if row['IsDeleted'] == 0
        org = rootmodel.find_organization_by_integration_id(row['AccountId'])
        
        if !org.nil?
            person = GoImport::Person.new
            add_employee(person)

            person.integration_id = row['Id']
            person.first_name = row['FirstName']
            person.last_name = row['LastName']

            person.direct_phone_number = row['Phone']
            person.fax_phone_number = row['Fax']
            person.mobile_phone_number = row['MobilePhone']
            person.home_phone_number = row['HomePhone']
            person.position = row['Title']
            person.email = row['Email']
        end
    end
end

def to_deal(row, rootmodel, converter)
    if row['IsDeleted'] != '0'
        return nil
    end

    deal = GoImport::Deal.new

    deal.integration_id = row['Id']
    deal.customer = rootmodel.find_organization_by_integration_id(row['AccountId'])
    deal.responsible_coworker = rootmodel.find_coworker_by_integration_id(row['OwnerId'])
    deal.customer_contact =
        rootmodel.find_person_by_integration_id(row['PrimaryPartnerAccountId'])
    deal.name = row['Name']
    deal.description = row['Description']
    deal.value = row['Amount']
    deal.probability = row['Probability']

    deal.set_tag row['Type']

    if converter.respond_to?(:get_deal_status_from_salesforce_stage)
        status = converter.get_deal_status_from_salesforce_stage(row['StageName'])

        if !status.nil?
            deal.status = status
        end
    end
    
    return deal
end

def to_note(row, rootmodel)
    if row['IsDeleted'] != '0'
        return nil
    end

    note = GoImport::Note.new

    note.integration_id = row['Id']
    note.text = row['Title'] + ' ' + row['Body']
    
    note.date = row['CreatedDate']

    note.created_by = rootmodel.find_coworker_by_integration_id(row['CreatedById'])
    note.organization = rootmodel.find_organization_by_integration_id(row['AccountId'])

    # TODO: we should probably set the classification in the same was
    # a a deal's status is set.
    
    return note
end

def convert_source
    puts "Trying to convert Superoffice to LIME Go..."

    converter = Converter.new

    salesforce_export_zipfile = get_salesforce_export_zipfile()
    
    if salesforce_export_zipfile.nil? then
        puts "Could find Salesforce export zip file."
        raise
    end

    rootmodel = GoImport::RootModel.new
    converter.configure(rootmodel)
    
    # We know have the Salesforce export zip file in
    # export_zip_files[0]. We should unzip the file to a temp folder
    # and return the path.
    working_folder = Dir.mktmpdir("go-import") 
    puts "upzip '#{salesforce_export_zipfile}' to '#{working_folder.to_s}'..."
    
    Dir.chdir(working_folder) do
        Zip::File.open(salesforce_export_zipfile) do |zip_file|
            zip_file.each do |entry|
                if entry.to_s.include?("/") then
                #                        puts "DIR"
                else
                    entry.extract
                end
            end
        end

        #puts 'sleep a while'
        #sleep 5
        
        puts "Trying to import users..."
        process_rows(USER_FILE) do |row|
            rootmodel.add_coworker(to_coworker(row))
        end

        puts "Trying to import organizations..."
        process_rows(ORGANIZATION_FILE) do |row|
            rootmodel.add_organization(to_organization(row, rootmodel))
        end

        puts "Trying to import persons..."
        process_rows(PERSON_FILE) do |row|
            add_person_to_organization(row, rootmodel)
        end

        puts "Trying to import deals..."
        process_rows(DEAL_FILE) do |row|
            rootmodel.add_deal(to_deal(row, rootmodel, converter))
        end

        puts "Trying to import notes..."
        process_rows(NOTE_FILE) do |row|
            rootmodel.add_note(to_note(row, rootmodel))
        end
    end
    
    puts "Trying to remove '#{working_folder}'."
    FileUtils.rm_rf(working_folder)
    
    return rootmodel
                               
end

