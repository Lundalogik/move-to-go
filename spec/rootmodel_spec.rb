require "spec_helper"
require 'go_import'

describe "RootModel" do
    let(:rootmodel) {
        GoImport::RootModel.new
    }

    it "will contain import coworker by default" do
        rootmodel.find_coworker_by_integration_id("import").first_name.should eq "Import"
        rootmodel.coworkers.length.should eq 1
    end
    
    it "can add a coworker from a new coworker" do
        # given
        coworker = GoImport::Coworker.new
        coworker.integration_id = "123key"
        coworker.first_name="Kalle"
        coworker.last_name="Anka"
        coworker.email = "kalle.anka@vonanka.com"

        # when
        rootmodel.add_coworker(coworker)

        # end
        rootmodel.find_coworker_by_integration_id("123key").first_name.should eq "Kalle"
        rootmodel.coworkers.length.should eq 2
    end

    it "will make coworkers immutable after it has been added" do
        # given
        coworker = GoImport::Coworker.new
        coworker.integration_id = "123key"
        coworker.first_name = "vincent"

        # when
        rootmodel.add_coworker(coworker)

        # then
        coworker.is_immutable.should eq true
    end
    

    it "will only add coworkers" do
        # given
        not_a_coworker = { :integration_id => "123", :first_name => "Vincent" }

        # when, then
        expect {
            rootmodel.add_coworker(not_a_coworker)
        }.to raise_error(ArgumentError)
        rootmodel.coworkers.length.should eq 1        
    end

    it "will not add a new coworker when the coworker is already added (same integration id)" do
        # when
        coworker1 = GoImport::Coworker.new({
                                               :integration_id => "123key",
                                               :first_name => "Kalle",
                                               :last_name => "Anka",
                                               :email => "kalle.anka@vonanka.com"
                                           })
        rootmodel.add_coworker(coworker1)
        rootmodel.coworkers.length.should eq 2

        # when
        coworker2 = GoImport::Coworker.new({

                                               :integration_id => "123key",
                                               :first_name => "Knatte",
                                               :last_name => "Anka",
                                               :email => "knatte.anka@vonanka.com"
                                           })
        expect {
            rootmodel.add_coworker(coworker2)
        }.to raise_error(GoImport::AlreadyAddedError)
        rootmodel.find_coworker_by_integration_id("123key").first_name.should eq "Kalle"
        rootmodel.coworkers.length.should eq 2
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

    it "will make organizations immutable after it has been added" do
        # given
        organization = GoImport::Organization.new
        organization.integration_id = "123key"
        organization.name = "Beagle Boys"

        # when
        rootmodel.add_organization(organization)

        # then
        organization.is_immutable.should eq true
    end
    
    it "will only add organizations" do
        # given
        not_an_organization = { :integration_id => "123", :name => "This is not a note"}

        # when, then
        expect {
            rootmodel.add_organization(not_an_organization)
        }.to raise_error(ArgumentError)
        rootmodel.organizations.length.should eq 0
    end
    
    it "will not add a new organization when the organization is already added (same integration id)" do
        # given
        org = GoImport::Organization.new({
                                             :integration_id => "123key",
                                             :name => "Beagle Boys"
                                         })
        rootmodel.add_organization(org)
        rootmodel.organizations.length.should eq 1
        rootmodel.find_organization_by_integration_id("123key").name.should eq "Beagle Boys"

        # when, then
        org2 = GoImport::Organization.new({
                                              :integration_id => "123key",
                                              :name => "Beagle Boys 2"
                                          })
        expect {
            rootmodel.add_organization(org2)
        }.to raise_error(GoImport::AlreadyAddedError)
        rootmodel.find_organization_by_integration_id("123key").name.should eq "Beagle Boys"
        rootmodel.organizations.length.should eq 1
    end

    it "will not add a organization when integration_id is nil" do
        # given
        org1 = GoImport::Organization.new
        org1.name = "Beagle Boys"
        org1.integration_id = nil

        # when, then
        expect {
            rootmodel.add_organization(org1)
        }.to raise_error(GoImport::IntegrationIdIsRequiredError)
    end

    it "will not add a organization when integration_id is empty" do
        # given
        org1 = GoImport::Organization.new
        org1.name = "Beagle Boys"
        org1.integration_id = ""

        # when, then
        expect {
            rootmodel.add_organization(org1)
        }.to raise_error(GoImport::IntegrationIdIsRequiredError)
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

    it "will make deal immutable after it has been added" do
        # given
        deal = GoImport::Deal.new
        deal.integration_id = "123key"
        deal.name = "Big deal"

        # when
        rootmodel.add_deal(deal)

        # then
        deal.is_immutable.should eq true
    end    

    it "will only add deals" do
        # given
        not_a_deal = { :integration_id => "123", :name => "This is not a deal" }

        # when, then
        expect {
            rootmodel.add_deal(not_a_deal)
        }.to raise_error(ArgumentError)
        rootmodel.deals.length.should eq 0
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
        deal1 = GoImport::Deal.new({
                                       :integration_id => "123key",
                                       :name => "Big deal"
                                   })
        rootmodel.add_deal(deal1)
        rootmodel.deals.length.should eq 1
        rootmodel.find_deal_by_integration_id("123key").name.should eq "Big deal"

        # when, then
        deal2 = GoImport::Deal.new({
                                       :integration_id => "123key",
                                       :name => "Bigger deal"
                                   })
        expect {
            rootmodel.add_deal(deal2)
        }.to raise_error(GoImport::AlreadyAddedError)
        rootmodel.find_deal_by_integration_id("123key").name.should eq "Big deal"
        rootmodel.deals.length.should eq 1
    end

    it "will not add a deal when integration_id is nil" do
        # given
        deal = GoImport::Deal.new
        deal.name = "The new deal"
        deal.integration_id = nil

        # when, then
        expect {
            rootmodel.add_deal(deal)
        }.to raise_error(GoImport::IntegrationIdIsRequiredError)
    end

    it "will not add a deal when integration_id is empty" do
        # given
        deal = GoImport::Deal.new
        deal.name = "The new deal"
        deal.integration_id = ""

        # when, then
        expect {
            rootmodel.add_deal(deal)
        }.to raise_error(GoImport::IntegrationIdIsRequiredError)
    end

    it "will only add notes" do
        # given
        not_a_note = { :integration_id => "123", :text => "This is not a note"}

        # when, then
        expect {
            rootmodel.add_note(not_a_note)
        }.to raise_error(ArgumentError)
        rootmodel.notes.length.should eq 0
    end

    it "will make note immutable after it has been added" do
        # given
        note = GoImport::Note.new        
        note.text = "this is a note"

        # when
        rootmodel.add_note(note)

        # then
        note.is_immutable.should eq true
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

    it "will generate an integration id if the new note dont have one" do
        # given
        note = GoImport::Note.new
        note.text = "This is a note"

        # when
        rootmodel.add_note(note)

        # then
        note.integration_id.length.should be > 0
    end

    it "will generate unique integration ids for each note" do
        # given
        note1 = GoImport::Note.new
        note1.text = "This is a note"

        note2 = GoImport::Note.new
        note2.text = "This is a different note"

        # when
        rootmodel.add_note note1
        rootmodel.add_note note2

        # then
        note1.integration_id.should be != note2.integration_id
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

    it "will not add a new note when the note is already added (same integration id)" do
        # given
        note = GoImport::Note.new({
                                      :integration_id => "123key",
                                      :text => "This is a note"
                                  })
        rootmodel.add_note(note)
        rootmodel.notes.length.should eq 1

        # when, then
        note2 = GoImport::Note.new({
                                       :integration_id => "123key",
                                       :text => "This is another note"
                                   })
        expect {
            rootmodel.add_note(note2)
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
