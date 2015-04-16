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

When organizations (and persons) are imported LIME Go will try to match your organizations with organizations in our database. LIME Go will try to match organizations by organization number, name, address, etc. If the import contains more data about each organization then the probablity that LIME Go will find a match increase.

If an organization is found it will get the relation set in the import (default is Customer), responsible coworker, integration id, tags and custom fields. If a match is found LIME Go will *not* import fields such as address, phone number, website, etc since we belive that our data is more uptodate than your data. Your data is only used for matching in this case.

If a match is not found, LIME Go will create a new organization with all data from the import file. The organization will be tagged with "FailedToMatch". This means that for these organizations address, phone number, etc will be imported.

If more than one organization in the import file refers to the same organization LIME Go the imported organizations will be tagged with "PossibleDuplicate". Fields such as address, phone number, etc will *not* be impoted.

All imported organizations will be tagged "Import".

Coworkers, deals and notes is *always* imported as is. These objects are linked to an organization.

### Integration id

Integration Ids are required for coworkers, organizations and deals and must be set before the object is added to the rootmodel. Some sources will automagically (such as LIME Easy) set the integration id while others (Execel) require you to set it.

### Running an import more than once.

LIME Go will *not* overwrite data on existing organizations. This means that if you run an import twice with different data LIME Go will not get the data from the last run.

The reasoning behind this that the import is a way to load an initial state into LIME Go. It is not a way to build long running integrations. We are building a REST API for integrations.

## Help

You can find generated documentation on [rubydoc](http://rubydoc.info/gems/go_import/frames)

## Legal

### License
[Mozilla Public License, version 2.0](LICENSE)

### Copyright
Copyright Lundalogik AB
