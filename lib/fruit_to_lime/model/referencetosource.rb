module FruitToLime
    class ReferenceToSource
        include SerializeHelper
        attr_accessor :name, :id, :format

        def serialize_variables
            [:name, :format, :id].map { |prop| { :id => prop, :type => :string } }
        end

        def serialize_name
            "ReferenceToSource"
        end

        def get_import_rows
            (serialize_variables + [{ :id => :value, :type => :string }]).map do |p|
                map_to_row p
            end
        end

        def initialize(opt = nil)
            if opt != nil
                serialize_variables.each do |myattr|
                    val = opt[myattr[:id]]
                    instance_variable_set("@" + myattr[:id].to_s,val) if val != nil
                end
            end
        end

        def to_s
            return "#{@name}_#{@format}_#{@id}"
        end

        def ==(other)
            if other==nil 
                return false
            end
            return @name == other.name && @id == other.id && @format== other.format
        end

        def par_se(id)
            @name = 'pase'
            @format = 'External'
            @id = id
        end
    end
end