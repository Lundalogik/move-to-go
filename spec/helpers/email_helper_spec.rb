require 'spec_helper'
require 'fruit_to_lime'

describe FruitToLime::EmailHelper do
    it "should validate a common email address" do
        # given
        import_email = "apl@lundalogik.se"

        # when, then
        FruitToLime::EmailHelper.is_valid?(import_email).should eq true
    end

    it "should validate an address with firstname.lastname" do
        FruitToLime::EmailHelper.is_valid?("firstname.lastname@example.com").should eq true
    end

    it "should validate an address with lots of subdomains" do
        FruitToLime::EmailHelper.is_valid?("firstname.lastname@sub1.sub2.example.com").should eq true
    end

    it "should validate an address with some special chars" do
        FruitToLime::EmailHelper.is_valid?("firstname-lastname+=@sub1.sub2.example.com").should eq true
    end

    it "should validate an address with no top level domain" do
        FruitToLime::EmailHelper.is_valid?("firstname@example").should eq true
    end

    it "should not validate an invalid address" do
        FruitToLime::EmailHelper.is_valid?("hubbabubba").should eq false
    end
end
