:: This script will convert an exported KONTAKT.mdb in the folder
:: Export to a file that can be imported into LIME Go.
:: The file will be named go.xml

@echo off
ruby convert.rb to_go --coworkers=Export\User.txt --organizations=Export\Company.txt --persons=Export\Company-Person.txt --orgnotes=Export\Company-History.txt --includes=Export\Project-Included.txt --deals=Export\Project.txt --dealnotes=Export\Project-History.txt  --output=go.xml


