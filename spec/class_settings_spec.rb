require "spec_helper"
require 'go_import'

describe "ClassSettings" do
    let(:class_settings) {
        GoImport::ClassSettings.new
    }

    it "can set custom field and if there is already an existing custom field, then it is overwritten." do
        class_settings.set_custom_field({:integration_id => "link_to_bi_system", :title => "Link to BI system"})
        class_settings.set_custom_field({:integration_id => "link_to_bi_system", :title => "Link to BI system 2"})
        class_settings.custom_fields.length.should eq 1
        class_settings.custom_fields[0].title.should eq "Link to BI system 2"
    end

    it "should not allow new custom fields without id and integration id" do
        begin
            class_settings.set_custom_field({:integration_id => "", :id => "", :title => "Link to BI system"})
        rescue
        end

        class_settings.custom_fields.length.should eq 0
    end

    it "should allow new custom field with integration_id" do
        class_settings.set_custom_field({:integration_id => "link_to_bi_system", :title => "Link to BI system"})
        class_settings.custom_fields.length.should eq 1
        class_settings.custom_fields[0].title.should eq "Link to BI system"
    end

    it "should allow new custom field with id" do
        class_settings.set_custom_field({:id => "123", :title => "Link to BI system"})
        class_settings.custom_fields.length.should eq 1
        class_settings.custom_fields[0].title.should eq "Link to BI system"
    end
end

