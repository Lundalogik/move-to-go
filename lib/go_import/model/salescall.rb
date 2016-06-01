require_relative 'history'
module GoImport
    class SalesCall < History
        def initialize(opt = nil)
            super(opt)

            @classification = HistoryClassification::SalesCall
        end
    end
end
