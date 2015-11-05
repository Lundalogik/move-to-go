require 'spec_helper'
require 'go_import'
require 'nokogiri'
describe GoImport::SerializeHelper do
    describe "Validate according to xsd" do
        let(:validate_result) {
            rootmodel = GoImport::RootModel.new
            rootmodel.settings.with_organization do |s|
                s.set_custom_field({:integration_id => "2", :title => "cf title"})
                s.set_custom_field({:integration_id => "3", :title => "cf title2"})
            end
            coworker = GoImport::Coworker.new({
                                                  :integration_id => "123",
                                                  :first_name => "Kalle",
                                                  :last_name => "Anka",
                                                  :email => "kalle.anka@vonanka.com"
                                              })
            rootmodel.add_coworker(coworker)
            organization = GoImport::Organization.new
            organization.name = "Ankeborgs bibliotek"
            organization.with_source do |source|
                source.par_se('122345')
            end
            #organization.source_ref = {:name => 'Go',:id => "PASE122345"}
            organization.set_tag("tag:bibliotek")
            organization.set_tag("tag:Bj\u{00F6}rk")
            organization.set_custom_value("2", "cf value")
            organization.set_custom_value("3", "cf Bj\u{00F6}rk")
            organization.integration_id = "313"
            organization.with_postal_address do |addr|
                addr.city = "Ankeborg"
            end
            organization.with_visit_address do |addr|
                addr.city = "Gaaseborg"
            end
            coworker = GoImport::Coworker.new({:integration_id => "1", :first_name => "Vincent", :last_name => "Vega"})
            organization.responsible_coworker = coworker

            emp = GoImport::Person.new
            emp.integration_id = "1"
            emp.first_name = "Kalle"
            emp.last_name = "Anka"
            emp.direct_phone_number = '234234234'
            emp.currently_employed = true
            rootmodel.add_organization organization
            xsd_file = File.join(File.dirname(__FILE__), '..', 'sample_data', 'schema0.xsd')

            xsd = Nokogiri::XML::Schema(File.read(xsd_file))
            doc = Nokogiri::XML(GoImport::SerializeHelper::serialize(rootmodel, -1))
            xsd.validate(doc)
        }

        it "Should not contain validation errors" do
            expect(validate_result).to eq([])
        end
    end
end
