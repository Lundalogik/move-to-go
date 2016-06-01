require 'spec_helper'
require 'go_import'

describe GoImport::ShardHelper do
    it "should shard 50 objects of a single type into two shards" do
        # given
        model =  GoImport::RootModel.new

        (1..50).each do |n|
            organization = GoImport::Organization.new
            organization.name = "Ankeborgs bibliotek"
            organization.integration_id = n.to_s
            model.add_organization(organization)
        end

        sharder = GoImport::ShardHelper.new(25)

        # when, the
        sharder.shard_model(model).length.should eq 2
    end

    it "should shard 60 objects of different type into three shards" do
        # given
        model =  GoImport::RootModel.new

        (1..10).each do |n|
            organization = GoImport::Organization.new
            organization.name = "Ankeborgs bibliotek"
            organization.integration_id = n.to_s

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

        (1..10).each do |n|
            deal = GoImport::Deal.new
            deal.name = "Big deal"
            deal.integration_id = n.to_s
            model.add_deal(deal)
        end

        (1..10).each do |n|
            comment = GoImport::Comment.new
            comment.text = "Important comment"
            model.add_comment(comment)
        end

        (1..10).each do |n|
            link = GoImport::Link.new
            link.url = "https://go.lime-go.com"
            link.name = "Our url"
            model.add_link(link)
        end

        sharder = GoImport::ShardHelper.new(20)

        # when, then
        sharder.shard_model(model).length.should eq 3
    end

    it "should be able to change the shard size" do
        # given
        model =  GoImport::RootModel.new

        (1..20).each do |n|
            organization = GoImport::Organization.new
            organization.name = "Ankeborgs bibliotek"
            organization.integration_id = n.to_s
            model.add_organization(organization)
        end

        sharder = GoImport::ShardHelper.new(5)

        # when, then
        sharder.shard_model(model).length.should eq 4
    end

    it "should add an organization into a shard" do
        # given

        model =  GoImport::RootModel.new

        organization = GoImport::Organization.new
        organization.name = "Ankeborgs bibliotek"
        organization.integration_id = "123"

        sharder = GoImport::ShardHelper.new()
        model.add_organization(organization)

        # when, then
        sharder.shard_model(model)[0].find_organization_by_integration_id("123").should eq organization
    end

    it "should add a deal into a shard" do
        # given

        model =  GoImport::RootModel.new

        deal = GoImport::Deal.new
        deal.name = "Big deal"
        deal.integration_id = "123"

        sharder = GoImport::ShardHelper.new()
        model.add_deal(deal)

        # when, then
        sharder.shard_model(model)[0].find_deal_by_integration_id("123").should eq deal
    end

    it "should keep the settings into a shard" do
        # given

        model =  GoImport::RootModel.new

        model.settings.with_organization do |organization|
            organization.set_custom_field( { :integrationid => 'external_url', :title => 'Link to external system', :type => :Link } )
        end

        model.settings.with_deal do |deal|
            deal.add_status({:label => "Prospecting", :integration_id => "prospect"})
            deal.add_status({:label => "Qualified", :integration_id => "qualification"})
            deal.add_status({:label => "Won", :integration_id => "won", :assessment => GoImport::DealState::PositiveEndState })
            deal.add_status({:label => "Lost", :integration_id => "Lost", :assessment => GoImport::DealState::NegativeEndState })
        end

        sharder = GoImport::ShardHelper.new()

        # when, then
        sharder.shard_model(model)[0].settings.should eq model.settings
    end

end
