module FruitToLime
    module ModelHasCustomFields
        def set_custom_field(obj)
            @custom_fields = [] if @custom_fields==nil
            new_custom_field = CustomField.new(obj)
            index = @custom_fields.find_index do |custom_field| 
                custom_field.same_as?(new_custom_field)
            end
            if index
                @custom_fields.delete_at index
            end
            @custom_fields.push new_custom_field
            return new_custom_field
        end

        def add_custom_field(obj)
            @custom_fields = [] if @custom_fields==nil
            custom_field = CustomField.new(obj)
            @custom_fields.push custom_field
            return custom_field
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
