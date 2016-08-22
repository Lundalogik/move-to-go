require 'iso_country_codes'
module MoveToGo
    class Address 
        attr_accessor :street, :zip_code, :city, :country_code, :location
        def serialize_variables
            [ :street, :zip_code, :city, :country_code, :location].map {|p| {:id=>p,:type=>:string} }
        end
        include SerializeHelper
        def initialize()
        end

        # What fields/rows on the class is supposed to be used by the Gem to generate the xml
        # This method uses {#serialize_variables}. It also adds {#country_name} to be serialized
        def get_import_rows
            (serialize_variables+[{:id=>:country_name, :type=>:string}]).map do |p|
                map_to_row p
            end
        end
        # Used as a convenience in order to get country code from internally used {#country_code}
        def country_name
            if @country_code
                IsoCountryCodes.find(@country_code).name
            else
                nil
            end
        end

        # Used as a convenience in order to map country name to the internal {#country_code}
        def country_name=(name)
            @country_code = case name
            when nil
                nil
            when 'Sverige'
                'SE'
            else
                begin
                    IsoCountryCodes.search_by_name(name).first.alpha2
                rescue
                    nil
                end
            end
        end
        # parses a line like "226 48 LUND" into its corresponding
        # zipcode and city properties on the address
        def parse_zip_and_address_se(line)
            Address.parse_line_to_zip_and_address_se(line, self)
        end

        private
        def self.parse_line_to_zip_and_address_se(line, address)
            matched_zipcode = /^\d{3}\s?\d{2}/.match(line)
            if matched_zipcode && matched_zipcode.length == 1
                address.zip_code = matched_zipcode[0].strip()
                matched_city = /\D*$/.match(line)
                if matched_city && matched_city.length == 1
                    address.city = matched_city[0].strip()
                    return address
                end
            end
            return nil
        end
    end
end
