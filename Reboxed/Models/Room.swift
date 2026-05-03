import SwiftData
import Foundation

@Model
final class Room {
    var uid: String = ""
    var title: String = ""
    var descriptionText: String = ""
    var sortOrder: Int = 0
    var createdAt: Date = Date()
    var modifiedAt: Date = Date()

    var house: House?

    // Boxes in this room
    @Relationship(deleteRule: .cascade, inverse: \StorageBox.room)
    var boxes: [StorageBox]? = []

    // Items placed directly in this room (not in a box)
    @Relationship(deleteRule: .cascade, inverse: \Item.room)
    var directItems: [Item]? = []

    // Boxes & items headed here as relocation destination
    @Relationship(deleteRule: .nullify, inverse: \StorageBox.destinationRoom)
    var arrivingBoxes: [StorageBox]? = []

    @Relationship(deleteRule: .nullify, inverse: \Item.destinationRoom)
    var arrivingItems: [Item]? = []

    @Relationship(deleteRule: .cascade, inverse: \Photo.room)
    var photos: [Photo]? = []

    init() {
        uid = UIDService.generate(for: .room)
    }
}
