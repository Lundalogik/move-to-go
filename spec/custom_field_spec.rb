require "spec_helper"
require 'go_import'

describe "CustomField" do
    before (:all) do
        @custom_field = GoImport::CustomField.new({:id => 'the id',
            :integration_id=>'the key',
            :value=> 'the value'})
    end

    it "is the same as a custom field with the same integration_id" do
        @custom_field.same_as?(GoImport::CustomField.new({:integration_id=>'the key',
            :value=> 'the value 2'})).should eq true
    end

    it "is the same as a custom field with the same id" do
        @custom_field.same_as?(GoImport::CustomField.new({:id=>'the id',
            :value=> 'the value 2'})).should eq true
    end

end

