# encoding: utf-8
module FruitToLime
    class ClassSettings
        include SerializeHelper
        attr_reader :custom_fields

        def initialize(opt = nil)
            if opt != nil
                serialize_variables.each do |myattr|
                    val = opt[myattr[:id]]
                    instance_variable_set("@" + myattr[:id].to_s, val) if val != nil
                end
            end
        end

        def serialize_variables
            [{:id => :custom_fields, :type => :custom_fields} ]
        end

        def serialize_name
            "ClassSettings"
        end

        def set_custom_field(obj)
            @custom_fields = [] if @custom_fields==nil

            field = CustomField.new(obj)

            index = @custom_fields.find_index do |custom_field| 
                custom_field.same_as?(field)
            end
            if index
                @custom_fields.delete_at index
            end

            @custom_fields.push field

            return field
        end

        def add_custom_field(obj)
            @custom_fields = [] if @custom_fields==nil

            field = CustomField.new(obj)
            @custom_fields.push field

            return field
        end
    end
end