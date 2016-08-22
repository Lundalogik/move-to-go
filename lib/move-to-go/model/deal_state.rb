module MoveToGo
    module DealState
        # This is the default, a deal with a status with this state is
        # currently being worked on.
        NotAnEndState = 0

        # The deal has reached a positive end state, eg we have won
        # the deal.
        PositiveEndState = 1

        # The deal has reached a negative end state, eg we have lost
        # the deal.
        NegativeEndState = -1
    end
end
