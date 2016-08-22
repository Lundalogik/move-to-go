require_relative 'history'
module MoveToGo
    class TalkedTo < History
        def initialize(opt = nil)
            super(opt)

            @classification = HistoryClassification::TalkedTo
        end
    end
end
