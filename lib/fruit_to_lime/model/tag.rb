# encoding: utf-8

module FruitToLime
    class Tag
        def serialize_name
            "Tag"
        end

        attr_accessor :value

        def initialize(val=nil)
            if val
                @value = val
            end
        end

        def to_rexml(elem)
            element_name = serialize_name
            elem.add_element(element_name).text = @value.to_s.encode('utf-8')
        end

        def to_s
            return "tag: '#{@value}'"
        end

        def ==(other)
            if other.respond_to?(:value)
                return @value == other.value
            else
                return false
            end
        end
    end
end
