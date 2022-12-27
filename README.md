# move-to-go

## What is move-to-go?
move-to-go is a ruby-based migration tool for [Lime Go](http://www.lime-go.com/). 
It can take virtually any data source as input and generate a zip file that LIME Go likes.
These files can then easily be migrated to Lime Go by Lime Technologies. 
During an migration an automatic matching against all base data will be performed.

Organizations, Persons, Deals, Histories, Todos, Coworkers and Documents can be migrated to Lime Go.

move-to-go is a [ruby gem](https://rubygems.org/gems/move-to-go). Install with

```shell
gem install move-to-go
```

## Getting started
[We have put together a simple step by step guide for preforming a migrations](step-by-step.md)

## Working with sources

To help you get started a couple of different sources are included in move-to-go. 
These sources contains basic code and a folder structure for a specific migration.

You can list the available sources with

```shell
move-to-go list-sources
```
### Current sources

- Migrate from CSV-files
- Migrate from Lime Easy
- Migrate from a Excel-file
- Migrate from VISMA Administration 2000
- Migrate from Salesforce
- Migrate from a custom source

To create a new project with

```shell
move-to-go new excel-migration excel
```

This will create a folder named excel-migration from the source excel. It is good practice to name the project after the customer that you are doing the migration for.

In the project folder you have a file called converter.rb. It is now your job to customize this script to do the data-mapping and adding tags. Follow the instructions in converter.rb to do the data-mapping.

To create the zip-file that should be sent to Lime Go use

```shell
move-to-go run
```

This will create a go_0.zip file. If the file already exists it will be replaced. 

If the migration contains lots of data, the result will be split into several zip files.

**Note:** There is a max request length of ~2gb currently in place on the lime go admin site where the zips are going to be eventually uploaded to. If after converting the data you have zip(s) that have a size that is higher than 2gb then you should supply the `--shard_size=<number_of_items_per_data_type>` option when running this command and set it to a number that is substantially lower than the number of items of your largest zip file. Usually this might happen when you are converting documents i.e. If you have 12000 documents in your largest zip file of 3.5 gb and you supply the option with a value of 5000 then you will end up with 2 zip files of ~1.2gb each. By default, the shard_zize is 25000 so lowering the number will cause the script to return more zip files but that is obviously expected.

## What happens when you move to Lime Go?

Since Lime Go contains [all organizations and persons](http://www.lime-go.com/foretagsinformation/) an migration not an import in the traditional sense. 
What you really do when migrating organizations is to tell Lime Go that these organizations are my customers.

When organizations (and persons) are migrated Lime Go will try to match your organizations with organizations in our database. Lime Go will try to match organizations by organization number, name, address, etc. If the migration contains more data about each organization then the probability that Lime Go will find a match increase.

If an organization is found it will get the relation set in the migration (default is Customer), responsible coworker, integration id, tags and custom fields. If a match is found Lime Go will *not* migrate fields such as address, phone number, website, etc since we believe that our data is more up to date than your data. Your data is only used for matching in this case.

If a match is not found, Lime Go will create a new organization with all data from the migrat file. The organization will be tagged with "FailedToMatch". This means that for these organizations address, phone number, etc will be migrated.

If more than one organization in the migration file refers to the same organization Lime Go the migrated organizations will be tagged with "PossibleDuplicate". Fields such as address, phone number, etc will *not* be migrated.

All migrated organizations will be tagged "Import".

Coworkers, deals and histories are *always* migrated as is. These objects are linked to an organization.

## Running an migration more than once.

Lime Go will *not* overwrite data on existing organizations. This means that if you run an migration twice with different data Lime Go will not get the data from the last run.

The reasoning behind this that the migration is a way to load an initial state into Lime Go. 
It is not a way to build long running integrations. We are building a REST API for integrations.

---

## Integration id

It is required to set integration id for all migrated objects. The integration id for example used to connect deals to organizations and coworkers are deals. When migrating Lime Go will try to match migrated objects to existing objects by integration id.

If an integration id is missing in your migration file you can generate one from the row.

```ruby
organization.integration_id = row.to_hash
```

As long as your data is free from duplicates this will create a unique key, which is also recallable with the exact same input data. Do not use organization name as integration id. 

The integrationid is NOT the same as Bisnode-id. See below for more info how to handle Bisnode-ids.

## Rootmodel
The rootmodel is an object that keeps track of your migrated data and turns it into a format Lime Go can read. The rootmodel helps you keep track go objects and relations between them during the migration

Datasource -> [your code] -> rootmodel -> go.zip

Helpfull rootmodel code:
```ruby

# create a brand new rootmodel. Usually only done once for an migration

rootmodel = MoveToGo::RootModel.new


# Settings. The rootmodel is capable of storing how a brand new
# Lime Go app should be set up. Most commonly; which custom fields should exist
# and how the business statuses should be configured


rootmodel.settings.with_person  do |person|
    person.set_custom_field( { :integration_id => 'shoe_size', :title => 'Shoe size', :type => :String} )
end

rootmodel.settings.with_deal do |deal|
    deal.add_status( {:label => '1. Kvalificering' })
    deal.add_status( {:label => '2. Deal closed', :assessment => MoveToGo::DealState::PositiveEndState })
    deal.add_status( {:label => '4. Deal lost', :assessment => MoveToGo::DealState::NegativeEndState })
end


# Once a object, such as an organisation is created and mapped to migrated data
# it should be added to the rootmodel

organisation = MoveToGo::Organisation.new()
# Add data to your new fancy organisation…
rootmodel.add_organization(organisation)

# As migrated persons belong to an migrated organisation, they must be mapped
# together. The rootmodel will help you with this:
person = MoveToGo::Person.new()
#Add data to your fancy new person…
id = data_row['id']
organisation = rootmodel.find_organization_by_integration_id(id)
organisation.add_employee(person)

# The same goes for deals and histories, however, the syntax differs slightly.
# A deal or a history has relations to both organisations and persons

deal = MoveToGo::Deal.new()
#Add data to your fancy new deal…
org_id = deal_data_row['organisation_id']
person_id = deal_ata_row['person_id']
deal.customer = rootmodel.find_organization_by_integration_id(org_id)
deal.customer_contact = rootmodel.find_person_by_integration_id(org_id)

# History logs
# There are five types of history logs:
# - SalesCall: We talked to the client about a sale. This might be a phone call or a talk in person.
# - Comment: This is a general comment about the organization or deal.
# - TalkedTo: This is a general comment regarding a talk we had with someone at the client.
# - TriedToReach: We tried to reach someone but failed.
# - ClientVisit: We had a meeting at the client's site.
comment = MoveToGo::Comment.new()
comment.integration_id = ...
comment.text = ...
comment.created_by = rootmodel.find_coworker_by_integration_id(...)
comment.deal = rootmodel.find_deal_by_integration_id(...)                 # If related to deal
comment.person = rootmodel.find_person_by_integration_id(...)             # if related to person
comment.organization = rootmodel.find_organization_by_integration_id(...) # if related to organization
rootmodel.add_comment(comment)

salesCall = MoveToGo::SalesCall.new()
# Set properties...
rootmodel.add_sales_call(salesCall)

talkedTo = MoveToGo::TalkedTo.new()
# Set properties...
rootmodel.add_talked_to(talkedTo)

triedToReach = MoveToGo::TriedToReach.new()
# Set properties...
rootmodel.add_tried_to_reach(triedToReach)

clientVisit = MoveToGo::clientVisit.new()
# Set properties...
rootmodel.add_client_visit(clientVisit)

Note: When history logs have been migrated to go. 
It's possible to make a re-migrate to update fields, but it's not possible to change type of history log.
```


## Organisations
A core concept in the Lime Go migration is a organisation. A organisation. When migrating an organisation to Lime Go, we will try to match the organisation to existing source data in Lime Go. The matching is performed by fuzzy lookups on all supplied data, meaning the more and better data you supply to the migration, the higher the likelihood of a positive match will be. Many of your supplied attributes will only be used for matching and won't override our source data in Lime Go, such as addresses. Attributes, such as organisation number or Bisnode-id, are considered more important then other attributes and will greatly  improve the likelihood of a positive match.

An organisation has the following attributes and functions. Assuming we have read each organisation in the source data into a hash, `row`.

```ruby
organisation = MoveToGo::Organisation.new()
organisation.name = row['name']
organization.organization_number = row['orgnr']
organization.web_site = row['website']
bisnode_id = row['Bisnode-id']

# It's not uncommon that e-mail addresses are miss formed from a migration source.
# MoveToGo supplies a helper function for this
if MoveToGo::EmailHelper.is_valid?(row['e-mail'])
    organization.email = row['e-mail']
end

organization.with_postal_address do |address|
    address.street = row['street']
    address.zip_code = row['zip']
    address.city = row['city']
end

organization.with_visit_address do |addr|
    addr.street = row['visit street']
    addr.zip_code = row['visit zip']
    addr.city = row['visit city']
end

# Add a responsible coworker to the organisation
organization.responsible_coworker = rootmodel.find_coworker_by_integration_id(row['Medarbetare'])

# A very important and common thing is to set tags on organisations
organization.set_tag(row['customer category'])

# If you have created custom fields in the settings you can set their value.
# First parameter is the id of the custom field and second is the desired value
organization.set_custom_value(”customer_number”, row['cust_no'])

# Relations. There are five relation types in Lime Go to pick from.
# The following is an example of assigning relations to a organisation
if row['Customer relation'] == 'Customer'
    # We have made a deal with this organization.
    organization.relation = MoveToGo::Relation::IsACustomer
elsif row['Customer relation'] == 'Prospect'
    # Something is happening with this organization, we might have
  # booked a meeting with them or created a deal, etc.
    organization.relation = MoveToGo::Relations::WorkingOnIt
elsif row['Customer relation'] == 'Lost customer'
    # We had something going with this organization but we
    # couldn't close the deal and we don't think they will be a
    # customer to us in the foreseeable future.
    organization.relation = MoveToGo::Relation::WasACustomer
else
    organization.relation = MoveToGo::Relation::BeenInTouch
end

```

### Bisnode IDs
If the source data contains Bisnode-ids you should use them for matching. Move-to-go supports Bisnode-ids for Swedish, Norwegian and Danish organizations. If your source data have Swedish Bisnode-ids use the following in your to_organization (or similar):


```ruby
organization.with_source do |source|
    source.par_se('1:2345')
end
```

Where `1:2345` is the Bisnode-id. If the id is in the form `2345` you should prepend with `1:`.

If your source has Norwegian organizations use `ecp_no` instead of `par_se`. Use `ecp_dk` for Danish.

### Organization duplicates
Organization duplicates can be a problem when doing migrations. In best case they will just end up as possible duplicates in Lime Go.
In worst case they will cause the migration to fail.
You can find, handle and remove duplicates in Move-to-go, by:

```ruby
rootmodel.organizations
    .find_duplicates_by(:name,:organization_number, "visiting_address.city")
    .map_duplicates { |duplicate_set| # Handle each duplicate set ([org1, org2, ...])
        duplicate_set.merge_all! # Move all data in the set to one of the organizations. Returns the empty organizations
    }
    .each { |org|
        rootmodel.remove_organization(org) #Remove the empty organizations from the rootmodel
    }
```

Instead of using `merge_all!` you can handle your mergeing manualy by

```ruby
rootmodel.organizations
    .find_duplicates_by(:name)
    .map_duplicates { |duplicate_set| # Handle each  
        org_to_keep = duplicate_set.find{|org| org.my_property_i_care_about == "My Value" }
        duplicate_set.each{|org|
            if org != org_to_keep
                org_to_keep.move_data_from(org)
            end
        }
        duplicate_set.remove(org_to_keep)
        duplicate_set # Return the organizations to be removed
    }
    .each { |org|
        rootmodel.remove_organization(org)
    }
```



## Persons
Persons are employees of the organizations in Lime Go. Just as with the organisations, the migrated persons will be
matched against the source data in Lime Go.

```ruby
person = MoveToGo::Person.new()

person.first_name = "Kalle"
person.last_name = "Kula"
# It is common that the persons name in the migrated data isn't in seperate
# fields, but as a single string. MoveToGo supplies a helper function
person.parse_name_to_firstname_lastname_se(row['name'])
# or

# Validate email:
if MoveToGo::EmailHelper.is_valid?(row['Email'])
        person.email = row['Email']
end

# If the phone number data is a mess
person.mobile_phone_number, person.direct_phone_number = MoveToGo::PhoneHelper.parse_numbers(row['Telefon'], [",", "/", "\\"])
# or if it is very well formed
person.direct_phone_number = row['direct number']
person.mobile_phone_number = row['mobile']

person.position = row['position']

# Add tags. Tags are used for values
person.set_tag("VIP")

# If you have created custom fields during the setup
person.set_custom_value("shoe_size", row['shoe size'])

```

## Smart helper functions and ruby trix

### Parse a persons full name into a first and last name
```ruby
person.parse_name_to_firstname_lastname_se(name, when_missing = '')
```

### Parse a phone number
```ruby

number = MoveToGo::PhoneHelper.parse_numbers("046 - 270 48 00")

# In the case there are multiple numbers in the same string
source = "046 - 270 48 00/ 031-712 44 00"
number1, number2 = MoveToGo::PhoneHelper.parse_numbers(source, '/')

#If you are pick about only getting valid phone number you can use a strict mode.
# Parses the specifed number_string and returns only valid numbers.
MoveToGo::PhoneHelper.parse_numbers_strict(number_string, delimiters = ',')

MoveToGo::PhoneHelper.set_country_code(country_code)
# Sets the country code used during parsning. The default is Swedish (:se) and
# if you are parsing Swedish numbers you don't need to set the country code.

```

### Validate an email address
```ruby
MoveToGo::EmailHelper.is_valid?("kalle.kula@lundalogik.se") => True

MoveToGo::EmailHelper.is_valid?("kalle@.kula @lundalogik.se") => False
```

## Runtime configuration

By default move-to-go will set a deal's responsible to the 'migrator' coworker if no one specified. You can override this to allow no coworker by adding the following to your converter.rb

```ruby
ALLOW_DEALS_WITHOUT_RESPONSIBLE = 1
```

By default move-to-go will **NOT** report any warnings in regards for example to data that have not been able to be converted. If you want to see these warnings then you should set the following in converter.rb
```ruby
REPORT_RESULT = 1
```

## Development of core lib
It's possible to execute projects without to install move-to-go

```
Example from git root:
  Create project
  > ruby bin/move-to-go new my-test base-crm
  As the above command also install you have to uninstall
  > gem uninstall move-to-go

  Project adaption, change imports to relative:

  In file 'converter.rb', replace:
    require 'move-to-go'
  with:
    require_relative('../lib/move-to-go')

  In file 'move-to-go/runner.rb', replace:
    require 'move-to-go'
  with:
    require_relative('../../lib/move-to-go')

  > cd <your project folder>
  > ruby ../bin/move-to-go run
```

## Help

You can find generated documentation on [rubydoc](http://rubydoc.info/gems/move-to-go/frames)

You can find the FAQ owned by ES on the [repo's wiki](https://github.com/Lundalogik/move-to-go/wiki/FAQ)

## Legal

### License
[Mozilla Public License, version 2.0](LICENSE)

### Copyright
Copyright Lime Technologies AB
