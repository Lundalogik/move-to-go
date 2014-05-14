require "sixarm_ruby_email_address_validation"

module FruitToLime
    # The EmailHelper helps you validate email addresses.
    class EmailHelper
        def self.is_valid?(email)
            return (email =~ EmailAddressValidation::Pattern) ? true : false
        end
    end
end
