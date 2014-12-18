module GoImport
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

    class Deal
        include SerializeHelper, ModelHasCustomFields, ModelHasTags

        # Get/set the deal's status. Statuses must be configured in
        # LIME Go before the import.
        attr_accessor :status

        attr_accessor :id, :integration_id, :name, :description, :probability, :order_date

        # you add custom values by using {#set_custom_value}
        attr_reader :custom_values

        attr_reader :customer, :responsible_coworker, :customer_contact, :value

        def serialize_variables
            [ :id, :integration_id, :name, :description, :probability, :value, :order_date ].map {
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

        def validate
            error = String.new

            if @name.nil? || @name.empty?
                error = "A name is required for deal.\n}"
            end

            if !@status.nil? && @status.status_reference.nil?
                error = "#{error}\nStatus must have a status reference."
            end

            if !@status.nil? && !@status.status_reference.nil? && @status.status_reference.validate.length > 0
                error = "#{error}\n#{@status.status_reference.validate}"
            end

            if error.length > 0
                error = "#{error}\n#{serialize()}"
            end

            return error
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
            @status = DealStatus.new if @status.nil?
            
            @status.status_reference = DealStatusReference.from_deal_status(status)
        end

        def customer=(customer)
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
            @responsible_coworker_reference = CoworkerReference.from_coworker(coworker)

            if coworker.is_a?(Coworker)
                @responsible_coworker = coworker
            end
        end

        def customer_contact=(person)
            @customer_contact_reference = PersonReference.from_person(person)

            if person.is_a?(Person)
                @customer_contact = person
            end
        end

        def value=(value)
            if value.nil?
                @value = "0"
            elsif value.empty?
                @value = "0"
            else
                # we have had some issues with LIME Easy imports where
                # the value was in the format "357 000". We need to
                # remove those spaces.
                fixed_value = value.gsub(" ", "")

                if is_integer?(fixed_value)
                    @value = fixed_value
                elsif is_float?(fixed_value)
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

        def is_float?(value)
            true if Float(value) rescue false
        end
    end
end
