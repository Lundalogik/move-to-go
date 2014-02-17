module FruitToLime
    class RootModel
        attr_accessor :organizations, :coworkers, :deals
        def serialize_variables
            [
                {:id=>:organizations,:type=>:organizations},
                {:id=>:coworkers, :type=>:coworkers}
            ]
        end
        def serialize_name
            "GoImport"
        end
        include SerializeHelper
        def initialize()
            @organizations = []
            @coworkers = []
        end
        def find_organization_by_reference(organization_reference)
            same_as_this = organization_reference.same_as_this_method
            return @organizations.find do |org|
                same_as_this.call(org)
            end
        end

        def validate()
            error = String.new

            @organizations.each do |o|
                validation_message = o.validate()

                if !validation_message.empty?
                    error = "#{error}\n#{validation_message}"
                end
            end

            return error
        end
    end
end
