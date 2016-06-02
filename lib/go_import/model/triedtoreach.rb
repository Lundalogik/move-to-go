require_relative 'history'
module GoImport
    class TriedToReach < History
        def initialize(opt = nil)
            super(opt)

            @classification = HistoryClassification::TriedToReach
        end
    end
end
