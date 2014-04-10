# encoding: utf-8
module FruitToLime
    class Settings
        include SerializeHelper
        attr_reader :organization, :person, :deal
        def with_organization
            @organization = ClassSettings.new if @organization ==nil
            yield @organization
        end
        def with_person
            @person = ClassSettings.new if @person ==nil
            yield @person
        end
        def with_deal
            @deal = ClassSettings.new if @deal ==nil
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