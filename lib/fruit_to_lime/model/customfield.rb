module FruitToLime
    class CustomField

        attr_accessor :id, :integration_id, :title, :value
        def serialize_variables
            [:id, :integration_id, :title, :value].map {|p| {:id=>p,:type=>:string} }
        end

        def get_import_rows
            serialize_variables.map do |p|
                map_to_row p
            end
        end

        def serialize_name
            "CustomField"
        end
        include SerializeHelper
        def initialize(opt=nil)
            if opt!=nil
                serialize_variables.each do |myattr|
                    val = opt[myattr[:id]]
                    instance_variable_set("@"+myattr[:id].to_s,val) if val!=nil
                end
            end
        end
 
	end
end