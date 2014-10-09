# go_import [![Build Status](https://travis-ci.org/Lundalogik/go_import.png?branch=master)](https://travis-ci.org/Lundalogik/go_import)

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

## Help

You can find generated documentation on [rubydoc](http://rubydoc.info/gems/go_import/frames)

## Legal

### License
[Mozilla Public License, version 2.0](LICENSE)

### Copyright
Copyright Lundalogik AB
