module GoImport
    private
    def self.require_all_in(folder)
        Dir.glob(::File.join(::File.dirname(::File.absolute_path(__FILE__)),folder), &method(:require))
    end

    require_relative 'go_import/errors'
    require_relative 'go_import/serialize_helper'
    require_relative 'go_import/model_helpers'
    require_relative 'go_import/can_become_immutable'
    GoImport::require_all_in 'go_import/model/*.rb'
    require_relative 'go_import/csv_helper'
    require_relative 'go_import/roo_helper'
    require_relative 'go_import/phone_helper'
    require_relative 'go_import/email_helper'
    require_relative 'go_import/excel_helper'
    require_relative 'go_import/templating'
    require_relative 'go_import/source'
    require_relative 'go_import/shard_helper'
end
