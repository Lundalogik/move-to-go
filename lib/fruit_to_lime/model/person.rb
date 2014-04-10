module FruitToLime
    class PersonReference
        include SerializeHelper
        attr_accessor :id, :integration_id
        def serialize_variables
            [ :id, :integration_id ].map { |prop| {:id=>prop,:type=>:string} }
        end

        def initalize()
        end
        def to_s
            return "(#{id}, #{integration_id})"
        end
        def empty?
            return !@integration_id && !@id
        end
        def same_as_this_method()
            if @integration_id
                return lambda { |person|
                    person.integration_id == @integration_id
                }
            elsif @id
                return lambda { |person|
                    person.id == @id
                }
            else
                raise "No reference!"
            end
        end
    end

    class Person < PersonReference
        include SerializeHelper, ModelHasCustomFields, ModelHasTags
        attr_accessor :first_name, :last_name,
            :direct_phone_number, :fax_phone_number, :mobile_phone_number, :home_phone_number,
            :position, :email, :alternative_email, :postal_address, :currently_employed,
            :organization
        attr_reader :custom_values

        def initialize(opt = nil)
            @currently_employed = true
            if opt != nil
                serialize_variables.each do |myattr|
                    val = opt[myattr[:id]]
                    instance_variable_set("@" + myattr[:id].to_s, val) if val != nil
                end
            end
        end

        def with_postal_address
            @postal_address = Address.new
            yield @postal_address
        end

        def with_source
            @source = ReferenceToSource.new
            yield @source
        end

        def tags
            @tags
        end

        def serialize_name
            "Person"
        end

        def serialize_variables
            [
             {:id => :id, :type => :string},
             {:id => :integration_id, :type => :string},
             {:id => :source, :type => :source_ref},
             {:id => :first_name, :type => :string},
             {:id => :last_name, :type => :string},

             {:id => :direct_phone_number, :type => :string},
             {:id => :fax_phone_number, :type => :string},
             {:id => :mobile_phone_number, :type => :string},
             {:id => :home_phone_number, :type => :string},

             {:id => :position, :type => :string},
             
             {:id => :tags, :type => :tags},
             
             {:id => :email, :type => :string},
             {:id => :alternative_email, :type => :string},

             {:id => :postal_address, :type => :address},
             {:id => :custom_values, :type => :custom_values},
             {:id => :currently_employed, :type => :bool},
             {:id => :organization, :type => :organization_reference},
             
            ]
        end

        def get_import_rows
            (serialize_variables + [ { :id => :organization, :type => :organization_reference } ]).map do |p|
                map_to_row p
            end
        end

        def to_s
            return "#{first_name} #{last_name}"
        end

        def validate
            error = String.new

            if (@first_name.nil? || @first_name.empty?) &&
                    (@last_name.nil? || @last_name.empty?)
                error = "A firstname or lastname is required for person.\n#{serialize()}"
            end

            return error
        end
    end
end
