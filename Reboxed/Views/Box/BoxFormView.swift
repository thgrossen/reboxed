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
    var location: ItemLocation? = nil
    var editBox: StorageBox? = nil
    @Environment( \.modelContext ) private var modelContext
    @Environment( \.dismiss ) private var dismiss

    @State private var title = ""
    @State private var descriptionText = ""
    @State private var boxType = ""
    @State private var owner = ""
    @State private var tags: [ String ] = []
    @State private var lengthCm  = 0.0
    @State private var widthCm   = 0.0
    @State private var heightCm  = 0.0
    @State private var isHeavy   = false
    @State private var isFragile = false
    @State private var selectedLocation: ItemLocation?
    @State private var showLocationPicker = false
    @State private var selectedPreset: BoxSizePreset? = nil
    @Query( sort: \BoxSizePreset.sortOrder ) private var sizePresets: [ BoxSizePreset ]

    init( location: ItemLocation? = nil, editBox: StorageBox? = nil )
    {
        self.location = location
        self.editBox  = editBox
        _selectedLocation = State( initialValue: location )
    }

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
                Section( "Location" )
                {
                    Button { showLocationPicker = true } label: {
                        LabeledContent( "Stored in" )
                        {
                            Text( locationDisplayName )
                        }
                    }
                    .buttonStyle( .plain )
                    .foregroundStyle( selectedLocation == nil ? .secondary : .primary )
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
                Section( "Dimensions" )
                {
                    if sizePresets.isEmpty == false
                    {
                        Picker( "Size", selection: $selectedPreset )
                        {
                            Text( "Custom" ).tag( Optional<BoxSizePreset>.none )
                            ForEach( sizePresets ) { preset in
                                Text( preset.displayName ).tag( Optional( preset ) )
                            }
                        }
                        .onChange( of: selectedPreset )
                        {
                            if let preset = selectedPreset
                            {
                                lengthCm = preset.lengthCm
                                widthCm  = preset.widthCm
                                heightCm = preset.heightCm
                            }
                        }
                    }
                    if selectedPreset == nil
                    {
                        LabeledContent( "Length (cm)" )
                        {
                            TextField( "0", value: $lengthCm, format: .number )
                                .multilineTextAlignment( .trailing )
                                #if canImport(UIKit)
                                .keyboardType( .decimalPad )
                                #endif
                        }
                        LabeledContent( "Width (cm)" )
                        {
                            TextField( "0", value: $widthCm, format: .number )
                                .multilineTextAlignment( .trailing )
                                #if canImport(UIKit)
                                .keyboardType( .decimalPad )
                                #endif
                        }
                        LabeledContent( "Height (cm)" )
                        {
                            TextField( "0", value: $heightCm, format: .number )
                                .multilineTextAlignment( .trailing )
                                #if canImport(UIKit)
                                .keyboardType( .decimalPad )
                                #endif
                        }
                    }
                    Toggle( "Heavy", isOn: $isHeavy )
                    Toggle( "Fragile", isOn: $isFragile )
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
                        .disabled(
                            title.trimmingCharacters( in: .whitespaces ).isEmpty ||
                            ( editBox == nil && selectedLocation == nil )
                        )
                }
            }
            .onAppear { loadExisting() }
            .sheet( isPresented: $showLocationPicker )
            {
                ItemLocationPickerView( selection: $selectedLocation, includeBoxes: false )
            }
        }
    }

    private var locationDisplayName: String
    {
        guard let loc = selectedLocation
        else { return "Tap to select…" }
        switch loc
        {
        case .box( let b ):   return b.title
        case .room( let r ):  return r.title
        case .house( let h ): return h.title
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
        lengthCm  = box.lengthCm
        widthCm   = box.widthCm
        heightCm  = box.heightCm
        isHeavy   = box.isHeavy
        isFragile = box.isFragile

        if let room = box.room         { selectedLocation = .room( room ) }
        else if let house = box.house  { selectedLocation = .house( house ) }
    }

    private func save()
    {
        let box = editBox ?? StorageBox()
        box.title = title.trimmingCharacters( in: .whitespaces )
        box.descriptionText = descriptionText
        box.boxType = boxType
        box.owner = owner
        box.tags = tags
        box.lengthCm  = lengthCm
        box.widthCm   = widthCm
        box.heightCm  = heightCm
        box.isHeavy   = isHeavy
        box.isFragile = isFragile
        box.modifiedAt = Date()

        box.house = nil
        box.room  = nil

        if let loc = selectedLocation
        {
            switch loc
            {
            case .house( let h ): box.house = h
            case .room( let r ):  box.room = r
            case .box: break
            }
        }

        if editBox == nil
        {
            let existing = ( try? modelContext.fetch( FetchDescriptor<StorageBox>() ) ) ?? []
            let maxNumber = existing.map( \.boxNumber ).max() ?? 0
            box.boxNumber = maxNumber + 1
            modelContext.insert( box )
        }
        dismiss()
    }
}
