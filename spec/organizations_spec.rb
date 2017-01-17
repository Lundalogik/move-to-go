require 'spec_helper'
require 'move-to-go'

describe MoveToGo::Organizations do
    it "should find duplicates based on name of the organizations" do
        # given
        model =  MoveToGo::RootModel.new

        organization = MoveToGo::Organization.new
        organization.name = "Lundalogik AB"
        organization.integration_id = "1337"
        model.add_organization(organization)

        (1..3).each do |n|
            organization = MoveToGo::Organization.new
            organization.name = "Ankeborgs bibliotek"
            organization.integration_id = n.to_s
            model.add_organization(organization)
        end

        set_to_check = []
        model.organizations
            .find_duplicates_by(:name)
            .each do |duplicate_set|
                set_to_check = duplicate_set
            end
        # when, the
        set_to_check.length.should eq 3
    end

    it "should not find duplicates based on name and integration id of the organizations" do
        # given
        model =  MoveToGo::RootModel.new

        (1..3).each do |n|
            organization = MoveToGo::Organization.new
            organization.name = "Ankeborgs bibliotek"
            organization.integration_id = n.to_s
            model.add_organization(organization)
        end

        set_to_check = []
        model.organizations
            .find_duplicates_by(:name, :integration_id)
            .each do |duplicate_set|
                set_to_check = duplicate_set
            end
        # when, the
        set_to_check.length.should eq 0
    end

    it "should work with address" do
        # given
        model =  MoveToGo::RootModel.new

        (1..3).each do |n|
            organization = MoveToGo::Organization.new
            organization.name = "Ankeborgs bibliotek"
            organization.integration_id = n.to_s
            organization.with_postal_address do |address|
                address.city = "Lund"
            end
            model.add_organization(organization)
        end

        set_to_check = []
        model.organizations
            .find_duplicates_by("name", "postal_address.city")
            .map do |duplicate_set|
                set_to_check = duplicate_set
            end
        # when, the
        set_to_check.length.should eq 3
    end

    it "should find duplicates based on name of the organizations" do
        # given
        model =  MoveToGo::RootModel.new

        organization = MoveToGo::Organization.new
        organization.name = "Lundalogik AB"
        organization.integration_id = "1337"
        model.add_organization(organization)

        (1..3).each do |n|
            organization = MoveToGo::Organization.new
            organization.name = "Ankeborgs bibliotek"
            organization.integration_id = n.to_s
            model.add_organization(organization)
        end

        set_to_check = []
        model.organizations
            .find_duplicates_by(:name)
            .map do |duplicate_set|
                set_to_check = duplicate_set
            end
        # when, the
        set_to_check.length.should eq 3
    end

    it "should work with a single organization in rootmodel" do
        # given
        model =  MoveToGo::RootModel.new

        organization = MoveToGo::Organization.new
        organization.name = "Lundalogik AB"
        organization.integration_id = "1337"
        model.add_organization(organization)

        set_to_check = []
        model.organizations
            .find_duplicates_by(:name)
            .map do |duplicate_set|
                set_to_check = duplicate_set
            end
        # when, the
        set_to_check.length.should eq 0
    end

    it "should be able to merge duplicates" do
        # given
        model =  MoveToGo::RootModel.new

        (1..3).each do |n|
            organization = MoveToGo::Organization.new
            organization.name = "Ankeborgs bibliotek"
            organization.integration_id = n.to_s
            model.add_organization(organization)
            
            person = MoveToGo::Person.new
            person.first_name = "Kalle"
            organization.add_employee(person)

            deal = MoveToGo::Deal.new
            deal.name = "Big deal"
            deal.integration_id = n.to_s
            deal.customer = organization
            model.add_deal(deal)

            note = MoveToGo::History.new
            note.text = "Hello"
            note.organization = organization
            model.add_history(note)

        end

        model.organizations
            .find_duplicates_by(:name)
            .map_duplicates{ |duplicate_set|
                duplicate_set.merge_all!
            }
            .each{ |duplicate_org|
                model.remove_organization(duplicate_org)
            }

        # when, the
        model.organizations.values.length.should eq 1
        model.organizations.values.first.employees.length.should eq 3
        model.organizations.values.first.deals.length.should eq 3
        model.organizations.values.first.histories.length.should eq 3
    end

    it "should be able to merge fields of an organizations to empty fields on another organization" do
        # given
        model =  MoveToGo::RootModel.new

        model.settings.with_organization do |setting|
           setting.set_custom_field({:integration_id=>"link_to_bi_system", :title=>"Link to BI system"})
        end

        org1 = MoveToGo::Organization.new
        org1.name = "Lundalogik AB"
        org1.integration_id = "1337"
        org1.email = "info@lundalogik.se"
        model.add_organization(org1)

        org2 = MoveToGo::Organization.new
        org2.name = "Lundalogik AB"
        org2.organization_number = "123"
        org2.integration_id = "123"
        org2.email = "inbox@lundalogik.com"
        org2.with_postal_address do |address|
            address.city = "Lund"
            address.street = "Sankt Lars"
        end
        org2.set_custom_value("link_to_bi_system", "https")

        model.add_organization(org2)

        model.organizations
            .find_duplicates_by(:name)
            .map_duplicates do |duplicate_set|
                master_org = duplicate_set.find {|org| org.integration_id == "1337"}
                org_to_be_merged = duplicate_set.find {|org| org.integration_id == "123"}
                master_org.move_data_from(org_to_be_merged)
            end
        
        org = model.find_organization_by_integration_id("1337")
        # when, the
        org.organization_number.should eq "123"
        org.email.should eq "info@lundalogik.se"
        org.postal_address.city.should eq "Lund"
        org.postal_address.street.should eq "Sankt Lars"
        org.custom_values.first.value.should eq "https"
    end

    it "should handle if the value of a field is Nil" do
        # given
        model =  MoveToGo::RootModel.new

        organization = MoveToGo::Organization.new
        organization.name = nil
        organization.integration_id = "1337"
        model.add_organization(organization)

        (1..3).each do |n|
            organization = MoveToGo::Organization.new
            organization.name = "Ankeborgs bibliotek"
            organization.integration_id = n.to_s
            model.add_organization(organization)
        end

        set_to_check = []
        model.organizations
            .find_duplicates_by(:name)
            .each do |duplicate_set|
                set_to_check = duplicate_set
            end
        # when, the
        set_to_check.length.should eq 3
    end

end
