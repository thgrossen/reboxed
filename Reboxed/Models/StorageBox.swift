import SwiftData
import Foundation

@Model
final class StorageBox {
    var uid: String = ""
    var title: String = ""
    var descriptionText: String = ""
    var boxType: String = ""
    var tags: [String] = []
    var owner: String = ""
    var createdAt: Date = Date()
    var modifiedAt: Date = Date()

    // Current location (set one of these)
    var house: House?
    var room: Room?

    // Relocation destination
    var destinationHouse: House?
    var destinationRoom: Room?

    @Relationship(deleteRule: .cascade, inverse: \Item.storageBox)
    var items: [Item]? = []

    @Relationship(deleteRule: .cascade, inverse: \Photo.storageBox)
    var photos: [Photo]? = []

    init() {
        uid = UIDService.generate(for: .box)
    }

    var currentLocationName: String {
        if let room { return "\(room.house?.title ?? "") › \(room.title)" }
        if let house { return house.title }
        return ""
    }
}
