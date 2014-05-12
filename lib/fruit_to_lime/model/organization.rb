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
    end

    class Organization
        include SerializeHelper, ModelHasCustomFields, ModelHasTags

        attr_accessor :id, :integration_id, :name, :organization_number, :email, :web_site,
        :postal_address, :visit_address, :central_phone_number, :responsible_coworker, :source_data

        attr_reader :employees
        # you add custom values by using {#set_custom_value}
        attr_reader :custom_values

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

        # @example Set the responsible coworker of the organization to the coworker with integration id 943
        #     o.with_responsible_coworker do |responsible_coworker|
        #          responsible_coworker.integration_id = "943"
        #     end
        # @see CoworkerReference responsible_coworker
        def with_responsible_coworker
            @responsible_coworker = CoworkerReference.new if @responsible_coworker==nil
            yield @responsible_coworker
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

        # TODO! Remove, it's obsolete
        # @!visibility private
        def add_responsible_coworker(val)
            coworker = if val.is_a? CoworkerReference then val else CoworkerReference.new(val) end
            @responsible_coworker = coworker
            coworker
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
