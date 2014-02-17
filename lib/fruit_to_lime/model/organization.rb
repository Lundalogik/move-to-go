module FruitToLime
   class OrganizationReference
        include SerializeHelper
        attr_accessor :id, :integration_id, :name
        def serialize_variables
            [ :id, :integration_id, :name ].map { |prop| {:id=>prop,:type=>:string} }
        end

        def initalize()
        end
        def to_s
            return "(#{id}, #{integration_id}, #{name})"
        end
        def empty?
            return !@integration_id && !@id && !@name
        end
        def same_as_this_method()
            if @integration_id
                return lambda { |org|
                    org.integration_id == @integration_id
                }
            elsif @id
                return lambda { |org|
                    org.id == @id
                }
            elsif @name
                return lambda { |org|
                    org.name == @name
                }
            else
                raise "No reference!"
            end
        end
    end

    class Organization < OrganizationReference
        include SerializeHelper

        attr_accessor :organization_number, :email, :web_site, :external_link, :postal_address, :visit_address
        attr_reader :employees, :notes, :custom_fields

        def initialize()
        end

        def with_postal_address
            @postal_address = Address.new
            yield @postal_address
        end

        def with_visit_address
            @visit_address = Address.new
            yield @visit_address
        end

        def set_custom_field(obj)
            @custom_fields = [] if @custom_fields==nil
            @custom_fields.push CustomField.new(obj)
        end

        def with_source
            @source = ReferenceToSource.new
            yield @source
        end

        def add_employee(val)
            @employees = [] if @employees==nil
            @employees.push(if val.is_a? Person then val else Person.new(val) end)
        end

        def tags
            @tags
        end

        def add_tag(str)
            @tags = [] if @tags == nil
            @tags.push(Tag.new(str))
        end

        def serialize_variables
            [
             :id, :integration_id, :name, :organization_number, :external_link, :email, :web_site ].map {
                |prop| { :id => prop, :type => :string }
            } +
                [
                 { :id => :postal_address, :type => :address},
                 { :id => :visit_address, :type => :address},
                 { :id => :employees, :type => :persons},
                 { :id => :tags, :type => :tags},
                 { :id => :custom_fields, :type => :custom_fields},
                 { :id => :source, :type => :source_ref}
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
