require_relative 'history'
module MoveToGo
    class ClientVisit < History
        def initialize(opt = nil)
            super(opt)

            @classification = HistoryClassification::ClientVisit
        end
    end
end
