/*******************************************************************************
 * The MIT License (MIT)
 *
 * Copyright (c) 2026, Thomas Grossen
 ******************************************************************************/

import Foundation
import SwiftData

@Model
final class Room
{
    var uid:                String  = ""
    var title:              String  = ""
    var descriptionText:    String  = ""
    var floor:              Int     = 0
    var sortOrder:          Int     = 0
    var createdAt:          Date    = Date()
    var modifiedAt:         Date    = Date()

    var house: House?

    // Boxes in this room
    @Relationship( deleteRule: .cascade, inverse: \StorageBox.room )     var boxes: [ StorageBox ]? = []

    // Items placed directly in this room (not in a box)
    @Relationship( deleteRule: .cascade, inverse: \Item.room )     var directItems: [ Item ]? = []

    // Boxes & items headed here as relocation destination
    @Relationship( deleteRule: .nullify, inverse: \StorageBox.destinationRoom )     var arrivingBoxes: [ StorageBox ]? = []

    @Relationship( deleteRule: .nullify, inverse: \Item.destinationRoom )     var arrivingItems: [ Item ]? = []

    @Relationship( deleteRule: .cascade, inverse: \Photo.room )     var photos: [ Photo ]? = []

    init()
    {
        self.uid = UIDService.generate( for: .room )
    }
}
