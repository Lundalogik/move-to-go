module FruitToLime
   class OrganizationReference
        include SerializeHelper
        attr_accessor :id, :integration_id, :heading
        def serialize_variables
            [ :id, :integration_id, :heading ].map { |prop| {
                    :id => prop, :type => :string
                }
            }
        end

        def initalize()
        end

        def to_s
            return "(#{id}, #{integration_id}, #{heading})"
        end

        def empty?
            return !@integration_id && !@id && !@heading
        end

        # *** TODO: delete this?
        def same_as_this_method()
            if @integration_id
                return lambda { |org|
                    org.integration_id == @integration_id
                }
            elsif @id
                return lambda { |org|
                    org.id == @id
                }
            elsif @heading
                return lambda { |org|
                    org.heading == @heading
                }
            else
                raise "No reference!"
            end
        end
    end

    class Organization
        include SerializeHelper, ModelHasCustomFields, ModelHasTags

        attr_accessor :id, :integration_id, :name, :organization_number, :email, :web_site, :external_link,
        :postal_address, :visit_address, :central_phone_number, :responsible_coworker, :source_data

        #        attr_reader :employees, :custom_fields
        attr_reader :employees

        def initialize()
        end

        def to_reference()
            reference = OrganizationReference.new
            reference.id = @id
            reference.integration_id = @integration_id
            reference.heading = @name
            return reference
        end

        def ==(that)
            if that.nil?
                return false
            end

            if that.is_a? Organization
                return @integration_id == that.integration_id
            elsif that.is_a? String
                return @integration_id == that
            end

            return false
        end

        def with_postal_address
            @postal_address = Address.new
            yield @postal_address
        end

        def with_visit_address
            @visit_address = Address.new
            yield @visit_address
        end

        def with_source
            @source = ReferenceToSource.new
            yield @source
        end

        def add_employee(val)
            @employees = [] if @employees==nil
            @employees.push(if val.is_a? Person then val else Person.new(val) end)
        end

        def serialize_variables
            [
             :id, :integration_id, :name, :organization_number, :external_link,
             :email, :web_site, :central_phone_number ].map {
                |prop| { :id => prop, :type => :string }
            } +
                [
                 { :id => :postal_address, :type => :address },
                 { :id => :visit_address, :type => :address },
                 { :id => :employees, :type => :persons },
                 { :id => :tags, :type => :tags },
                 { :id => :custom_fields, :type => :custom_fields },
                 { :id => :source, :type => :source_ref },
                 { :id => :responsible_coworker, :type => :coworker_reference}
                ]
        end

        def serialize_name
            "Organization"
        end

        def to_s
            return "#{name}"
        end

        def validate
            error = String.new

            if @name.nil? || @name.empty?
                error = "A name is required for organization.\n#{serialize()}"
            end

            if @employees != nil
                @employees.each do |person|
                    validation_message = person.validate()
                    if !validation_message.empty?
                        error = "#{error}\n#{validation_message}"
                    end
                end
            end

            return error
        end
    end
end