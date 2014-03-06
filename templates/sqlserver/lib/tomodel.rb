require 'fruit_to_lime'
require 'roo'
require 'date'

class ToModel
    def to_organization(row)
        organization = FruitToLime::Organization.new()
        organization.integration_id = row['id']
        organization.name = row['name']
        return organization
    end

    def to_model(organization_rows)
        model = FruitToLime::RootModel.new

        organization_rows.each do |row|
            model.organizations.push(to_organization(row))
        end

        return model
    end
end

require "thor"
require "fileutils"
require 'pathname'
require 'tiny_tds'

class Cli < Thor
     desc "to_go", "Connects to sql server and queries for organizations to Go xml format. HOST, DATABASE, USERNAME and PASSWORD for Sql server connection. FILE is output file where Go xml will go."
    def to_go(host, database, username, password, file = nil)
        puts "Connecting to database #{database} on server #{host} as user #{username}"
        client = TinyTds::Client.new(
            :username => username,
            :password => password,
            :host => host,
            :database => database)

        organizationSql =
            "SELECT
                c.id,
                c.name,
            FROM
                company c"

        organization_rows = client.execute(organizationSql)

        file = 'export.xml' if file == nil
        tomodel = ToModel.new()
        model = tomodel.to_model(organization_rows)
        error = model.sanity_check
        if error.empty?
            model.serialize_to_file(file)
            puts "'#{organizations}' has been converted into '#{file}'."
        else
            puts "'#{organizations}' could not be converted due to"
            puts error
        end
    end
end
