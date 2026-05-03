import SwiftUI
import SwiftData

struct RelocationDashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \House.title) private var houses: [House]

    var body: some View {
        NavigationStack {
            List {
                ForEach(houses) { house in
                    let arrivingBoxes = (house.arrivingBoxes ?? []).sorted { $0.title < $1.title }
                    let arrivingItems = (house.arrivingItems ?? []).sorted { $0.title < $1.title }
                    let total = arrivingBoxes.count + arrivingItems.count
                    if total > 0 {
                        Section {
                            ForEach(arrivingBoxes) { box in
                                NavigationLink(value: box) {
                                    HStack {
                                        BoxRowView(box: box)
                                        Spacer()
                                        if let room = box.destinationRoom {
                                            Text("→ \(room.title)")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                }
                            }
                            ForEach(arrivingItems) { item in
                                NavigationLink(value: item) {
                                    HStack {
                                        ItemRowView(item: item)
                                        Spacer()
                                        if let room = item.destinationRoom {
                                            Text("→ \(room.title)")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                }
                            }
                            Button("Move all to \(house.title)") {
                                moveAll(boxes: arrivingBoxes, items: arrivingItems, to: house)
                            }
                            .foregroundStyle(.tint)
                        } header: {
                            Text("→ \(house.title) (\(total))")
                        }
                    }
                }
            }
            .navigationTitle("Relocation")
            .navigationDestination(for: StorageBox.self) { BoxDetailView(box: $0) }
            .navigationDestination(for: Item.self) { ItemDetailView(item: $0) }
            .overlay {
                if houses.allSatisfy({ ($0.arrivingBoxes?.isEmpty ?? true) && ($0.arrivingItems?.isEmpty ?? true) }) {
                    EmptyStateView(
                        icon: "arrow.triangle.swap",
                        title: "No Pending Relocations",
                        message: "Set a destination on a box or item to track its move."
                    )
                }
            }
        }
    }

    private func moveAll(boxes: [StorageBox], items: [Item], to house: House) {
        for box in boxes {
            let targetRoom = box.destinationRoom
            box.room = targetRoom
            box.house = targetRoom == nil ? house : nil
            box.destinationHouse = nil
            box.destinationRoom = nil
        }
        for item in items {
            let targetRoom = item.destinationRoom
            item.room = targetRoom
            item.house = targetRoom == nil ? house : nil
            item.storageBox = nil
            item.destinationHouse = nil
            item.destinationRoom = nil
        }
    }
}
