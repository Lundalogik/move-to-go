# encoding: utf-8

require 'zip'
require 'securerandom'
require "progress"

module GoImport
    # The root model for Go import. This class is the container for everything else.
    class RootModel
        # the import_coworker is a special coworker that is set as
        # responsible for objects that requires a coworker, eg a note.
        attr_accessor :import_coworker

        attr_accessor :settings, :organizations, :coworkers, :deals, :notes

        # The configuration is used to set run-time properties for
        # go-import. This should not be confused with the model's
        # settings. Sets the following properties:
        #
        # ALLOW_DEALS_WITHOUT_RESPONSIBLE - if set to true, deals
        # without a responsible will NOT have the import user set as
        # default.
        attr_accessor :configuration

        attr_reader :documents

        def serialize_variables
            [
             {:id => :settings, :type => :settings},
             {:id => :coworkers, :type => :coworkers},
             {:id => :organizations, :type => :organizations},
             {:id => :deals, :type => :deals},
             {:id => :notes, :type => :notes},
             {:id => :documents, :type => :documents},
            ]
        end

        def serialize_name
            "GoImport"
        end

        include SerializeHelper

        def initialize()
            @settings = Settings.new
            @organizations = {}
            @coworkers = {}
            @import_coworker = Coworker.new
            @import_coworker.integration_id = "import"
            @import_coworker.first_name = "Import"
            @coworkers[@import_coworker.integration_id] = @import_coworker
            @deals = {}
            @notes = {}
            @documents = Documents.new
            @configuration = {}

            configure
        end

        # Adds the specifed coworker object to the model.

        # @example Add a coworker from a new coworker
        #    coworker = GoImport::Coworker.new
        #    coworker.integration_id = "123"
        #    coworker.first_name="Kalle"
        #    coworker.last_name="Anka"
        #    coworker.email = "kalle.anka@vonanka.com"
        #    rootmodel.add_coworker(coworker)
        def add_coworker(coworker)
            if coworker.nil?
                return nil
            end

            if !coworker.is_a?(Coworker)
                raise ArgumentError.new("Expected a coworker")
            end

            if coworker.integration_id.nil? || coworker.integration_id.length == 0
                raise IntegrationIdIsRequiredError, "An integration id is required for a coworker."
            end

            if find_coworker_by_integration_id(coworker.integration_id) != nil
                raise AlreadyAddedError, "Already added a coworker with integration_id #{coworker.integration_id}"
            end

            @coworkers[coworker.integration_id] = coworker
            coworker.set_is_immutable

            return coworker
        end

        # Adds the specifed organization object to the model.
        # @example Add an organization from a new organization
        #    organization = GoImport::Organization.new
        #    organization.integration_id = "123"
        #    organization.name = "Beagle Boys"
        #    rootmodel.add_organization(organization)
        def add_organization(organization)
            if organization.nil?
                return nil
            end

            if !organization.is_a?(Organization)
                raise ArgumentError.new("Expected an organization")
            end

            if organization.integration_id.nil? || organization.integration_id.length == 0
                raise IntegrationIdIsRequiredError, "An integration id is required for an organization."
            end

            if find_organization_by_integration_id(organization.integration_id) != nil
                raise AlreadyAddedError, "Already added an organization with integration_id #{organization.integration_id}"
            end

            @organizations[organization.integration_id] = organization
            organization.set_is_immutable

            return organization
        end

        # Adds the specifed deal object to the model.
        # @example Add a deal from a new deal
        #    deal = GoImport::Deal.new
        #    deal.integration_id = "123"
        #    deal.name = "Big deal"
        #    rootmodel.add_deal(deal)
        def add_deal(deal)
            if deal.nil?
                return nil
            end

            if !deal.is_a?(Deal)
                raise ArgumentError.new("Expected a deal")
            end

            if deal.integration_id.nil? || deal.integration_id.length == 0
                raise IntegrationIdIsRequiredError, "An integration id is required for a deal."
            end

            if find_deal_by_integration_id(deal.integration_id) != nil
                raise AlreadyAddedError, "Already added a deal with integration_id #{deal.integration_id}"
            end

            if !configuration[:allow_deals_without_responsible] && deal.responsible_coworker.nil?
                deal.responsible_coworker = @import_coworker
            end

            @deals[deal.integration_id] = deal
            deal.set_is_immutable

            return deal
        end

        def configure()
            if defined?(ALLOW_DEALS_WITHOUT_RESPONSIBLE)
                config_value = ALLOW_DEALS_WITHOUT_RESPONSIBLE.to_s

                configuration[:allow_deals_without_responsible] =
                    config_value.downcase == "true" || config_value == "1"
            end
        end

        # Adds the specifed note object to the model.
        #
        # If no integration_id has been specifed go-import generate
        # one.
        #
        # @example Add a note from a new note
        #    note = GoImport::Note.new
        #    note.integration_id = "123"
        #    note.text = "This is a note"
        #    rootmodel.add_note(note)
        def add_note(note)
            if note.nil?
                return nil
            end

            if !note.is_a?(Note)
                raise ArgumentError.new("Expected a note")
            end

            if note.integration_id.nil? || note.integration_id.length == 0
                note.integration_id = @notes.length.to_s
            end

            if find_note_by_integration_id(note.integration_id) != nil
                raise AlreadyAddedError, "Already added a note with integration_id #{note.integration_id}"
            end

            if note.created_by.nil?
                note.created_by = @import_coworker
            end

            @notes[note.integration_id] = note
            note.set_is_immutable

            return note
        end

        def add_link(link)
            @documents = Documents.new if @documents == nil

            return @documents.add_link(link)
        end

        def add_file(file)
            @documents = Documents.new if @documents == nil

            return @documents.add_file(file)
        end

        def find_coworker_by_integration_id(integration_id)
            if @coworkers.has_key?(integration_id)
                return @coworkers[integration_id]
            else
                report_failed_to_find_object("coworker", integration_id)
                return nil
            end
        end

        def find_organization_by_integration_id(integration_id)
            if @organizations.has_key?(integration_id)
                return @organizations[integration_id]
            else
                report_failed_to_find_object("organization", integration_id)
                return nil
            end

        end

        def find_person_by_integration_id(integration_id)
            return nil if @organizations.nil?
            @organizations.each do |key, organization|
                person = organization.find_employee_by_integration_id(integration_id)
                return person if person
            end
            report_failed_to_find_object("person", integration_id)
            return nil
        end

        def find_note_by_integration_id(integration_id)
            if @notes.has_key?(integration_id)
                return @notes[integration_id]
            else
                report_failed_to_find_object("note", integration_id)
                return nil
            end
        end

        # find deals for organization using {Organization#integration_id}
        def find_deals_for_organization(organization)
            deals = []

            deals = @deals.values.select do |deal|
                !deal.customer.nil? && deal.customer.integration_id == organization.integration_id
            end

            return deals
        end

        def find_deal_by_integration_id(integration_id)
            if @deals.has_key?(integration_id)
                return @deals[integration_id]
            else
                report_failed_to_find_object("deal", integration_id)
                return nil
            end
        end

        # Returns a string describing problems with the data. For
        # instance if integration_id for any entity is not unique.
        def sanity_check
            error = String.new

            # dups = get_integration_id_duplicates(with_non_empty_integration_id(@coworkers))
            # dups_error_items = (dups.collect{|coworker| coworker.integration_id}).compact
            # if dups.length > 0
            #     error = "#{error}\nDuplicate coworker integration_id: #{dups_error_items.join(", ")}."
            # end

            # dups = get_integration_id_duplicates(with_non_empty_integration_id(@organizations))
            # dups_error_items = (dups.collect{|org| org.integration_id}).compact
            # if dups.length > 0
            #     error = "#{error}\nDuplicate organization integration_id: #{dups_error_items.join(", ")}."
            # end

            # dups = get_integration_id_duplicates(with_non_empty_integration_id(@deals))
            # dups_error_items = (dups.collect{|deal| deal.integration_id}).compact
            # if dups_error_items.length > 0
            #     error = "#{error}\nDuplicate deal integration_id: #{dups_error_items.join(", ")}."
            # end

            persons = @organizations.collect{|k, o| o.employees}.flatten.compact
            dups = get_integration_id_duplicates(with_non_empty_integration_id(persons))
            dups_error_items = (dups.collect{|person| person.integration_id}).compact
            if dups_error_items.length > 0
                error = "#{error}\nDuplicate person integration_id: #{dups_error_items.join(", ")}."
            end

            dups = get_integration_id_duplicates(with_non_empty_integration_id(@documents.links))
            dups_error_items = (dups.collect{|l| l.integration_id}).compact
            if dups_error_items.length > 0
                error = "#{error}\nDuplicate link integration_id: #{dups_error_items.join(", ")}."
            end

            return error.strip
        end

        def validate(ignore_invalid_files = false, max_file_size)
            errors = String.new
            warnings = String.new

            @organizations.each do |k, o|
                validation_message = o.validate()

                if !validation_message.empty?
                    errors = "#{errors}\n#{validation_message}"
                end
            end

            converter_deal_statuses = @settings.deal.statuses.map {|status| status.label} if @settings.deal != nil
            @deals.each do |key, deal|
            #@deals.each do |deal|
                error, warning = deal.validate converter_deal_statuses

                if !error.empty?
                    errors = "#{errors}\n#{error}"
                end
                if !warning.empty?
                    warnings = "#{warnings}\n#{warning}"
                end
            end

            #@notes.each do |note|
            @notes.each do |key, note|
                validation_message = note.validate

                if !validation_message.empty?
                    errors = "#{errors}\n#{validation_message}"
                end
            end

            @documents.links.each do |link|
                validation_message = link.validate
                if !validation_message.empty?
                    errors = "#{errors}\n#{validation_message}"
                end
            end

            @documents.files.each do |file|
                validation_message = file.validate(ignore_invalid_files, max_file_size)
                if !validation_message.empty?
                    errors = "#{errors}\n#{validation_message}"
                end
            end

            return [errors.strip, warnings.strip]
        end

        # @!visibility private
        def to_rexml(doc)
            element_name = serialize_name
            elem = doc.add_element(element_name,{"Version"=>"v2_0"})
            SerializeHelper::serialize_variables_rexml(elem, self)
        end

        # @!visibility private
        # zip-filename is the name of the zip file to create
        def save_to_zip(zip_filename, files_filename)
            puts "Trying to save to zip..."
            # saves the model to a zipfile that contains xml data and
            # document files.

            if ::File.exists?(zip_filename)
                ::File.delete zip_filename
            end

            go_data_file = Tempfile.new('go')
            puts "Creating go.xml file with data..."
            if !files_filename.nil?
                saved_documents = @documents
                @documents = Documents.new
            end
            serialize_to_file(go_data_file)
            create_zip(zip_filename, go_data_file, documents.files)

            if !files_filename.nil?
                go_files_file = Tempfile.new('go-files')
                puts "Creating go.xml file with documents information..."
                @organizations = []
                @coworkers = []
                @deals = []
                @notes = []
                @documents = saved_documents
                serialize_to_file(go_files_file)

                files_zip_filename = files_filename+".zip"
                if ::File.exists?(files_zip_filename)
                    ::File.delete files_zip_filename
                end
                create_zip(files_zip_filename, go_files_file, documents.files)
            end
        end

        def create_zip(filename, xml, files)
            Zip::File.open("#{Dir.pwd}/#{filename}", Zip::File::CREATE) do |zip_file|
                puts "Add go.xml file to zip '#{filename}'..."
                zip_file.add('go.xml', xml)

                if files.length > 0
                    if defined?(FILES_FOLDER) && !FILES_FOLDER.empty?()
                        puts "Files with relative path are imported from '#{FILES_FOLDER}'."
                        root_folder = FILES_FOLDER
                    else
                        puts "Files with relative path are imported from the current folder (#{Dir.pwd})."
                        root_folder = Dir.pwd
                    end

                    # If a file's path is absolute, then we probably dont
                    # have the files in the same location here. For
                    # example, the customer might have stored their files
                    # at f:\lime-easy\documents. We must replace this part
                    # of each file with the root_folder from above.
                    if defined?(FILES_FOLDER_AT_CUSTOMER) && !FILES_FOLDER_AT_CUSTOMER.empty?()
                        files_folder_at_customer = FILES_FOLDER_AT_CUSTOMER
                        puts "Files with absolute paths will have the part '#{files_folder_at_customer}' replaced with '#{root_folder}'."
                    else
                        files_folder_at_customer = ""
                        puts "Files with absolute paths will be imported from their origial location."
                    end

                    # 1) files/ - a folder with all files referenced from
                    # the source.
                    files.with_progress(" - Trying to add files to zip...").each do |file|
                        # we dont need to check that the file exists since
                        # we assume that rootmodel.validate has been
                        # called before save_to_zip.
                        file.add_to_zip_file(zip_file)
                    end
                end
                puts "Compressing zip file ... "
            end
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
                obj.integration_id != nil && !obj.integration_id.empty?
            end
        end

        def report_failed_to_find_object(object, integration_id)
          puts "Failed to find a #{object} when looking for id: #{integration_id}"
        end
    end
end
