import SwiftUI
import SwiftData

struct HouseDetailView: View {
    @Bindable var house: House
    @Environment(\.modelContext) private var modelContext
    @State private var showEdit = false
    @State private var showAddRoom = false
    @State private var showAddBox = false
    @State private var showAddItem = false
    @State private var showLabelPrint = false

    private var sortedRooms: [Room] {
        (house.rooms ?? []).sorted { $0.sortOrder < $1.sortOrder }
    }

    var body: some View {
        List {
            // Info section
            if !house.descriptionText.isEmpty {
                Section {
                    Text(house.descriptionText)
                        .foregroundStyle(.secondary)
                }
            }

            if !house.street.isEmpty || !house.city.isEmpty {
                Section("Address") {
                    VStack(alignment: .leading, spacing: 2) {
                        if !house.street.isEmpty { Text(house.street) }
                        Text([house.postalCode, house.city].filter { !$0.isEmpty }.joined(separator: " "))
                        if !house.country.isEmpty { Text(house.country) }
                    }
                    .font(.body)
                }
            }

            // QR Code
            Section("QR Code") {
                HStack(spacing: 16) {
                    QRCodeView(uid: house.uid, size: 90)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(house.uid)
                            .font(.system(.caption, design: .monospaced))
                            .foregroundStyle(.secondary)
                        Button("Print Label") { showLabelPrint = true }
                    }
                }
            }

            // Rooms
            Section {
                ForEach(sortedRooms) { room in
                    NavigationLink(value: room) {
                        RoomRowView(room: room)
                    }
                }
                .onDelete(perform: deleteRooms)
                Button { showAddRoom = true } label: {
                    Label("Add Room", systemImage: "plus")
                }
            } header: {
                Text("Rooms (\(sortedRooms.count))")
            }

            // Direct boxes (no room)
            let boxes = (house.directBoxes ?? []).sorted { $0.title < $1.title }
            if !boxes.isEmpty || showAddBox {
                Section {
                    ForEach(boxes) { box in
                        NavigationLink(value: box) {
                            BoxRowView(box: box)
                        }
                    }
                    .onDelete(perform: deleteDirectBoxes)
                    Button { showAddBox = true } label: {
                        Label("Add Box", systemImage: "plus")
                    }
                } header: {
                    Text("Direct Boxes (\(boxes.count))")
                }
            } else {
                Section {
                    Button { showAddBox = true } label: {
                        Label("Add Box (no room)", systemImage: "plus")
                    }
                } header: {
                    Text("Direct Boxes")
                }
            }

            // Arriving items (relocation)
            let arriving = (house.arrivingBoxes ?? []).count + (house.arrivingItems ?? []).count
            if arriving > 0 {
                Section("Arriving Here (\(arriving))") {
                    NavigationLink("View Relocation Dashboard") {
                        RelocationDashboardView()
                    }
                }
            }
        }
        .navigationTitle(house.title.isEmpty ? "Place" : house.title)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") { showEdit = true }
            }
        }
        .sheet(isPresented: $showEdit) { HouseFormView(mode: .edit(house)) }
        .sheet(isPresented: $showAddRoom) { RoomFormView(house: house) }
        .sheet(isPresented: $showAddBox) { BoxFormView(location: .house(house)) }
        .sheet(isPresented: $showAddItem) { ItemFormView(location: .house(house)) }
        .sheet(isPresented: $showLabelPrint) {
            LabelPrintView(entries: [(uid: house.uid, title: house.title)])
        }
    }

    private func deleteRooms(at offsets: IndexSet) {
        let sorted = sortedRooms
        for index in offsets { modelContext.delete(sorted[index]) }
    }

    private func deleteDirectBoxes(at offsets: IndexSet) {
        let sorted = (house.directBoxes ?? []).sorted { $0.title < $1.title }
        for index in offsets { modelContext.delete(sorted[index]) }
    }
}
