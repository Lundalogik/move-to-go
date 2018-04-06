module MoveToGo
    class Todo < CanBecomeImmutable
        include SerializeHelper
        ##
        # :attr_accessor: id
        immutable_accessor :id
        ##
        # :attr_accessor: integration_id
        immutable_accessor :integration_id

        attr_reader :text
        attr_reader :date_start, :date_start_has_time, :date_checked
        attr_reader :organization, :created_by, :assigned_coworker, :person, :deal

        def initialize(opt = nil)
            if !opt.nil?
                serialize_variables.each do |myattr|
                    val = opt[myattr[:id]]
                    instance_variable_set("@" + myattr[:id].to_s, val) if val != nil
                end
            end
        end

        def serialize_variables
            [ :id, :text, :integration_id ].map {
                |p| {
                    :id => p,
                    :type => :string
                }
            } +
                [
                 { :id => :date_start, :type => :datetime },
                 { :id => :date_start_has_time, :type => :bool },
                 { :id => :date_checked, :type => :datetime },
                 { :id => :created_by_reference, :type => :coworker_reference, :element_name => :created_by },
                 { :id => :assigned_coworker_reference, :type => :coworker_reference, :element_name => :assigned_coworker },
                 { :id => :organization_reference, :type => :organization_reference, :element_name => :organization },
                 { :id => :deal_reference, :type => :deal_reference, :element_name => :deal },
                 { :id => :person_reference, :type => :person_reference, :element_name => :person }
                ]
        end

        def get_import_rows
            (serialize_variables + [
                { :id => :organization, :type => :organization_reference},
                { :id => :person, :type => :person_reference}
                ]).map do |p|
                map_to_row p
            end
        end

        def serialize_name
            "Todo"
        end

        def organization=(org)
            raise_if_immutable
            @organization_reference = OrganizationReference.from_organization(org)

            if org.is_a?(Organization)
                @organization = org
            end
        end

        def created_by=(coworker)
            raise_if_immutable
            @created_by_reference = CoworkerReference.from_coworker(coworker)

            if coworker.is_a?(Coworker)
                @created_by = coworker
            end
        end

        def assigned_coworker=(coworker)
            raise_if_immutable
            @assigned_coworker_reference = CoworkerReference.from_coworker(coworker)

            if coworker.is_a?(Coworker)
                @assigned_coworker = coworker
            end
        end

        def person=(person)
            raise_if_immutable
            @person_reference = PersonReference.from_person(person)

            if person.is_a?(Person)
                @person = person
            end
        end

        def deal=(deal)
            raise_if_immutable
            @deal_reference = DealReference.from_deal(deal)

            if deal.is_a?(Deal)
                @deal = deal
            end
        end

        def text=(text)
            raise_if_immutable
            @text = text

            if @text.nil?
                return
            end

            if @text.length == 0
                return
            end

            @text.strip!
            
            # remove form feeds
            @text.gsub!("\f", "")

            # remove vertical spaces
            @text.gsub!("\v", "")

            # remove backspace
            @text.gsub!("\b", "")
        end

        def date_start=(datetime)
            begin
                @date_start = DateTime.parse(datetime)
            rescue 
                puts "\nParsed datetime '#{datetime}' but got error"
                raise
            end
        end

        def date_start_has_time=(bool)
            @date_start_has_time = bool            
        end

        def date_checked=(datetime)
            @date_checked = DateTime.parse(datetime) if datetime != ""
        end

        def validate
            error = String.new

            if (@text.nil? || @text.empty?)
                error = "Text is required for todo\n"
            end

            if @created_by.nil?
                error = "#{error}Created_by is required for todo\n"
            end

            if @assigned_coworker_reference.nil?
                error = "#{error}Assigned_coworker is required for todo\n"
            end

            if @date_start.nil?
                error = "#{error}Date_start is required for todo\n"
            end

            if @date_start_has_time.nil?
                error = "#{error}Date_start_has_time is required for todo\n"
            end

            if @organization.nil?
                error = "#{error}Organization is required for todo\n"
            end

            return error
        end
    end
end
