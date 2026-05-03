import SwiftUI
import SwiftData

struct HouseListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \House.title) private var houses: [House]
    @State private var showAddHouse = false

    var body: some View {
        NavigationStack {
            Group {
                if houses.isEmpty {
                    EmptyStateView(
                        icon: "house",
                        title: "No Places",
                        message: "Add a house, flat, or storage unit to get started."
                    )
                } else {
                    List {
                        ForEach(houses) { house in
                            NavigationLink(value: house) {
                                HouseRowView(house: house)
                            }
                        }
                        .onDelete(perform: deleteHouses)
                    }
                }
            }
            .navigationTitle("Places")
            .navigationDestination(for: House.self) { HouseDetailView(house: $0) }
            .navigationDestination(for: Room.self) { RoomDetailView(room: $0) }
            .navigationDestination(for: StorageBox.self) { BoxDetailView(box: $0) }
            .navigationDestination(for: Item.self) { ItemDetailView(item: $0) }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button { showAddHouse = true } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddHouse) {
                HouseFormView(mode: .create)
            }
        }
    }

    private func deleteHouses(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(houses[index])
        }
    }
}
