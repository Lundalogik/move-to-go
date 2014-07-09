# encoding: utf-8
module FruitToLime
    class DealClassSettings < ClassSettings
        attr_reader :statuses

        def initialize(opt = nil)
            @statuses = []
            if opt != nil
                serialize_variables.each do |myattr|
                    val = opt[myattr[:id]]
                    instance_variable_set("@" + myattr[:id].to_s, val) if val != nil
                end
            end
        end

        def serialize_variables
            super() + [{:id => :statuses, :type => :statuses }]
        end

        def add_status(obj)
            @statuses = [] if @statuses.nil?

            if obj.is_a?(DealStatusSetting)
                status = obj
            else
                status = DealStatusSetting.new(obj)
            end

            if status.label.nil? || status.label.empty?
                raise InvalidDealStatusError, "Deal status must have a label"
            end

            if status.assessment.nil?
                status.assessment = DealState::NotAnEndState
            end

            index = @statuses.find_index do |deal_status|
                deal_status.same_as?(status)
            end
            if index
                @statuses.delete_at index
            end

            @statuses.push status

            return status
        end

        def find_status_by_label(label)
            return nil if @statuses.nil?

            return @statuses.find do |status|
                !status.label.nil? && status.label.casecmp(label) == 0
            end
        end

        def find_status_by_integration_id(integration_id)
            return nil if @statuses.nil?

            return @statuses.find do |status|
                !status.integration_id.nil? && status.integration_id.casecmp(integration_id) == 0
            end
        end

        def find_status_by_id(id)
            return nil if @statuses.nil?

            return @statuses.find do |status|
                !status.id.nil? && status.id.casecmp(integration_id) == 0
            end
        end
    end
end
