# go_import

## What is go_import?
go_import is a ruby-based import tool for [LIME Go](http://www.lime-go.com/). It can take virtually any data source as input and generate a zip file that LIME Go likes.
These files can then easily be imported to LIME Go by Lundalogik. During an import an automatic matching against all base data will be performed.

Organizations, Persons, Deals, Notes, Coworkers and Documents can be imported to LIME Go.

go_import is a [ruby gem](https://rubygems.org/gems/go_import). Install with

```shell
gem install go_import
```

## Working with sources

To help you get started a couple of different sources are included in go-import. These sources contains basic code and a folder structure for a specific import.

You can list the available sources with

```shell
go-import list-sources
```
###Current sources

- Import from CSV-files
- Import from LIME Easy
- Import from a Excel-file
- Import from VISMA SPCS
- Import from Salesforce
- Import from a custom source

To create a new project with

```shell
go-import new excel-migration excel
```

This will create a folder named excel-migration from the source excel. It is good practice to name the project after the customer that you are doing the migration for.

In the project folder you have a file called converter.rb. It is now your job to customize this script to do the data-mapping and adding tags. Follow the instructions in converter.rb to do the data-mapping.

To create the zip-file that should be sent to LIME Go use

```shell
go-import run
```

This will create a go.zip file. If the file already exists it will be replaced.

## What happens in LIME Go during import?

Since LIME Go contains [all organizations and persons](http://www.lime-go.com/foretagsinformation/) an import not an import in the traditional sense. What you really do when importing organizations is to tell LIME Go that these organizations are my customers.

When organizations (and persons) are imported LIME Go will try to match your organizations with organizations in our database. LIME Go will try to match organizations by organization number, name, address, etc. If the import contains more data about each organization then the probability that LIME Go will find a match increase.

If an organization is found it will get the relation set in the import (default is Customer), responsible coworker, integration id, tags and custom fields. If a match is found LIME Go will *not* import fields such as address, phone number, website, etc since we believe that our data is more up to date than your data. Your data is only used for matching in this case.

If a match is not found, LIME Go will create a new organization with all data from the import file. The organization will be tagged with "FailedToMatch". This means that for these organizations address, phone number, etc will be imported.

If more than one organization in the import file refers to the same organization LIME Go the imported organizations will be tagged with "PossibleDuplicate". Fields such as address, phone number, etc will *not* be imported.

All imported organizations will be tagged "Import".

Coworkers, deals and notes are *always* imported as is. These objects are linked to an organization.

## Integration id

It is required to set integration id for all imported objects. The integration id for example used to connect deals to organizations and coworkers are deals. When importing LIME Go will try to match imported objects to existing objects by integration id.

If an integration id is missing in your import file you can generate one from the row.

```ruby
organisation.integration_id = row.to_hash
```

As long as your data is free from duplicates this will create a unique key, which is also recallable with the exact same input data.

## Rootmodel
The rootmodel is an object that keeps track of your imported data and turns it into a format LIME Go can read. The rootmodel helps you keep track go objects and relations between them during the import

Datasource -> [your code] -> rootmodel -> go.zip

Helpfull rootmodel code:
```ruby

# create a brand new rootmodel. Usually only done once for an import

rootmodel = GoImport::RootModel.new


# Settings. The rootmodel is capable of storing how a brand new
# LIME GO app should be set up. Most commonly; which custom fields should exist	 and how the business statuses should be configured

rootmodel.settings.with_person  do |person|
	person.set_custom_field( { :integration_id => ’shoe_size’, :title => ’Shoe size’, :type => :String} )
end

rootmodel.settings.with_deal do |deal|
	deal.add_status( {:label => ’1. Kvalificering’ })
	deal.add_status( {:label => ’2. Deal closed’, :assessment => GoImport::DealState::PositiveEndState })
	deal.add_status( {:label => ’4. Deal lost’, :assessment => GoImport::DealState::NegativeEndState })
end


# Once a object, such as an organisation is created and mapped to import data it should be added to the rootmodel

organisation = GoImport::Organisation.new()
# Add data to your new fancy organisation…
rootmodel.add_organization(organisation)

# As imported persons belong to an imported organisation, they must be mapped together. The rootmodel will help you with this:
person = GoImport::Person.new()
#Add data to your fancy new person…
id = import_data_row[’id’]
organisation = rootmodel.find_organization_by_integration_id(id)
organisation.add_employee(person)

# The same goes for deals and notes, however, the syntax differs slightly.
# A deal or a note has relations to both organisations and persons

deal = GoImport::Deal.new()
#Add data to your fancy new deal…
org_id = deal_import_data_row[’organisation_id’]
person_id = deal_import_data_row[’person_id’]
deal.organisation = rootmodel.find_organization_by_integration_id(org_id)
deal.organisation = rootmodel.find_person_by_integration_id(org_id)
#Above example works the same for a note

```


## Organisations
A core concept in the LIME Go import is a organisation. A organisation. When importing an organisation to LIME Go, we will try to match the organisation to existing source data in LIME Go. The matching is performed by fuzzy lookups on all supplied data, meaning the more and better data you supply to the import, the higher the likelihood of a positive match will be. Many of your supplied attributes will only be used for matching and won’t override our source data in LIME Go, such as addresses. Attributes, such as organisation number or Bisnode-id, are considered more important then other attributes and will greatly  improve the likelihood of a positive match.

An organisation has the following attributes and functions. Assuming we have read each organisation in the source data into a hash, `row`.

```ruby
organisation = GoImport::Organisation.new()
organisation.name = row[’name’]
organization.organization_number = row[’orgnr’]
organization.web_site = row[’website’]
bisnode_id = row[’Bisnode-id’]

# It’s not uncommon that e-mail addresses are miss formed from a import source. GoImport supplies a helper function for this
if GoImport::EmailHelper.is_valid?(row[’e-mail’])
	organization.email = row[’e-mail’]
end

organization.with_postal_address do |address|
	address.street = row[’street’]
	address.zip_code = row[’zip’]
	address.city = row[’city’]
	address.location = row[’location’] # Country
end

organization.with_visit_address do |addr|
	addr.street = row[’visit street’]
 	addr.zip_code = row[’visit zip’]
	addr.city = row[’visit city’]
end

# Add a responsible coworker to the organisation
organization.responsible_coworker = rootmodel.find_coworker_by_integration_id(row[’Medarbetare’])

# A very important and common thing is to set tags on organisations
organization.set_tag(row[’customer category’])
```

## Running an import more than once.

LIME Go will *not* overwrite data on existing organizations. This means that if you run an import twice with different data LIME Go will not get the data from the last run.

The reasoning behind this that the import is a way to load an initial state into LIME Go. It is not a way to build long running integrations. We are building a REST API for integrations.

## Help

You can find generated documentation on [rubydoc](http://rubydoc.info/gems/go_import/frames)

## Legal

### License
[Mozilla Public License, version 2.0](LICENSE)

### Copyright
Copyright Lundalogik AB
