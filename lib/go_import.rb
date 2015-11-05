module GoImport
    private
    def self.require_all_in(folder)
        Dir.glob(File.join( File.dirname(File.absolute_path(__FILE__)),folder), &method(:require))
    end

    require 'go_import/errors'
    require 'go_import/serialize_helper'
    require 'go_import/model_helpers'
    require 'go_import/can_become_immutable'
    GoImport::require_all_in 'go_import/model/*.rb'
    require 'go_import/csv_helper'
    require 'go_import/roo_helper'
    require 'go_import/phone_helper'
    require 'go_import/email_helper'
    require 'go_import/excel_helper'
    require 'go_import/templating'
    require 'go_import/source'
end
