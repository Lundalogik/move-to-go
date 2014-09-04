require 'date'
module GoImport
    class OrganizationReference
        include SerializeHelper
        attr_accessor :id, :integration_id, :heading
        def serialize_variables
            [ :id, :integration_id, :heading ].map { |prop| {
                    :id => prop, :type => :string
                }
            }
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
            return "(#{id}, #{integration_id}, #{heading})"
        end

        def empty?
            return !@integration_id && !@id && !@heading
        end

        def self.from_organization(organization)
            if organization.nil?
                return nil
            elsif organization.is_a?(Organization)
                return organization.to_reference
            elsif organization.is_a?(OrganizationReference)
                return organization
            end
        end
    end

    class Organization
        include SerializeHelper, ModelHasCustomFields, ModelHasTags

        attr_accessor :id, :integration_id, :name, :organization_number, :email, :web_site,
        :postal_address, :visit_address, :central_phone_number, :source_data

        # Sets/gets the date when this organization's relation was
        # changed. Default is Now.
        attr_reader :relation_last_modified

        attr_reader :employees, :responsible_coworker, :relation
        # you add custom values by using {#set_custom_value}
        attr_reader :custom_values

        def initialize(opt = nil)
            if !opt.nil?
                serialize_variables.each do |myattr|
                    val = opt[myattr[:id]]
                    instance_variable_set("@" + myattr[:id].to_s, val) if val != nil
                end
            end

            @relation = Relation::NoRelation if @relation.nil?
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
            end

            return false
        end

        # @example Set city of postal address to 'Lund'
        #     o.with_postal_address do |addr|
        #         addr.city = "Lund"
        #     end
        # @see Address address
        def with_postal_address
            @postal_address = Address.new if @postal_address == nil
            yield @postal_address
        end

        # @example Set city of visit address to 'Lund'
        #     o.with_visit_address do |addr|
        #         addr.city = "Lund"
        #     end
        # @see Address address
        def with_visit_address
            @visit_address = Address.new if @visit_address == nil
            yield @visit_address
        end

        # @example Set the source to par id 4653
        #     o.with_source do |source|
        #          source.par_se('4653')
        #     end
        # @see ReferenceToSource source
        def with_source
            @source = ReferenceToSource.new if @source == nil
            yield @source
        end

        # @example Add an employee and then add additional info to that employee
        #    employee = o.add_employee({
        #        :integration_id => "79654",
        #        :first_name => "Peter",
        #        :last_name => "Wilhelmsson"
        #    })
        #    employee.direct_phone_number = '+234234234'
        #    employee.currently_employed = true
        # @see Person employee
        def add_employee(val)
            @employees = [] if @employees == nil
            person = if val.is_a? Person then val else Person.new(val) end
            @employees.push(person)
            person
        end

        def responsible_coworker=(coworker)
            @responsible_coworker = CoworkerReference.from_coworker(coworker)
        end

        # Sets the organization's relation to the specified value. The
        # relation must be a valid value from the Relation module
        # otherwise an InvalidRelationError error will be thrown.
        def relation=(relation)
            if relation == Relation::NoRelation || relation == Relation::WorkingOnIt ||
                    relation == Relation::IsACustomer || relation == Relation::WasACustomer || relation == Relation::BeenInTouch
                @relation = relation
                @relation_last_modified = Time.now.strftime("%Y-%m-%d") if @relation_last_modified.nil? &&
                    @relation != Relation::NoRelation
            else
                raise InvalidRelationError
            end
        end

        def relation_last_modified=(date)
            begin
                @relation_last_modified = @relation != Relation::NoRelation ? Date.parse(date).strftime("%Y-%m-%d") : nil
            rescue
                raise InvalidValueError, date
            end
        end

        def find_employee_by_integration_id(integration_id)
            return nil if @employees.nil?
            return @employees.find do |e|
                e.integration_id == integration_id
            end
        end

        def serialize_variables
            [
             { :id => :id, :type => :string },
             { :id => :integration_id, :type => :string },
             { :id => :source, :type => :source_ref },
             { :id => :name, :type => :string },
             { :id => :organization_number, :type => :string },
             { :id => :postal_address, :type => :address },
             { :id => :visit_address, :type => :address },
             { :id => :central_phone_number, :type => :string },
             { :id => :email, :type => :string },
             { :id => :web_site, :type => :string },
             { :id => :employees, :type => :persons },
             { :id => :custom_values, :type => :custom_values },
             { :id => :tags, :type => :tags },
             { :id => :responsible_coworker, :type => :coworker_reference},
             { :id => :relation, :type => :string },
             { :id => :relation_last_modified, :type => :string }
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

            if !@source.nil?
                if @source.id.nil? || @source.id == ""
                    error = "#{error}\nReference to source must have an id"
                end
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
