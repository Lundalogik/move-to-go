require "spec_helper"
require 'fruit_to_lime'

describe "Deal" do
    let(:deal){
        FruitToLime::Deal.new
    }

    it "can attach a current status" do
        deal.with_status do |status|
            status.label = 'xyz'
            status.id = '123'
            status.date = DateTime.now
            status.note = 'ho ho'
        end
    end

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
        deal.name = "The big deal"

        # when, then
        deal.validate.should eq ""
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
end
