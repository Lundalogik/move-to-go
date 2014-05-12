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
end
