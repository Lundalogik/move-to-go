# Fruit_To_LIME [![Build Status](https://travis-ci.org/Lundalogik/go_import.png?branch=master)](https://travis-ci.org/Lundalogik/fruit_to_lime) 

## What is Fruit_To_LIME?
Fruit_To_LIME is a ruby-based import tool for [LIME Go](http://www.lime-go.com/). It can take virtually any input and generate pretty looking xml-files that LIME Go likes.
These files can then easily be imported to LIME Go by Lundalogik. During an import a automatic matching against all base data will be performed. 

Organizations, Persons, Deals, Notes, Coworkers and Documents can be imported to LIME Go.

Fruit_to_lime is a [ruby gem](https://rubygems.org/gems/fruit_to_lime). Install with 

```shell
gem install fruit_to_lime
```

## Working with templates

To help you get started a couple of templates for different sources are included in Fruit_To_LIME. These templates contains basic code and a folder structure for a specific import. 
It is not required to use a template, but they will help you a lot along the way.

You can list the available templates with 

```shell
fruit_to_lime list_templates
```
###Current templates

- Import from CSV-files
- Import from LIME Easy
- Import from a Excel-file
- Import from MS-SQL Server
- Import from VISMA SPCS

To create a new project, create a new folder and in that folder run

```shell
> fruit_to_lime unpack_template TEMPLATE
```

You'll now have a folder structure looking like this:
    
    ./convert.rb
    ./Gemfile
    ./lib/
        ./tomodel.rb
    ./Rakefile.rb
    ./spec/

If you have Bundler installed run to get the required gems for the template:

```shell
bundle install
```

Your job is now to implement `./lib/tomodel.rb`

## tomodel.rb

`tomodel.rb` has a few functions for you to implement. In the templates theses functions are more or less done. What you need to do is to do the data-mapping and adding tags.
Example of an CSV import of 4 separate CSV files, containing coworkers, organizations, persons and deals:

### Function `to_model()`:

This function reads the data and pipes it to other functions to do the setup and mapping

```ruby
def process_rows(file_name)
    data = File.open(file_name, 'r').read.encode('UTF-8',"ISO-8859-1")
    rows = FruitToLime::CsvHelper::text_to_hashes(data)
    rows.each do |row|
        yield row
    end
end

def to_model(coworkers_filename, organization_filename, persons_filename, deals_filename)
    # A rootmodel is used to represent all entitite/models
    # that is exported
    rootmodel = FruitToLime::RootModel.new

    configure rootmodel

    # coworkers
    # start with these since they are referenced
    # from everywhere....
    if coworkers_filename != nil
        process_rows coworkers_filename do |row|
            rootmodel.add_coworker(to_coworker(row))
        end
    end

    # organizations
    if organization_filename != nil
        process_rows organization_filename do |row|
            rootmodel.add_organization(to_organization(row, rootmodel))
        end
    end

    # persons
    # depends on organizations
    if persons_filename != nil
        process_rows persons_filename do |row|
            # adds it self to the employer
            to_person(row, rootmodel)
        end
    end

    # deals
    # deals can reference coworkers (responsible), organizations
    # and persons (contact)
    if deals_filename != nil
        process_rows deals_filename do |row|
            rootmodel.add_deal(to_deal(row, rootmodel))
        end
    end

    return rootmodel
end
```

### Function `to_organisations`:

This function reads the data and pipes it to other functions to do the setup and mapping

## Runing an import

Use tomodel.rb to map import data to LIME Go data. When you are done execute (this may vary from template to template)

```shell
ruby convert.rb to_go infile.cvs go-importdata.xml
```

to create an xml-file (go-importdata.xml in this case) that can be imported by LIME Go.

## Help

You can find generated documentation on [rubydoc](http://rubydoc.info/gems/fruit_to_lime/frames)

## Legal

### License
[Mozilla Public License, version 2.0](LICENSE)

### Copyright
Copyright Lundalogik AB
