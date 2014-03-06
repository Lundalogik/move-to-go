module FruitToLime
    module ModelHasCustomFields
        #        attr_reader :custom_fields

        #@custom_fields = []

        def set_custom_field(obj)
            @custom_fields = [] if @custom_fields==nil
            @custom_fields.push CustomField.new(obj)
        end
    end

    module ModelHasTags
        def add_tag(str)
            @tags = [] if @tags == nil
            @tags.push(Tag.new(str))
        end
    end
end
