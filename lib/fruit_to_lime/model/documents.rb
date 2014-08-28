# encoding: utf-8
module FruitToLime
    #  This class is the container for all documents, ie links and
    #  files.
    class Documents
        # *** TODO: add files when supported by the backend.

        include SerializeHelper

        attr_accessor :links

        def serialize_variables
            [
             {:id => :links, @type => :links}
            ]
        end

        def serialize_name
            "Documents"
        end

        def initialize
            @links = []
        end

        def add_link(link)
            @links = [] if @links == nil

            if link.nil?
                return nil
            end

            link = Link.new(link) if !link.is_a?(Link)

            if (!link.integration_id.nil? && link.integration_id.length > 0) &&
                    find_link_by_integration_id(link.integration_id) != nil
                raise AlreadyAddedError, "Already added a link with integration_id #{link.integration_id}"
            end

            @links.push(link)

            return link
        end

        def find_link_by_integration_id(integration_id)
            return @links.find do |link|
                link.integration_id == integration_id
            end
        end
    end
end
