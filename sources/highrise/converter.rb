# encoding: UTF-8
require 'move-to-go'


# This Converter will convert a generic source to a XML file that can
# be imported into LIME Go.
#
# You MUST customzie this script to read a source and return a
# RootModel.
#
# Reference documentation for move-to-go can be found at
# https://rubygems.org/gems/move-to-go (click Documentation)
#
# Generate the xml-file that should be sent to LIME Go with the
# command:
# move-to-go run
#
# Good luck.

# If you are importing files then you must set the FILES_FOLDER
# constant. FILES_FOLDER should point to the folder where the files
# are stored. FILES_FOLDER can be relative to the project directory
# or absolute. Note that you need to escape \ with a \ so in order to
# write \ use \\.

APIKEY = '1d821ac9a9be7192c93da633a9588fd9'
SITENAME = 'lundalogikab3'

# If you are importing files with an absolute path (eg
# m:\documents\readme.doc) then you probably wont have files at that
# location on the computer where "move-to-go run" is executed. Set
# FILES_FOLDER_AT_CUSTOMER to the folder where documents are stored at
# the customers site. Ie, in this example m:\documents.
# Note that you need to escape \ with a \ so in order to write \ use
# \\.
FILES_FOLDER_AT_CUSTOMER = "m:\\documents\\"

class Converter
    def to_organization(from_company, organization, rootmodel)

    	##Add tags, relations and other stuff
		
        return organization
    end

    def to_person(from_person, person, rootmodel)
    	
    	#Add tags, contact info and other stuff

    	person.email = from_person.email_addresses
    	return person
    end
end
