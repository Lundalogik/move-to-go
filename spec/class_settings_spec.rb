require "spec_helper"
require 'fruit_to_lime'

describe "ClassSettings" do
    let(:class_settings) {
        FruitToLime::ClassSettings.new
    }

    it "can set custom field and if there is already an existing custom field, then it is overwritten." do
        class_settings.set_custom_field({:integration_id=>"link_to_bi_system", :title=>"Link to BI system"})
        class_settings.set_custom_field({:integration_id=>"link_to_bi_system", :title=>"Link to BI system 2"})
        class_settings.custom_fields.length.should eq 1
        class_settings.custom_fields[0].title.should eq "Link to BI system 2" 
    end

    it "can add custom field and if there is already an existing custom field, then an AlreadyAddedError will be raised (and nothing is added)." do
        class_settings.add_custom_field({:integration_id=>"link_to_bi_system", :title=>"Link to BI system"})
        expect { 
            class_settings.add_custom_field({:integration_id=>"link_to_bi_system", :title=>"Link to BI system 2"})
        }.to raise_error(FruitToLime::AlreadyAddedError)
        class_settings.custom_fields.length.should eq 1
        class_settings.custom_fields[0].title.should eq "Link to BI system" 
    end

end

