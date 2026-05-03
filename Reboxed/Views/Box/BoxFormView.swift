/*******************************************************************************
 * The MIT License (MIT)
 *
 * Copyright (c) 2026, Thomas Grossen
 ******************************************************************************/

import SwiftUI
import SwiftData

enum ItemLocation
{
    case house( House )
    case room( Room )
    case box( StorageBox )
}

struct BoxFormView: View
{
    let location: ItemLocation
    var editBox: StorageBox? = nil
    @Environment( \.modelContext ) private var modelContext
    @Environment( \.dismiss ) private var dismiss

    @State private var title = ""
    @State private var descriptionText = ""
    @State private var boxType = ""
    @State private var owner = ""
    @State private var tags: [ String ] = []

    var body: some View
    {
        NavigationStack
        {
            Form
            {
                Section( "Box" )
                {
                    TextField( "Title (e.g. Kitchen Fragile)", text: $title )
                    TextField( "Description", text: $descriptionText, axis: .vertical )
                        .lineLimit( 2...4 )
                }
                Section( "Details" )
                {
                    ListValuePicker(
                        category: ListValue.Category.boxType,
                        label: "Box Type",
                        selection: $boxType
                    )
                    ListValuePicker(
                        category: ListValue.Category.owner,
                        label: "Owner",
                        selection: $owner
                    )
                }
                Section( "Tags" )
                {
                    TagEditorView( tags: $tags )
                }
            }
            .navigationTitle( editBox == nil ? "New Box" : "Edit Box" )
            #if os(iOS)
            .navigationBarTitleDisplayMode( .inline )
            #endif
            .toolbar
            {
                ToolbarItem( placement: .cancellationAction )
                {
                    Button( "Cancel" ) { dismiss() }
                }
                ToolbarItem( placement: .confirmationAction )
                {
                    Button( "Save" ) { save() }
                        .disabled( title.trimmingCharacters( in: .whitespaces ).isEmpty )
                }
            }
            .onAppear { loadExisting() }
        }
    }

    private func loadExisting()
    {
        guard let box = editBox else { return }
        title = box.title
        descriptionText = box.descriptionText
        boxType = box.boxType
        owner = box.owner
        tags = box.tags
    }

    private func save()
    {
        let box = editBox ?? StorageBox()
        box.title = title.trimmingCharacters( in: .whitespaces )
        box.descriptionText = descriptionText
        box.boxType = boxType
        box.owner = owner
        box.tags = tags
        box.modifiedAt = Date()

        if editBox == nil
        {
            switch location
            {
            case .house( let h ): box.house = h
            case .room( let r ): box.room = r
            case .box: break
            }
            modelContext.insert( box )
        }
        dismiss()
    }
}
