module FruitToLime
    class Coworker
        include SerializeHelper
        attr_accessor :id, :integration_id, :email, :first_name, :last_name, :direct_phone_number,
        :mobile_phone_number, :home_phone_number

        def initialize(opt = nil)
            if opt != nil
                serialize_variables.each do |myattr|
                    val = opt[myattr[:id]]
                    instance_variable_set("@" + myattr[:id].to_s, val) if val != nil
                end
            end
        end

        def serialize_variables
            [
             :id, :integration_id, :email, :first_name, :last_name, 
             :direct_phone_number, :mobile_phone_number, :home_phone_number
            ].map {|p| { :id => p, :type => :string } }
        end

        def to_reference
            reference = CoworkerReference.new
            reference.id = @id
            reference.integration_id = @integration_id
            reference.heading = "#{@first_name} #{@last_name}".strip

            return reference
        end

        def serialize_name
            "Coworker"
        end

        def ==(that)
            if that.nil?
                return false
            end

            if that.is_a? Coworker
                return @integration_id == that.integration_id
            end

            return false
        end
    end
end
