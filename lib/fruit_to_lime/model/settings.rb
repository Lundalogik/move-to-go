# encoding: utf-8
module FruitToLime
    class Settings
        include SerializeHelper
        attr_reader :organization, :person, :deal

        # @example Add custom fields available for organization
        #    rootmodel.settings.with_organization do |organization_settings|
        #        organization_settings.set_custom_field({:integration_id=>"link_to_bi_system", :title=>"Link to BI system"})
        #        organization_settings.set_custom_field({:integration_id=>"yield_quota", :title=>"Yield quota"})
        #    end
        # @see ClassSettings
        # @see CustomField
        # @see RootModel
        def with_organization
            @organization = ClassSettings.new if @organization ==nil
            yield @organization
        end

        # @example Add custom fields available for person
        #    rootmodel.settings.with_person do |person_settings|
        #        person_settings.set_custom_field({:integration_id=>"link_to_bi_system", :title=>"Link to BI system"})
        #    end
        # @see ClassSettings
        # @see CustomField
        # @see RootModel
        def with_person
            @person = ClassSettings.new if @person ==nil
            yield @person
        end

        # @example Add custom fields available for deal
        #    rootmodel.settings.with_deal do |deal_settings|
        #        deal_settings.set_custom_field({:integration_id=>"link_to_bi_system", :title=>"Link to BI system"})
        #    end
        # @see ClassSettings
        # @see CustomField
        # @see RootModel
        def with_deal
            @deal = DealClassSettings.new if @deal ==nil
            yield @deal
        end

        def initialize(opt = nil)
            if opt != nil
                serialize_variables.each do |myattr|
                    val = opt[myattr[:id]]
                    instance_variable_set("@" + myattr[:id].to_s, val) if val != nil
                end
            end
        end

        def serialize_variables
            [:organization, :person, :deal].map {|p| {:id => p, :type => :class_settings} }
        end

        def serialize_name
            "Settings"
        end
    end
end
