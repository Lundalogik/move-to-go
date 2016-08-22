require 'spec_helper'
require 'move-to-go'

describe MoveToGo::ShardHelper do
    it "should shard 50 objects of a single type into two shards" do
        # given
        model =  MoveToGo::RootModel.new

        (1..50).each do |n|
            organization = MoveToGo::Organization.new
            organization.name = "Ankeborgs bibliotek"
            organization.integration_id = n.to_s
            model.add_organization(organization)
        end

        sharder = MoveToGo::ShardHelper.new(25)

        # when, the
        sharder.shard_model(model).length.should eq 2
    end

    it "should shard 60 objects of different type into three shards" do
        # given
        model =  MoveToGo::RootModel.new

        (1..10).each do |n|
            organization = MoveToGo::Organization.new
            organization.name = "Ankeborgs bibliotek"
            organization.integration_id = n.to_s

            person = MoveToGo::Person.new
            person.first_name = "Kalle"
            person.last_name = "Kula"
            organization.add_employee(person)

            person = MoveToGo::Person.new
            person.first_name = "Nisse"
            person.last_name = "Nice"
            organization.add_employee(person)

            model.add_organization(organization)
        end

        (1..10).each do |n|
            deal = MoveToGo::Deal.new
            deal.name = "Big deal"
            deal.integration_id = n.to_s
            model.add_deal(deal)
        end

        (1..10).each do |n|
            comment = MoveToGo::Comment.new
            comment.text = "Important comment"
            model.add_comment(comment)
        end

        (1..10).each do |n|
            link = MoveToGo::Link.new
            link.url = "https://go.lime-go.com"
            link.name = "Our url"
            model.add_link(link)
        end

        sharder = MoveToGo::ShardHelper.new(20)

        # when, then
        sharder.shard_model(model).length.should eq 3
    end

    it "should be able to change the shard size" do
        # given
        model =  MoveToGo::RootModel.new

        (1..20).each do |n|
            organization = MoveToGo::Organization.new
            organization.name = "Ankeborgs bibliotek"
            organization.integration_id = n.to_s
            model.add_organization(organization)
        end

        sharder = MoveToGo::ShardHelper.new(5)

        # when, then
        sharder.shard_model(model).length.should eq 4
    end

    it "should add an organization into a shard" do
        # given

        model =  MoveToGo::RootModel.new

        organization = MoveToGo::Organization.new
        organization.name = "Ankeborgs bibliotek"
        organization.integration_id = "123"

        sharder = MoveToGo::ShardHelper.new()
        model.add_organization(organization)

        # when, then
        sharder.shard_model(model)[0].find_organization_by_integration_id("123").should eq organization
    end

    it "should add a deal into a shard" do
        # given

        model =  MoveToGo::RootModel.new

        deal = MoveToGo::Deal.new
        deal.name = "Big deal"
        deal.integration_id = "123"

        sharder = MoveToGo::ShardHelper.new()
        model.add_deal(deal)

        # when, then
        sharder.shard_model(model)[0].find_deal_by_integration_id("123").should eq deal
    end

    it "should keep the settings into a shard" do
        # given

        model =  MoveToGo::RootModel.new

        model.settings.with_organization do |organization|
            organization.set_custom_field( { :integrationid => 'external_url', :title => 'Link to external system', :type => :Link } )
        end

        model.settings.with_deal do |deal|
            deal.add_status({:label => "Prospecting", :integration_id => "prospect"})
            deal.add_status({:label => "Qualified", :integration_id => "qualification"})
            deal.add_status({:label => "Won", :integration_id => "won", :assessment => MoveToGo::DealState::PositiveEndState })
            deal.add_status({:label => "Lost", :integration_id => "Lost", :assessment => MoveToGo::DealState::NegativeEndState })
        end

        sharder = MoveToGo::ShardHelper.new()

        # when, then
        sharder.shard_model(model)[0].settings.should eq model.settings
    end

end
