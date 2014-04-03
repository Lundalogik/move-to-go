require "spec_helper"
require 'fruit_to_lime'

describe "CustomField" do
    before (:all) do
        @custom_field = FruitToLime::CustomField.new({:id => 'the id',
            :integration_id=>'the key',
            :title=> 'the title',
            :value=> 'the value'})
    end

    it "is the same as a custom field with the same integration_id" do
        @custom_field.same_as?(FruitToLime::CustomField.new({:integration_id=>'the key',
            :title=> 'the title 2',
            :value=> 'the value 2'})).should eq true
    end

    it "is the same as a custom field with the same id" do
        @custom_field.same_as?(FruitToLime::CustomField.new({:id=>'the id',
            :title=> 'the title 2',
            :value=> 'the value 2'})).should eq true
    end

end

