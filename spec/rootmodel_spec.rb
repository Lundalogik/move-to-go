require "spec_helper"
require 'fruit_to_lime'

describe "RootModel" do
    let(:rootmodel) {
        FruitToLime::RootModel.new
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
        coworker = FruitToLime::Coworker.new
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
        }.to raise_error(FruitToLime::AlreadyAddedError)
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
        organization = FruitToLime::Organization.new
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
        }.to raise_error(FruitToLime::AlreadyAddedError)
        rootmodel.find_organization_by_integration_id("123key").name.should eq "Beagle Boys"
        rootmodel.organizations.length.should eq 1
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
        deal = FruitToLime::Deal.new
        deal.integration_id = "123key"
        deal.name = "Big deal"

        # when
        rootmodel.add_deal(deal)

        # then
        rootmodel.find_deal_by_integration_id("123key").name.should eq "Big deal"
        rootmodel.deals.length.should eq 1
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
        }.to raise_error(FruitToLime::AlreadyAddedError)
        rootmodel.find_deal_by_integration_id("123key").name.should eq "Big deal"
        rootmodel.deals.length.should eq 1
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
        note = FruitToLime::Note.new
        note.integration_id = "123key"
        note.text = "This is a note"

        # when
        rootmodel.add_note(note)

        # then
        rootmodel.find_note_by_integration_id("123key").text.should eq "This is a note"
        rootmodel.notes.length.should eq 1
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
        }.to raise_error(FruitToLime::AlreadyAddedError)
        rootmodel.notes.length.should eq 1
        rootmodel.find_note_by_integration_id("123key").text.should eq "This is a note"
    end

    it "will ignore empty integration ids during sanity check" do
        org1 = FruitToLime::Organization.new
        org1.name = "company 1"
        rootmodel.organizations.push org1

        org2 = FruitToLime::Organization.new
        org2.name = "company 2"
        rootmodel.organizations.push org2

        rootmodel.sanity_check.should eq ""
    end

    it "will report when the same integration id is used during sanity check" do
        org1 = FruitToLime::Organization.new
        org1.integration_id = "1"
        org1.name = "company 1"
        rootmodel.organizations.push org1

        org2 = FruitToLime::Organization.new
        org2.integration_id = "1"
        org2.name = "company 2"
        rootmodel.organizations.push org2

        rootmodel.sanity_check.should eq "Duplicate organization integration_id: 1."
    end

    it "will report when the same integrationid on person is used during sanity check" do
        org1 = FruitToLime::Organization.new
        org1.integration_id = "1"
        org1.name = "company 1"
        person1 = FruitToLime::Person.new
        person1.integration_id = '1'
        org1.add_employee person1

        rootmodel.organizations.push org1

        org2 = FruitToLime::Organization.new
        org2.integration_id = "2"
        org2.name = "company 2"
        person2 = FruitToLime::Person.new
        person2.integration_id = '1'
        org2.add_employee person2
        rootmodel.organizations.push org2

        rootmodel.sanity_check.should eq "Duplicate person integration_id: 1."
    end
end
