require "spec_helper"
require 'move-to-go'

describe "Link" do
    let("link") {
        MoveToGo::Link.new
    }

    it "is valid when it has url, created_by and organization" do
        # given
        link.url = "http://dropbox.com/"
        link.created_by = MoveToGo::CoworkerReference.new( { :integration_id => "123", :heading => "billy bob" } )
        link.organization = MoveToGo::OrganizationReference.new({ :integration_id => "456", :heading => "Lundalogik" })

        # when, then
        link.validate.should eq ""
    end

    it "is valid when it has url, created_by and deal" do
        # given
        link.url = "http://dropbox.com/"
        link.created_by = MoveToGo::CoworkerReference.new( { :integration_id => "123", :heading => "billy bob" } )
        link.deal = MoveToGo::DealReference.new({ :integration_id => "456", :heading => "The new deal" })

        # when, then
        link.validate.should eq ""
    end

    it "is not valid when it has url and deal" do
        # must have a created_by
        # given
        link.url = "http://dropbox.com/"
        link.deal = MoveToGo::DealReference.new({ :integration_id => "456", :heading => "The new deal" })

        # when, then
        link.validate.length.should be > 0
    end

    it "is not valid when it has url and created_by" do
        # must have an deal or organization
        # given
        link.url = "http://dropbox.com/"
        link.created_by = MoveToGo::CoworkerReference.new( { :integration_id => "123", :heading => "billy bob" } )

        # when, then
        link.validate.length.should be > 0
    end

    it "is not valid when it has deal and created_by" do
        # must have an url
        # given
        link.created_by = MoveToGo::CoworkerReference.new( { :integration_id => "123", :heading => "billy bob" } )
        link.deal = MoveToGo::DealReference.new({ :integration_id => "456", :heading => "The new deal" })

        # when, then
        link.validate.length.should be > 0
    end

    it "is valid when it has url, created_by, deal and orgaization" do
        # given
        link.url = "http://dropbox.com/"
        link.created_by = MoveToGo::CoworkerReference.new( { :integration_id => "123", :heading => "billy bob" } )
        link.deal = MoveToGo::DealReference.new({ :integration_id => "456", :heading => "The new deal" })
        link.organization = MoveToGo::OrganizationReference.new({ :integration_id => "456", :heading => "Lundalogik" })

        # when, then
        link.validate.should eq ""
    end
    
    it "is valid when it has url, created_by, deal, person and orgaization" do
        # given
        link.url = "http://dropbox.com/"
        link.created_by = MoveToGo::CoworkerReference.new( { :integration_id => "123", :heading => "billy bob" } )
        link.deal = MoveToGo::DealReference.new({ :integration_id => "456", :heading => "The new deal" })
        link.person = MoveToGo::PersonReference.new({ :integration_id => "456", :heading => "Limer" })
        link.organization = MoveToGo::OrganizationReference.new({ :integration_id => "456", :heading => "Lundalogik" })

        # when, then
        link.validate.should eq ""
    end

    it "will set organization ref when organization is assigned" do
        # given
        org = MoveToGo::Organization.new({:integration_id => "123", :name => "Beagle Boys!"})

        # when
        link.organization = org

        # then
        link.organization.is_a?(MoveToGo::Organization).should eq true
        link.instance_variable_get(:@organization_reference).is_a?(MoveToGo::OrganizationReference).should eq true
    end

    it "will set deal ref when deal is assigned" do
        # given
        deal = MoveToGo::Deal.new({:integration_id => "123" })
        deal.name = "The new deal"

        # when
        link.deal = deal

        # then
        link.deal.is_a?(MoveToGo::Deal).should eq true
        link.instance_variable_get(:@deal_reference).is_a?(MoveToGo::DealReference).should eq true
    end

    it "will set person ref when person is assigned" do
        # given
        person = MoveToGo::Person.new({:integration_id => "123" })
        person.first_name = "The"
        person.last_name = "Limer"

        # when
        link.person = person

        # then
        link.person.is_a?(MoveToGo::Person).should eq true
        link.instance_variable_get(:@person_reference).is_a?(MoveToGo::PersonReference).should eq true
    end

    it "will set coworker ref when coworker is assigned" do
        # given
        coworker = MoveToGo::Coworker.new({:integration_id => "123" })
        coworker.parse_name_to_firstname_lastname_se "Billy Bob"

        # when
        link.created_by = coworker

        # then
        link.created_by.is_a?(MoveToGo::Coworker).should eq true
        link.instance_variable_get(:@created_by_reference).is_a?(MoveToGo::CoworkerReference).should eq true
    end
end
