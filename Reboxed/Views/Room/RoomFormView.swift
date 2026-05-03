import SwiftUI

struct RoomFormView: View {
    let house: House
    var room: Room? = nil
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var descriptionText = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("Room name (e.g. Living Room)", text: $title)
                    TextField("Description", text: $descriptionText, axis: .vertical)
                        .lineLimit(2...4)
                }
            }
            .navigationTitle(room == nil ? "New Room" : "Edit Room")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear {
                title = room?.title ?? ""
                descriptionText = room?.descriptionText ?? ""
            }
        }
    }

    private func save() {
        if let existing = room {
            existing.title = title.trimmingCharacters(in: .whitespaces)
            existing.descriptionText = descriptionText
            existing.modifiedAt = Date()
        } else {
            let newRoom = Room()
            newRoom.title = title.trimmingCharacters(in: .whitespaces)
            newRoom.descriptionText = descriptionText
            newRoom.house = house
            newRoom.sortOrder = (house.rooms?.count ?? 0)
            modelContext.insert(newRoom)
        }
        dismiss()
    }
}
