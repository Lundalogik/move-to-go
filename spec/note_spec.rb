require "spec_helper"
require 'fruit_to_lime'

describe "Note" do
    let("note") {
        FruitToLime::Note.new
    }

    it "must have a text" do
        note.validate.length > 0
    end

    it "is valid when it has text, created_by and organization" do
        note.text = "They are very interested in the new deal (the one where you get a free bike as a gift)"
        note.created_by = FruitToLime::CoworkerReference.new( { :integration_id => "123", :heading => "kalle anka" } )
        note.organization = FruitToLime::OrganizationReference.new({ :integration_id => "456", :heading => "Lundalogik" })

        note.validate.should eq ""
    end

    it "will auto convert org to org.ref during assignment" do
        # given
        org = FruitToLime::Organization.new({:integration_id => "123", :name => "Beagle Boys!"})

        # when
        note.organization = org

        # then
        note.organization.is_a?(FruitToLime::OrganizationReference).should eq true
    end

    it "will auto convert person to person.ref during assignment" do
        # given
        person = FruitToLime::Person.new({:integration_id => "123" })
        person.parse_name_to_firstname_lastname_se "Billy Bob"

        # when
        note.person = person

        # then
        note.person.is_a?(FruitToLime::PersonReference).should eq true
    end

    it "will auto convert coworker to coworker.ref during assignment" do
        # given
        coworker = FruitToLime::Coworker.new({:integration_id => "123" })
        coworker.parse_name_to_firstname_lastname_se "Billy Bob"

        # when
        note.created_by = coworker

        # then
        note.created_by.is_a?(FruitToLime::CoworkerReference).should eq true
    end
end
