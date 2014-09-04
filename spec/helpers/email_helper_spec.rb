require 'spec_helper'
require 'go_import'

describe GoImport::EmailHelper do
    it "should validate a common email address" do
        # given
        import_email = "apl@lundalogik.se"

        # when, then
        GoImport::EmailHelper.is_valid?(import_email).should eq true
    end

    it "should validate an address with firstname.lastname" do
        GoImport::EmailHelper.is_valid?("firstname.lastname@example.com").should eq true
    end

    it "should validate an address with lots of subdomains" do
        GoImport::EmailHelper.is_valid?("firstname.lastname@sub1.sub2.example.com").should eq true
    end

    it "should validate an address with some special chars" do
        GoImport::EmailHelper.is_valid?("firstname-lastname+=@sub1.sub2.example.com").should eq true
    end

    it "should validate an address with no top level domain" do
        GoImport::EmailHelper.is_valid?("firstname@example").should eq true
    end

    it "should not validate an invalid address" do
        GoImport::EmailHelper.is_valid?("hubbabubba").should eq false
    end
end
