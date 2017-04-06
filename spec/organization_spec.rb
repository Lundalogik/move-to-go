require "spec_helper"
require 'move-to-go'

describe "Organization" do
    let(:organization) {
        MoveToGo::Organization.new
    }

    it "should have import tag as default" do
        # given, when, then
        organization.tags.count.should eq 1
        organization.tags[0].value.should eq 'Import'
    end

    it "should not accept empty tags" do
        # given
        organization.tags.count.should eq 1

        # when
        organization.set_tag ""

        # then
        organization.tags.count.should eq 1
    end

    it "should not accept nil tags" do
        # given
        organization.tags.count.should eq 1

        # when
        organization.set_tag ""

        # then
        organization.tags.count.should eq 1
    end

    it "should not accept objects as tags" do
        # given
        organization.tags.count.should eq 1

        # when
        not_a_tag = {}
        not_a_tag[:text] = 'this is not a tag'
        organization.set_tag not_a_tag

        # then
        organization.tags.count.should eq 1
    end
    
    
    it "must have a name" do
        # given, when
        organization.name = "Lundalogik"

        # then
        organization.validate.should eq ""
    end

    it "will fail on validation if it has a source with no sourceid" do
        # given
        organization.name =  "Lundalogik"

        # when
        organization.with_source do |source|
            source.par_se('')
        end

        # then
        organization.validate.length.should be > 0
    end

    it "will fail on source validation, only numbers" do
        # given
        organization.name =  "Lundalogik"

        # when
        organization.with_source do |source|
            source.par_se('11234')
        end

        # then
        organization.validate.length.should be > 0
    end


    it "will fail on source validation, begins with :" do
        # given
        organization.name =  "Lundalogik"

        # when
        organization.with_source do |source|
            source.par_se(':11234')
        end

        # then
        organization.validate.length.should be > 0
    end

    it "will fail on source validation, ends with :" do
        # given
        organization.name =  "Lundalogik"

        # when
        organization.with_source do |source|
            source.par_se('11234:')
        end

        # then
        organization.validate.length.should be > 0
    end

    it "will not fail on source validation, pattern 1" do
        # given
        organization.name =  "Lundalogik"

        # when
        organization.with_source do |source|
            source.par_se('1:1234')
        end

        # then
        organization.validate.length.should be == 0
    end

    it "will not fail on source validation, pattern 2" do
        # given
        organization.name =  "Lundalogik"

        # when
        organization.with_source do |source|
            source.par_se('113:234')
        end

        # then
        organization.validate.length.should be == 0
    end

    it "will fail on validation if no name is specified" do
        # given
        organization.name = ""

        # when, then
        organization.validate.length.should be > 0
    end

    it "will set coworker ref when coworker is assigned" do
        # given
        coworker = MoveToGo::Coworker.new({:integration_id => "456", :first_name => "Billy", :last_name => "Bob"})

        # when
        organization.responsible_coworker = coworker

        # then
        organization.responsible_coworker.is_a?(MoveToGo::Coworker).should eq true
        organization.instance_variable_get(:@responsible_coworker_reference).is_a?(MoveToGo::CoworkerReference).should eq true
    end

    it "will have a no relation as default" do
        # given, when, then
        organization.relation.should eq MoveToGo::Relation::NoRelation
    end

    it "should only accept relations from Relations enum" do
        # given, when
        organization.relation = MoveToGo::Relation::IsACustomer

        # then
        organization.relation.should eq MoveToGo::Relation::IsACustomer
    end

    it "should not accept invalid relations" do
        # when, then
        expect {
            organization.relation = "hubbabubba"
        }.to raise_error(MoveToGo::InvalidRelationError)
    end

    it "should not have a relation modified date if relation is NoRelation" do
        # given, when
        organization.relation = MoveToGo::Relation::NoRelation

        # then
        organization.relation_last_modified.nil?.should eq true
    end

    it "should have a relation modified date if relation is IsACustomer" do
        # given, when
        organization.relation = MoveToGo::Relation::IsACustomer

        # then
        organization.relation_last_modified.nil?.should eq false
    end

    it "should set relation last modified when relation is set" do
        # given
        organization.relation = MoveToGo::Relation::IsACustomer

        # when
        organization.relation_last_modified = "2014-07-01"

        # then
        organization.relation_last_modified.should eq "2014-07-01"
    end

    it "should not set relation last modified when relation is NoRelation" do
        # given
        organization.relation = MoveToGo::Relation::NoRelation

        # when
        organization.relation_last_modified = "2014-07-01"

        # then
        organization.relation_last_modified.nil?.should eq true
    end

    it "should only set relation last modified to valid date" do
        # given
        organization.relation = MoveToGo::Relation::IsACustomer
        
        # when, then
        expect {
            organization.relation_last_modified = "hubbabubba"
        }.to raise_error(MoveToGo::InvalidValueError)
    end
    
    it "can have custom value" do
        # given, when
        organization.set_custom_value "field_integration_id", "the is a value"

        # then
        organization.custom_values.length.should eq 1
    end

    it "can have a custom numeric value" do
        # given, when
        organization.set_custom_value "price", 100

        # then
        organization.custom_values.length.should eq 1
        organization.custom_values[0].value.should eq "100"
    end

    it "a custom value can not be empty" do
        # given, when
        organization.set_custom_value "field_integration_id", ""

        # then
        organization.custom_values.length.should eq 0
    end
end

describe "OrganizationReference" do
    it "can be created from an organization" do
        # given
        org = MoveToGo::Organization.new
        org.name = "Lundalogik"
        org.integration_id = "123"

        # when
        ref = MoveToGo::OrganizationReference.from_organization(org)

        # then
        ref.is_a?(MoveToGo::OrganizationReference).should eq true
        ref.heading.should eq "Lundalogik"
        ref.integration_id.should eq "123"
    end

    it "can be created from an organization_reference" do
        # given
        orgref = MoveToGo::OrganizationReference.new
        orgref.heading = "Lundalogik"

        # when
        ref = MoveToGo::OrganizationReference.from_organization(orgref)

        # then
        ref.is_a?(MoveToGo::OrganizationReference).should eq true
    end

    it "is nil when created from nil" do
        # given, when
        ref = MoveToGo::OrganizationReference.from_organization(nil)

        # then
        ref.should eq nil
    end
end
