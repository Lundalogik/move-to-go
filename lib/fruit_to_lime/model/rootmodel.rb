# encoding: utf-8
module FruitToLime
    # The root model for Go import. This class is the container for everything else.
    class RootModel
        # the import_coworker is a special coworker that is set as
        # responsible for objects that requires a coworker, eg a note.
        attr_accessor :import_coworker

        attr_accessor :settings, :organizations, :coworkers, :deals, :notes
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
        # @example Add a coworker from a hash
        #    rootmodel.add_coworker({
        #        :integration_id=>"123",
        #        :first_name=>"Kalle",
        #        :last_name=>"Anka",
        #        :email=>"kalle.anka@vonanka.com"
        #    })
        #
        # @example Add a coworker from a new coworker
        #    coworker = FruitToLime::Coworker.new
        #    coworker.integration_id = "123"
        #    coworker.first_name="Kalle"
        #    coworker.last_name="Anka"
        #    coworker.email = "kalle.anka@vonanka.com"
        #    rootmodel.add_coworker(coworker)
        #
        # @example If you want to keep adding coworkers and dont care about duplicates not being added
        #    begin
        #       rootmodel.add_coworker(coworker)
        #    rescue FruitToLime::AlreadyAddedError
        #       puts "Warning: already added coworker"
        #    end
        # @see Coworker
        def add_coworker(coworker)
            @coworkers = [] if @coworkers == nil

            if coworker == nil
                raise "Missing coworker to add!"
            end

            coworker = Coworker.new(coworker) if !coworker.is_a?(Coworker)

            if find_coworker_by_integration_id(coworker.integration_id) != nil
                raise AlreadyAddedError, "Already added a coworker with integration_id #{coworker.integration_id}"
            end

            @coworkers.push(coworker)
        end

        # TODO! Remove, it's obsolete
        # @!visibility private
        def add_note(text)
            @notes = [] if @notes == nil
            @notes.push(if text.is_a? Note then text else Note.new(text) end)
        end

        def with_new_note
            @notes = [] if @notes == nil

            note = Note.new
            @notes.push note
            yield note
        end

        def find_coworker_by_integration_id(integration_id)
            return @coworkers.find do |coworker|
                coworker.integration_id == integration_id
            end
        end

        def find_organization_by_integration_id(integration_id)
            return @organizations.find do |organization|
                organization.integration_id == integration_id
            end
        end

        # find deals for organization using {Organization#integration_id}
        def find_deals_for_organization(organization)
            deals = []

            deals = @deals.select do |deal|
                !deal.customer.nil? && deal.customer.integration_id == organization.integration_id
            end

            return deals
        end

        # Returns a string describing problems with the data. For instance if integration_id for any entity is not unique.
        def sanity_check
            error = String.new

            dups = get_integration_id_duplicates(with_non_empty_integration_id(@coworkers))
            dups_error_items = (dups.collect{|coworker| coworker.integration_id}).compact
            if dups.length > 0
                error = "#{error}\nDuplicate coworker integration_id: #{dups_error_items.join(", ")}."
            end

            dups = get_integration_id_duplicates(with_non_empty_integration_id(@organizations))
            dups_error_items = (dups.collect{|org| org.integration_id}).compact
            if dups.length > 0
                error = "#{error}\nDuplicate organization integration_id: #{dups_error_items.join(", ")}."
            end

            dups = get_integration_id_duplicates(with_non_empty_integration_id(@deals))
            dups_error_items = (dups.collect{|deal| deal.integration_id}).compact
            if dups_error_items.length > 0
                error = "#{error}\nDuplicate deal integration_id: #{dups_error_items.join(", ")}."
            end

            persons = @organizations.collect{|o| o.employees}.flatten.compact
            dups = get_integration_id_duplicates(with_non_empty_integration_id(persons))
            dups_error_items = (dups.collect{|person| person.integration_id}).compact
            if dups_error_items.length > 0
                error = "#{error}\nDuplicate person integration_id: #{dups_error_items.join(", ")}."
            end

            return error.strip
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

            @notes.each do |note|
                validation_message = note.validate

                if !validation_message.empty?
                    error = "#{error}\n#{validation_message}"
                end
            end

            return error.strip
        end

        # @!visibility private
        def to_rexml(doc)
            element_name = serialize_name
            elem = doc.add_element(element_name,{"Version"=>"v2_0"})
            SerializeHelper::serialize_variables_rexml(elem, self)
        end

        private
        # returns all items from the object array with duplicate integration ids.
        # To get all organizations with the same integration_id use
        # @example Get all the organization duplicates with the same integration id
        #      rm.get_integration_id_duplicates(rm.organizations)
        def get_integration_id_duplicates(objects)
            uniq_items = objects.uniq {|item| item.integration_id}.compact

            return (objects - uniq_items).compact
        end

        def with_non_empty_integration_id(objects)
            return objects.select do |obj|
                obj.integration_id!=nil && !obj.integration_id.empty?
            end
        end
    end
end
