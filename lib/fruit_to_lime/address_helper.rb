module FruitToLime
module AddressHelper
	# parses a line like "226 48 LUND" into its corresponding
	# zipcode and city properties on the address
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