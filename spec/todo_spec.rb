require "spec_helper"
require 'move-to-go'

describe "Todo" do
    let("todo") {
        MoveToGo::Todo.new
    }

    it "must have a text" do
        todo.validate.length.should be > 0
    end

    it "is valid when it has text, created_by, assigned_coworker, date_start, date_start_has_time and organization" do
        # given
        todo.text = "They are very interested in the new deal (the one where you get a free bike as a gift)"
        todo.created_by = MoveToGo::Coworker.new( { :integration_id => "123", :heading => "kalle anka" } )
        todo.organization = MoveToGo::Organization.new({ :integration_id => "456", :heading => "Lundalogik" })
        todo.assigned_coworker = MoveToGo::Coworker.new( { :integration_id => "123", :heading => "kalle anka" } )
        todo.date_start = "2011-01-01"
        todo.date_start_has_time = false

        # when, then
        todo.validate.should eq ""
    end

    it "is valid when it has text, created_by, assigned_coworker, date_start, date_start_has_time, org and person" do
        # given
        todo.text = "They are very interested in the new deal (the one where you get a free bike as a gift)"
        todo.created_by = MoveToGo::Coworker.new( { :integration_id => "123", :heading => "kalle anka" } )
        todo.organization = MoveToGo::Organization.new({ :integration_id => "456", :heading => "Lundalogik" })
        todo.person = MoveToGo::Person.new({ :integration_id => "456", :heading => "Billy Bob" })
        todo.assigned_coworker = MoveToGo::Coworker.new( { :integration_id => "123", :heading => "kalle anka" } )
        todo.date_start = "2011-01-01"
        todo.date_start_has_time = false

        # when, then
        todo.validate.should eq ""
    end

    it "is valid when it has text, created_by, assigned_coworker, date_start, date_start_has_time, org and deal" do
        # given
        todo.text = "They are very interested in the new deal (the one where you get a free bike as a gift)"
        todo.created_by = MoveToGo::Coworker.new( { :integration_id => "123", :heading => "kalle anka" } )
        todo.organization = MoveToGo::Organization.new({ :integration_id => "456", :heading => "Lundalogik" })
        todo.deal = MoveToGo::Deal.new({ :integration_id => "456", :heading => "The new deal" })
        todo.assigned_coworker = MoveToGo::Coworker.new( { :integration_id => "123", :heading => "kalle anka" } )
        todo.date_start = "2011-01-01"
        todo.date_start_has_time = false

        # when, then
        todo.validate.should eq ""
    end

    it "is invalid if no todo has no attached objects" do
        # given
        todo.text = "They are very interested in the new deal (the one where you get a free bike as a gift)"
        todo.created_by = MoveToGo::Coworker.new( { :integration_id => "123", :heading => "kalle anka" } )

        # when, then
        todo.validate.length.should be > 0
    end

    it "will set organization ref when organization is assigned" do
        # given
        org = MoveToGo::Organization.new({:integration_id => "123", :name => "Beagle Boys!"})

        # when
        todo.organization = org

        # then
        todo.organization.is_a?(MoveToGo::Organization).should eq true
        todo.instance_variable_get(:@organization_reference).is_a?(MoveToGo::OrganizationReference).should eq true
    end

    it "will set person ref when person is assigned" do
        # given
        person = MoveToGo::Person.new({:integration_id => "123" })
        person.parse_name_to_firstname_lastname_se "Billy Bob"

        # when
        todo.person = person

        # then
        todo.person.is_a?(MoveToGo::Person).should eq true
        todo.instance_variable_get(:@person_reference).is_a?(MoveToGo::PersonReference).should eq true
    end

    it "will set coworker ref when coworker is assigned" do
        # given
        coworker = MoveToGo::Coworker.new({:integration_id => "123" })
        coworker.parse_name_to_firstname_lastname_se "Billy Bob"

        # when
        todo.created_by = coworker

        # then
        todo.created_by.is_a?(MoveToGo::Coworker).should eq true
        todo.instance_variable_get(:@created_by_reference).is_a?(MoveToGo::CoworkerReference).should eq true
    end

    it "will set deal ref when deal is assigned" do
        # given
        deal = MoveToGo::Deal.new({:integration_id => "123" })
        deal.name = "The new deal"

        # when
        todo.deal = deal

        # then
        todo.deal.is_a?(MoveToGo::Deal).should eq true
        todo.instance_variable_get(:@deal_reference).is_a?(MoveToGo::DealReference).should eq true
    end

    it "should remove form feed from text" do
        # given
        textWithFormFeed = "Text with form feed"
        textWithoutFormFeed = "Text with form feed"

        # when
        todo.text = textWithFormFeed

        # then
        todo.text.should eq textWithoutFormFeed
    end

    it "should remove vertical tab from text" do
        # given
        textWithVerticalTab = "Text with \vvertical tab"
        textWithoutVerticalTab = "Text with vertical tab"

        # when
        todo.text = textWithVerticalTab

        # then
        todo.text.should eq textWithoutVerticalTab
    end

    it "should remove backspace from text" do
        # given
        textWithBackSpace = "Text with \bbackspace"
        textWithoutBackSpace = "Text with backspace"

        # when
        todo.text = textWithBackSpace

        # then
        todo.text.should eq textWithoutBackSpace
    end    
end
