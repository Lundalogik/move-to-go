require "spec_helper"
require 'go_import'

describe "History" do
    let("history") {
        GoImport::History.new
    }

    it "must have a text" do
        history.validate.length.should be > 0
    end

    it "is valid when it has text, created_by and organization" do
        # given
        history.text = "They are very interested in the new deal (the one where you get a free bike as a gift)"
        history.created_by = GoImport::Coworker.new( { :integration_id => "123", :heading => "kalle anka" } )
        history.organization = GoImport::Organization.new({ :integration_id => "456", :heading => "Lundalogik" })

        # when, then
        history.validate.should eq ""
    end

    it "is valid when it has text, created_by and person" do
        # given
        history.text = "They are very interested in the new deal (the one where you get a free bike as a gift)"
        history.created_by = GoImport::Coworker.new( { :integration_id => "123", :heading => "kalle anka" } )
        history.person = GoImport::Person.new({ :integration_id => "456", :heading => "Billy Bob" })

        # when, then
        history.validate.should eq ""
    end

    it "is valid when it has text, created_by and deal" do
        # given
        history.text = "They are very interested in the new deal (the one where you get a free bike as a gift)"
        history.created_by = GoImport::Coworker.new( { :integration_id => "123", :heading => "kalle anka" } )
        history.deal = GoImport::Deal.new({ :integration_id => "456", :heading => "The new deal" })

        # when, then
        history.validate.should eq ""
    end

    it "is invalid if no history has no attached objects" do
        # given
        history.text = "They are very interested in the new deal (the one where you get a free bike as a gift)"
        history.created_by = GoImport::Coworker.new( { :integration_id => "123", :heading => "kalle anka" } )

        # when, then
        history.validate.length.should be > 0
    end

    it "will set organization ref when organization is assigned" do
        # given
        org = GoImport::Organization.new({:integration_id => "123", :name => "Beagle Boys!"})

        # when
        history.organization = org

        # then
        history.organization.is_a?(GoImport::Organization).should eq true
        history.instance_variable_get(:@organization_reference).is_a?(GoImport::OrganizationReference).should eq true
    end

    it "will set person ref when person is assigned" do
        # given
        person = GoImport::Person.new({:integration_id => "123" })
        person.parse_name_to_firstname_lastname_se "Billy Bob"

        # when
        history.person = person

        # then
        history.person.is_a?(GoImport::Person).should eq true
        history.instance_variable_get(:@person_reference).is_a?(GoImport::PersonReference).should eq true
    end

    it "will set coworker ref when coworker is assigned" do
        # given
        coworker = GoImport::Coworker.new({:integration_id => "123" })
        coworker.parse_name_to_firstname_lastname_se "Billy Bob"

        # when
        history.created_by = coworker

        # then
        history.created_by.is_a?(GoImport::Coworker).should eq true
        history.instance_variable_get(:@created_by_reference).is_a?(GoImport::CoworkerReference).should eq true
    end

    it "will set deal ref when deal is assigned" do
        # given
        deal = GoImport::Deal.new({:integration_id => "123" })
        deal.name = "The new deal"

        # when
        history.deal = deal

        # then
        history.deal.is_a?(GoImport::Deal).should eq true
        history.instance_variable_get(:@deal_reference).is_a?(GoImport::DealReference).should eq true
    end

    it "should have Comment as default classification" do
        # then
        history.classification.should eq GoImport::HistoryClassification::Comment
    end

    it "should not accept invalid classifications" do
        # when, then
        expect {
            history.classification = "hubbabubba"
        }.to raise_error(GoImport::InvalidHistoryClassificationError)
    end

    it "should remove form feed from text" do
        # given
        textWithFormFeed = "Text with form feed"
        textWithoutFormFeed = "Text with form feed"

        # when
        history.text = textWithFormFeed

        # then
        history.text.should eq textWithoutFormFeed
    end

    it "should remove vertical tab from text" do
        # given
        textWithVerticalTab = "Text with \vvertical tab"
        textWithoutVerticalTab = "Text with vertical tab"

        # when
        history.text = textWithVerticalTab

        # then
        history.text.should eq textWithoutVerticalTab
    end

    it "should remove backspace from text" do
        # given
        textWithBackSpace = "Text with \bbackspace"
        textWithoutBackSpace = "Text with backspace"

        # when
        history.text = textWithBackSpace

        # then
        history.text.should eq textWithoutBackSpace
    end    
end
