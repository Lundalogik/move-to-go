module FruitToLime
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
    end
end
