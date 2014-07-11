module FruitToLime
    module ModelHasCustomFields
        # @example
        #     value = row['business_value_partner_info']
        #     obj.set_custom_value("partner_info", value)
        def set_custom_value(integration_id, value)
            return set_custom_field({integration_id: integration_id, value: value})
        end
        # @example
        #     value = row['business_value_partner_info']
        #     obj.set_custom_field({:integration_id=>"partner_info", :value=>value})
        def set_custom_field(obj)
            @custom_values = [] if @custom_values == nil
            value = obj[:value]
            field = CustomFieldReference.new(obj)
            custom_value = CustomValue.new
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
