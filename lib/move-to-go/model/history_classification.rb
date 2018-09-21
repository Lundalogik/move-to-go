module MoveToGo
    # Defines a history type. This defines what kind of
    # action that happened before the history was written.
    module HistoryClassification
        # We talked to the client about a sale. This might be a phone call
        # or a talk in person.
        SalesCall = 'SalesCall'

        # This is a general comment about the organization or deal.
        Comment = 'Comment'

        # This is a general comment regarding a talk we had with
        # someone at the client.
        TalkedTo = 'TalkedTo'

        # We tried to reach someone but failed.
        TriedToReach = 'TriedToReach'

        # We had a meeting at the client's site.
        ClientVisit = 'ClientVisit'
        
        #We had Email correspondence
        Email = 'Email'
    end
end



 
