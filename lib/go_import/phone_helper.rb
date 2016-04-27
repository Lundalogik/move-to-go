require 'global_phone'

module GoImport
    # The PhoneHelper helps you parse and format phone number strings
    # into pretty looking numbers.
    class PhoneHelper
        GlobalPhone.db_path = ::File.join(::File.dirname(__FILE__), 'global_phone.json')
        GlobalPhone.default_territory_name = :se

        # Sets the country code used during parsning. The default is
        # swedish (:se) and if you are parsing swedish numbers you
        # dont need to set the country code.
        def self.set_country_code(country_code)
            GlobalPhone.default_territory_name = country_code
        end

        # Parses the specifed number_string and returns only valid
        # numbers.
        # @see parse_numbers
        def self.parse_numbers_strict(number_string, delimiters = ',')
            parse_numbers number_string, delimiters, true
        end

        # Parses the specified number_string into one or more phone
        # numbers using the specified delimiters. If strict_mode is
        # true only valid numbers are returned, otherwise are invalid
        # numbers returned as found in the number_string.
        #
        # @example Parse a number
        #    number = GoImport::PhoneHelper.parse_numbers("046 - 270 48 00")
        #
        # @example Parses a string with two numbers and a custom delimiter
        #    source = "046 - 270 48 00/ 031-712 44 00"
        #    number1, number2 = GoImport::PhoneHelper.parse_numbers(source, '/')
        def self.parse_numbers(number_string, delimiters = ',', strict_mode = false)
            return nil if number_string.nil?
            numbers = []

            if delimiters.is_a?(Array)
                # we have several delimiters, replace all delimiters
                # in the number_string with the first delimiter
                delimiters.each do |del|
                    number_string = number_string.sub(del, delimiters[0])
                end
                delimiter = delimiters[0]
            elsif delimiters.is_a?(String)
                delimiter = delimiters
            else
                raise "delimiters should be either a string or and array of strings"
            end

            number_string.split(delimiter).each do |possible_number|
                if !possible_number.empty?
                    number = GlobalPhone.parse([possible_number])

                    if !number.nil? && number.valid?
                        numbers.push number.to_s
                    else
                        if !strict_mode
                            numbers.push possible_number
                        end
                    end
                end
            end

            if numbers.length == 0
                return ""
            elsif numbers.length == 1
                return numbers[0]
            else
                return numbers
            end
        end
    end
end
