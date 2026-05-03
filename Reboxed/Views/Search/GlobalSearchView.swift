import SwiftUI
import SwiftData

struct GlobalSearchView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \House.title) private var houses: [House]
    @Query(sort: \Room.title) private var rooms: [Room]
    @Query(sort: \StorageBox.title) private var boxes: [StorageBox]
    @Query(sort: \Item.title) private var items: [Item]
    @State private var searchText = ""

    private var results: SearchResults {
        guard searchText.count >= 2 else { return .empty }
        let q = searchText
        return SearchResults(
            houses: houses.filter { matches($0.title, $0.descriptionText, $0.uid, query: q) || matches($0.city, query: q) },
            rooms: rooms.filter { matches($0.title, $0.descriptionText, $0.uid, query: q) },
            boxes: boxes.filter { matches($0.title, $0.descriptionText, $0.uid, $0.owner, query: q) || $0.tags.contains { $0.localizedCaseInsensitiveContains(q) } },
            items: items.filter { matches($0.title, $0.descriptionText, $0.uid, $0.owner, query: q) || $0.tags.contains { $0.localizedCaseInsensitiveContains(q) } }
        )
    }

    var body: some View {
        NavigationStack {
            Group {
                if searchText.count < 2 {
                    EmptyStateView(icon: "magnifyingglass", title: "Search", message: "Type at least 2 characters.")
                } else if results.isEmpty {
                    EmptyStateView(icon: "magnifyingglass", title: "No Results", message: "Nothing matched "\(searchText)".")
                } else {
                    List {
                        if !results.houses.isEmpty {
                            Section("Places") {
                                ForEach(results.houses) { house in
                                    NavigationLink(value: house) { HouseRowView(house: house) }
                                }
                            }
                        }
                        if !results.rooms.isEmpty {
                            Section("Rooms") {
                                ForEach(results.rooms) { room in
                                    NavigationLink(value: room) { RoomRowView(room: room) }
                                }
                            }
                        }
                        if !results.boxes.isEmpty {
                            Section("Boxes") {
                                ForEach(results.boxes) { box in
                                    NavigationLink(value: box) { BoxRowView(box: box) }
                                }
                            }
                        }
                        if !results.items.isEmpty {
                            Section("Items") {
                                ForEach(results.items) { item in
                                    NavigationLink(value: item) { ItemRowView(item: item) }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Search")
            .searchable(text: $searchText)
            .navigationDestination(for: House.self) { HouseDetailView(house: $0) }
            .navigationDestination(for: Room.self) { RoomDetailView(room: $0) }
            .navigationDestination(for: StorageBox.self) { BoxDetailView(box: $0) }
            .navigationDestination(for: Item.self) { ItemDetailView(item: $0) }
        }
    }

    private func matches(_ values: String..., query: String) -> Bool {
        values.contains { $0.localizedCaseInsensitiveContains(query) }
    }
}

struct SearchResults {
    var houses: [House]
    var rooms: [Room]
    var boxes: [StorageBox]
    var items: [Item]
    var isEmpty: Bool { houses.isEmpty && rooms.isEmpty && boxes.isEmpty && items.isEmpty }
    static let empty = SearchResults(houses: [], rooms: [], boxes: [], items: [])
}
