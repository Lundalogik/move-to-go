module MoveToGo
    class PersonReference
        include SerializeHelper
        attr_accessor :id, :integration_id
        def serialize_variables
            [ :id, :integration_id ].map { |prop| {:id=>prop,:type=>:string} }
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

        def self.from_person(person)
            if person.nil?
                return nil
            elsif person.is_a?(Person)
                return person.to_reference
            elsif person.is_a?(PersonReference)
                return person
            end
        end
    end

    class Person < CanBecomeImmutable
        include SerializeHelper, ModelHasCustomFields, ModelHasTags

        ##
        # :attr_accessor: id
        immutable_accessor :id
        ##
        # :attr_accessor: integration_id
        immutable_accessor :integration_id
        ##
        # :attr_accessor: first_name
        immutable_accessor :first_name
        ##
        # :attr_accessor: last_name
        immutable_accessor :last_name
        ##
        # :attr_accessor: direct_phone_number
        immutable_accessor :direct_phone_number
        ##
        # :attr_accessor: fax_phone_number
        immutable_accessor :fax_phone_number
        ##
        # :attr_accessor: mobile_phone_number
        immutable_accessor :mobile_phone_number
        ##
        # :attr_accessor: home_phone_number
        immutable_accessor :home_phone_number
        ##
        # :attr_accessor: position
        immutable_accessor :position
        ##
        # :attr_accessor: email
        immutable_accessor :email
        ##
        # :attr_accessor: alternative_email
        immutable_accessor :alternative_email
        ##
        # :attr_accessor: postal_address
        immutable_accessor :postal_address
        ##
        # :attr_accessor: currently_employed
        immutable_accessor :currently_employed

        # you add custom values by using {#set_custom_value}
        attr_reader :custom_values, :organization

        def initialize(opt = nil)
            @currently_employed = true
            if opt != nil
                serialize_variables.each do |myattr|
                    val = opt[myattr[:id]]
                    instance_variable_set("@" + myattr[:id].to_s, val) if val != nil
                end
            end

            set_tag 'Import'
        end

        def set_organization_reference=(org)
            @organization = OrganizationReference.from_organization(org)
        end

        # @example Set city of postal address to 'Lund'
        #     p.with_postal_address do |addr|
        #         addr.city = "Lund"
        #     end
        # @see Address address
        def with_postal_address
            @postal_address = Address.new if @postal_address == nil
            yield @postal_address
        end

        # @example Set the source to par id 4653
        #     p.with_source do |source|
        #          source.par_se('4653')
        #     end
        # @see ReferenceToSource source
        def with_source
            @source = ReferenceToSource.new if @source == nil
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

        def to_reference()
            reference = PersonReference.new
            reference.id = @id
            reference.integration_id = @integration_id
            return reference
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
    end
end
