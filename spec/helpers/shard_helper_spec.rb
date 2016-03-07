require 'spec_helper'
require 'go_import'

describe GoImport::ShardHelper do
    it "should shard 50 000 objects of a single type into two shards" do
        # given
        model =  GoImport::RootModel.new

        (1..50000).each do |n|
            organization = GoImport::Organization.new
            organization.name = "Ankeborgs bibliotek"
            organization.integration_id = "#{n}"
            model.add_organization(organization)
        end

        sharder = GoImport::ShardHelper.new()
        sharder.shard_model(model)

        # when, the
        sharder.get_shards().length.should eq 2
    end

    it "should shard 60 000 objects of different type into two shards" do
        # given
        model =  GoImport::RootModel.new

        (1..10000).each do |n|
            organization = GoImport::Organization.new
            organization.name = "Ankeborgs bibliotek"
            organization.integration_id = "#{n}"
            
            person = GoImport::Person.new
            person.first_name = "Kalle"
            person.last_name = "Kula"
            organization.add_employee(person)
            
            person = GoImport::Person.new
            person.first_name = "Nisse"
            person.last_name = "Nice"
            organization.add_employee(person)

            model.add_organization(organization)
        end

        (1..10000).each do |n|
            deal = GoImport::Deal.new
            deal.name = "Big deal"
            deal.integration_id = "#{n}"
            model.add_deal(deal)
        end

        (1..10000).each do |n|
            note = GoImport::Note.new
            note.text = "Important note"
            model.add_note(note)
        end

        (1..10000).each do |n|
            link = GoImport::Link.new
            link.url = "https://go.lime-go.com"
            link.name = "Our url"
            model.add_link(link)
        end

        sharder = GoImport::ShardHelper.new()
        sharder.shard_model(model)

        # when, then
        sharder.get_shards().length.should eq 3
    end

    it "should be able to change the shard size" do
        # given
        model =  GoImport::RootModel.new

        (1..200).each do |n|
            organization = GoImport::Organization.new
            organization.name = "Ankeborgs bibliotek"
            organization.integration_id = "#{n}"
            model.add_organization(organization)
        end


        sharder = GoImport::ShardHelper.new(50)
        sharder.shard_model(model)

        # when, then
        sharder.get_shards().length.should eq 4
    end

    it "should add an organization into a shard" do
        # given
        organization = GoImport::Organization.new
        organization.name = "Ankeborgs bibliotek"
        organization.integration_id = "123"

        sharder = GoImport::ShardHelper.new()
        sharder.add_organization(organization)

        # when, then
        sharder.shards[0].find_organization_by_integration_id("123").should eq organization
    end

    it "should add a deal into a shard" do
        # given
        deal = GoImport::Deal.new
        deal.name = "Big deal"
        deal.integration_id = "123"

        sharder = GoImport::ShardHelper.new()
        sharder.add_deal(deal)

        # when, then
        sharder.shards[0].find_deal_by_integration_id("123").should eq deal
    end

    it "should count the number of persons in an organization" do
        # given
        organization = GoImport::Organization.new
        organization.name = "Ankeborgs bibliotek"
        organization.integration_id = "123"
        
        person = GoImport::Person.new
        person.first_name = "Kalle"
        person.last_name = "Kula"
        organization.add_employee(person)
        
        person = GoImport::Person.new
        person.first_name = "Nisse"
        person.last_name = "Nice"
        organization.add_employee(person)

        sharder = GoImport::ShardHelper.new()
        sharder.add_organization(organization)

        # when, then
        sharder.current_shard_count.should eq 3
    end

end


