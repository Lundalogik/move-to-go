require "spec_helper"
require 'go_import'

describe "Organization" do
    let(:organization) {
        GoImport::Organization.new
    }

    it "must have a name" do
        organization.name = "Lundalogik"

        organization.validate.should eq ""
    end

    it "will fail on validateion if it has a source with no sourceid" do
        # given
        organization.name =  "Lundalogik"

        # when
        organization.with_source do |source|
            source.par_se('')
        end

        # then
        organization.validate.length.should be > 0
    end

    it "will fail on validation if no name is specified" do
        # given
        organization.name = ""

        # when, then
        organization.validate.length.should be > 0
    end

    it "will set coworker ref when coworker is assigned" do
        # given
        coworker = GoImport::Coworker.new({:integration_id => "456", :first_name => "Billy", :last_name => "Bob"})

        # when
        organization.responsible_coworker = coworker

        # then
        organization.responsible_coworker.is_a?(GoImport::Coworker).should eq true
        organization.instance_variable_get(:@responsible_coworker_reference).is_a?(GoImport::CoworkerReference).should eq true
    end

    it "will have a no relation as default" do
        # given, when, then
        organization.relation.should eq GoImport::Relation::NoRelation
    end

    it "should only accept relations from Relations enum" do
        # given, when
        organization.relation = GoImport::Relation::IsACustomer

        # then
        organization.relation.should eq GoImport::Relation::IsACustomer
    end

    it "should not accept invalid relations" do
        # when, then
        expect {
            organization.relation = "hubbabubba"
        }.to raise_error(GoImport::InvalidRelationError)
    end

    it "should not have a relation modified date if relation is NoRelation" do
        # given, when
        organization.relation = GoImport::Relation::NoRelation

        # then
        organization.relation_last_modified.nil?.should eq true
    end

    it "should have a relation modified date if relation is IsACustomer" do
        # given, when
        organization.relation = GoImport::Relation::IsACustomer

        # then
        organization.relation_last_modified.nil?.should eq false
    end

    it "should set relation last modified when relation is set" do
        # given
        organization.relation = GoImport::Relation::IsACustomer

        # when
        organization.relation_last_modified = "2014-07-01"

        # then
        organization.relation_last_modified.should eq "2014-07-01"
    end

    it "should not set relation last modified when relation is NoRelation" do
        # given
        organization.relation = GoImport::Relation::NoRelation

        # when
        organization.relation_last_modified = "2014-07-01"

        # then
        organization.relation_last_modified.nil?.should eq true
    end

    it "should only set relation last modified to valid date" do
        # given
        organization.relation = GoImport::Relation::IsACustomer

        # when, then
        expect {
            organization.relation_last_modified = "hubbabubba"
        }.to raise_error(GoImport::InvalidValueError)
    end
end

describe "OrganizationReference" do
    it "can be created from an organization" do
        # given
        org = GoImport::Organization.new
        org.name = "Lundalogik"
        org.integration_id = "123"

        # when
        ref = GoImport::OrganizationReference.from_organization(org)

        # then
        ref.is_a?(GoImport::OrganizationReference).should eq true
        ref.heading.should eq "Lundalogik"
        ref.integration_id.should eq "123"
    end

    it "can be created from an organization_reference" do
        # given
        orgref = GoImport::OrganizationReference.new
        orgref.heading = "Lundalogik"

        # when
        ref = GoImport::OrganizationReference.from_organization(orgref)

        # then
        ref.is_a?(GoImport::OrganizationReference).should eq true
    end

    it "is nil when created from nil" do
        # given, when
        ref = GoImport::OrganizationReference.from_organization(nil)

        # then
        ref.should eq nil
    end
end
