require "spec_helper"
require 'fruit_to_lime'

describe "Person" do
    before (:all) do
        @person = FruitToLime::Person.new
    end

    it "can set a customfield" do
        @person.set_custom_field({:integration_id=>'the key',
            :title=> 'the title',
            :value=> 'the value'})

        field = @person.custom_fields[0]
        field.integration_id.should eq 'the key'
        field.title.should eq 'the title'
        field.value.should eq 'the value'
    end

    it "should have a firstname if no lastname" do
        @person.first_name = "Vincent"
        @person.last_name = nil

        error = @person.validate
        error.should be_empty
    end

    it "should have a lastname if no firstname" do
        @person.first_name = String.new
        @person.last_name = "Vega"

        error = @person.validate
        error.should be_empty
    end

    it "shouldnt pass validation with no firstname and lastname" do
        @person.first_name = String.new
        @person.last_name = nil

        error = @person.validate
        error.should start_with("A firstname or lastname is required for person")
    end
end

