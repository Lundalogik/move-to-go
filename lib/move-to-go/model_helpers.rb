module MoveToGo
    module ModelHasCustomFields
        # @example
        #     value = row['business_value_partner_info']
        #     obj.set_custom_value("external_url", "https://www.somecompany.com")        
        def set_custom_value(integration_id, value)
            @custom_values = [] if @custom_values == nil

            if value.nil?
                return
            end

            valueAsString = value.to_s
            if valueAsString.length == 0
                return
            end
            
            field = CustomFieldReference.new({:integration_id => integration_id})
            custom_value = CustomValue.new
            custom_value.value = valueAsString
            custom_value.field = field

            index = @custom_values.find_index do |custom_value|
                custom_value.field.same_as?(field)
            end

            if index
                @custom_values.delete_at index
            end

            @custom_values.push custom_value
            return custom_value
        end
    end

    module ImmutableModel
        @is_immutable = false
        def self.immutable_accessor(name)
            define_method(name) do
                return instance_variable_get("@#{name}")
            end

            define_method("#{name}=") do |value|
                raise_if_immutable
                instance_variable_set("@#{name}", value)
            end
        end

        def raise_if_immutable
            if @is_immutable
                raise ObjectIsImmutableError
            end
        end

        def is_immutable()
            @is_immutable = true
        end
    end
    
    module ModelWithIntegrationIdSameAs
        # check if other is same as regarding integration_id or id
        def same_as?(other)
            if @integration_id != nil && @integration_id == other.integration_id
                return true
            end
            if @id != nil && @id == other.id
                return true
            end
            return false
        end
    end

    module ModelHasTags
        attr_reader :tags

        # @example
        #     obj.set_tag("partner")
        def set_tag(str)
            if str.nil?
                return
            end

            if !str.is_a?(String)
                return
            end

            if str.length == 0
                return
            end
            
            @tags = [] if @tags == nil
            if ! @tags.any? {|tag| tag.value == str }
                @tags.push(Tag.new(str))
            end
        end
    end
end
