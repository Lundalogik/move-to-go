require "spec_helper"
require 'fruit_to_lime'

describe "Link" do
    let("link") {
        FruitToLime::Link.new
    }

    it "is valid when it has url, created_by and organization" do
        # given
        link.url = "http://dropbox.com/"
        link.created_by = FruitToLime::CoworkerReference.new( { :integration_id => "123", :heading => "billy bob" } )
        link.organization = FruitToLime::OrganizationReference.new({ :integration_id => "456", :heading => "Lundalogik" })

        # when, then
        link.validate.should eq ""
    end

    it "is valid when it has url, created_by and deal" do
        # given
        link.url = "http://dropbox.com/"
        link.created_by = FruitToLime::CoworkerReference.new( { :integration_id => "123", :heading => "billy bob" } )
        link.deal = FruitToLime::DealReference.new({ :integration_id => "456", :heading => "The new deal" })

        # when, then
        link.validate.should eq ""
    end

    it "is not valid when it has url and deal" do
        # must have a created_by
        # given
        link.url = "http://dropbox.com/"
        link.deal = FruitToLime::DealReference.new({ :integration_id => "456", :heading => "The new deal" })

        # when, then
        link.validate.length.should be > 0
    end

    it "is not valid when it has url and created_by" do
        # must have an deal or organization
        # given
        link.url = "http://dropbox.com/"
        link.created_by = FruitToLime::CoworkerReference.new( { :integration_id => "123", :heading => "billy bob" } )

        # when, then
        link.validate.length.should be > 0
    end

    it "is not valid when it has deal and created_by" do
        # must have an url
        # given
        link.created_by = FruitToLime::CoworkerReference.new( { :integration_id => "123", :heading => "billy bob" } )
        link.deal = FruitToLime::DealReference.new({ :integration_id => "456", :heading => "The new deal" })

        # when, then
        link.validate.length.should be > 0
    end

    it "is not valid when it has url, created_by, deal and orgaization" do
        # given
        link.url = "http://dropbox.com/"
        link.created_by = FruitToLime::CoworkerReference.new( { :integration_id => "123", :heading => "billy bob" } )
        link.deal = FruitToLime::DealReference.new({ :integration_id => "456", :heading => "The new deal" })
        link.organization = FruitToLime::OrganizationReference.new({ :integration_id => "456", :heading => "Lundalogik" })

        # when, then
        link.validate.length.should be > 0
    end

    it "will auto convert org to org.ref during assignment" do
        # given
        org = FruitToLime::Organization.new({:integration_id => "123", :name => "Beagle Boys!"})

        # when
        link.organization = org

        # then
        link.organization.is_a?(FruitToLime::OrganizationReference).should eq true
    end

    it "will auto convert deal to deal.ref during assignment" do
        # given
        deal = FruitToLime::Deal.new({:integration_id => "123" })
        deal.name = "The new deal"

        # when
        link.deal = deal

        # then
        link.deal.is_a?(FruitToLime::DealReference).should eq true
    end

    it "will auto convert coworker to coworker.ref during assignment" do
        # given
        coworker = FruitToLime::Coworker.new({:integration_id => "123" })
        coworker.parse_name_to_firstname_lastname_se "Billy Bob"

        # when
        link.created_by = coworker

        # then
        link.created_by.is_a?(FruitToLime::CoworkerReference).should eq true
    end


end
