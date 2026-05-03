/*******************************************************************************
 * The MIT License (MIT)
 *
 * Copyright (c) 2026, Thomas Grossen
 ******************************************************************************/

import SwiftUI
import SwiftData
import Observation

@Observable
final class ScannerViewModel
{
    enum NavigationTarget: Identifiable, Hashable
    {
        case house( House )
        case room( Room )
        case box( StorageBox )
        case item( Item )

        var id: String
        {
            switch self
            {
            case .house( let h ): return "H-\( h.uid )"
            case .room( let r ): return "R-\( r.uid )"
            case .box( let b ): return "B-\( b.uid )"
            case .item( let i ): return "I-\( i.uid )"
            }
        }

        static func == ( lhs: NavigationTarget, rhs: NavigationTarget ) -> Bool
        {
            lhs.id == rhs.id
        }

        func hash( into hasher: inout Hasher )
        {
            hasher.combine( id )
        }
    }

    var navigationTarget: NavigationTarget?
    var unknownUID: String?

    @MainActor
    func resolve( uid: String, context: ModelContext )
    {
        unknownUID = nil
        navigationTarget = nil

        switch UIDService.entityPrefix( from: uid )
        {
        case .place:
            let descriptor = FetchDescriptor<House>( predicate: #Predicate { $0.uid == uid } )
            if let house = ( try? context.fetch( descriptor ) )?.first
            {
                navigationTarget = .house( house )
            }
            else { unknownUID = uid }

        case .room:
            let descriptor = FetchDescriptor<Room>( predicate: #Predicate { $0.uid == uid } )
            if let room = ( try? context.fetch( descriptor ) )?.first
            {
                navigationTarget = .room( room )
            }
            else { unknownUID = uid }

        case .box:
            let descriptor = FetchDescriptor<StorageBox>( predicate: #Predicate { $0.uid == uid } )
            if let box = ( try? context.fetch( descriptor ) )?.first
            {
                navigationTarget = .box( box )
            }
            else { unknownUID = uid }

        case .item:
            let descriptor = FetchDescriptor<Item>( predicate: #Predicate { $0.uid == uid } )
            if let item = ( try? context.fetch( descriptor ) )?.first
            {
                navigationTarget = .item( item )
            }
            else { unknownUID = uid }

        case nil:
            unknownUID = uid
        }
    }
}
