import SwiftUI
import SwiftData

struct ListValuePicker: View {
    let category: String
    let label: String
    @Binding var selection: String
    @Environment(\.modelContext) private var modelContext
    @Query private var allValues: [ListValue]
    @State private var showAddNew = false
    @State private var newValue = ""

    private var values: [ListValue] {
        allValues
            .filter { $0.category == category }
            .sorted { $0.sortOrder < $1.sortOrder }
    }

    var body: some View {
        Picker(label, selection: $selection) {
            Text("None").tag("")
            ForEach(values) { item in
                Text(item.value).tag(item.value)
            }
            Divider()
            Text("Add new…").tag("__add__")
        }
        .onChange(of: selection) {
            if selection == "__add__" {
                selection = ""
                showAddNew = true
            }
        }
        .alert("New \(label)", isPresented: $showAddNew) {
            TextField("\(label) name", text: $newValue)
            Button("Add") { saveNewValue() }
            Button("Cancel", role: .cancel) { newValue = "" }
        }
    }

    private func saveNewValue() {
        let trimmed = newValue.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        let maxOrder = values.map(\.sortOrder).max() ?? -1
        let new = ListValue(category: category, value: trimmed, sortOrder: maxOrder + 1)
        modelContext.insert(new)
        selection = trimmed
        newValue = ""
    }
}
