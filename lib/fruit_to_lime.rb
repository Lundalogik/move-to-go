module FruitToLime
    private
    def self.require_all_in(folder)
        Dir.glob(File.join( File.dirname(File.absolute_path(__FILE__)),folder), &method(:require))
    end

    require 'fruit_to_lime/errors'
    require 'fruit_to_lime/serialize_helper'
    require 'fruit_to_lime/model_helpers'
    FruitToLime::require_all_in 'fruit_to_lime/model/*.rb'
    require 'fruit_to_lime/csv_helper'
    require 'fruit_to_lime/roo_helper'
    require 'fruit_to_lime/phone_helper'
    require 'fruit_to_lime/templating'
end
