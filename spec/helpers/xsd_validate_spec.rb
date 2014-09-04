require 'spec_helper'
require 'go_import'
require 'nokogiri'
describe GoImport::SerializeHelper do
    describe "Validate according to xsd" do
        let(:validate_result) {
            i = GoImport::RootModel.new
            i.settings.with_organization do |s|
                s.set_custom_field({:integration_id=>"2", :title=>"cf title"})
                s.set_custom_field({:integration_id=>"3", :title=>"cf title2"})
            end
            i.add_coworker({
                :integration_id=>"123",
                :first_name=>"Kalle",
                :last_name=>"Anka",
                :email=>"kalle.anka@vonanka.com"
            })
            o = GoImport::Organization.new
            o.name = "Ankeborgs bibliotek"
            o.with_source do |source|
                source.par_se('122345')
            end
            #o.source_ref = {:name=>'Go',:id=>"PASE122345"}
            o.set_tag("tag:bibliotek")
            o.set_tag("tag:Bj\u{00F6}rk")
            o.set_custom_field({:integration_id=>"2", :value=>"cf value"})
            o.set_custom_field({:integration_id=>"3", :value=>"cf Bj\u{00F6}rk"})
            o.with_postal_address do |addr|
                addr.city = "Ankeborg"
            end
            o.with_visit_address do |addr|
                addr.city = "Gaaseborg"
            end
            coworker = GoImport::Coworker.new({:integration_id => "1", :first_name => "Vincent", :last_name => "Vega"})
            o.responsible_coworker = coworker

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
            doc = Nokogiri::XML(GoImport::SerializeHelper::serialize(i,-1))
            xsd.validate(doc)
        }
        it "Should not contain validation errors" do
            expect(validate_result).to eq([])
        end
    end
end
