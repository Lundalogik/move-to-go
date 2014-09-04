require 'spec_helper'
require 'go_import'

describe GoImport::Address do
    describe "Parse line with swedish zip and city into zipcode" do
        let (:zip_code) {
            address = GoImport::Address.new
            line = "114 45 STOCKHOLM"
            address.parse_zip_and_address_se(line).zip_code
        }
        it "should have zipcode equal to '114 45'" do
            zip_code.should eq '114 45'
        end
    end

    describe "Parse line with swedish zip and city into city" do
        let (:city){
            address = GoImport::Address.new
            line = "114 45 STOCKHOLM"
            address.parse_zip_and_address_se(line).city
        }
        it "should have city equal to 'STOCKHOLM'" do
            city.should eq 'STOCKHOLM'
        end
    end

    describe "Parse line with non-swedish zip and city assuming swedish format" do
        describe "praha example" do
            let (:parse_result){
                address = GoImport::Address.new
                line = "CZ-140 00 PRAHA 4"
                address.parse_zip_and_address_se(line)          
            }
            it "should be nil" do
                parse_result.should == nil
            end
        end
        describe "finnish example" do
            let (:parse_result){
                address = GoImport::Address.new
                line = "0511  HELSINKI"
                address.parse_zip_and_address_se(line)          
            }
            it "should be nil" do
                parse_result.should == nil
            end
        end
    end
end