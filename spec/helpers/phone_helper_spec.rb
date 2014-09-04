require 'spec_helper'
require 'go_import'

describe GoImport::PhoneHelper do
    before(:each) do
        GoImport::PhoneHelper.set_country_code(:se)
    end

    it "should parse phonenumbers" do
        # given, when
        nice_number = GoImport::PhoneHelper.parse_numbers("0709-685226")

        # then
        nice_number.should eq "+46709685226"
    end

    it "should parse multiple numbers with default delimiter" do
        # given
        source = "046 - 270 48 00, 0709-685226"

        # when
        home, mobile = GoImport::PhoneHelper.parse_numbers(source)

        # then
        home.should eq "+46462704800"
        mobile.should eq "+46709685226"
    end

    it "should parse multiple numbers with custom delimiter" do
        # given
        source = "046 - 270 48 00/ 0709-685226"

        # when
        home, mobile = GoImport::PhoneHelper.parse_numbers(source, '/')

        # then
        home.should eq "+46462704800"
        mobile.should eq "+46709685226"
    end

    it "should parse numbers with different delimiters" do
        # given
        source1 = "046 - 270 48 00/ 0709-685226"
        source2 = "08-562 776 00, 070-73 85 180"
        source3 = "031-712 44 00\\\\ 0707 38 52 72/, 031 71 244 04"

        # when
        home1, mobile1 = GoImport::PhoneHelper.parse_numbers(source1, ['/', ',', "\\\\"])
        home2, mobile2 = GoImport::PhoneHelper.parse_numbers(source2, ['/', ',', "\\\\"])
        home3, mobile3, direct3 = GoImport::PhoneHelper.parse_numbers(source3, ['/', ',', "\\\\"])

        # then
        home1.should eq "+46462704800"
        mobile1.should eq "+46709685226"

        home2.should eq "+46856277600"
        mobile2.should eq "+46707385180"

        home3.should eq "+46317124400"
        mobile3.should eq "+46707385272"
        direct3.should eq "+46317124404"
    end

    it "should not mess with invalid numbers by default" do
        # given
        source = "im not a number"

        # when
        number = GoImport::PhoneHelper.parse_numbers(source)

        # then
        number.should eq "im not a number"
    end

    it "should not mess with invalid numbers unless strict mode" do
        # given
        source = "im not a number"

        # when
        number = GoImport::PhoneHelper.parse_numbers_strict(source)

        # then
        number.should eq ""
    end

    it "should parse foreign numbers" do
        # given
        source = "22 13 00 30"

        # when
        GoImport::PhoneHelper.set_country_code(:no)
        number = GoImport::PhoneHelper.parse_numbers(source)

        # then
        number.should eq "+4722130030"
    end
end
