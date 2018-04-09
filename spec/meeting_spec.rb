require "spec_helper"
require 'move-to-go'

describe "Meeting" do
    let("meeting") {
        MoveToGo::Meeting.new
    }

    it "must have a text" do
        meeting.validate.length.should be > 0
    end

    it "is valid when it has attributes and organization" do
        # given
        meeting.heading = "They are very interested in the new deal (the one where you get a free bike as a gift)"
        meeting.created_by = MoveToGo::Coworker.new( { :integration_id => "123", :heading => "kalle anka" } )
        meeting.organization = MoveToGo::Organization.new({ :integration_id => "456", :heading => "Lundalogik" })
        meeting.assigned_coworker = MoveToGo::Coworker.new( { :integration_id => "123", :heading => "kalle anka" } )
        meeting.date_start = "2011-01-01 10:00"
        meeting.date_stop = "2011-01-01 12:00"
        meeting.date_start_has_time = true

        # when, then
        meeting.validate.should eq ""
    end

    it "is valid when it has text, created_by, assigned_coworker, date_start, date_start_has_time, org and person" do
        # given
        meeting.heading = "They are very interested in the new deal (the one where you get a free bike as a gift)"
        meeting.created_by = MoveToGo::Coworker.new( { :integration_id => "123", :heading => "kalle anka" } )
        meeting.organization = MoveToGo::Organization.new({ :integration_id => "456", :heading => "Lundalogik" })
        meeting.person = MoveToGo::Person.new({ :integration_id => "456", :heading => "Billy Bob" })
        meeting.assigned_coworker = MoveToGo::Coworker.new( { :integration_id => "123", :heading => "kalle anka" } )
        meeting.date_start = "2011-01-01 10:00"
        meeting.date_stop = "2011-01-01 12:00"
        meeting.date_start_has_time = true

        # when, then
        meeting.validate.should eq ""
    end

    it "is valid when it has text, created_by, assigned_coworker, date_start, date_start_has_time, org and deal" do
        # given
        meeting.heading = "They are very interested in the new deal (the one where you get a free bike as a gift)"
        meeting.created_by = MoveToGo::Coworker.new( { :integration_id => "123", :heading => "kalle anka" } )
        meeting.organization = MoveToGo::Organization.new({ :integration_id => "456", :heading => "Lundalogik" })
        meeting.deal = MoveToGo::Deal.new({ :integration_id => "456", :heading => "The new deal" })
        meeting.assigned_coworker = MoveToGo::Coworker.new( { :integration_id => "123", :heading => "kalle anka" } )
        meeting.date_start = "2011-01-01 10:00"
        meeting.date_stop = "2011-01-01 12:00"
        meeting.date_start_has_time = true

        # when, then
        meeting.validate.should eq ""
    end

    it "is invalid if no meeting has no attached objects" do
        # given
        meeting.text = "They are very interested in the new deal (the one where you get a free bike as a gift)"
        meeting.created_by = MoveToGo::Coworker.new( { :integration_id => "123", :heading => "kalle anka" } )

        # when, then
        meeting.validate.length.should be > 0
    end

    it "will set organization ref when organization is assigned" do
        # given
        org = MoveToGo::Organization.new({:integration_id => "123", :name => "Beagle Boys!"})

        # when
        meeting.organization = org

        # then
        meeting.organization.is_a?(MoveToGo::Organization).should eq true
        meeting.instance_variable_get(:@organization_reference).is_a?(MoveToGo::OrganizationReference).should eq true
    end

    it "will set person ref when person is assigned" do
        # given
        person = MoveToGo::Person.new({:integration_id => "123" })
        person.parse_name_to_firstname_lastname_se "Billy Bob"

        # when
        meeting.person = person

        # then
        meeting.person.is_a?(MoveToGo::Person).should eq true
        meeting.instance_variable_get(:@person_reference).is_a?(MoveToGo::PersonReference).should eq true
    end

    it "will set coworker ref when coworker is assigned" do
        # given
        coworker = MoveToGo::Coworker.new({:integration_id => "123" })
        coworker.parse_name_to_firstname_lastname_se "Billy Bob"

        # when
        meeting.created_by = coworker

        # then
        meeting.created_by.is_a?(MoveToGo::Coworker).should eq true
        meeting.instance_variable_get(:@created_by_reference).is_a?(MoveToGo::CoworkerReference).should eq true
    end

    it "will set deal ref when deal is assigned" do
        # given
        deal = MoveToGo::Deal.new({:integration_id => "123" })
        deal.name = "The new deal"

        # when
        meeting.deal = deal

        # then
        meeting.deal.is_a?(MoveToGo::Deal).should eq true
        meeting.instance_variable_get(:@deal_reference).is_a?(MoveToGo::DealReference).should eq true
    end

    it "should remove form feed from text" do
        # given
        textWithFormFeed = "Text with form feed"
        textWithoutFormFeed = "Text with form feed"

        # when
        meeting.text = textWithFormFeed

        # then
        meeting.text.should eq textWithoutFormFeed
    end

    it "should remove vertical tab from text" do
        # given
        textWithVerticalTab = "Text with \vvertical tab"
        textWithoutVerticalTab = "Text with vertical tab"

        # when
        meeting.text = textWithVerticalTab

        # then
        meeting.text.should eq textWithoutVerticalTab
    end

    it "should remove backspace from text" do
        # given
        textWithBackSpace = "Text with \bbackspace"
        textWithoutBackSpace = "Text with backspace"

        # when
        meeting.text = textWithBackSpace

        # then
        meeting.text.should eq textWithoutBackSpace
    end    
end
