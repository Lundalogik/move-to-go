
require 'spec_helper'
require 'fruit_to_lime'
require 'nokogiri'
describe FruitToLime::SerializeHelper do

    describe "Validate according to xsd" do
        let(:validate_result) {
            i = FruitToLime::RootModel.new
            i.settings.with_organization do |s|
                s.set_custom_field({:integration_id=>"2", :title=>"cf title"})
                s.set_custom_field({:integration_id=>"3", :title=>"cf title2"})
            end
            o = FruitToLime::Organization.new
            o.name = "Ankeborgs bibliotek"
            o.with_source do |source|
                source.par_se('122345')
            end
            #o.source_ref = {:name=>'Go',:id=>"PASE122345"}
            o.add_tag("tag:bibliotek")
            o.add_tag("tag:Bj\u{00F6}rk")
            o.set_custom_field({:integration_id=>"2", :value=>"cf value"})
            o.set_custom_field({:integration_id=>"3", :value=>"cf Bj\u{00F6}rk"})
            o.with_postal_address do |addr|
                addr.city = "Ankeborg"
            end
            o.with_visit_address do |addr|
                addr.city = "Gaaseborg"
            end
            o.add_responsible_coworker({
                :integration_id => "1"
            })
            emp = o.add_employee({
                :integration_id => "1",
                :first_name => "Kalle",
                :last_name => "Anka"
            })
            emp.direct_phone_number = '234234234'
            emp.currently_employed = true
            i.organizations.push(o)
            xsd_file = File.join(File.dirname(__FILE__), '..', 'sample_data', 'schema0.xsd')
            
            xsd = Nokogiri::XML::Schema(File.read(xsd_file))
            #puts  FruitToLime::SerializeHelper::serialize(i)
            doc = Nokogiri::XML(FruitToLime::SerializeHelper::serialize(i,-1))
            xsd.validate(doc)
        }
        it "Should not contain validation errors" do
            expect(validate_result).to eq([])
        end
        
    end
end