# encoding: UTF-8
require 'move-to-go'
require 'roo'

# This Converter will convert an Excel file to a XML file that can be
# imported into LIME Go.
#
# You need to customize this script to suit your Excel file.

# First set the name of the Excel file to convert. It is a filename
# relative to this folder.
EXCEL_FILE = "Exempelfil.xlsx"

COWORKER_SHEET = "Medarbetare"
ORGANIZATION_SHEET = "Företag"
PERSON_SHEET = "Kontaktperson"
HISTORY_SHEET = "Anteckningar"

# Then you need to modify the script below according to the TODO
# comments.

# To generate the xml-file that should be sent to LIME Go with the
# command:
# move-to-go run

class Converter
    def configure(rootmodel)
        # *** TODO: Add custom field to your rootmodel here. Custom fields
        # can be added to organization, deal and person. Valid types
        # are :String and :Link. If no type is specified :String is
        # used as default.

        # Organizastion
        # rootmodel.settings.with_organization do |organization|
        #     organization.set_custom_field( { :integration_id => 'source', :title => 'Källa', :type => :Link } )
        # end

        #Person
        #rootmodel.settings.with_person  do |person|
            # person.set_custom_field( { :integration_id => 'shoe_size', :title => 'Shoe Size', :type => :String} )
        #end

        end

    def import_person_to_organization(row, rootmodel)
        person = to_person(row, rootmodel)
        organization = rootmodel.find_organization_by_integration_id(row['Kundnummer/FöretagsID'])

        if !organization.nil?
            organization.add_employee(person)
        end
    end

    def to_coworker(row)
        coworker = MoveToGo::Coworker.new()

        # *** TODO:
        #
        # Set coworker properties from the row.

        coworker.parse_name_to_firstname_lastname_se row['Namn/Titel']
        coworker.integration_id = row['Namn/Titel']
        if MoveToGo::EmailHelper.is_valid?(row['Email'])
            coworker.email = row['Email']
        end

        ccoworker.direct_phone_number = MoveToGo::PhoneHelper.parse_numbers_strict(row['DirectPhoneNumber'])
        coworker.mobile_phone_number = MoveToGo::PhoneHelper.parse_numbers_strict(row['MobilePhoneNumber'])
        coworker.home_phone_number = MoveToGo::PhoneHelper.parse_numbers_strict(row['HomePhoneNumber'])

        return coworker
    end

    def to_organization(row, rootmodel)
        organization = MoveToGo::Organization.new()

        # Integrationid is typically the id in the system that we are
        # getting the csv from. Must be set to be able to import the
        # same file more than once without creating duplicates
        organization.integration_id = row['Kundnummer/FöretagsID']

        # Sets the organization's relation. Relation must be a value
        # from MoveToGo::Relation.
        organization.relation = MoveToGo::Relation::IsACustomer

        # *** TODO:
        #
        # Set organization properties from the row.

        organization.name = row['Namn']
        organization.organization_number=row['Organisationsnummer']

        # Postaladdress
        organization.with_postal_address do |address|
             address.street = row['Postadress']
             address.zip_code = row['Postnummer']
             address.city = row['Postnummer']
        end

        # Visitingaddress
        organization.with_visit_address do |addr|
             addr.street = row['Besöksadress']
             addr.zip_code = row['Besökspostnummer']
             addr.city = row['Besöksort']
        end

        # Set responsible such as
        # organization.responsible_coworker = rootmodel.find_coworker_by_integration_id(row['Ansvarig saljare'])

        # Set categorytag
         if row['Företagskategori']
             category = row['Företagskategori'].split(',')
             category.each do |categorytag|
                 organization.set_tag(categorytag.strip)
             end
         end

        # Custom fields should be set like this.
        # organization.set_custom_value("source", "internet")

        ## LIME Go Relation.
        # let's say that there is a option field in Easy called 'Customer relation'
        # with the options '1.Customer', '2.Prospect' '3.Partner' and '4.Lost customer'

        if row['Relation'] == 'Kund'
        # We have made a deal with this organization.
             organization.relation = MoveToGo::Relation::IsACustomer
        elsif row['Relation'] == 'Prospekt'
        # Something is happening with this organization, we might have
        # booked a meeting with them or created a deal, etc.
             organization.relation = MoveToGo::Relation::WorkingOnIt
        elsif row['Relation'] == 'Tidigare kund'
             organization.relation = MoveToGo::Relation::WasACustomer
        # We had something going with this organization but we
        # couldn't close the deal and we don't think they will be a
        # customer to us in the foreseeable future.
        #     organization.relation = MoveToGo::Relation::BeenInTouch
        else
             organization.relation = MoveToGo::Relation::NoRelation
        end 

        return organization
    end

    def to_person(row, rootmodel)
        person = MoveToGo::Person.new()

        # *** TODO:
        #
        # Set person properties from the row.

        person.parse_name_to_firstname_lastname_se(row['Namn'])
        if MoveToGo::EmailHelper.is_valid?(row['Email'])
            person.email = row['Email']
        end

        person.direct_phone_number = row['Telefon']
        person.mobile_phone_number = row['Mobiltelefon']

        person.position = row['Titel']

        return person
    end

    def to_history(row, rootmodel)
        history = MoveToGo::History.new()

        # *** TODO:
        #
        # Set history properties from the row.

        history.organization = rootmodel.find_organization_by_integration_id(row['Kundnummer/FöretagsID'])
        history.created_by = rootmodel.find_coworker_by_integration_id(row['Skapad av medarbetare'])
        history.text = row['Textanteckningar/Historik']
        history.date = row['Skapad den']

        return history
    end
end
