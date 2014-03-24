module FruitToLime
    class DealStatus
        include SerializeHelper

        attr_accessor :id, :label

        def serialize_variables
            [ :id, :label ].map{ |p| { :id => p, :type => :string } }
        end
    end
end
