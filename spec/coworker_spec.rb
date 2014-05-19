# encoding: utf-8
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

        it "sets default name when name is empty" do
            coworker.parse_name_to_firstname_lastname_se '', 'a default'

            coworker.first_name.should eq 'a default'
        end

        it "sets default name when name is nil" do
            coworker.parse_name_to_firstname_lastname_se nil, 'a default'

            coworker.first_name.should eq 'a default'
        end
    end

    describe "guess_email" do
        it "guesses kalle.nilsson@x.com for coworker with firstname 'Kalle', lastname 'Nilsson' and domain set to 'x.com" do
            coworker.first_name = 'Kalle'
            coworker.last_name = 'Nilsson'

            guessed = coworker.guess_email 'x.com'

            guessed.should eq 'kalle.nilsson@x.com'
        end

        it "guesses '' when lastname is missing" do
            coworker.first_name = 'Kalle'
            coworker.last_name = ''

            guessed = coworker.guess_email 'x.com'

            guessed.should eq ''
        end

        it "guesses '' when firstname is missing" do
            coworker.first_name = nil
            coworker.last_name = 'Nilsson'

            guessed = coworker.guess_email 'x.com'

            guessed.should eq ''
        end

        it "guesses åäöèé to be aaoee" do
            coworker.first_name = 'åäöèé'
            coworker.last_name = 'Nilsson'

            guessed = coworker.guess_email 'x.com'

            guessed.should eq 'aaoee.nilsson@x.com'
        end

        it "guesses 'sven-erik.nilsson@x.com' when firstname has two names with ' ' between them" do
            coworker.first_name = 'Sven Erik'
            coworker.last_name = 'Nilsson'

            guessed = coworker.guess_email 'x.com'

            guessed.should eq 'sven-erik.nilsson@x.com'
        end

        it "guesses 'sven.nilsson-svensson@x.com' when lastnames has two names with ' ' between them" do
            coworker.first_name = 'Sven'
            coworker.last_name = 'Nilsson Svensson'

            guessed = coworker.guess_email 'x.com'

            guessed.should eq 'sven.nilsson-svensson@x.com'
        end
    end
end
