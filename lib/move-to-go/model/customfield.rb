module MoveToGo
    class CustomFieldReference
        include SerializeHelper, ModelWithIntegrationIdSameAs

        attr_accessor :integration_id

        def initialize(opt=nil)
            if opt != nil
                serialize_variables.each do |myattr|
                    val = opt[myattr[:id]]
                    instance_variable_set("@" + myattr[:id].to_s, val) if val != nil
                end
            end
        end

        def serialize_variables
            [:integration_id].map {|p| { :id => p, :type => :string } }
        end

        def get_import_rows
            serialize_variables.map do |p|
                map_to_row p
            end
        end

        def serialize_name
            "CustomFieldReference"
        end
    end

    class CustomField
        include SerializeHelper, ModelWithIntegrationIdSameAs
        attr_accessor :id, :integration_id, :title, :type

        def initialize(opt=nil)
            if opt != nil
                serialize_variables.each do |myattr|
                    val = opt[myattr[:id]]
                    instance_variable_set("@" + myattr[:id].to_s, val) if val != nil
                end
            end
        end

        def serialize_variables
            [:id, :integration_id, :title, :type].map {|p| { :id => p, :type => :string } }
        end

        def get_import_rows
            serialize_variables.map do |p|
                map_to_row p
            end
        end

        def serialize_name
            "CustomField"
        end
    end

    class CustomValue
        include SerializeHelper
        attr_accessor :field, :value

        def initialize(opt=nil)
            if opt != nil
                serialize_variables.each do |myattr|
                    val = opt[myattr[:id]]
                    instance_variable_set("@" + myattr[:id].to_s, val) if val != nil
                end
            end
        end

        def serialize_variables
            [ { :id =>:field, :type => :custom_field_reference },
                { :id =>:value, :type => :string }]
        end

        def get_import_rows
            serialize_variables.map do |p|
                map_to_row p
            end
        end

        def serialize_name
            "CustomValue"
        end
    end
end
