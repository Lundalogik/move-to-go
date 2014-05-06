module FruitToLime
    class DealStatus
        include SerializeHelper

        attr_accessor :id, :label, :date, :note

        def serialize_variables
            [ :id, :label, :note ].map{ |p| { :id => p, :type => :string } } +
            [ :date ].map { |p| { :id => p, :type => :date } }
        end
    end
end
