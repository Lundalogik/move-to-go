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

    def configure(model)
        # add custom field to your model here. Custom fields can be
        # added to organization, deal and person. Valid types are
        # :String and :Link. If no type is specified :String is used
        # as default.

        model.settings.with_deal do |deal|
            deal.set_custom_field( { :integrationid => 'discount_url', :title => 'Rabatt url', :type => :Link } )
        end
    end

    def to_model(organization_file_name)
        # from excel to csv
        organization_file_data = Roo::Excelx.new(organization_file_name)

        model = FruitToLime::RootModel.new
        configure model
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
        error = model.sanity_check
        if error.empty?
            validation_errors = model.validate

            if validation_errors.empty?
                model.serialize_to_file(file)
                puts "'#{organizations}' has been converted into '#{file}'."
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
