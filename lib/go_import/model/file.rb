require 'pathname'
require_relative '../serialize_helper'

# Note that we name this class File and ruby alread have a File class.
# To refrence to this

module GoImport
    class File
        include SerializeHelper
        attr_accessor :id, :integration_id, :path, :description

        attr_reader :organization, :created_by, :deal

        attr_writer :name

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
            [ :id, :integration_id, :path, :name, :description ].map {
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

        def name
            if @name.nil? || @name.empty?
                if !@path.nil?
                    return Pathname.new(path).basename.to_s
                end
            end

            return @name
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
                error = "Url is required for link\n"
            end

            if @created_by.nil?
                error = "#{error}Created_by is required for link\n"
            end

            if @organization.nil? && @deal.nil?
                error = "#{error}A link must have either an organization or a deal\n"
            end

            if !@organization.nil? && !@deal.nil?
                error = "#{error}A link can't be attached to both an organization and a deal"
            end

            return error
        end


    end
end
