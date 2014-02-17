module FruitToLime
    class CoworkerReference 
        attr_accessor :id, :heading, :integration_id
        def serialize_variables
            [:id, :text, :integration_id, :classification].map {|p| {:id=>p,:type=>:string} }
        end
        def serialize_name
            "CoworkerReference"
        end
        include SerializeHelper
        def initialize()
        end
    end
end