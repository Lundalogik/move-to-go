module FruitToLime
    class Note
        include SerializeHelper
        attr_accessor :id, :text, :integration_id, :classification, :date, :created_by, :organization, :person

        def serialize_variables
            [ :id, :text, :integration_id, :classification ].map {
                |p| {
                    :id => p,
                    :type => :string
                }
            } +
                [
                 { :id => :date, :type => :date },
                 { :id => :created_by, :type => :coworker_reference },
                 { :id => :organization, :type => :organization_reference },
                 { :id => :person, :type => :person_reference }
                ]
        end

        def get_import_rows
            (serialize_variables+[
                {:id=>:organization, :type=>:organization_reference},
                {:id=>:person, :type=>:person_reference}
                ]).map do |p|
                map_to_row p
            end
        end

        def serialize_name
            "Note"
        end

        def validate
            error = String.new

            if @text.nil? || @text.empty?
                error = "Text is required for note\n"
            end

            if @created_by.nil?
                error = "#{error}Created_by is required for note\n"
            end

            if @organization.nil?
                error = "#{error}Organization is required for note\n"
            end

            return error
        end
    end
end
