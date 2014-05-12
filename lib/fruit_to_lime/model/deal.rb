
module FruitToLime
    class Deal
        include SerializeHelper, ModelHasCustomFields, ModelHasTags

        attr_accessor :id, :integration_id, :name, :description, :probability, :value, :order_date, :customer,
        :responsible_coworker, :customer_contact, :status
        # you add custom values by using {#set_custom_value}
        attr_reader :custom_values

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

        def validate
            error = String.new

            if @name.nil? || @name.empty?
                error = "A name is required for deal.\n#{serialize()}"
            end

            return error
        end

        def with_status
            @status = DealStatus.new
            yield @status
        end

    end
end
