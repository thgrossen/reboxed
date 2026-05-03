/*******************************************************************************
 * The MIT License (MIT)
 *
 * Copyright (c) 2026, Thomas Grossen
 ******************************************************************************/

import SwiftData
import Foundation

@Model
final class Item
{
    var uid: String = ""
    var title: String = ""
    var descriptionText: String = ""
    var tags: [ String ] = []
    var owner: String = ""
    var createdAt: Date = Date()
    var modifiedAt: Date = Date()

    // Current location (set one of these)
    var storageBox: StorageBox?
    var room: Room?
    var house: House?

    // Relocation destination
    var destinationHouse: House?
    var destinationRoom: Room?

    @Relationship( deleteRule: .cascade, inverse: \ItemLink.sourceItem )
    var outgoingLinks: [ ItemLink ]? = []

    @Relationship( deleteRule: .cascade, inverse: \ItemLink.targetItem )
    var incomingLinks: [ ItemLink ]? = []

    @Relationship( deleteRule: .cascade, inverse: \Photo.item )
    var photos: [ Photo ]? = []

    init()
    {
        uid = UIDService.generate( for: .item )
    }

    // Bidirectional links — merges both directions
    var linkedItems: [ Item ]
    {
        let out = ( outgoingLinks ?? [] ).compactMap( \.targetItem )
        let inc = ( incomingLinks ?? [] ).compactMap( \.sourceItem )
        return Array( Set( out + inc ) )
    }

    var currentLocationName: String
    {
        if let storageBox { return storageBox.currentLocationName + " › \( storageBox.title )" }
        if let room { return "\( room.house?.title ?? "" ) › \( room.title )" }
        if let house { return house.title }
        return ""
    }
}
