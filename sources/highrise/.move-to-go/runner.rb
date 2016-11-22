# encoding: UTF-8

require 'move-to-go'
require 'highrise'
require_relative("../converter")

def convert_source
    puts "Trying to convert a custom source to LIME Go..."

    converter = Converter.new
    rootmodel = MoveToGo::RootModel.new

    Highrise::Base.site = "https://#{SITENAME}.highrisehq.com"
    Highrise::Base.user = APIKEY
    Highrise::Base.format = :xml
    
    #Company
    companies = Highrise::Company.find_all_across_pages(:params => {})
    companies.each{ |company| 
        organization = MoveToGo::Organization.new()

        organization.integration_id = company.id.to_s
        organization.name = company.name

        rootmodel.add_organization(
            converter.to_organization(company, organization, rootmodel))
    }

    #Person
    persons = Highrise::Person.find_all_across_pages(:params => {})    
    persons.each{ |highrise_person|             
        person = MoveToGo::Person.new()

        person.integration_id = highrise_person.id.to_s 
        person.first_name = highrise_person.first_name
        person.last_name = highrise_person.last_name

        employer = rootmodel.find_organization_by_integration_id(highrise_person.company_id.to_s)
        if employer            
            employer.add_employee(person)
        end
                
        converter.to_person(highrise_person, person, rootmodel)

    }

    if rootmodel.nil?
        puts "The returned rootmodel is nil. You must return a MoveToGo::RootModel."
        raise "The returned rootmodel is nil. You must return a MoveToGo::RootModel."
    end

    if !rootmodel.is_a?(MoveToGo::RootModel)
        puts "The returned object is not an instance of MoveToGo::RootModel."
        raise "The returned object is not an instance of MoveToGo::RootModel."
    end

    return rootmodel
end

