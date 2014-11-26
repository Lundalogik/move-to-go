module GoImport
    class AlreadyAddedError < StandardError
    end

    class InvalidCustomFieldError < StandardError
    end

    class InvalidRelationError < StandardError
    end

    class InvalidValueError < StandardError
        def initalize(value)
            super("#{value} is not a valid value.")
        end
    end

    class InvalidDealStatusError < StandardError
    end

    class InvalidNoteClassificationError < StandardError
        def initalize(classification)
            super("#{classification} is not a valid note classification")
        end
    end
end
