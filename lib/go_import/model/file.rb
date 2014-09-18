require 'pathname'
require_relative '../serialize_helper'

# Note that we name this class File and ruby alread have a File class.
# To refrence to this

module GoImport
    class File
        include SerializeHelper
        attr_accessor :id, :integration_id, :description

        attr_reader :organization, :created_by, :deal

        attr_reader :path

        attr_reader :name

        # zip_path is used internally when the file is stored in the
        # zip file that is sent to LIME Go. You should not modify this
        # property
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
                 { :id => :created_by, :type => :coworker_reference },
                 { :id => :organization, :type => :organization_reference },
                 { :id => :deal, :type => :deal_reference }
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
            return Pathname.new(@path).relative?
        end

        def organization=(org)
            @organization = OrganizationReference.from_organization(org)
        end

        def deal=(deal)
            @deal = DealReference.from_deal(deal)
        end

        def created_by=(coworker)
            @created_by = CoworkerReference.from_coworker(coworker)
        end

        def validate
            error = String.new

            if @path.nil? || @path.empty?
                error = "Path is required for file.\n"
            else
                if has_relative_path?()
                    if defined?(FILES_FOLDER) && !FILES_FOLDER.empty?()
                        root_folder = FILES_FOLDER
                    else
                        root_folder = Dir.pwd
                    end

                    if !::File.exists?("#{root_folder}/#{@path}")
                        error = "#{error}Can't find file '#{root_folder}/#{@path}'.\n"
                    end
                else
                    if !::File.exists?(@path)
                        error = "#{error}Can't find file '#{@path}'.\n"
                    end
                end
            end

            if @name.nil? || @name.empty?
                error = "#{error}A file must have a name.\n"
            end

            if @created_by.nil?
                error = "#{error}Created_by is required for file.\n"
            end

            if @organization.nil? && @deal.nil?
                error = "#{error}A file must have either an organization or a deal.\n"
            end

            if !@organization.nil? && !@deal.nil?
                error = "#{error}A file can't be attached to both an organization and a deal."
            end

            return error
        end
    end
end
