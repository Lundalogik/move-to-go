module GoImport
    class Note < CanBecomeImmutable
        include SerializeHelper
        immutable_accessor :id
        immutable_accessor :integration_id
        immutable_accessor :date

        attr_reader :text
        attr_reader :organization, :created_by, :person, :deal

        # The note's classification. It should be a value from
        # {#NoteClassification}. The default value is Comment.
        attr_reader :classification

        def initialize(opt = nil)
            if !opt.nil?
                serialize_variables.each do |myattr|
                    val = opt[myattr[:id]]
                    instance_variable_set("@" + myattr[:id].to_s, val) if val != nil
                end
            end

            @classification = NoteClassification::Comment if @classification.nil?
        end

        def serialize_variables
            [ :id, :text, :integration_id, :classification ].map {
                |p| {
                    :id => p,
                    :type => :string
                }
            } +
                [
                 { :id => :date, :type => :date },
                 { :id => :created_by_reference, :type => :coworker_reference, :element_name => :created_by },
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
            "Note"
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

        def classification=(classification)
            raise_if_immutable
            if classification == NoteClassification::Comment || classification == NoteClassification::SalesCall ||
                    classification == NoteClassification::TalkedTo || classification == NoteClassification::TriedToReach ||
                    classification == NoteClassification::ClientVisit
                @classification = classification
            else
                raise InvalidNoteClassificationError, classification
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

        def validate
            error = String.new

            if @text.nil? || @text.empty?
                error = "Text is required for note\n"
            end

            if @created_by.nil?
                error = "#{error}Created_by is required for note\n"
            end

            if @organization.nil? && @deal.nil? && @person.nil?
                error = "#{error}Organization, deal or person is required for note\n"
            end

            return error
        end
    end
end
