# encoding: utf-8
module FruitToLime
    class RootModel
        # the import_coworker is a special coworker that is set as
        # responsible for objects that requires a coworker, eg a note.
        attr_accessor :settings, :organizations, :coworkers, :deals, :notes, :import_coworker
        def serialize_variables
            [
             {:id => :settings, :type => :settings},
             {:id => :coworkers, :type => :coworkers},
             {:id => :organizations, :type => :organizations},
             {:id => :deals, :type => :deals},
             {:id => :notes, :type => :notes},
            ]
        end

        def serialize_name
            "GoImport"
        end

        include SerializeHelper

        def initialize()
            @settings = Settings.new
            @organizations = []
            @coworkers = []
            @import_coworker = Coworker.new
            @import_coworker.integration_id = "import"
            @import_coworker.first_name = "Import"
            @coworkers.push @import_coworker
            @deals = []
            @notes = []
        end

        # Adds the specifed coworker object to the model.
        def add_coworker(coworker)
            @coworkers = [] if @coworkers == nil

            if coworker != nil && coworker.is_a?(Coworker) && !@coworkers.include?(coworker)
                @coworkers.push(coworker)
            end
        end

        def add_note(text)
            @notes = [] if @notes == nil
            @notes.push(if text.is_a? Note then text else Note.new(text) end)
        end

        def with_note
            @notes = [] if @notes == nil

            note = Note.new
            @notes.push note
            yield note
        end

        # *** TODO:
        #
        # delete find_organization_by_reference and
        #same_as_this_method from organization?
        def find_organization_by_reference(organization_reference)
            same_as_this = organization_reference.same_as_this_method
            return @organizations.find do |org|
                same_as_this.call(org)
            end
        end

        def find_coworker_by_integration_id(integration_id)
            return @coworkers.find do |coworker|
                coworker == integration_id
            end
        end

        def find_organization_by_integration_id(integration_id)
            return @organizations.find do |organization|
                organization == integration_id
            end
        end

        def find_deals_for_organization(organization)
            deals = []

            deals = @deals.select do |deal|
                !deal.customer.nil? && deal.customer.integration_id == organization.integration_id
            end

            return deals
        end

        def sanity_check
            error = String.new

            dups = get_duplicates(@coworkers) {|coworker| coworker.integration_id}
            dups_error_items = (dups.collect{|coworker| coworker.integration_id}).compact
            if dups.length > 0
                error = "#{error}\nDuplicate coworker integration_id: #{dups_error_items.join(", ")}."
            end

            dups = get_duplicates(@organizations) {|org| org.integration_id}
            dups_error_items = (dups.collect{|org| org.integration_id}).compact
            if dups.length > 0
                error = "#{error}\nDuplicate organization integration_id: #{dups_error_items.join(", ")}."
            end

            dups = get_duplicates(@deals) {|deal| deal.integration_id}
            dups_error_items = (dups.collect{|deal| deal.integration_id}).compact
            if dups_error_items.length > 0
                error = "#{error}\nDuplicate deal integration_id: #{dups_error_items.join(", ")}."
            end

            return error.strip
        end

        # returns all items from the object array with duplicate keys.
        # To get all organizations with the same integration_id use
        # get_duplicates(organizations, {|org| org.integration_id})
        def get_duplicates(objects, &key)
            uniq_items = objects.uniq {|item| key.call(item)}.compact

            return (objects - uniq_items).compact
        end

        def validate()
            error = String.new

            @organizations.each do |o|
                validation_message = o.validate()

                if !validation_message.empty?
                    error = "#{error}\n#{validation_message}"
                end
            end

            @deals.each do |deal|
                validation_message = deal.validate

                if !validation_message.empty?
                    error = "#{error}\n#{validation_message}"
                end
            end

            return error.strip
        end

        def to_rexml(doc)
            element_name = serialize_name
            elem = doc.add_element(element_name,{"Version"=>"v2_0"})
            SerializeHelper::serialize_variables_rexml(elem, self)
        end
    end
end
