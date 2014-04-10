require 'spec_helper'
require 'fruit_to_lime'

describe FruitToLime::SerializeHelper do

    describe "Serialize note" do
        let(:serialized) {
            n = FruitToLime::Note.new
            n.text = "text"
            FruitToLime::SerializeHelper::serialize(n,-1)
        }
        it "should contain text" do
            serialized.should match(/<Text>[\n ]*text[\n ]*<\/Text>/)
        end
        it "should contain start tag" do
            serialized.should match(/<Note>/)
        end
        it "should be utf-8" do
            serialized.encoding.should equal Encoding::UTF_8
        end
    end

    describe "Serialize note with xml inside" do
        let(:serialized) {
            n = FruitToLime::Note.new
            n.text = "<text>"
            FruitToLime::SerializeHelper::serialize(n,-1)
        }
        it "should contain encoded text" do
            serialized.should match(/<Text>[\n ]*&lt;text&gt;[\n ]*<\/Text>/)
        end
    end

    describe "Serialize custom value with xml inside" do
        let(:serialized) {
            v = FruitToLime::CustomValue.new
            v.value = "<text>"
            v.field = FruitToLime::CustomFieldReference.new()
            v.field.id = "1"
            FruitToLime::SerializeHelper::serialize(v,-1)
        }
        it "should contain encoded text" do
            serialized.should match(/<Value>[\n ]*&lt;text&gt;[\n ]*<\/Value>/)
        end

    end

    describe "Serialize without data" do
        let(:serialized) {
            p = FruitToLime::Person.new
            FruitToLime::SerializeHelper::serialize(p,-1)
        }
        it "should not contain fields that are not set" do
            serialized.should_not match(/<Email>/)
            serialized.should_not match(/<Position>/)
            serialized.should_not match(/<AlternativeEmail>/)
            serialized.should_not match(/<Tags>/)
            serialized.should_not match(/<CustomValues>/)
        end
        it "should be utf-8" do
            serialized.encoding.should equal Encoding::UTF_8
        end
    end

    describe "Serialize person" do
        let(:serialized) {
            p = FruitToLime::Person.new
            p.id = "1"
            p.first_name = "Kalle"
            p.last_name = "Anka"
            p.with_source do |source|
                source.par_se('122345')
            end
            #p.source_ref = {:name=>'Go',:id=>"PASE122345"}
            p.with_postal_address do |addr|
                addr.city = "Ankeborg"
            end
            p.currently_employed=true
            p.add_tag("tag:anka")
            p.add_tag("tag:Bj\u{00F6}rk")
            p.add_tag("tag:<Bj\u{00F6}rk>")
            p.set_custom_field({:integration_id=>"2", :value=>"cf value"})
            p.set_custom_field({:integration_id=>"3", :value=>"cf Bj\u{00F6}rk"})
            p.set_custom_field({:integration_id=>"4", :value=>"cf <Bj\u{00F6}rk>"})
            FruitToLime::SerializeHelper::serialize(p,-1)
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
            o.add_employee({
                :integration_id => "1",
                :first_name => "Kalle",
                :last_name => "Anka"
            })
            FruitToLime::SerializeHelper::serialize(o,-1)
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

    describe "Serialize goimport" do
        let(:serialized) {
            i = FruitToLime::RootModel.new
            o = FruitToLime::Organization.new
            o.name = "Ankeborgs bibliotek"
            i.organizations.push(o)
            FruitToLime::SerializeHelper::serialize(i,-1)
        }
        it "should contain name" do
            serialized.should match(/Ankeborgs bibliotek/)
        end
        it "should have version" do
            serialized.should match(/<GoImport Version='v2_0'/)
        end
        it "should be utf-8" do
            serialized.encoding.should equal Encoding::UTF_8
        end
    end
    describe "Get import rows" do
        describe "for person" do
            let(:import_rows) { FruitToLime::Person.new.get_import_rows }
            it "should contain integration id" do
                import_rows.should include({:id=>'integration_id', :name=>'Integration id', :type=>:string})
                import_rows.should include({:id=>'id', :name=>'Go id', :type=>:string})
            end
            it "should contain address" do
                expected = {:id=>'postal_address', :name=>'Postal address', :type=>:address,
                    :model=>[
                    {:id=>'street',:name=>'Street', :type=>:string},
                    {:id=>'zip_code',:name=>'Zip code', :type=>:string},
                    {:id=>'city',:name=>'City', :type=>:string},
                    {:id=>'country_code',:name=>'Country code', :type=>:string},
                    {:id=>'location',:name=>'Location', :type=>:string},
                    {:id=>'country_name',:name=>'Country name', :type=>:string},
                ]}
                import_rows.should include(expected)
            end
            it "should contain organization" do
                import_rows.should include({
                    :id=>'organization',
                    :name=>'Organization',
                    :type=>:organization_reference,
                    :model=>[
                        {:id=>'id', :name=>'Go id', :type=>:string},
                        {:id=>'integration_id', :name=>'Integration id', :type=>:string},
                        {:id=>'heading', :name=>'Heading', :type=>:string}
                        ]
                    })
            end
        end
        describe "for organization" do
            let(:import_rows) { FruitToLime::Organization.new.get_import_rows }
            it "should contain integration id" do
                import_rows.should include({:id=>'integration_id', :name=>'Integration id', :type=>:string})
                import_rows.should include({:id=>'id', :name=>'Go id', :type=>:string})
            end
            it "should contain address" do
                expected = {:id=>'postal_address', :name=>'Postal address', :type=>:address,
                    :model=>[
                        {:id=>'street',:name=>'Street', :type=>:string},
                        {:id=>'zip_code',:name=>'Zip code', :type=>:string},
                        {:id=>'city',:name=>'City', :type=>:string},
                        {:id=>'country_code',:name=>'Country code', :type=>:string},
                        {:id=>'location',:name=>'Location', :type=>:string},
                        {:id=>'country_name',:name=>'Country name', :type=>:string},
                    ]}
                import_rows.should include(expected)
            end
        end
    end
end
