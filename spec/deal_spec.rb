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

    it "will fail on validation if name, responsible and customer is empty" do
        # given, when
        deal.name = "The big deal"
        deal.customer = FruitToLime::Organization.new({:integration_id => "123", :name => "Lundalogik"})
        deal.responsible_coworker =
            FruitToLime::Coworker.new({ :integration_id => "456", :first_name => "Billy", :last_name => "Bob" })

        # then
        deal.validate.should eq ""
    end
end
