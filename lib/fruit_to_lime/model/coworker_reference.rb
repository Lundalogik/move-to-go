module FruitToLime
    class CoworkerReference
        include SerializeHelper
        attr_accessor :id, :heading, :integration_id

        def initialize()
        end

        def serialize_variables
            [:id, :heading, :integration_id].map {|p| {:id => p, :type => :string} }
        end

        def serialize_name
            "CoworkerReference"
        end
    end
end
