require "spec_helper"
require 'move-to-go'

describe "RootModel" do
    let(:rootmodel) {
        MoveToGo::RootModel.new
    }

    it "will contain import coworker by default" do
        rootmodel.find_coworker_by_integration_id("import").first_name.should eq "Import"
        rootmodel.coworkers.length.should eq 1
    end

    it "can add a coworker from a new coworker" do
        # given
        coworker = MoveToGo::Coworker.new
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
        coworker = MoveToGo::Coworker.new
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
        coworker1 = MoveToGo::Coworker.new({
                                               :integration_id => "123key",
                                               :first_name => "Kalle",
                                               :last_name => "Anka",
                                               :email => "kalle.anka@vonanka.com"
                                           })
        rootmodel.add_coworker(coworker1)
        rootmodel.coworkers.length.should eq 2

        # when
        coworker2 = MoveToGo::Coworker.new({

                                               :integration_id => "123key",
                                               :first_name => "Knatte",
                                               :last_name => "Anka",
                                               :email => "knatte.anka@vonanka.com"
                                           })
        expect {
            rootmodel.add_coworker(coworker2)
        }.to raise_error(MoveToGo::AlreadyAddedError)
        rootmodel.find_coworker_by_integration_id("123key").first_name.should eq "Kalle"
        rootmodel.coworkers.length.should eq 2
    end

    it "can add an organization from a new organization" do
        # given
        organization = MoveToGo::Organization.new
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
        organization = MoveToGo::Organization.new
        organization.integration_id = "123key"
        organization.name = "Beagle Boys"

        # when
        rootmodel.add_organization(organization)

        # then
        organization.is_immutable.should eq true
    end

    it "will only add organizations" do
        # given
        not_an_organization = { :integration_id => "123", :name => "This is not a history"}

        # when, then
        expect {
            rootmodel.add_organization(not_an_organization)
        }.to raise_error(ArgumentError)
        rootmodel.organizations.length.should eq 0
    end

    it "will not add a new organization when the organization is already added (same integration id)" do
        # given
        org = MoveToGo::Organization.new({
                                             :integration_id => "123key",
                                             :name => "Beagle Boys"
                                         })
        rootmodel.add_organization(org)
        rootmodel.organizations.length.should eq 1
        rootmodel.find_organization_by_integration_id("123key").name.should eq "Beagle Boys"

        # when, then
        org2 = MoveToGo::Organization.new({
                                              :integration_id => "123key",
                                              :name => "Beagle Boys 2"
                                          })
        expect {
            rootmodel.add_organization(org2)
        }.to raise_error(MoveToGo::AlreadyAddedError)
        rootmodel.find_organization_by_integration_id("123key").name.should eq "Beagle Boys"
        rootmodel.organizations.length.should eq 1
    end

    it "will not add a organization when integration_id is nil" do
        # given
        org1 = MoveToGo::Organization.new
        org1.name = "Beagle Boys"
        org1.integration_id = nil

        # when, then
        expect {
            rootmodel.add_organization(org1)
        }.to raise_error(MoveToGo::IntegrationIdIsRequiredError)
    end

    it "will not add a organization when integration_id is empty" do
        # given
        org1 = MoveToGo::Organization.new
        org1.name = "Beagle Boys"
        org1.integration_id = ""

        # when, then
        expect {
            rootmodel.add_organization(org1)
        }.to raise_error(MoveToGo::IntegrationIdIsRequiredError)
    end

    it "can add a deal from a new deal" do
        # given
        deal = MoveToGo::Deal.new
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
        deal = MoveToGo::Deal.new
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
        deal = MoveToGo::Deal.new
        deal.integration_id = "123key"
        deal.name = "Big deal"

        # when
        rootmodel.add_deal(deal)

        # then
        deal.responsible_coworker.integration_id.should eq rootmodel.import_coworker.integration_id
    end

    it "will not set reponsible coworker to import_coworker if specifed" do
        # given
        deal = MoveToGo::Deal.new
        deal.integration_id = "123key"
        deal.name = "Big deal"
        coworker = MoveToGo::Coworker.new
        coworker.integration_id = "123"
        deal.responsible_coworker = coworker

        # when
        rootmodel.add_deal(deal)

        # then
        deal.responsible_coworker.integration_id.should eq coworker.integration_id
    end

    it "will not set responsible coworker to import_coworker if allowed" do
        # given
        deal = MoveToGo::Deal.new
        deal.integration_id = "123key"
        deal.name = "Big Deal"

        rootmodel.configuration[:allow_deals_without_responsible] = true

        # when
        rootmodel.add_deal(deal)

        # then
        deal.responsible_coworker.should eq nil
    end

    it "will set responsible coworker to import_coworker if configured" do
        # given
        deal = MoveToGo::Deal.new
        deal.integration_id = "123key"
        deal.name = "Big Deal"

        rootmodel.configuration[:allow_deals_without_responsible] = false

        # when
        rootmodel.add_deal(deal)

        # then
        deal.responsible_coworker.integration_id.should eq rootmodel.import_coworker.integration_id
    end

    it "will not add a new deal when the deal is already added (same integration id)" do
        # given
        deal1 = MoveToGo::Deal.new({
                                       :integration_id => "123key",
                                       :name => "Big deal"
                                   })
        rootmodel.add_deal(deal1)
        rootmodel.deals.length.should eq 1
        rootmodel.find_deal_by_integration_id("123key").name.should eq "Big deal"

        # when, then
        deal2 = MoveToGo::Deal.new({
                                       :integration_id => "123key",
                                       :name => "Bigger deal"
                                   })
        expect {
            rootmodel.add_deal(deal2)
        }.to raise_error(MoveToGo::AlreadyAddedError)
        rootmodel.find_deal_by_integration_id("123key").name.should eq "Big deal"
        rootmodel.deals.length.should eq 1
    end

    it "will not add a deal when integration_id is nil" do
        # given
        deal = MoveToGo::Deal.new
        deal.name = "The new deal"
        deal.integration_id = nil

        # when, then
        expect {
            rootmodel.add_deal(deal)
        }.to raise_error(MoveToGo::IntegrationIdIsRequiredError)
    end

    it "will not add a deal when integration_id is empty" do
        # given
        deal = MoveToGo::Deal.new
        deal.name = "The new deal"
        deal.integration_id = ""

        # when, then
        expect {
            rootmodel.add_deal(deal)
        }.to raise_error(MoveToGo::IntegrationIdIsRequiredError)
    end

    it "will add comment" do
                # given
        comment = MoveToGo::Comment.new
        comment.text = "this is a comment"

        # when
        rootmodel.add_comment(comment)

        # then
        rootmodel.histories.length.should eq 1
        rootmodel.histories["0"].is_a?(MoveToGo::Comment).should eq true
    end

    it "will add sales call" do
                # given
        salesCall = MoveToGo::SalesCall.new
        salesCall.text = "this is a sales call"

        # when
        rootmodel.add_sales_call(salesCall)

        # then
        rootmodel.histories.length.should eq 1
        rootmodel.histories["0"].is_a?(MoveToGo::SalesCall).should eq true
    end

    it "will add talked to" do
                # given
        talkedTo = MoveToGo::TalkedTo.new
        talkedTo.text = "this is a sales call"

        # when
        rootmodel.add_talked_to(talkedTo)

        # then
        rootmodel.histories.length.should eq 1
        rootmodel.histories["0"].is_a?(MoveToGo::TalkedTo).should eq true
    end

    it "will add tried to reach" do
                # given
        triedToReach = MoveToGo::TriedToReach.new
        triedToReach.text = "this is a sales call"

        # when
        rootmodel.add_tried_to_reach(triedToReach)

        # then
        rootmodel.histories.length.should eq 1
        rootmodel.histories["0"].is_a?(MoveToGo::TriedToReach).should eq true
    end

        it "will add client visit" do
                # given
        clientVisit = MoveToGo::ClientVisit.new
        clientVisit.text = "this is a client visit"

        # when
        rootmodel.add_client_visit(clientVisit)

        # then
        rootmodel.histories.length.should eq 1
        rootmodel.histories["0"].is_a?(MoveToGo::ClientVisit).should eq true
    end

    it "will only add comment" do
        # given
        not_a_comment = { :integration_id => "123", :text => "This is not a comment"}

        # when, then
        expect {
            rootmodel.add_comment(not_a_comment)
        }.to raise_error(ArgumentError)
        rootmodel.histories.length.should eq 0
    end

    it "will make comment immutable after it has been added" do
        # given
        comment = MoveToGo::Comment.new
        comment.text = "this is a comment"

        # when
        rootmodel.add_comment(comment)

        # then
        comment.is_immutable.should eq true
    end

    it "can add a comment from a new comment" do
        # given
        comment = MoveToGo::Comment.new
        comment.integration_id = "123key"
        comment.text = "This is a comment"

        # when
        rootmodel.add_comment(comment)

        # then
        rootmodel.find_history_by_integration_id("123key").text.should eq "This is a comment"
        rootmodel.histories.length.should eq 1
    end

    it "will generate an integration id if the new comment dont have one" do
        # given
        comment = MoveToGo::Comment.new
        comment.text = "This is a comment"

        # when
        rootmodel.add_comment(comment)

        # then
        comment.integration_id.length.should be > 0
    end

    it "will generate unique integration ids for each history" do
        # given
        comment1 = MoveToGo::Comment.new
        comment1.text = "This is a history"

        comment2 = MoveToGo::Comment.new
        comment2.text = "This is a different history"

        # when
        rootmodel.add_comment(comment1)
        rootmodel.add_comment(comment2)

        # then
        comment1.integration_id.should be != comment2.integration_id
    end

    it "will not add a nil history" do
        # given, when
        rootmodel.add_comment(nil)

        # then
        rootmodel.histories.length.should eq 0
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
        link = MoveToGo::Link.new
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
        file = MoveToGo::File.new
        file.integration_id = "123key"
        file.path = "k:\kontakt\databas\dokument"

        # when
        rootmodel.add_file file

        # then
        rootmodel.documents.find_file_by_integration_id("123key").path.should eq "k:\kontakt\databas\dokument"
        rootmodel.documents.files.length.should eq 1
    end

    it "will not add a new comment when the comment is already added (same integration id)" do
        # given
        comment = MoveToGo::Comment.new({
                                      :integration_id => "123key",
                                      :text => "This is a comment"
                                  })
        rootmodel.add_comment(comment)
        rootmodel.histories.length.should eq 1

        # when, then
        comment2 = MoveToGo::Comment.new({
                                       :integration_id => "123key",
                                       :text => "This is another comment"
                                   })
        expect {
            rootmodel.add_comment(comment2)
        }.to raise_error(MoveToGo::AlreadyAddedError)
        rootmodel.histories.length.should eq 1
        rootmodel.find_history_by_integration_id("123key").text.should eq "This is a comment"
    end

    it "Will find a person by integration id" do
        # given
        organization = MoveToGo::Organization.new
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

    it "Will will not find a person by wrong integration id" do
        # given
        organization = MoveToGo::Organization.new
        organization.name = "Hubba Bubba"
        organization.integration_id = "321"
        organization.add_employee({
            :integration_id => "123",
            :first_name => "Billy",
            :last_name => "Bob"
        })

        rootmodel.add_organization(organization)

        # when
        found_person = rootmodel.find_person_by_integration_id("321")

        # then
        found_person.should eq nil

    end

    it "Will find a person by integration id from an organization with many employees" do
        # given
        organization = MoveToGo::Organization.new
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

    it "will have correct count on number of persons" do
        # given
        organization = MoveToGo::Organization.new
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
        persons = rootmodel.persons

        # then
        persons.length.should eq 2

    end

    it "will report when two links has the same integration id during sanity check" do
        # given
        link1 = MoveToGo::Link.new
        link1.integration_id = "1"

        link2 = MoveToGo::Link.new
        link2.integration_id = "2"

        rootmodel.add_link link1
        rootmodel.add_link link2

        # when
        link2.integration_id = "1"

        # then
        rootmodel.sanity_check.should eq "Duplicate link integration_id: 1."
    end

    it "will find an organization based on a property" do
        # given
        organization = MoveToGo::Organization.new
        organization.name = "Hubba Bubba"
        organization.integration_id = "321"
        rootmodel.add_organization(organization)

        organization2 = MoveToGo::Organization.new
        organization2.name = "Bongo bong"
        organization2.integration_id = "123"
        rootmodel.add_organization(organization2)

        # when
        result = rootmodel.find_organization{|org| org.name == "Hubba Bubba"}

        # then
        result.should eq organization
    end

    it "will return nil if it doesn't find an organization on a property" do
        # given
        organization = MoveToGo::Organization.new
        organization.name = "Hubba Bubba"
        organization.integration_id = "321"
        rootmodel.add_organization(organization)

        organization2 = MoveToGo::Organization.new
        organization2.name = "Bongo bong"
        organization2.integration_id = "123"
        rootmodel.add_organization(organization2)

        # when
        result = rootmodel.find_organization{|org| org.name == "Nope"}

        # then
        result.should eq nil
    end

    it "will find an person based on a property" do
        # given
        organization = MoveToGo::Organization.new
        organization.name = "Hubba Bubba"
        organization.integration_id = "321"
        rootmodel.add_organization(organization)

        person = MoveToGo::Person.new
        person.first_name = "Kalle"
        person.email = "kalle@kula.se"

        organization.add_employee(person)

        # when
        result = rootmodel.find_person{|per| per.email == "kalle@kula.se"}

        # then
        result.should eq person
    end

    it "will return nil if it doesn't find a person on a property" do
        # given
        organization = MoveToGo::Organization.new
        organization.name = "Hubba Bubba"
        organization.integration_id = "321"
        rootmodel.add_organization(organization)

        person = MoveToGo::Person.new
        person.first_name = "Kalle"
        person.email = "kalle@kula.se"

        organization.add_employee(person)

        # when
        result = rootmodel.find_person{|per| per.email == "john@appleseed.com"}

        # then
        result.should eq nil
    end

    it "will find an deal based on a property" do
        # given
        deal = MoveToGo::Deal.new
        deal.name = "Big Deal"
        deal.integration_id = "321"
        deal.value = 23456789
        rootmodel.add_deal(deal)

        # when
        result = rootmodel.find_deal{|d| d.name == "Big Deal"}

        # then
        result.should eq deal
    end

    it "will return nil if it doesn't find a deal on a property" do
        # given
        deal = MoveToGo::Deal.new
        deal.name = "Big Deal"
        deal.integration_id = "321"
        deal.value = 23456789
        rootmodel.add_deal(deal)

        # when
        result = rootmodel.find_deal{|d| d.value == 0}

        # then
        result.should eq nil
    end

    it "will find an comment based on a property" do
        # given
        organization = MoveToGo::Organization.new
        organization.name = "Hubba Bubba"
        organization.integration_id = "321"
        rootmodel.add_organization(organization)

        comment = MoveToGo::Comment.new
        comment.text = "Hello!"
        comment.organization = organization

        rootmodel.add_comment(comment)
        # when
        result = rootmodel.find_history{|n| n.text == "Hello!"}

        # then
        result.should eq comment
    end

    it "will return nil if it doesn't find a history on a property" do
        # given
        organization = MoveToGo::Organization.new
        organization.name = "Hubba Bubba"
        organization.integration_id = "321"
        rootmodel.add_organization(organization)

        comment = MoveToGo::Comment.new
        comment.text = "Hello!"
        comment.organization = organization

        rootmodel.add_comment(comment)
        # when
        result = rootmodel.find_history{|n| n.text == "Goodbye!"}

        # then
        result.should eq nil
    end

    it "will find an document based on a property" do
        # given
        organization = MoveToGo::Organization.new
        organization.name = "Hubba Bubba"
        organization.integration_id = "321"
        rootmodel.add_organization(organization)

        link = MoveToGo::Link.new
        link.name = "Tender"
        link.integration_id = "123"
        link.url = "https://go.lime-go.com"
        link.organization = organization

        rootmodel.documents.add_link(link)
        # when
        result = rootmodel.find_document(:link){|l| l.url == "https://go.lime-go.com"}

        # then
        result.should eq link
    end

    it "will return nil if it doesn't find a document on a property" do
      # given
      organization = MoveToGo::Organization.new
      organization.name = "Hubba Bubba"
      organization.integration_id = "321"
      rootmodel.add_organization(organization)

      link = MoveToGo::Link.new
      link.name = "Tender"
      link.integration_id = "123"
      link.url = "https://go.lime-go.com"
      link.organization = organization

      rootmodel.documents.add_link(link)
      # when
      result = rootmodel.find_document(:link){|l| l.name == "Contract"}

      # then
      result.should eq nil
    end

    it "will find companies based on their property" do
        # given
        organization = MoveToGo::Organization.new
        organization.name = "Hubba Bubba"
        organization.integration_id = "321"
        rootmodel.add_organization(organization)

        organization = MoveToGo::Organization.new
        organization.name = "Hubba Bubba"
        organization.integration_id = "123"
        rootmodel.add_organization(organization)
        # when
        result = rootmodel.select_organizations{|org| org.name == "Hubba Bubba"}

        # then
        result.length.should eq 2
    end

    it "will return empty array if it doesn't find any organization on a property" do
        # given
        organization = MoveToGo::Organization.new
        organization.name = "Hubba Bubba"
        organization.integration_id = "321"
        rootmodel.add_organization(organization)

        organization = MoveToGo::Organization.new
        organization.name = "Hubba Bubba"
        organization.integration_id = "123"
        rootmodel.add_organization(organization)
        # when
        result = rootmodel.select_organizations{|org| org.name == "Hubba"}

        # then
        result.should eq []
    end

    it "will find persons based on their property" do
        # given
        organization = MoveToGo::Organization.new
        organization.name = "Hubba Bubba"
        organization.integration_id = "321"
        rootmodel.add_organization(organization)
        person = MoveToGo::Person.new
        person.first_name = "Kalle"
        person.email = "kalle@kula.se"
        person.position = "Chief"
        organization.add_employee(person)

        organization = MoveToGo::Organization.new
        organization.name = "Bongo Bong"
        organization.integration_id = "123"
        rootmodel.add_organization(organization)
        person = MoveToGo::Person.new
        person.first_name = "Nisse"
        person.email = "nisse@elf.com"
        person.position = "Chief"
        organization.add_employee(person)

        # when
        result = rootmodel.select_persons{|per| per.position == "Chief"}
        # then
        result.length.should eq 2
    end

    it "will return empty array if it doesn't find any persons on their property" do
        # given
        organization = MoveToGo::Organization.new
        organization.name = "Hubba Bubba"
        organization.integration_id = "321"
        rootmodel.add_organization(organization)
        person = MoveToGo::Person.new
        person.first_name = "Kalle"
        person.email = "kalle@kula.se"
        person.position = "Chief"
        organization.add_employee(person)

        organization = MoveToGo::Organization.new
        organization.name = "Bongo Bong"
        organization.integration_id = "123"
        rootmodel.add_organization(organization)
        person = MoveToGo::Person.new
        person.first_name = "Nisse"
        person.email = "nisse@elf.com"
        person.position = "Chief"
        organization.add_employee(person)

        # when
        result = rootmodel.select_persons{|per| per.position == "Slave"}

        # then
        result.should eq []
    end

    it "will find coworker based on their property" do
        # when
        coworker1 = MoveToGo::Coworker.new({
                                               :integration_id => "111key",
                                               :first_name => "Kalle",
                                               :last_name => "Anka",
                                               :email => "kalle.anka@vonanka.com"
                                           })
        coworker2 = MoveToGo::Coworker.new({

                                               :integration_id => "222key",
                                               :first_name => "Knatte",
                                               :last_name => "Anka",
                                               :email => "knatte.anka@vonanka.com"
                                           })
        rootmodel.add_coworker(coworker1)
        rootmodel.add_coworker(coworker2)

        # then
        result = rootmodel.find_coworker{|coworker| coworker.email == "knatte.anka@vonanka.com"}
        result.should eq coworker2
    end

    it "will return nil if it doesn't find an coworker on a property" do
        # when
        coworker1 = MoveToGo::Coworker.new({
                                               :integration_id => "111key",
                                               :first_name => "Kalle",
                                               :last_name => "Anka",
                                               :email => "kalle.anka@vonanka.com"
                                           })
        rootmodel.add_coworker(coworker1)

        # then
        result = rootmodel.find_coworker{|coworker| coworker.email == "Kall"}
        result.should eq nil
    end

    it "will find deals based on their property" do
        # given
        deal = MoveToGo::Deal.new
        deal.name = "Big Deal"
        deal.value = 1234
        deal.integration_id = "1"
        rootmodel.add_deal deal

        deal = MoveToGo::Deal.new
        deal.name = "Bigger Deal"
        deal.value = 1234
        deal.integration_id = "2"
        rootmodel.add_deal deal

        # when
        result = rootmodel.select_deals{|d| d.value == "1234"}
        # then
        result.length.should eq 2
    end

    it "will return empty array if it doesn't find any persons on their property" do
        # given
        deal = MoveToGo::Deal.new
        deal.name = "Big Deal"
        deal.value = 1234
        deal.integration_id = "1"
        rootmodel.add_deal deal

        deal = MoveToGo::Deal.new
        deal.name = "Bigger Deal"
        deal.value = 1234
        deal.integration_id = "2"
        rootmodel.add_deal deal

        # when
        result = rootmodel.select_deals{|d| d.name == "Small deal"}

        # then
        result.should eq []
    end
end
