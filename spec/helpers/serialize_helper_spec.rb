require 'spec_helper'
require 'move-to-go'

describe MoveToGo::SerializeHelper do

    describe "Serialize history" do
        let(:serialized) {
            n = MoveToGo::History.new
            n.text = "text"
            MoveToGo::SerializeHelper::serialize(n,-1)
        }
        it "should contain text" do
            serialized.should match(/<Text>[\n ]*text[\n ]*<\/Text>/)
        end
        it "should contain start tag" do
            serialized.should match(/<History>/)
        end
        it "should be utf-8" do
            serialized.encoding.should equal Encoding::UTF_8
        end
    end

    describe "Serialize history with xml inside" do
        let(:serialized) {
            n = MoveToGo::History.new
            n.text = "<text>"
            MoveToGo::SerializeHelper::serialize(n,-1)
        }
        it "should contain encoded text" do
            serialized.should match(/<Text>[\n ]*&lt;text&gt;[\n ]*<\/Text>/)
        end
    end

    describe "Serialize custom value with xml inside" do
        let(:serialized) {
            v = MoveToGo::CustomValue.new
            v.value = "<text>"
            v.field = MoveToGo::CustomFieldReference.new()
            v.field.integration_id = "1"
            MoveToGo::SerializeHelper::serialize(v,-1)
        }
        it "should contain encoded text" do
            serialized.should match(/<Value>[\n ]*&lt;text&gt;[\n ]*<\/Value>/)
        end

    end

    describe "Serialize without data" do
        let(:serialized) {
            p = MoveToGo::Person.new
            MoveToGo::SerializeHelper::serialize(p,-1)
        }
        it "should not contain fields that are not set" do
            serialized.should_not match(/<Email>/)
            serialized.should_not match(/<Position>/)
            serialized.should_not match(/<AlternativeEmail>/)
            serialized.should_not match(/<CustomValues>/)
        end
        it "should be utf-8" do
            serialized.encoding.should equal Encoding::UTF_8
        end
    end

    describe "Serialize person" do
        let(:serialized) {
            p = MoveToGo::Person.new
            p.id = "1"
            p.first_name = "Kalle"
            p.last_name = "Anka"
            p.with_source do |source|
                source.par_se('122345')
            end
            #p.source_ref = {:name => 'Go',:id => "PASE122345"}
            p.with_postal_address do |addr|
                addr.city = "Ankeborg"
            end
            p.currently_employed=true
            p.set_tag("tag:anka")
            p.set_tag("tag:Bj\u{00F6}rk")
            p.set_tag("tag:<Bj\u{00F6}rk>")
            # p.set_custom_field({:integration_id => "2", :value => "cf value"})
            # p.set_custom_field({:integration_id => "3", :value => "cf Bj\u{00F6}rk"})
            # p.set_custom_field({:integration_id => "4", :value => "cf <Bj\u{00F6}rk>"})
            p.set_custom_value("2", "cf value")
            p.set_custom_value("3", "cf Bj\u{00F6}rk")
            p.set_custom_value("4", "cf <Bj\u{00F6}rk>")
            MoveToGo::SerializeHelper::serialize(p,-1)
        }
        it "should contain first and last name" do
            serialized.should match(/<FirstName>[\n ]*Kalle[\n ]*<\/FirstName>/)
            serialized.should match(/Anka/)
        end
        it "should contain currently_employed" do
            serialized.should match(/<CurrentlyEmployed>[\n ]*true[\n ]*<\/CurrentlyEmployed>/)
        end
        it "should tag name" do
            serialized.should match(/tag:anka/)
        end
        it "should contain address" do
            serialized.should match(/Ankeborg/)
        end
        it "should contain custom field" do
            serialized.should match(/cf value/)
        end
        it "should contain reference to source" do
            serialized.should match(/122345/)
        end
        it "should handle sv chars in tags" do
            serialized.should match(/tag:Bj\u{00F6}rk/)
        end
        it "should handle sv chars in custom value" do
            serialized.should match(/cf Bj\u{00F6}rk/)
        end
        it "should handle xml in tag" do
            serialized.should match(/tag:&lt;Bj\u{00F6}rk&gt;/)
        end
        it "should handle xml in custom value" do
            serialized.should match(/cf &lt;Bj\u{00F6}rk&gt;/)
        end
        it "should be utf-8" do
            serialized.encoding.should equal Encoding::UTF_8
        end
    end
    describe "Serialize organization" do
        let(:serialized) {
            organization = MoveToGo::Organization.new
            organization.name = "Ankeborgs bibliotek"
            organization.with_source do |source|
                source.par_se('122345')
            end
            #organization.source_ref = {:name => 'Go',:id => "PASE122345"}
            organization.set_tag("tag:bibliotek")
            organization.set_tag("tag:Bj\u{00F6}rk")
            organization.set_custom_value("2", "cf value")
            organization.set_custom_value("3", "cf Bj\u{00F6}rk")
            organization.with_postal_address do |addr|
                addr.city = "Ankeborg"
            end
            organization.with_visit_address do |addr|
                addr.city = "Gaaseborg"
            end
            organization.add_employee({
                :integration_id => "1",
                :first_name => "Kalle",
                :last_name => "Anka"
            })
            MoveToGo::SerializeHelper::serialize(organization, -1)
        }

        it "should contain name" do
            serialized.should match(/Ankeborgs bibliotek/)
        end
        it "should contain employee" do
            serialized.should match(/Kalle/)
            serialized.should match(/Anka/)
        end
        it "should contain address" do
            serialized.should match(/Ankeborg/)
            serialized.should match(/Gaaseborg/)
        end
        it "should tag name" do
            serialized.should match(/<Tag>[\n ]*tag:bibliotek[\n ]*<\/Tag>/)
        end
        it "should contain custom field" do
            serialized.should match(/cf value/)
            #puts serialized
        end
        it "should contain reference to source" do
            serialized.should match(/122345/)
        end
        it "should handle sv chars in tags" do
            serialized.should match(/tag:Bj\u{00F6}rk/)
        end
        it "should handle sv chars in custom value" do
            serialized.should match(/cf Bj\u{00F6}rk/)
        end
        it "should be utf-8" do
            serialized.encoding.should equal Encoding::UTF_8
        end
    end

    describe "Serialize MoveToGo" do
        let(:serialized) {
            rootmodel = MoveToGo::RootModel.new
            organization = MoveToGo::Organization.new
            organization.name = "Ankeborgs bibliotek"
            organization.integration_id = "123"
            rootmodel.add_organization organization
            MoveToGo::SerializeHelper::serialize(rootmodel, -1)
        }
        it "should contain name" do
            serialized.should match(/Ankeborgs bibliotek/)
        end
        it "should have version" do
            serialized.should match(/<GoImport Version='v3_0'/)
        end
        it "should be utf-8" do
            serialized.encoding.should equal Encoding::UTF_8
        end
    end
    describe "Get import rows" do
        describe "for person" do
            let(:import_rows) { MoveToGo::Person.new.get_import_rows }
            it "should contain integration id" do
                import_rows.should include({:id => 'integration_id', :name => 'Integration id', :type => :string})
                import_rows.should include({:id => 'id', :name => 'Go id', :type => :string})
            end
            it "should contain address" do
                expected = {:id => 'postal_address', :name => 'Postal address', :type => :address,
                    :model => [
                    {:id => 'street',:name => 'Street', :type => :string},
                    {:id => 'zip_code',:name => 'Zip code', :type => :string},
                    {:id => 'city',:name => 'City', :type => :string},
                    {:id => 'country_code',:name => 'Country code', :type => :string},
                    {:id => 'location',:name => 'Location', :type => :string},
                    {:id => 'country_name',:name => 'Country name', :type => :string},
                ]}
                import_rows.should include(expected)
            end
            it "should contain organization" do
                import_rows.should include({
                    :id => 'organization',
                    :name => 'Organization',
                    :type => :organization_reference,
                    :model => [
                        {:id => 'id', :name => 'Go id', :type => :string},
                        {:id => 'integration_id', :name => 'Integration id', :type => :string},
                        {:id => 'heading', :name => 'Heading', :type => :string}
                        ]
                    })
            end
        end
        describe "for organization" do
            let(:import_rows) { MoveToGo::Organization.new.get_import_rows }
            it "should contain integration id" do
                import_rows.should include({:id => 'integration_id', :name => 'Integration id', :type => :string})
                import_rows.should include({:id => 'id', :name => 'Go id', :type => :string})
            end
            it "should contain address" do
                expected = {:id => 'postal_address', :name => 'Postal address', :type => :address,
                    :model => [
                        {:id => 'street',:name => 'Street', :type => :string},
                        {:id => 'zip_code',:name => 'Zip code', :type => :string},
                        {:id => 'city',:name => 'City', :type => :string},
                        {:id => 'country_code',:name => 'Country code', :type => :string},
                        {:id => 'location',:name => 'Location', :type => :string},
                        {:id => 'country_name',:name => 'Country name', :type => :string},
                    ]}
                import_rows.should include(expected)
            end
        end
    end
end
