# encoding: utf-8
module GoImport
    #  This class is the container for all documents, ie links and
    #  files.
    class Documents
        include SerializeHelper

        attr_reader :links, :files

        def serialize_variables
            [
             {:id => :links, @type => :links},
             {:id => :files, @type => :files}
            ]
        end

        def serialize_name
            "Documents"
        end

        def initialize
            @links = []
            @files = []
        end

        def add_link(link)
            @links = [] if @links == nil

            if link.nil?
                return nil
            end

            link = Link.new(link) if !link.is_a?(Link)

            if (!link.integration_id.nil? && link.integration_id.length > 0) &&
                    find_link_by_integration_id(link.integration_id) != nil
                raise AlreadyAddedError, "Already added a link with integration_id '#{link.integration_id}'."
            end

            @links.push link

            return link
        end

        def find_link_by_integration_id(integration_id)
            return @links.find do |link|
                link.integration_id == integration_id
            end
        end

        def add_file(file)
            @files = [] if @files == nil

            if file.nil?
                return nil
            end

            file = File.new(file) if !file.is_a?(File)

            if (!file.integration_id.nil? && file.integration_id.length > 0) &&
                    find_file_by_integration_id(file.integration_id) != nil
                raise AlreadyAddedError, "Already added a file with integration_id '#{file.integration_id}'."
            end

            @files.push file

            return file
        end

        def find_file_by_integration_id(integration_id)
            return @files.find do |file|
                file.integration_id = integration_id
            end
        end
    end
end
