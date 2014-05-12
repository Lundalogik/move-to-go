require "spec_helper"
require 'fruit_to_lime'

describe "Organization" do
    let(:organization) {
        FruitToLime::Organization.new
    }

    it "must have a name" do
        organization.name = "Lundalogik"

        organization.validate.should eq ""
    end

    it "will fail on validation if no name is specified" do
        organization.name = ""

        organization.validate.length > 0
    end
end
