module FruitToLime
    class Link
        include SerializeHelper
        attr_accessor :id, :integration_id, :url, :name, :description

        attr_reader :organization, :created_by, :deal

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
                 { :id => :created_by, :type => :coworker_reference },
                 { :id => :organization, :type => :organization_reference },
                 { :id => :deal, :type => :deal_reference }
                ]
        end

        def organization=(org)
            @organization = OrganizationReference.from_organization(org)
        end

        def deal=(deal)
            @deal = DealReference.from_deal(deal)
        end

        def created_by=(coworker)
            @created_by = CoworkerReference.from_coworker(coworker)
        end

        def validate
            error = String.new

            if @url.nil? || @url.empty?
                error = "Url is required for link\n"
            end

            if @created_by.nil?
                error = "#{error}Created_by is required for link\n"
            end

            if @organization.nil? && @deal.nil?
                error = "#{error}A link must have either an organization or a deal\n"
            end

            if !@organization.nil? && !@deal.nil?
                error = "#{error}A link can't be attached to both an organization and a deal"
            end

            return error
        end
    end
end

