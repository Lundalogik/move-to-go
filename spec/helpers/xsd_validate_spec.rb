require 'spec_helper'
require 'move-to-go'
require 'nokogiri'
describe MoveToGo::SerializeHelper do
    describe "Validate according to xsd" do
        let(:rootmodel) do
            rootmodel = MoveToGo::RootModel.new
            rootmodel.settings.with_organization do |s|
                s.set_custom_field({:integration_id => "2", :title => "cf title"})
                s.set_custom_field({:integration_id => "3", :title => "cf title2"})
            end
            rootmodel
        end

        let(:coworker) do
            MoveToGo::Coworker.new({
                :integration_id => "123",
                :first_name => "Kalle",
                :last_name => "Anka",
                :email => "kalle.anka@vonanka.com"
            })
        end
 
        let(:organization) do
            organization = MoveToGo::Organization.new
            organization.name = "Ankeborgs bibliotek"
            organization.with_source do |source|
                source.par_se('122345')
            end
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
            organization
        end

        let(:employee) do
            emp = MoveToGo::Person.new
            emp.integration_id = "12345"
            emp.first_name = "Kalle"
            emp.last_name = "Anka"
            emp.direct_phone_number = '234234234'
            emp.currently_employed = true
            emp
        end

        let(:deal) do
            deal = MoveToGo::Deal.new
            deal.integration_id = "42"
            deal.name = "foo"
            deal.offer_date = "2012-12-12T00:00:00"
            deal.order_date = "2012-12-01T00:00:00"
            deal.value = "0"
            deal.probability = "20"
            deal
        end

        let(:link) do
            link = MoveToGo::Link.new
            link.integration_id = "12"
            link.url = "https://go.lime-go.com"
            link
        end

        let(:file) do
            file = MoveToGo::File.new
            file.integration_id = "12"
            file.name = "smallfile.txt"
            file
        end

        it "Should not contain validation errors" do
            rootmodel.add_coworker(coworker)
            organization.responsible_coworker = MoveToGo::Coworker.new({:integration_id => "1", :first_name => "Vincent", :last_name => "Vega"})
            organization.add_employee employee
            rootmodel.add_organization organization

            doc = Nokogiri::XML(MoveToGo::SerializeHelper::serialize(rootmodel, -1))

            xsd_file = File.join(File.dirname(__FILE__), '..', 'sample_data', 'schema0.xsd')
            xsd = Nokogiri::XML::Schema(File.read(xsd_file))            
            expect(xsd.validate(doc)).to eq([])
        end

        it "Documents can have many references" do
            rootmodel.add_coworker(coworker)
            organization.add_employee employee
            rootmodel.add_organization organization
            deal.customer = organization
            rootmodel.add_deal deal
            
            link.deal = deal
            link.organization = organization
            link.person = employee
            rootmodel.add_link link

            file.deal = deal
            file.organization = organization
            file.person = employee
            rootmodel.add_file file

            doc = Nokogiri::XML(MoveToGo::SerializeHelper::serialize(rootmodel, -1))
            xsd_file = File.join(File.dirname(__FILE__), '..', 'sample_data', 'schema0.xsd')
            xsd = Nokogiri::XML::Schema(File.read(xsd_file))            
            expect(xsd.validate(doc)).to eq([])
        end

        it "valudate deals" do
            rootmodel.add_coworker(coworker)
            rootmodel.add_organization organization
            deal.customer = organization
            rootmodel.add_deal deal

            doc = Nokogiri::XML(MoveToGo::SerializeHelper::serialize(rootmodel, -1))
            xsd_file = File.join(File.dirname(__FILE__), '..', 'sample_data', 'schema0.xsd')
            xsd = Nokogiri::XML::Schema(File.read(xsd_file))            
            expect(xsd.validate(doc)).to eq([])
        end
    end
end
