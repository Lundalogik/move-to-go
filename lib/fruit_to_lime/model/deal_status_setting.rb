# encoding: utf-8
module FruitToLime
    class DealStatusSetting
        include SerializeHelper

        attr_accessor :id, :integration_id, :label, :assessment

        def initialize(opt = nil)
            if opt != nil
                serialize_variables.each do |myattr|
                    val = opt[myattr[:id]]
                    instance_variable_set("@" + myattr[:id].to_s, val) if val != nil
                end
            end
        end

        def serialize_variables
            [ :id, :integration_id, :label, :assessment ].map{ |p| { :id => p, :type => :string } }
        end

        def serialize_name
            "DealStatus"
        end

        def to_reference()
            reference = DealStatusReference.new
            reference.id = @id
            reference.label = @label
            reference.integration_id = @integration_id

            return reference
        end

        def same_as?(other)
            if @integration_id != nil && @integration_id == other.integration_id
                return true
            end

            if @id != nil && @id == other.id
                return true
            end

            if @label != nil && @label == other.label
                return true
            end

            return false
        end
    end
end
