require "spec_helper"
require 'fruit_to_lime'

describe "Organization" do
    let(:organization) {
        FruitToLime::Organization.new
    }

    it "must have a name" do
        organization.name = "Lundalogik"

        organization.validate.should eq ""
    end

    it "will fail on validation if no name is specified" do
        organization.name = ""

        organization.validate.length > 0
    end
end

describe "OrganizationReference" do
    it "can be created from an organization" do
        # given
        org = FruitToLime::Organization.new
        org.name = "Lundalogik"
        org.integration_id = "123"

        # when
        ref = FruitToLime::OrganizationReference.from_organization(org)

        # then
        ref.is_a?(FruitToLime::OrganizationReference).should eq true
        ref.heading.should eq "Lundalogik"
        ref.integration_id.should eq "123"
    end

    it "can be created from an organization_reference" do
        # given
        orgref = FruitToLime::OrganizationReference.new
        orgref.heading = "Lundalogik"

        # when
        ref = FruitToLime::OrganizationReference.from_organization(orgref)

        # then
        ref.is_a?(FruitToLime::OrganizationReference).should eq true
    end

    it "is nil when created from nil" do
        # given, when
        ref = FruitToLime::OrganizationReference.from_organization(nil)

        # then
        ref.should eq nil
    end
end
