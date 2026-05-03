import SwiftData
import Foundation

@MainActor
enum ModelContainerService {
    private static let cloudKitContainer = "iCloud.me.grossen.Reboxed"

    static func makeContainer() throws -> ModelContainer {
        let schema = Schema([
            House.self,
            Room.self,
            StorageBox.self,
            Item.self,
            ItemLink.self,
            Photo.self,
            ListValue.self
        ])
        let config = ModelConfiguration(
            schema: schema,
            cloudKitDatabase: .private(cloudKitContainer)
        )
        return try ModelContainer(for: schema, configurations: [config])
    }

    static func makeInMemoryContainer() throws -> ModelContainer {
        let schema = Schema([
            House.self,
            Room.self,
            StorageBox.self,
            Item.self,
            ItemLink.self,
            Photo.self,
            ListValue.self
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        return try ModelContainer(for: schema, configurations: [config])
    }

    static func seedDefaultsIfNeeded(context: ModelContext) {
        let descriptor = FetchDescriptor<ListValue>(
            predicate: #Predicate { $0.category == "boxType" }
        )
        let existing = (try? context.fetch(descriptor)) ?? []
        guard existing.isEmpty else { return }

        for entry in ListValue.defaultBoxTypes {
            context.insert(ListValue(
                category: ListValue.Category.boxType,
                value: entry.value,
                sortOrder: entry.order,
                isSeeded: true
            ))
        }
        try? context.save()
    }
}
