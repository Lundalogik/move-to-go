module MoveToGo
    private
    def self.require_all_in(folder)
        Dir.glob(::File.join(::File.dirname(::File.absolute_path(__FILE__)),folder), &method(:require))
    end

    require_relative 'move-to-go/errors'
    require_relative 'move-to-go/serialize_helper'
    require_relative 'move-to-go/model_helpers'
    require_relative 'move-to-go/can_become_immutable'
    MoveToGo::require_all_in 'move-to-go/model/*.rb'
    require_relative 'move-to-go/csv_helper'
    require_relative 'move-to-go/roo_helper'
    require_relative 'move-to-go/phone_helper'
    require_relative 'move-to-go/email_helper'
    require_relative 'move-to-go/excel_helper'
    require_relative 'move-to-go/templating'
    require_relative 'move-to-go/source'
    require_relative 'move-to-go/shard_helper'
end
