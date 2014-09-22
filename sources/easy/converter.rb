# encoding: UTF-8
require 'go_import'

# Customize this file to suit your input files.
#
# Documentation go_import can be found at
# http://rubygems.org/gems/go_import
#
# go_import contains all objects in LIME Go such as organization,
# people, deals, etc. What properties each object has is described in
# the documentation.

# *** TODO:
#
# You must customize this template so it works with your LIME Easy
# database. Modify each to_* method and set properties on the LIME Go
# objects.
#
# Follow these steps:
#
# 1) Export all data from KONTAKT.mdb to a folder named Export located
# in the folder created by go_import new. Export data using the
# magical tool called PowerSellMigrationExport.exe that can be found
# in K:\Lundalogik\LIME Easy\Tillbehör\Migrationsexport.
#
# 2) Modify this file (the to_* methods) according to your customer's
# KONTAKT.mdb and wishes.
#
# 3) Run go-import run
#
# 4) Upload go.zip to LIME Go. First test your import on staging and
# when your customer has approved the import, run it on production.
#
# You will get a WARNING from 'go-import run' about FILES_FOLDER has
# not been set. You can ignore the warning since documents are
# exported with an absolute path from LIME Easy.

############################################################################
## Constants
# Edit these constants to fit your needs

# determines if documents should be imported.
# IMPORT_DOCUMENTS = true

# set the name of the company-resposible field.
# ORGANIZATION_RESPONSIBLE_FIELD = "Responsible"

# set the name of the deal-responsible field.
# DEAL_RESPONSIBLE_FIELD = "Responsible"


class Converter
    # Reads a row from the Easy exported Company.txt
    # and ads custom fields to the go_import organization.

    # NOTE!!! You should customize this method to include
    # and transform the fields you want to import to LIME Go.
    # The method includes examples of different types of
    # fields and how you should handle them.
    # Sometimes it's enough to uncomment some code and
    # change the row name but in most cases you need to
    # do some thinking of your own.
    def to_organization(organization, row)
        # Here are some standard fields that are present
        # on a LIME Go organization and are usually represented
        # as superfields in Easy.

        # organization.email = row['e-mail']
        # organization.organization_number = row['orgnr']
        # organization.web_site = row['website']

        ####################################################################
        ## Bisnode ID fields

        # NOTE!!! If a bisnode-id is present you dont need to set
        # fields like address or website since they are reterived from
        # PAR.

        # bisnode_id = row['Bisnode-id']

        # if bisnode_id && !bisnode_id.empty?
        #     organization.with_source do |source|
        #         source.par_se(bisnode_id)
        #     end
        # end

        # If a company is missing a bisnode ID then you should do this
        # in order to capture any possible data that is written manually
        # on that company card.

        # if bisnode_id && bisnode_id.empty?
        #     organization.web_site = row['website']
        # end

        ####################################################################
        # Address fields.
        # Addresses consists of several parts in LIME Go. Lots of other
        # systems have the address all in one line, to be able to
        # match when importing it is way better to split the addresses

        # organization.with_postal_address do |address|
        #     address.street = row['street']
        #     address.zip_code = row['zip']
        #     address.city = row['city']
        #     address.location = row['location']
        # end

        # Same as visting address

        # organization.with_visit_address do |addr|
        #     addr.street = row['visit street']
        #     addr.zip_code = row['visit zip']
        #     addr.city = row['visit city']
        # end

        #####################################################################
        ## Tags.
        # Tags are set and defined at the same place
        # Setting a tag: Imported is useful for the user

        # organization.set_tag("Imported")

        #####################################################################
        ## Option fields.
        # Option fields are normally translated into tags
        # The option field customer category for instance,
        # has the options "A-customer", "B-customer", and "C-customer"

        # organization.set_tag(row['customer category'])

        #####################################################################
        ## LIME Go Relation.
        # let's say that there is a option field in Easy called 'Customer relation'
        # with the options '1.Customer', '2.Prospect' '3.Partner' and '4.Lost customer'

        # if row['Customer relation'] == '1.Customer'
        # We have made a deal with this organization.
        #     organization.relation = GoImport::Relation::IsACustomer
        # elsif row['Customer relation'] == '3.Partner'
        # We have made a deal with this organization.
        #     organization.relation = GoImport::Relation::IsACustomer
        # elsif row['Customer relation'] == '2.Prospect'
        # Something is happening with this organization, we might have
        # booked a meeting with them or created a deal, etc.
        #     organization.relation = GoImport::Relation::WorkingOnIt
        # elsif row['Customer relation'] == '4.Lost customer'
        # We had something going with this organization but we
        # couldn't close the deal and we don't think they will be a
        # customer to us in the foreseeable future.
        #     organization.relation = GoImport::Relation::BeenInTouch
        # else
        #     organization.relation = GoImport::Relation::NoRelation
        # end

        return organization
    end

    # Reads a row from the Easy exported Company-Person.txt
    # and ads custom fields to the go_import organization.

    # NOTE!!! You should customize this method to include
    # and transform the fields you want to import to LIME Go.
    # The method includes examples of different types of
    # fields and how you should handle them.
    # Sometimes it's enough to uncomment some code and
    # change the row name but in most cases you need to
    # do some thinking of your own.
    def to_person(person, row)
        ## Here are some standard fields that are present
        # on a LIME Go person and are usually represented
        # as superfields in Easy.

        # person.direct_phone_number = row['Direktnummer']
        # person.mobile_phone_number = row['Mobil']
        # person.email = row['e-mail']
        # person.position = row['position']

        #####################################################################
        ## Tags.
        # Tags are set and defined at the same place
        # Setting a tag: Imported is useful for the user

        # person.set_tag("Imported")

        #####################################################################
        ## Checkbox fields.
        # Checkbox fields are normally translated into tags
        # Xmas card field is a checkbox in Easy

        # if row['Xmas card'] == "1"
        #     person.set_tag("Xmas card")
        # end

        #####################################################################
        ## Multioption fields or "Set"- fields.
        # Set fields are normally translated into multiple tags in LIME Go
        # interests is an example of a set field in LIME Easy.

        # if row['intrests']
        #     intrests = row['intrests'].split(';')
        #     intrests.each do |intrest|
        #         person.set_tag(intrest)
        #     end
        # end

        #####################################################################
        ## LIME Go custom fields.
        # This is how you populate a LIME Go custom field that was created in
        # the configure method.
        # person.set_custom_value("shoe_size", row['shoe size'])
    end

    # Reads a row from the Easy exported Project.txt
    # and ads custom fields to the go_import organization.

    # NOTE!!! You should customize this method to include
    # and transform the fields you want to import to LIME Go.
    # The method includes examples of different types of
    # fields and how you should handle them.
    # Sometimes it's enough to uncomment some code and
    # change the row name but in most cases you need to
    # do some thinking of your own.
    def to_deal(deal, row)
        ## Here are some standard fields that are present
        # on a LIME Go deal and are usually represented
        # as superfields in Easy.

        # deal.order_date = row['order date']

        # Deal.value should be integer
        # The currency used in Easy should match the one used in Go

        # deal.value = row['value']

        # should be between 0 - 100
        # remove everything that is not an intiger

        # deal.probability = row['probability'].gsub(/[^\d]/,"").to_i unless row['probability'].nil?

        # Sets the deal's status to the value of the Easy field. This
        # assumes that the status is already created in LIME Go. To
        # create statuses during import add them to the settings
        # during configure.

        # if !row['Status'].nil? && !row['Status'].empty?
        #     deal.status = row['Status']
        # end

        #####################################################################
        ## Tags.
        # Tags are set and defined at the same place
        # Setting a tag: Imported is useful for the user

        # deal.set_tag("Imported")

        return deal
    end

    def configure(rootmodel)
        #####################################################################
        ## LIME Go custom fields.
        # This is how you add a custom field in LIME Go.
        # Custom fields can be added to organization, deal and person.
        # Valid types are :String and :Link. If no type is specified
        # :String is used as default.

        # rootmodel.settings.with_person  do |person|
        #     person.set_custom_field( { :integration_id => 'shoe_size', :title => 'Shoe size', :type => :String} )
        # end

        # rootmodel.settings.with_deal do |deal|
            # assessment is default DealState::NoEndState
        #     deal.add_status( {:label => '1. Kvalificering' })
        #     deal.add_status( {:label => '2. Deal closed', :assessment => GoImport::DealState::PositiveEndState })
        #     deal.add_status( {:label => '4. Deal lost', :assessment => GoImport::DealState::NegativeEndState })
        # end
    end
end

