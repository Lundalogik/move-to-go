require "spec_helper"
require 'go_import'

describe "RootModel" do
    let(:rootmodel) {
        GoImport::RootModel.new
    }

    it "will contain integration coworker by default" do
        rootmodel.find_coworker_by_integration_id("import").first_name.should eq "Import"
        rootmodel.coworkers.length.should eq 1
    end

    it "can add a coworker from a hash" do
        rootmodel.add_coworker({
            :integration_id => "123key",
            :first_name => "Kalle",
            :last_name => "Anka",
            :email => "kalle.anka@vonanka.com"
        })
        rootmodel.find_coworker_by_integration_id("123key").first_name.should eq "Kalle"
        rootmodel.coworkers.length.should eq 2
    end

    it "can add a coworker from a new coworker" do
        coworker = GoImport::Coworker.new
        coworker.integration_id = "123key"
        coworker.first_name="Kalle"
        coworker.last_name="Anka"
        coworker.email = "kalle.anka@vonanka.com"
        rootmodel.add_coworker(coworker)
        rootmodel.find_coworker_by_integration_id("123key").first_name.should eq "Kalle"
        rootmodel.coworkers.length.should eq 2
    end

    it "will not add a new coworker when the coworker is already added (same integration id)" do
        rootmodel.add_coworker({
            :integration_id=>"123key",
            :first_name=>"Kalle",
            :last_name=>"Anka",
            :email=>"kalle.anka@vonanka.com"
        })
        rootmodel.coworkers.length.should eq 2
        expect {
            rootmodel.add_coworker({
                :integration_id=>"123key",
                :first_name=>"Knatte",
                :last_name=>"Anka",
                :email=>"knatte.anka@vonanka.com"
            })
        }.to raise_error(GoImport::AlreadyAddedError)
        rootmodel.find_coworker_by_integration_id("123key").first_name.should eq "Kalle"
        rootmodel.coworkers.length.should eq 2
    end

    it "can add an organization from hash" do
        rootmodel.add_organization({
                                       :integration_id => "123key",
                                       :name => "Beagle Boys"
        })
        rootmodel.find_organization_by_integration_id("123key").name.should eq "Beagle Boys"
        rootmodel.organizations.length.should eq 1
    end

    it "can add an organization from a new organization" do
        # given
        organization = GoImport::Organization.new
        organization.integration_id = "123key"
        organization.name = "Beagle Boys"

        # when
        rootmodel.add_organization(organization)

        # then
        rootmodel.find_organization_by_integration_id("123key").name.should eq "Beagle Boys"
        rootmodel.organizations.length.should eq 1
    end

    it "will not add a new organizations when the organizations is already added (same integration id)" do
        # given
        rootmodel.add_organization({
            :integration_id => "123key",
            :name => "Beagle Boys"
        })
        rootmodel.organizations.length.should eq 1
        rootmodel.find_organization_by_integration_id("123key").name.should eq "Beagle Boys"

        # when, then
        expect {
            rootmodel.add_organization({
                :integration_id => "123key",
                :name => "Beagle Boys 2"
            })
        }.to raise_error(GoImport::AlreadyAddedError)
        rootmodel.find_organization_by_integration_id("123key").name.should eq "Beagle Boys"
        rootmodel.organizations.length.should eq 1
    end

    it "will not add a organization without integration id" do
        # given
        org1 = GoImport::Organization.new
        org1.name = "Beagle Boys"

        # when, then
        expect {
            rootmodel.add_organization(org1)
        }.to raise_error(GoImport::IntegrationIDIsRequiredError)

       
    end

    it "can add a deal from hash" do
        rootmodel.add_deal({
                :integration_id => "123key",
                :name => "Big deal"
        })
        rootmodel.find_deal_by_integration_id("123key").name.should eq "Big deal"
        rootmodel.deals.length.should eq 1
    end

    it "can add a deal from a new deal" do
        # given
        deal = GoImport::Deal.new
        deal.integration_id = "123key"
        deal.name = "Big deal"

        # when
        rootmodel.add_deal(deal)

        # then
        rootmodel.find_deal_by_integration_id("123key").name.should eq "Big deal"
        rootmodel.deals.length.should eq 1
    end

    it "will set reponsible coworker to import_coworker if none specifed" do
        # given
        deal = GoImport::Deal.new
        deal.integration_id = "123key"
        deal.name = "Big deal"

        # when
        rootmodel.add_deal(deal)

        # then
        deal.responsible_coworker.integration_id.should eq rootmodel.import_coworker.integration_id
    end

    it "will not set reponsible coworker to import_coworker if specifed" do
        # given
        deal = GoImport::Deal.new
        deal.integration_id = "123key"
        deal.name = "Big deal"
        coworker = GoImport::Coworker.new
        coworker.integration_id = "123"
        deal.responsible_coworker = coworker

        # when
        rootmodel.add_deal(deal)

        # then
        deal.responsible_coworker.integration_id.should eq coworker.integration_id
    end

    it "will not add a new deal when the deal is already added (same integration id)" do
        # given
        rootmodel.add_deal({
            :integration_id => "123key",
            :name => "Big deal"
        })
        rootmodel.deals.length.should eq 1
        rootmodel.find_deal_by_integration_id("123key").name.should eq "Big deal"

        # when, then
        expect {
            rootmodel.add_deal({
                :integration_id => "123key",
                :name => "Bigger deal"
            })
        }.to raise_error(GoImport::AlreadyAddedError)
        rootmodel.find_deal_by_integration_id("123key").name.should eq "Big deal"
        rootmodel.deals.length.should eq 1
    end

    it "will add two deal without integration id" do
        # given
        deal1 = GoImport::Deal.new
        deal1.name = "The big deal"
        deal2 = GoImport::Deal.new
        deal2.name = "The even bigger deal"

        # when
        rootmodel.add_deal(deal1)
        rootmodel.add_deal(deal2)

        # then
        rootmodel.deals.length.should eq 2
    end    

    it "can add a note from hash" do
        rootmodel.add_note({
                               :integration_id => "123key",
                               :text => "This is a note"
        })
        rootmodel.find_note_by_integration_id("123key").text.should eq "This is a note"
        rootmodel.notes.length.should eq 1
    end

    it "can add a note from a new note" do
        # given
        note = GoImport::Note.new
        note.integration_id = "123key"
        note.text = "This is a note"

        # when
        rootmodel.add_note(note)

        # then
        rootmodel.find_note_by_integration_id("123key").text.should eq "This is a note"
        rootmodel.notes.length.should eq 1
    end

    it "will not add a nil note" do
        # given, when
        rootmodel.add_note(nil)

        # then
        rootmodel.notes.length.should eq 0
    end

    it "will not add a nil organization" do
        # given, when
        rootmodel.add_organization(nil)

        # then
        rootmodel.organizations.length.should eq 0
    end

    it "will not add a nil deal" do
        # given, when
        rootmodel.add_deal(nil)

        # then
        rootmodel.deals.length.should eq 0
    end

    it "will not add a nil coworker" do
        # given, when
        rootmodel.add_coworker(nil)

        # then
        # 1 since we always have the import coworker
        rootmodel.coworkers.length.should eq 1
    end

    it "will add a new link" do
        # given
        link = GoImport::Link.new
        link.integration_id = "123key"
        link.url = "http://dropbox.com/files/readme.txt"

        # when
        rootmodel.add_link link

        # then
        rootmodel.documents.find_link_by_integration_id("123key").url.should eq "http://dropbox.com/files/readme.txt"
        rootmodel.documents.links.length.should eq 1
    end

    it "will add a new file" do
        # given
        file = GoImport::File.new
        file.integration_id = "123key"
        file.path = "k:\kontakt\databas\dokument"

        # when
        rootmodel.add_file file

        # then
        rootmodel.documents.find_file_by_integration_id("123key").path.should eq "k:\kontakt\databas\dokument"
        rootmodel.documents.files.length.should eq 1
    end

    it "will not add a new organizations when the organizations is already added (same integration id)" do
        # given
        rootmodel.add_note({
            :integration_id => "123key",
            :text => "This is a note"
        })
        rootmodel.notes.length.should eq 1

        # when, then
        expect {
            rootmodel.add_note({
                :integration_id => "123key",
                :text => "This is another note"
            })
        }.to raise_error(GoImport::AlreadyAddedError)
        rootmodel.notes.length.should eq 1
        rootmodel.find_note_by_integration_id("123key").text.should eq "This is a note"
    end

    it "Will find a person by integration id" do
        # given
        organization = GoImport::Organization.new
        organization.name = "Hubba Bubba"
        organization.integration_id = "321"
        organization.add_employee({
            :integration_id => "123",
            :first_name => "Billy",
            :last_name => "Bob"
        })

        rootmodel.add_organization(organization)

        # when
        found_person = rootmodel.find_person_by_integration_id("123")

        # then
        found_person.integration_id.should eq "123"
        found_person.first_name.should eq "Billy"
        found_person.last_name.should eq "Bob"
    end

    it "Will find a person by integration id from an organization with many employees" do
        # given
        organization = GoImport::Organization.new
        organization.name = "Hubba Bubba"
        organization.integration_id = "321"
        organization.add_employee({
            :integration_id => "123",
            :first_name => "Billy",
            :last_name => "Bob"
        })
        organization.add_employee({
            :integration_id => "456",
            :first_name => "Vincent",
            :last_name => "Vega"
        })

        rootmodel.add_organization(organization)

        # when
        found_person = rootmodel.find_person_by_integration_id("123")

        # then
        found_person.integration_id.should eq "123"
        found_person.first_name.should eq "Billy"
        found_person.last_name.should eq "Bob"
    end

    # it "will ignore empty integration ids during sanity check" do
    #     org1 = GoImport::Organization.new
    #     org1.name = "company 1"
    #     rootmodel.organizations.push org1

    #     org2 = GoImport::Organization.new
    #     org2.name = "company 2"
    #     rootmodel.organizations.push org2

    #     rootmodel.sanity_check.should eq ""
    # end

    # it "will report when the same integration id is used during sanity check" do
    #     org1 = GoImport::Organization.new
    #     org1.integration_id = "1"
    #     org1.name = "company 1"
    #     rootmodel.add_organization org1

    #     org2 = GoImport::Organization.new
    #     org2.integration_id = "1"
    #     org2.name = "company 2"
    #     rootmodel.add_organization org2

    #     rootmodel.sanity_check.should eq "Duplicate organization integration_id: 1."
    # end

    # it "will report when the same integrationid on person is used during sanity check" do
    #     org1 = GoImport::Organization.new
    #     org1.integration_id = "1"
    #     org1.name = "company 1"
    #     person1 = GoImport::Person.new
    #     person1.integration_id = '1'
    #     org1.add_employee person1

    #     rootmodel.add_organization org1

    #     org2 = GoImport::Organization.new
    #     org2.integration_id = "2"
    #     org2.name = "company 2"
    #     person2 = GoImport::Person.new
    #     person2.integration_id = '1'
    #     org2.add_employee person2
    #     rootmodel.add_organization org2

    #     rootmodel.sanity_check.should eq "Duplicate person integration_id: 1."
    # end

    it "will report when two links has the same integration id during sanity check" do
        # given
        link1 = GoImport::Link.new
        link1.integration_id = "1"

        link2 = GoImport::Link.new
        link2.integration_id = "2"

        rootmodel.add_link link1
        rootmodel.add_link link2

        # when
        link2.integration_id = "1"

        # then
        rootmodel.sanity_check.should eq "Duplicate link integration_id: 1."
    end
end
