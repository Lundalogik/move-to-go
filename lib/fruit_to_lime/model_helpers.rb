module FruitToLime
    module ModelHasCustomFields
        def set_custom_value(value, field)
            @custom_values = [] if @custom_values==nil
            custom_value = CustomValue.new()
            custom_value.value = value
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
        def set_custom_field(obj)
            value = obj[:value]
            ref = CustomFieldReference.new(obj)
            return set_custom_value(value, ref)
        end
    end

    module ModelWithIntegrationIdSameAs
        def same_as?(other)
            if @integration_id!=nil && @integration_id == other.integration_id
                return true
            end
            if @id != nil && @id == other.id
                return true
            end
            return false
        end
    end

    module ModelHasTags
        def add_tag(str)
            @tags = [] if @tags == nil
            @tags.push(Tag.new(str))
        end
        def set_tag(str)
            @tags = [] if @tags == nil
            if ! @tags.any? {|tag| tag.value = str }
                @tags.push(Tag.new(str))
            end
        end
    end
end
