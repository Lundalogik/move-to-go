module MoveToGo
    class Coworker < CanBecomeImmutable
        include SerializeHelper
        immutable_accessor :id
        immutable_accessor :integration_id
        immutable_accessor :email
        immutable_accessor :first_name
        immutable_accessor :last_name
        immutable_accessor :direct_phone_number
        immutable_accessor :mobile_phone_number
        immutable_accessor :home_phone_number

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

        def parse_name_to_firstname_lastname_se(name, when_missing = '')
            if name.nil? or name.empty?
                @first_name = when_missing
                return
            end

            splitted = name.split(' ')
            @first_name = splitted[0]
            if splitted.length > 1
                @last_name = splitted.drop(1).join(' ')
            end
        end

        def to_email_chars(s)
            s.tr " åäöèé", "-aaoee"
        end

        def guess_email(domain)
            return '' if @last_name.nil? || @last_name.empty?
            return '' if @first_name.nil? || @first_name.empty?

            firstname = to_email_chars @first_name.downcase
            lastname = to_email_chars @last_name.downcase
            return "#{firstname}.#{lastname}@#{domain}"
        end

        def validate
            error = String.new

            if (@first_name.nil? || @first_name.empty?) &&
               (@last_name.nil? || @last_name.empty?)
                error = "A firstname or lastname is required for coworker.\n#{serialize()}"
            end
            
            return error
        end
    end
end
