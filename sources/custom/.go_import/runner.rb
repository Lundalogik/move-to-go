# encoding: UTF-8

require 'go_import'
require_relative("../converter")

def convert_source
    puts "Trying to convert a custom source to LIME Go..."

    converter = Converter.new

    if !converter.respond_to?(:to_go)
        puts "The converter must have a method called to_go that returns an instance of GoImport::RootModel."
        raise "The converter must have a method called to_go that returns an instance of GoImport::RootModel."
    end

    rootmodel = converter.to_go

    if rootmodel.nil?
        puts "The returned rootmodel is nil. You must return a GoImport::RootModel."
        raise "The returned rootmodel is nil. You must return a GoImport::RootModel."
    end

    if !rootmodel.is_a?(GoImport::RootModel)
        puts "The returned object is not an instance of GoImport::RootModel."
        raise "The returned object is not an instance of GoImport::RootModel."
    end

    return rootmodel
end

