module FruitToLime
    class DealStatus
        include SerializeHelper

        attr_accessor :id, :date, :status_reference, :note

        def initialize(opt = nil)
            if opt != nil
                serialize_variables.each do |myattr|
                    val = opt[myattr[:id]]
                    instance_variable_set("@" + myattr[:id].to_s, val) if val != nil
                end
            end
        end

        def serialize_variables
            [ :id, :label, :note ].map{ |p| { :id => p, :type => :string } } +
                [ :date ].map { |p| { :id => p, :type => :date } } +
                [ :status_reference ].map { |p| { :id => p, :type => :deal_status_reference } }
        end

    end
end
