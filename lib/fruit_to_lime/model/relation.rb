module FruitToLime
    module Relation
        # This is the default, we have not been in contact with this
        # organization in any way.
        NoRelation = 0

        # Something is happening with this organization, we might have
        # booked a meeting with them or created a deal, etc.
        WorkingOnIt = 1

        # We have made a deal with this organization.
        IsACustomer = 2

        # We have made a deal with this organization but it was some
        # time ago and we don't consider them a customer any more.
        WasACustomer = 3

        # We had something going with this organization but we
        # couldn't close the deal and we don't think they will be a
        # customer to us in the foreseeable future.
        BeenInTouch = 4
    end
end
