import SwiftUI

struct ItemDetailView: View {
    @Bindable var item: Item
    @Environment(\.modelContext) private var modelContext
    @State private var showEdit = false
    @State private var showLinks = false
    @State private var showLabelPrint = false
    @State private var showDestinationPicker = false

    var body: some View {
        List {
            if !item.descriptionText.isEmpty {
                Section {
                    Text(item.descriptionText).foregroundStyle(.secondary)
                }
            }

            Section("Details") {
                if !item.owner.isEmpty {
                    LabeledContent("Owner", value: item.owner)
                }
                if !item.tags.isEmpty {
                    TagsView(tags: item.tags)
                }
                if !item.currentLocationName.isEmpty {
                    LabeledContent("Location", value: item.currentLocationName)
                }
            }

            Section("QR Code") {
                HStack(spacing: 16) {
                    QRCodeView(uid: item.uid, size: 90)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.uid)
                            .font(.system(.caption, design: .monospaced))
                            .foregroundStyle(.secondary)
                        Button("Print Label") { showLabelPrint = true }
                    }
                }
            }

            Section("Destination") {
                if let dest = item.destinationHouse {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("→ \(dest.title)")
                            if let room = item.destinationRoom {
                                Text(room.title).font(.caption).foregroundStyle(.secondary)
                            }
                        }
                        Spacer()
                        Button("Change") { showDestinationPicker = true }
                            .buttonStyle(.borderless)
                        Button("Clear") {
                            item.destinationHouse = nil
                            item.destinationRoom = nil
                        }
                        .buttonStyle(.borderless)
                        .foregroundStyle(.red)
                    }
                } else {
                    Button { showDestinationPicker = true } label: {
                        Label("Set Destination", systemImage: "arrow.triangle.swap")
                    }
                }
            }

            Section {
                ForEach(item.linkedItems) { linked in
                    NavigationLink(value: linked) {
                        ItemRowView(item: linked)
                    }
                }
                Button { showLinks = true } label: {
                    Label("Manage Links", systemImage: "link")
                }
            } header: {
                Text("Linked Items (\(item.linkedItems.count))")
            }
        }
        .navigationTitle(item.title.isEmpty ? "Item" : item.title)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") { showEdit = true }
            }
        }
        .sheet(isPresented: $showEdit) {
            ItemFormView(location: .house(House()), editItem: item)
        }
        .sheet(isPresented: $showLinks) {
            ItemLinksView(item: item)
        }
        .sheet(isPresented: $showLabelPrint) {
            LabelPrintView(entries: [(uid: item.uid, title: item.title)])
        }
        .sheet(isPresented: $showDestinationPicker) {
            DestinationPickerView(
                destinationHouse: Binding(get: { item.destinationHouse }, set: { item.destinationHouse = $0 }),
                destinationRoom: Binding(get: { item.destinationRoom }, set: { item.destinationRoom = $0 })
            )
        }
    }
}
