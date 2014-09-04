require "spec_helper"
require 'go_import'

describe "Documents" do
    let(:documents) {
        GoImport::Documents.new
    }

    it "can add a new link" do
        # given
        link = GoImport::Link.new
        link.integration_id = "123key"
        link.url = "http://dropbox.com/files/readme.txt"

        # when
        documents.add_link link

        # then
        documents.find_link_by_integration_id("123key").url.should eq "http://dropbox.com/files/readme.txt"
        documents.links.length.should eq 1
    end

    it "will not add a new link when a link with the same integration_id already exists" do
        # given
        documents.add_link({ :integration_id => "123", :url => "http://dropbox.com" })
        documents.links.length.should eq 1

        # when, then
        expect {
            documents.add_link({ :integration_id => "123", :url => "http://drive.google.com" })
        }.to raise_error(GoImport::AlreadyAddedError)
        documents.links.length.should eq 1
        documents.find_link_by_integration_id("123").url.should eq "http://dropbox.com"
    end

end

