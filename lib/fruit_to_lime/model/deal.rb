
module FruitToLime
    class DealReference
        include SerializeHelper
        attr_accessor :id, :integration_id
        def serialize_variables
            [ :id, :integration_id ].map { |prop| {:id => prop, :type => :string} }
        end

        def initalize()
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
            elsif person.is_a?(DealReference)
                return deal
            end
        end
    end

    class Deal
        include SerializeHelper, ModelHasCustomFields, ModelHasTags

        # Get/set the deal's status. Statuses must be configured in
        # LIME Go before the import.
        attr_accessor :status

        attr_accessor :id, :integration_id, :name, :description, :probability, :value, :order_date

        # you add custom values by using {#set_custom_value}
        attr_reader :custom_values

        attr_reader :customer, :responsible_coworker, :customer_contact

        def serialize_variables
            [ :id, :integration_id, :name, :description, :probability, :value, :order_date ].map {
                |p| {
                    :id => p,
                    :type => :string
                }
            } +
                [
                 { :id => :customer, :type => :organization_reference },
                 { :id => :responsible_coworker, :type => :coworker_reference },
                 { :id => :customer_contact, :type => :person_reference },
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

            if @customer.nil?
                error = "#{error}\nA customer is required for deal."
            end

            if error.length > 0
                error = "#{error}\n#{serialize()}"
            end

            return error
        end

        def with_status
            @status = DealStatus.new
            yield @status
        end

        def customer=(customer)
            @customer = OrganizationReference.from_organization(customer)
        end

        def responsible_coworker=(coworker)
            @responsible_coworker = CoworkerReference.from_coworker(coworker)
        end

        def customer_contact=(person)
            @customer_contact = PersonReference.from_person(person)
        end
    end
end
