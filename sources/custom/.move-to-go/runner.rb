# encoding: UTF-8

require 'move-to-go'
require_relative("../converter")

def convert_source
    puts "Trying to convert a custom source to LIME Go..."

    converter = Converter.new

    if !converter.respond_to?(:to_go)
        puts "The converter must have a method called to_go that returns an instance of MoveToGo::RootModel."
        raise "The converter must have a method called to_go that returns an instance of MoveToGo::RootModel."
    end

    rootmodel = converter.to_go

    if rootmodel.nil?
        puts "The returned rootmodel is nil. You must return a MoveToGo::RootModel."
        raise "The returned rootmodel is nil. You must return a MoveToGo::RootModel."
    end

    if !rootmodel.is_a?(MoveToGo::RootModel)
        puts "The returned object is not an instance of MoveToGo::RootModel."
        raise "The returned object is not an instance of MoveToGo::RootModel."
    end

    return rootmodel
end

