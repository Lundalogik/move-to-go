module MoveToGo
    class Link
        include SerializeHelper
        attr_accessor :id, :integration_id, :url, :name, :description

        attr_reader :organization, :created_by, :deal, :person

        def initialize(opt = nil)
            if !opt.nil?
                serialize_variables.each do |myattr|
                    val = opt[myattr[:id]]
                    instance_variable_set("@" + myattr[:id].to_s, val) if val != nil
                end
            end
        end

        def serialize_name
            "Link"
        end

        def serialize_variables
            [ :id, :integration_id, :url, :name, :description ].map {
                |p| {
                    :id => p,
                    :type => :string
                }
            } +
                [
                 { :id => :created_by_reference, :type => :coworker_reference, :element_name => :created_by },
                 { :id => :organization_reference, :type => :organization_reference, :element_name => :organization },
                 { :id => :person_reference, :type => :person_reference, :element_name => :person },
                 { :id => :deal_reference, :type => :deal_reference, :element_name => :deal }
                ]
        end

        def organization=(org)
            @organization_reference = OrganizationReference.from_organization(org)

            if org.is_a?(Organization)
                @organization = org
            end
        end

        def person=(person)
            @person_reference = PersonReference.from_person(person)

            if person.is_a?(Person)
                @person = person
            end
        end

        def deal=(deal)
            @deal_reference = DealReference.from_deal(deal)

            if deal.is_a?(Deal)
                @deal = deal
            end
        end

        def created_by=(coworker)
            @created_by_reference = CoworkerReference.from_coworker(coworker)

            if coworker.is_a?(Coworker)
                @created_by = coworker
            end
        end

        def validate
            error = String.new

            if @url.nil? || @url.empty?
                error = "Url is required for link\n"
            end

            if @created_by_reference.nil?
                error = "#{error}Created_by is required for link\n"
            end

            if @organization_reference.nil? && @deal_reference.nil? && @person_reference.nil?
                error = "#{error}A link must have either an organization, person or a deal\n"
            end

            return error
        end
    end
end

