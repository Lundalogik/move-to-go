module MoveToGo
    class DealReference
        include SerializeHelper
        attr_accessor :id, :integration_id
        def serialize_variables
            [ :id, :integration_id ].map { |prop| {:id => prop, :type => :string} }
        end

        def initialize(opt = nil)
            if opt != nil
                serialize_variables.each do |var|
                    value = opt[var[:id]]
                    instance_variable_set("@" + var[:id].to_s, value) if value != nil
                end
            end
        end

        def to_s
            return "(#{id}, #{integration_id})"
        end

        def empty?
            return !@integration_id && !@id
        end

        def self.from_deal(deal)
            if deal.nil?
                return nil
            elsif deal.is_a?(Deal)
                return deal.to_reference
            elsif deal.is_a?(DealReference)
                return deal
            end
        end
    end

    class Deal < CanBecomeImmutable
        include SerializeHelper, ModelHasCustomFields, ModelHasTags

        ##
        # :attr_accessor: status
        # Get/set the deal's status. Statuses must be configured in
        # LIME Go before the import.
        immutable_accessor :status

        ##
        # :attr_accessor: id
        immutable_accessor :id
        ##
        # :attr_accessor: integration_id
        immutable_accessor :integration_id
        ##
        # :attr_accessor: name
        immutable_accessor :name
        ##
        # :attr_accessor: description
        immutable_accessor :description
        ##
        # :attr_accessor: probability
        immutable_accessor :probability
        ##
        # :attr_accessor: order_date
        immutable_accessor :order_date
        ##
        # :attr_accessor: offer_date
        immutable_accessor :offer_date

        # you add custom values by using {#set_custom_value}
        attr_reader :custom_values

        attr_reader :customer, :responsible_coworker, :customer_contact, :value

        def serialize_variables
            [ :id, :integration_id, :name, :description, :probability, :value, :order_date, :offer_date ].map {
                |p| {
                    :id => p,
                    :type => :string
                }
            } +
                [
                 { :id => :customer_reference, :type => :organization_reference, :element_name => :customer },
                 { :id => :responsible_coworker_reference, :type => :coworker_reference, :element_name => :responsible_coworker },
                 { :id => :customer_contact_reference, :type => :person_reference, :element_name => :customer_contact},
                 { :id => :custom_values, :type => :custom_values },
                 { :id => :tags, :type => :tags },
                 { :id => :status, :type => :deal_status }
                ]
        end

        def serialize_name
            "Deal"
        end

        def initialize(opt = nil)
            if !opt.nil?
                serialize_variables.each do |myattr|
                    val = opt[myattr[:id]]
                    instance_variable_set("@" + myattr[:id].to_s, val) if val != nil
                end
            end

            set_tag 'Import'
        end

        def to_s
            return "deal[id=#{@id}, integration_id=#{@integration_id}]"
        end

        def to_reference
            reference = DealReference.new
            reference.id = @id
            reference.integration_id = @integration_id
            return reference
        end

        def validate(labels = nil)
            errors = []
            warnings = []

            if @name.nil? || @name.empty?
                errors.push("A name is required for deal.")
            end

            if is_integer?(@value) && @value.to_i < 0
                errors.push("The value must be positive for deal.")
            end

            if !@status.nil? && @status.status_reference.nil?
                errors.push("Status must have a status reference.")
            end

            if !@status.nil? && !@status.status_reference.nil? && @status.status_reference.validate.length > 0
                val = @status.status_reference.validate
                if val.length > 0
                    errors.push(val)
                end
            end

            if !@status.nil? && !@status.status_reference.nil? && (labels.nil? || (!labels.nil? && !labels.include?(@status.status_reference.label)))
                warnings.push("Deal status '#{@status.status_reference.label}' missing, add to settings")
            end

            if @status == nil
                warnings.push("No status set on deal (#{@integration_id}) '#{@name}', will be set to default status at import")
            end

            if errors.length > 0
                errors.push(serialize())
            end

            return [errors.join('\n'), warnings.join('\n')]
        end

        def with_status
            @status = DealStatus.new if @status.nil?
            yield @status
        end

        # Sets the deal's status to the specifed status. The specifed
        # status could be either a DealStatusSetting, a string or an
        # integer. Use DealStatusSetting if you want to create new
        # statuses during import (you will probably add the
        # DealStatusSettings to the settings model). If the statuses
        # already exists in the application use the status label
        # (String) or integration id (Integer) here.
        def status=(status)
            raise_if_immutable
            @status = DealStatus.new if @status.nil?
            
            @status.status_reference = DealStatusReference.from_deal_status(status)
        end

        def customer=(customer)
            raise_if_immutable
            @customer_reference = OrganizationReference.from_organization(customer)

            if customer.is_a?(Organization)
                @customer = customer
            end
        end

        # Gets the customer to which this deal belongs
        def customer()
            return @customer
        end

        def responsible_coworker=(coworker)
            raise_if_immutable
            @responsible_coworker_reference = CoworkerReference.from_coworker(coworker)

            if coworker.is_a?(Coworker)
                @responsible_coworker = coworker
            end
        end

        def customer_contact=(person)
            raise_if_immutable
            @customer_contact_reference = PersonReference.from_person(person)

            if person.is_a?(Person)
                @customer_contact = person
            end
        end

        # Sets the deal's value. Both . and , are treated as thousand
        # separators and thus cents and other fractions will be
        # ignored. This makes it easier for us to convert a string
        # into an integer value.
        def value=(value)
            raise_if_immutable
            
            if value.nil?
                @value = "0"
            elsif value.respond_to?(:empty?) && value.empty?
                @value = "0"
            else
                # we have had some issues with LIME Easy imports where
                # the value was in the format "357 000". We need to
                # remove those spaces.
                fixed_value = value.to_s.gsub(" ", "")

                # we assume that both , and . are thousand separators
                # and remove them from the value string. We dont care
                # about decimal separators since the value is a deal's
                # value which is much larger than cents and ores.
                fixed_value = fixed_value.gsub(",", "")
                fixed_value = fixed_value.gsub(".", "")

                if is_integer?(fixed_value)
                    @value = fixed_value
                elsif fixed_value.length == 0
                    @value = "0"
                else
                    raise InvalidValueError, value
                end
            end
        end

        def is_integer?(value)
            true if Integer(value) rescue false
        end
    end
end
