require "spec_helper"
require 'fruit_to_lime'

describe "Person" do
    let(:person) {
        FruitToLime::Person.new
    }

    it "can set a customfield" do
        person.set_custom_field({:integration_id=>'the key',
            :value=> 'the value'})

        value = person.custom_values[0]
        field = value.field
        field.integration_id.should eq 'the key'
        value.value.should eq 'the value'
    end

    it "will set custom field with same integration_id to the last value" do
        person.set_custom_field({:integration_id=>'the key',
            :value=> 'the value'})

        person.set_custom_field({:integration_id=>'the key',
            :value=> 'the value 2'})
        value = person.custom_values[0]
        field = value.field

        person.custom_values.length.should eq 1 
        field.integration_id.should eq 'the key'
        value.value.should eq 'the value 2'
    end

    it "will set custom field with same id to the last value" do
        person.set_custom_field({:id=>'the id',
            :value=> 'the value'})

        person.set_custom_field({:id=>'the id',
            :value=> 'the value 2'})
        value = person.custom_values[0]
        field = value.field

        person.custom_values.length.should eq 1 
        field.id.should eq 'the id'
        value.value.should eq 'the value 2'
    end

    it "will only set tag once" do
        person.set_tag('tag1')
        person.set_tag('tag1')
        person.tags.length.should eq 1 
        tag = person.tags[0]
        tag.value.should eq 'tag1'
    end

    it "should have a firstname if no lastname" do
        person.first_name = "Vincent"
        person.last_name = nil

        error = person.validate
        error.should be_empty
    end

    it "should be currently employed if nothing specified" do
        expect(person.currently_employed).to eq(true)
    end

    it "should have a lastname if no firstname" do
        person.first_name = String.new
        person.last_name = "Vega"

        error = person.validate
        error.should be_empty
    end

    it "shouldnt pass validation with no firstname and lastname" do
        person.first_name = String.new
        person.last_name = nil

        error = person.validate
        error.should start_with("A firstname or lastname is required for person")
    end
end

