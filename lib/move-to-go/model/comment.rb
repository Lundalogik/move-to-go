require_relative 'history'
module MoveToGo
    class Comment < History
        def initialize(opt = nil)
            super(opt)

            @classification = HistoryClassification::Comment
        end
    end
end
