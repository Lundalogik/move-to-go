module GoImport
    # Defines a note's classification. This defines what kind of
    # action that happened before the note was written.
    module NoteClassification
        # We talked to the client about a sale. This might be a phone call
        # or a talk in person.
        SalesCall = 0

        # This is a general comment about the organization or deal.
        Comment = 1

        # This is a general comment regarding a talk we had with
        # someone at the client.
        TalkedTo = 2

        # We tried to reach someone but failed.
        TriedToReach = 3

        # We had a meeting at the client's site.
        ClientVisit = 4
    end
end



 
