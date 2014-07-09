require "spec_helper"
require 'fruit_to_lime'

describe "Deal" do
    let(:deal){
        FruitToLime::Deal.new
    }

    it "will auto convert org to org.ref during assignment" do
        # given
        org = FruitToLime::Organization.new({:integration_id => "123", :name => "Lundalogik"})

        # when
        deal.customer = org

        # then
        deal.customer.is_a?(FruitToLime::OrganizationReference).should eq true
    end

    it "will auto convert coworker to coworker.ref during assignment" do
        # given
        coworker = FruitToLime::Coworker.new({:integration_id => "456", :first_name => "Billy", :last_name => "Bob"})

        # when
        deal.responsible_coworker = coworker

        # then
        deal.responsible_coworker.is_a?(FruitToLime::CoworkerReference).should eq true
    end

    it "will auto convert person to person.ref during assignment" do
        # given
        person = FruitToLime::Person.new({:integration_id => "123"})

        # when
        deal.customer_contact = person

        # then
        deal.customer_contact.is_a?(FruitToLime::PersonReference).should eq true
    end

    it "will fail on validation if name is empty" do
        # given
        deal.name = ""
        deal.status = "required status"

        # when, then
        deal.validate.length.should be > 0
    end

    it "will fail on validation if name is nil" do
        # given
        deal.name = nil
        deal.status = "required status"

        # when, then
        deal.validate.length.should be > 0
    end

    it "will fail on validation if status dont have a status reference" do
        # given
        deal.name = "Deal must have a name"
        # this will create a status with a status_reference
        deal.status = "Driv"

        # when
        # and this will set the reference to nil (this will probably
        # never happen in the real world).
        deal.status.status_reference = nil

        # then
        deal.validate.length.should be > 0
    end

    it "will fail on validation if status has an invalid status reference" do
        # given
        deal.name = "Deal must have a name"
        deal.status = ""

        # when, then
        deal.validate.length.should be > 0
    end

    it "should convert value strings that looks like number to number" do
        # given
        deal.name = "The deal with a strange value"

        # when
        deal.value = "357 000"

        # then
        deal.value.should eq "357000"
    end

    it "should raise invalidvalueerror if value is not a number" do
        # given
        deal.name = "The deal with an invalid value"

        # when, then
        expect {
            deal.value = "Im not a number"
        }.to raise_error(FruitToLime::InvalidValueError)
    end

    it "should set value if value is an integer" do
        # given
        deal.name = "The new deal"

        # when
        deal.value = "100"

        # then
        deal.value.should eq "100"
    end

    it "should set value if value is a float" do
        # given
        deal.name = "The new deal"

        # when
        deal.value = "100.10"

        # then
        deal.value.should eq "100.10"
    end

    it "should set value to 0 if value is nil" do
        # given
        deal.name = "The new deal"

        # when
        deal.value = nil

        # then
        deal.value.should eq 0
    end

    it "should set status_reference from status_setting" do
        # This case should be used when the status is defined in the rootmodel

        # given
        deal.name = "Deal with status from deal_status_setting"
        deal_status_setting = FruitToLime::DealStatusSetting.new({:integration_id => "123", :label => "Driv"})

        # when
        deal.status = deal_status_setting

        # then
        deal.status.is_a?(FruitToLime::DealStatus).should eq true
        deal.status.status_reference.is_a?(FruitToLime::DealStatusReference).should eq true
        deal.status.status_reference.label.should eq "Driv"
        deal.status.status_reference.integration_id.should eq "123"
    end

    it "should set status_reference from label if status is a string" do
        # This case should be used when the status is already defined
        # in the appliation and is referenced by label

        # given
        deal.name = "Deal with status from label"

        # when
        deal.status = "Driv"

        # then
        deal.status.is_a?(FruitToLime::DealStatus).should eq true
        deal.status.status_reference.is_a?(FruitToLime::DealStatusReference).should eq true
        deal.status.status_reference.label.should eq "Driv"
        deal.status.status_reference.id.nil?.should eq true
    end

    it "should set status_reference from id if status is an integer" do
        # This case should be used when the status is already defined
        # in the application and is referenced by id

        # given
        deal.name = "Deal with status from id"

        # when
        deal.status = 123

        # then
        deal.status.is_a?(FruitToLime::DealStatus).should eq true
        deal.status.status_reference.is_a?(FruitToLime::DealStatusReference).should eq true
        deal.status.status_reference.label.nil?.should eq true
        deal.status.status_reference.id.should eq "123"
    end

    it "should raise error if status reference cant be created" do
        # given
        deal.name = "Deal with failed status"

        # when, then
        expect {
            deal.status = FruitToLime::DealStatus.new({:id => 123})
        }.to raise_error(FruitToLime::InvalidDealStatusError)
    end

end
