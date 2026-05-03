import SwiftUI

struct ItemFormView: View {
    let location: ItemLocation
    var editItem: Item? = nil
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var descriptionText = ""
    @State private var owner = ""
    @State private var tags: [String] = []

    var body: some View {
        NavigationStack {
            Form {
                Section("Item") {
                    TextField("Title (e.g. Xbox 365)", text: $title)
                    TextField("Description", text: $descriptionText, axis: .vertical)
                        .lineLimit(2...4)
                }
                Section("Details") {
                    ListValuePicker(
                        category: ListValue.Category.owner,
                        label: "Owner",
                        selection: $owner
                    )
                }
                Section("Tags") {
                    TagEditorView(tags: $tags)
                }
            }
            .navigationTitle(editItem == nil ? "New Item" : "Edit Item")
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
            .onAppear { loadExisting() }
        }
    }

    private func loadExisting() {
        guard let item = editItem else { return }
        title = item.title
        descriptionText = item.descriptionText
        owner = item.owner
        tags = item.tags
    }

    private func save() {
        let item = editItem ?? Item()
        item.title = title.trimmingCharacters(in: .whitespaces)
        item.descriptionText = descriptionText
        item.owner = owner
        item.tags = tags
        item.modifiedAt = Date()

        if editItem == nil {
            switch location {
            case .house(let h): item.house = h
            case .room(let r): item.room = r
            case .box(let b): item.storageBox = b
            }
            modelContext.insert(item)
        }
        dismiss()
    }
}
