require "spec_helper"
require 'move-to-go'

describe "File" do
    let ("file") {
        MoveToGo::File.new
    }

    it "is valid when it has path, created_by and organization" do
        # given
        file.path = "spec/sample_data/offert.docx"
        file.created_by = MoveToGo::CoworkerReference.new( { :integration_id => "123" } )
        file.organization = MoveToGo::OrganizationReference.new( { :integration_id => "456" } )

        # when, then
        file.validate.should eq ""
    end

    it "is valid when it has name, path, created_by and deal" do
        # given
        file.name = "Offert"
        file.path = "spec/sample_data/offert.docx"
        file.created_by = MoveToGo::CoworkerReference.new( { :integration_id => "123" } )
        file.deal = MoveToGo::DealReference.new( { :integration_id => "456" } )

        # when, then
        file.validate.should eq ""
    end

    it "is valid when it has name, invalid path, created_by and deal but ignores the path" do
        # given
        file.name = "Offert"
        file.path = "c:\\mydocs\\offert.docx"
        file.created_by = MoveToGo::CoworkerReference.new( { :integration_id => "123" } )
        file.deal = MoveToGo::DealReference.new( { :integration_id => "456" } )

        # when, then
        file.validate(true).should eq ""
    end


    it "is not valid when it has path and deal" do
        # must have a created_by
        # given
        file.path = "c:\mydocs\deal.xls"
        file.deal = MoveToGo::DealReference.new({ :integration_id => "456", :heading => "The new deal" })

        # when, then
        file.validate.length.should be > 0
    end

    it "is not valid when it has path and created_by" do
        # must have an deal or organization
        # given
        file.path = "c:\mydocs\deal.xls"
        file.created_by = MoveToGo::CoworkerReference.new( { :integration_id => "123", :heading => "billy bob" } )

        # when, then
        file.validate.length.should be > 0
    end

    it "is not valid when it has deal and created_by" do
        # must have a path
        # given
        file.created_by = MoveToGo::CoworkerReference.new( { :integration_id => "123", :heading => "billy bob" } )
        file.deal = MoveToGo::DealReference.new({ :integration_id => "456", :heading => "The new deal" })

        # when, then
        file.validate.length.should be > 0
    end

    it "knows when a path is not relative" do
        # given
        file.path = "c:\\files\\myfile.doc"

        # when, then
        file.has_relative_path?().should eq false
    end

    it "knows when a path is relative" do
        # given
        file.path = "files/myfile.doc"

        # when, then
        file.has_relative_path?().should eq true
    end


    it "will use filename from path as name if name set not explicit" do
        # given
        file.path = "some/files/myfile.docx"
        file.name = ""

        # when, then
        file.name.should eq 'myfile.docx'
    end

    it "will use name as name if name is set explicit" do
        # given
        file.path = "some/files/myfile.docx"
        file.name = "This is a filename"

        # when, then
        file.name.should eq 'This is a filename'
    end

    it "will not have a name if name is not set or path is empty" do
        # given
        file.path = ""
        file.name = ""

        # when, then
        file.name.should eq ''
    end

    it "will set organization ref when organization is assinged" do
        # given
        org = MoveToGo::Organization.new({:integration_id => "123", :name => "Beagle Boys!"})

        # when
        file.organization = org

        # then
        file.organization.is_a?(MoveToGo::Organization).should eq true
        file.instance_variable_get(:@organization_reference).is_a?(MoveToGo::OrganizationReference).should eq true
    end

    it "will set deal ref when deal is assinged" do
        # given
        deal = MoveToGo::Deal.new({:integration_id => "123" })
        deal.name = "The new deal"

        # when
        file.deal = deal

        # then
        file.deal.is_a?(MoveToGo::Deal).should eq true
        file.instance_variable_get(:@deal_reference).is_a?(MoveToGo::DealReference).should eq true
    end

    it "will set coworker ref when coworker is assinged" do
        # given
        coworker = MoveToGo::Coworker.new({:integration_id => "123" })
        coworker.parse_name_to_firstname_lastname_se "Billy Bob"

        # when
        file.created_by = coworker

        # then
        file.created_by.is_a?(MoveToGo::Coworker).should eq true
        file.instance_variable_get(:@created_by_reference).is_a?(MoveToGo::CoworkerReference).should eq true
    end

    describe "is large" do
        before(:all) do
            n = 100
            File.open("spec/sample_data/large.mpeg", 'w') do |f| 
              contents = "x" * (1024*1024)
              n.to_i.times { f.write(contents) }
            end
        end
        
        after(:all) do
            File.delete "spec/sample_data/large.mpeg"
        end

        it "is not valid" do
            # must be less than 100 Mb
            file.path = "spec/sample_data/large.mpeg"
            file.created_by = MoveToGo::CoworkerReference.new( { :integration_id => "123" } )
            file.organization = MoveToGo::OrganizationReference.new( { :integration_id => "456" } )

            # when, then
            file.validate.length.should be > 0
        end
    end

end
