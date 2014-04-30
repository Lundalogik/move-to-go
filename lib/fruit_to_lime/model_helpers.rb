module FruitToLime
    module ModelHasCustomFields
        # @example
        #     obj.set_custom_value(row['business_value_partner_info'], "partner_info")
        def set_custom_value(value, field)
            @custom_values = [] if @custom_values == nil
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
        # Note that this method is obsolete and will be removed later on. Please use {#set_custom_value}
        def set_custom_field(obj)
            value = obj[:value]
            ref = CustomFieldReference.new(obj)
            return set_custom_value(value, ref)
        end
    end

    module ModelWithIntegrationIdSameAs
        # check if other is same as regarding integration_id or id
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
        # @example
        #     obj.set_tag("partner")
        def set_tag(str)
            @tags = [] if @tags == nil
            if ! @tags.any? {|tag| tag.value == str }
                @tags.push(Tag.new(str))
            end
        end
    end
end
