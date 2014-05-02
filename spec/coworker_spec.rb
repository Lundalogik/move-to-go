require "spec_helper"
require 'fruit_to_lime'

describe "Coworker" do
    let(:coworker) {
        FruitToLime::Coworker.new
    }

    describe "parse_name_to_firstname_lastname_se" do
        it "can parse 'Kalle Nilsson' into firstname 'Kalle' and lastname 'Nilsson'" do
            coworker.parse_name_to_firstname_lastname_se 'Kalle Nilsson'

            coworker.first_name.should eq 'Kalle'
            coworker.last_name.should eq 'Nilsson'

        end

        it "can parse 'Kalle Svensson Nilsson' into firstname 'Kalle' and lastname 'Svensson Nilsson'" do
            coworker.parse_name_to_firstname_lastname_se 'Kalle Svensson Nilsson'

            coworker.first_name.should eq 'Kalle'
            coworker.last_name.should eq 'Svensson Nilsson'
        end
    end    
end
