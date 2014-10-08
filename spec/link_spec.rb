require "spec_helper"
require 'go_import'

describe "Link" do
    let("link") {
        GoImport::Link.new
    }

    it "is valid when it has url, created_by and organization" do
        # given
        link.url = "http://dropbox.com/"
        link.created_by = GoImport::CoworkerReference.new( { :integration_id => "123", :heading => "billy bob" } )
        link.organization = GoImport::OrganizationReference.new({ :integration_id => "456", :heading => "Lundalogik" })

        # when, then
        link.validate.should eq ""
    end

    it "is valid when it has url, created_by and deal" do
        # given
        link.url = "http://dropbox.com/"
        link.created_by = GoImport::CoworkerReference.new( { :integration_id => "123", :heading => "billy bob" } )
        link.deal = GoImport::DealReference.new({ :integration_id => "456", :heading => "The new deal" })

        # when, then
        link.validate.should eq ""
    end

    it "is not valid when it has url and deal" do
        # must have a created_by
        # given
        link.url = "http://dropbox.com/"
        link.deal = GoImport::DealReference.new({ :integration_id => "456", :heading => "The new deal" })

        # when, then
        link.validate.length.should be > 0
    end

    it "is not valid when it has url and created_by" do
        # must have an deal or organization
        # given
        link.url = "http://dropbox.com/"
        link.created_by = GoImport::CoworkerReference.new( { :integration_id => "123", :heading => "billy bob" } )

        # when, then
        link.validate.length.should be > 0
    end

    it "is not valid when it has deal and created_by" do
        # must have an url
        # given
        link.created_by = GoImport::CoworkerReference.new( { :integration_id => "123", :heading => "billy bob" } )
        link.deal = GoImport::DealReference.new({ :integration_id => "456", :heading => "The new deal" })

        # when, then
        link.validate.length.should be > 0
    end

    it "is not valid when it has url, created_by, deal and orgaization" do
        # given
        link.url = "http://dropbox.com/"
        link.created_by = GoImport::CoworkerReference.new( { :integration_id => "123", :heading => "billy bob" } )
        link.deal = GoImport::DealReference.new({ :integration_id => "456", :heading => "The new deal" })
        link.organization = GoImport::OrganizationReference.new({ :integration_id => "456", :heading => "Lundalogik" })

        # when, then
        link.validate.length.should be > 0
    end

    it "will set organization ref when organization is assigned" do
        # given
        org = GoImport::Organization.new({:integration_id => "123", :name => "Beagle Boys!"})

        # when
        link.organization = org

        # then
        link.organization.is_a?(GoImport::Organization).should eq true
        link.instance_variable_get(:@organization_reference).is_a?(GoImport::OrganizationReference).should eq true
    end

    it "will set deal ref when deal is assigned" do
        # given
        deal = GoImport::Deal.new({:integration_id => "123" })
        deal.name = "The new deal"

        # when
        link.deal = deal

        # then
        link.deal.is_a?(GoImport::Deal).should eq true
        link.instance_variable_get(:@deal_reference).is_a?(GoImport::DealReference).should eq true
    end

    it "will set coworker ref when coworker is assigned" do
        # given
        coworker = GoImport::Coworker.new({:integration_id => "123" })
        coworker.parse_name_to_firstname_lastname_se "Billy Bob"

        # when
        link.created_by = coworker

        # then
        link.created_by.is_a?(GoImport::Coworker).should eq true
        link.instance_variable_get(:@created_by_reference).is_a?(GoImport::CoworkerReference).should eq true
    end
end
