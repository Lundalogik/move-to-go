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
        note.created_by = GoImport::Coworker.new( { :integration_id => "123", :heading => "kalle anka" } )
        note.organization = GoImport::Organization.new({ :integration_id => "456", :heading => "Lundalogik" })

        # when, then
        note.validate.should eq ""
    end

    it "is valid when it has text, created_by and person" do
        # given
        note.text = "They are very interested in the new deal (the one where you get a free bike as a gift)"
        note.created_by = GoImport::Coworker.new( { :integration_id => "123", :heading => "kalle anka" } )
        note.person = GoImport::Person.new({ :integration_id => "456", :heading => "Billy Bob" })

        # when, then
        note.validate.should eq ""
    end

    it "is valid when it has text, created_by and deal" do
        # given
        note.text = "They are very interested in the new deal (the one where you get a free bike as a gift)"
        note.created_by = GoImport::Coworker.new( { :integration_id => "123", :heading => "kalle anka" } )
        note.deal = GoImport::Deal.new({ :integration_id => "456", :heading => "The new deal" })

        # when, then
        note.validate.should eq ""
    end

    it "is invalid if no note has no attached objects" do
        # given
        note.text = "They are very interested in the new deal (the one where you get a free bike as a gift)"
        note.created_by = GoImport::Coworker.new( { :integration_id => "123", :heading => "kalle anka" } )

        # when, then
        note.validate.length.should be > 0
    end

    it "will set organization ref when organization is assigned" do
        # given
        org = GoImport::Organization.new({:integration_id => "123", :name => "Beagle Boys!"})

        # when
        note.organization = org

        # then
        note.organization.is_a?(GoImport::Organization).should eq true
        note.instance_variable_get(:@organization_reference).is_a?(GoImport::OrganizationReference).should eq true
    end

    it "will set person ref when person is assigned" do
        # given
        person = GoImport::Person.new({:integration_id => "123" })
        person.parse_name_to_firstname_lastname_se "Billy Bob"

        # when
        note.person = person

        # then
        note.person.is_a?(GoImport::Person).should eq true
        note.instance_variable_get(:@person_reference).is_a?(GoImport::PersonReference).should eq true
    end

    it "will set coworker ref when coworker is assigned" do
        # given
        coworker = GoImport::Coworker.new({:integration_id => "123" })
        coworker.parse_name_to_firstname_lastname_se "Billy Bob"

        # when
        note.created_by = coworker

        # then
        note.created_by.is_a?(GoImport::Coworker).should eq true
        note.instance_variable_get(:@created_by_reference).is_a?(GoImport::CoworkerReference).should eq true
    end

    it "will set deal ref when deal is assigned" do
        # given
        deal = GoImport::Deal.new({:integration_id => "123" })
        deal.name = "The new deal"

        # when
        note.deal = deal

        # then
        note.deal.is_a?(GoImport::Deal).should eq true
        note.instance_variable_get(:@deal_reference).is_a?(GoImport::DealReference).should eq true
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

    it "should remove form feed from text" do
        # given
        textWithFormFeed = "Text with form feed"
        textWithoutFormFeed = "Text with form feed"

        # when
        note.text = textWithFormFeed

        # then
        note.text.should eq textWithoutFormFeed
    end

    it "should remove vertical tab from text" do
        # given
        textWithVerticalTab = "Text with \vvertical tab"
        textWithoutVerticalTab = "Text with vertical tab"

        # when
        note.text = textWithVerticalTab

        # then
        note.text.should eq textWithoutVerticalTab
    end

    it "should remove backspace from text" do
        # given
        textWithBackSpace = "Text with \bbackspace"
        textWithoutBackSpace = "Text with backspace"

        # when
        note.text = textWithBackSpace

        # then
        note.text.should eq textWithoutBackSpace
    end    
end
