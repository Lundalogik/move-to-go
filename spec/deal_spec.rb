require "spec_helper"
require 'fruit_to_lime'

describe "Deal" do
    let(:deal){
        FruitToLime::Deal.new
    }

    it "can attach a current status" do
        deal.with_status do |status|
            status.label = 'xyz'
            status.id = '123'
            status.date = DateTime.now
            status.note = 'ho ho'
        end
    end

    it "will auto convert org to org.ref during assignment" do
        # given
        org = FruitToLime::Organization.new({:integration_id => "123", :name => "Lundalogik"})

        # when
        deal.customer = org

        # then
        deal.customer.is_a?(FruitToLime::OrganizationReference).should eq true
    end
end
