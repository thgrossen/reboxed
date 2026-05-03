import SwiftData
import Foundation

@Model
final class ItemLink {
    var createdAt: Date = Date()
    var note: String = ""

    var sourceItem: Item?
    var targetItem: Item?

    init(source: Item, target: Item, note: String = "") {
        self.sourceItem = source
        self.targetItem = target
        self.note = note
    }
}
