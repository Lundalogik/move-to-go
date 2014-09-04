require "spec_helper"
require 'go_import'

describe "Note" do
    let("note") {
        GoImport::Note.new
    }

    it "must have a text" do
        note.validate.length.should be > 0
    end

    it "is valid when it has text, created_by and organization" do
        # given
        note.text = "They are very interested in the new deal (the one where you get a free bike as a gift)"
        note.created_by = GoImport::CoworkerReference.new( { :integration_id => "123", :heading => "kalle anka" } )
        note.organization = GoImport::OrganizationReference.new({ :integration_id => "456", :heading => "Lundalogik" })

        # when, then
        note.validate.should eq ""
    end

    it "is valid when it has text, created_by and person" do
        # given
        note.text = "They are very interested in the new deal (the one where you get a free bike as a gift)"
        note.created_by = GoImport::CoworkerReference.new( { :integration_id => "123", :heading => "kalle anka" } )
        note.person = GoImport::Person.new({ :integration_id => "456", :heading => "Billy Bob" })

        # when, then
        note.validate.should eq ""
    end

    it "is valid when it has text, created_by and deal" do
        # given
        note.text = "They are very interested in the new deal (the one where you get a free bike as a gift)"
        note.created_by = GoImport::CoworkerReference.new( { :integration_id => "123", :heading => "kalle anka" } )
        note.deal = GoImport::Deal.new({ :integration_id => "456", :heading => "The new deal" })

        # when, then
        note.validate.should eq ""
    end

    it "is invalid if no note has no attached objects" do
        # given
        note.text = "They are very interested in the new deal (the one where you get a free bike as a gift)"
        note.created_by = GoImport::CoworkerReference.new( { :integration_id => "123", :heading => "kalle anka" } )

        # when, then
        note.validate.length.should be > 0
    end

    it "will auto convert org to org.ref during assignment" do
        # given
        org = GoImport::Organization.new({:integration_id => "123", :name => "Beagle Boys!"})

        # when
        note.organization = org

        # then
        note.organization.is_a?(GoImport::OrganizationReference).should eq true
    end

    it "will auto convert person to person.ref during assignment" do
        # given
        person = GoImport::Person.new({:integration_id => "123" })
        person.parse_name_to_firstname_lastname_se "Billy Bob"

        # when
        note.person = person

        # then
        note.person.is_a?(GoImport::PersonReference).should eq true
    end

    it "will auto convert coworker to coworker.ref during assignment" do
        # given
        coworker = GoImport::Coworker.new({:integration_id => "123" })
        coworker.parse_name_to_firstname_lastname_se "Billy Bob"

        # when
        note.created_by = coworker

        # then
        note.created_by.is_a?(GoImport::CoworkerReference).should eq true
    end

    it "will auto convert deal to deal.ref during assignment" do
        # given
        deal = GoImport::Deal.new({:integration_id => "123" })
        deal.name = "The new deal"

        # when
        note.deal = deal

        # then
        note.deal.is_a?(GoImport::DealReference).should eq true
    end

    it "should have Comment as default classification" do
        # then
        note.classification.should eq GoImport::NoteClassification::Comment
    end

    it "should not accept invalid classifications" do
        # when, then
        expect {
            note.classification = "hubbabubba"
        }.to raise_error(GoImport::InvalidNoteClassificationError)
    end
end
