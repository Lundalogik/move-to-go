require "sixarm_ruby_email_address_validation"

module GoImport
    # The EmailHelper helps you validate email addresses.
    class EmailHelper
        def self.is_valid?(email)
            begin
                return (email =~ EmailAddressValidation::Pattern) ? true : false
            rescue
                return false
            end
        end
    end
end
