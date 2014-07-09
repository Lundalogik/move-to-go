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

        # Set custom field. If there is already an existing custom field, then it is overwritten.
        def set_custom_field(obj)
            @custom_fields = [] if @custom_fields.nil?

            if obj.is_a?(CustomField)
                field = obj
            else
                field = CustomField.new(obj)
            end

            if field.integration_id == "" && field.id == ""
                raise InvalidCustomFieldError, "Custom field must have either id or integration_id"
            end

            index = @custom_fields.find_index do |custom_field|
                custom_field.same_as?(field)
            end
            if index
                @custom_fields.delete_at index
            end

            @custom_fields.push field

            return field
        end
    end
end
