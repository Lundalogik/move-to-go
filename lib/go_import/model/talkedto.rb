require_relative 'history'
module GoImport
    class TalkedTo < History
        def initialize(opt = nil)
            super(opt)

            @classification = HistoryClassification::TalkedTo
        end
    end
end
