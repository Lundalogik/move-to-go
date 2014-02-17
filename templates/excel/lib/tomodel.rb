require 'fruit_to_lime'
require 'roo'

class ToModel
    def to_organization(row)
        organization = FruitToLime::Organization.new()
        # Map properties
        organization.integration_id = row['Id']
        organization.name = row['Name']

        return organization
    end

    def to_model(organization_file_name)
        # from excel to csv
        organization_file_data = Roo::Excelx.new(organization_file_name)

        model = FruitToLime::RootModel.new
        rows = FruitToLime::RooHelper.new(organization_file_data).rows
        rows.each do |row|
            model.organizations.push(to_organization(row))
        end
        return model
    end
end

require "thor"
require "fileutils"
require 'pathname'

class Cli < Thor
     desc "to_go ORGANIZATION FILE", "Converts excel file to Go xml format. ORGANIZATIONS is path to input file. FILE is output file where Go xml will go."
    def to_go(organizations, file = nil)
        file = 'export.xml' if file == nil
        toModel = ToModel.new()
        model = toModel.to_model(organizations)
        model.serialize_to_file(file)  
    end
end
