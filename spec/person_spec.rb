require "spec_helper"
require 'fruit_to_lime'

describe "Person" do
    let(:person) {
        FruitToLime::Person.new
    }

    it "can set a customfield" do
        person.set_custom_field({:integration_id=>'the key',
            :title=> 'the title',
            :value=> 'the value'})

        field = person.custom_fields[0]
        field.integration_id.should eq 'the key'
        field.title.should eq 'the title'
        field.value.should eq 'the value'
    end

    it "will set custom field with same integration_id to the last value" do
        person.set_custom_field({:integration_id=>'the key',
            :title=> 'the title',
            :value=> 'the value'})

        person.set_custom_field({:integration_id=>'the key',
            :title=> 'the title 2',
            :value=> 'the value 2'})
        person.custom_fields.length.should eq 1 
        field = person.custom_fields[0]
        field.integration_id.should eq 'the key'
        field.title.should eq 'the title 2'
        field.value.should eq 'the value 2'
    end

    it "will set custom field with same id to the last value" do
        person.set_custom_field({:id=>'the id',
            :title=> 'the title',
            :value=> 'the value'})

        person.set_custom_field({:id=>'the id',
            :title=> 'the title 2',
            :value=> 'the value 2'})
        person.custom_fields.length.should eq 1 
        field = person.custom_fields[0]
        field.id.should eq 'the id'
        field.title.should eq 'the title 2'
        field.value.should eq 'the value 2'
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

