import SwiftData
import Foundation

@Model
final class House {
    var uid: String = ""
    var title: String = ""
    var descriptionText: String = ""
    var street: String = ""
    var postalCode: String = ""
    var city: String = ""
    var country: String = ""
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var hasCoordinates: Bool = false
    var createdAt: Date = Date()
    var modifiedAt: Date = Date()

    // Rooms in this house
    @Relationship(deleteRule: .cascade, inverse: \Room.house)
    var rooms: [Room]? = []

    // Boxes placed directly in this house (no room)
    @Relationship(deleteRule: .cascade, inverse: \StorageBox.house)
    var directBoxes: [StorageBox]? = []

    // Items placed directly in this house (no room, no box)
    @Relationship(deleteRule: .cascade, inverse: \Item.house)
    var directItems: [Item]? = []

    // Boxes & items headed here as relocation destination
    @Relationship(deleteRule: .nullify, inverse: \StorageBox.destinationHouse)
    var arrivingBoxes: [StorageBox]? = []

    @Relationship(deleteRule: .nullify, inverse: \Item.destinationHouse)
    var arrivingItems: [Item]? = []

    @Relationship(deleteRule: .cascade, inverse: \Photo.house)
    var photos: [Photo]? = []

    init() {
        uid = UIDService.generate(for: .place)
    }
}
