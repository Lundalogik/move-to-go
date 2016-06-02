require_relative 'history'
module GoImport
    class ClientVisit < History
        def initialize(opt = nil)
            super(opt)

            @classification = HistoryClassification::ClientVisit
        end
    end
end
