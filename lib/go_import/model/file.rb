require 'pathname'
require_relative '../serialize_helper'

# Note that we name this class File and ruby alread have a File class.
# To refrence to this

module GoImport
    class File
        DEFAULT_MAX_FILE_SIZE = 100000000 # 100 Mb

        include SerializeHelper
        attr_accessor :id, :integration_id, :description

        attr_reader :organization, :created_by, :deal

        attr_reader :path

        attr_reader :name

        # location_in_zip_file is used internally when the file is
        # stored in the zip file that is sent to LIME Go. You should
        # not modify this property
        attr_accessor :location_in_zip_file

        def initialize(opt = nil)
            if !opt.nil?
                serialize_variables.each do |myattr|
                    val = opt[myattr[:id]]
                    instance_variable_set("@" + myattr[:id].to_s, val) if val != nil
                end
            end
        end

        def serialize_name
            "File"
        end

        def serialize_variables
            [ :id, :integration_id, :path, :name, :description, :location_in_zip_file ].map {
                |p| {
                    :id => p,
                    :type => :string
                }
            } +
                [
                 { :id => :created_by_reference, :type => :coworker_reference, :element_name => :created_by },
                 { :id => :organization_reference, :type => :organization_reference, :element_name => :organization },
                 { :id => :deal_reference, :type => :deal_reference, :element_name => :deal }
                ]
        end

        def path=(path)
            @path = path

            # when path is set, we should set the name to the path's
            # filename if name is NOT set already

            # Hm. this might introduce a bug if we set path twice and
            # never explicity set the name (it will get the name of
            # the first file)

            if (@name.nil? || @name.empty?) && (!@path.nil? && !@path.empty?)
                @name = Pathname.new(path).basename.to_s
            end
            @location_in_zip_file = "files/#{SecureRandom.uuid}#{::File.extname(@path).to_s}"

        end

        def name=(name)
            @name = name

            # a file must have a name, hence this.

            if @name.nil? || @name.empty?
                if !@path.nil? && !@path.empty?
                    @name = Pathname.new(@path).basename.to_s
                end
            end
        end

        def has_relative_path?()
            return !@path.match(/[a-zA-Z]{1}\:[\\\/]/)&&Pathname.new(@path).relative?
        end

        def organization=(org)
            @organization_reference = OrganizationReference.from_organization(org)

            if org.is_a?(Organization)
                @organization = org
            end
        end

        def deal=(deal)
            @deal_reference = DealReference.from_deal(deal)

            if deal.is_a?(Deal)
                @deal = deal
            end
        end

        def created_by=(coworker)
            @created_by_reference = CoworkerReference.from_coworker(coworker)

            if coworker.is_a?(Coworker)
                @created_by = coworker
            end
        end

        # This is the path to where the file should be accessed
        # from within the project.
        def path_for_project
            if @path.nil? || @path.empty?
                return ""
            end

            # Get the folder where files should be accessed from
            # during the import. If not defined in converter.rb use
            # the current directory
            if defined?(FILES_FOLDER) && !FILES_FOLDER.empty?()
                root_folder = FILES_FOLDER
            else
                root_folder = Dir.pwd
            end

            if has_relative_path?()
                # since this file is stored with a relative file name
                # we should get it from the root folder
                path_for_project = ::File.expand_path(@path, root_folder)
            else
                # the file is stored with an absolute path, if the
                # file cant be access using that path we must change
                # it to a path that is accessible from this computer.
                # The FILES_FOLDER_AT_CUSTOMER constant states what
                # part of the path that should be replaced with the
                # root folder.

                # We assume that the original system used ONE location
                # for all its files. If not, we should change
                # FILES_FOLDER_AT_CUSTOMER to a list of folders.
                if defined?(FILES_FOLDER_AT_CUSTOMER) && !FILES_FOLDER_AT_CUSTOMER.empty?()
                    files_folder_at_customer = FILES_FOLDER_AT_CUSTOMER
                else
                    files_folder_at_customer = ""
                end

                if files_folder_at_customer.empty?
                    path_for_project = @path
                else
                    path_for_project = ::File.expand_path(@path.downcase.sub(files_folder_at_customer.downcase, root_folder))
                end
            end

            return path_for_project
        end

        def add_to_zip_file(zip_file)
            zip_file.add(@location_in_zip_file, path_for_project)
        end

        def validate(ignore_invalid_files = false, max_file_size = DEFAULT_MAX_FILE_SIZE)
            error = String.new
            warning = String.new

            if @name.nil? || @name.empty?
                error = "#{error}A file must have a name.\n"
            end

            if @path.nil? || @path.empty?
                error = "Path is required for file.\n"
            elsif !ignore_invalid_files
                if !::File.exists?(path_for_project())
                    error = "#{error}Can't find file with name '#{@name}' and original path '#{@path}' at '#{path_for_project()}'."
                elsif ::File.exists?(path_for_project) && ::File.size(path_for_project()) > max_file_size
                    error = "#{error}File '#{@name}' is bigger than #{max_file_size} bytes."
                end
            end

            if @created_by_reference.nil?
                error = "#{error}Created_by is required for file (#{@name}).\n"
            end

            if @organization_reference.nil? && @deal_reference.nil?
                error = "#{error}The file (#{@name}) must have either an organization or a deal.\n"
            end

            if !@organization_reference.nil? && !@deal_reference.nil?
                error = "#{error}The file (#{@name}) can't be attached to both an organization and a deal."
            end

            return error
        end
    end
end
