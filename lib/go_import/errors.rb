module GoImport
    class AlreadyAddedError < StandardError
    end

    class IntegrationIdIsRequiredError < StandardError
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

    class InvalidHistoryClassificationError < StandardError
        def initalize(classification)
            super("#{classification} is not a valid history classification")
        end
    end

    class ObjectIsImmutableError < StandardError
    end
end
