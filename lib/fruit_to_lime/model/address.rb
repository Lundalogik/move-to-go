require 'iso_country_codes'
module FruitToLime
    class Address 
        attr_accessor :street, :zip_code, :city, :country_code, :location
        def serialize_variables
            [ :street, :zip_code, :city, :country_code, :location].map {|p| {:id=>p,:type=>:string} }
        end
        include SerializeHelper
        def initialize()
        end

        def get_import_rows
            (serialize_variables+[{:id=>:country_name, :type=>:string}]).map do |p|
                map_to_row p
            end
        end
        def country_name
            if @country_code
                IsoCountryCodes.find(@country_code).name
            else
                nil
            end
        end
        def country_name=(name)
            @country_code = case name
            when nil
                nil
            when 'Sverige'
                'SE'
            else
                 IsoCountryCodes.search_by_name(name).first.alpha2
            end
        end
        def parse_zip_and_address_se(line)
            FruitToLime::AddressHelper::parse_line_to_zip_and_address_se(line, self)
        end
    end
end