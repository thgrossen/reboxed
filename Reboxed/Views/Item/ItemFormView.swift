/*******************************************************************************
 * The MIT License (MIT)
 *
 * Copyright (c) 2026, Thomas Grossen
 ******************************************************************************/

import SwiftUI
import SwiftData
import PhotosUI

struct ItemFormView: View
{
    var location: ItemLocation? = nil
    var editItem: Item? = nil
    @Environment( \.modelContext ) private var modelContext
    @Environment( \.dismiss ) private var dismiss

    @State private var title = ""
    @State private var descriptionText = ""
    @State private var owner = ""
    @State private var tags: [ String ] = []

    @State private var capturedPhotos: [ Data ] = []
    @State private var librarySelection: [ PhotosPickerItem ] = []
    @State private var showCamera = false
    @State private var showLibrary = false
    @State private var showPhotoOptions = false
    @State private var showLocationPicker = false
    @State private var selectedLocation: ItemLocation?
    @State private var pendingLinks: [ Item ] = []
    @State private var showLinkPicker = false

    init( location: ItemLocation? = nil, editItem: Item? = nil )
    {
        self.location = location
        self.editItem = editItem
        _selectedLocation = State( initialValue: location )
    }

    var body: some View
    {
        NavigationStack
        {
            Form
            {
                if editItem == nil
                {
                    Section( "Photos" )
                    {
                        ScrollView( .horizontal, showsIndicators: false )
                        {
                            HStack( spacing: 8 )
                            {
                                ForEach( capturedPhotos.indices, id: \.self ) { index in
                                    PhotoThumbnailView( data: capturedPhotos[ index ] )
                                        .onLongPressGesture { capturedPhotos.remove( at: index ) }
                                }
                                Button
                                {
                                    showPhotoOptions = true
                                } label: {
                                    Image( systemName: "plus" )
                                        .frame( width: 72, height: 72 )
                                        .background( Color.secondary.opacity( 0.15 ) )
                                        .clipShape( RoundedRectangle( cornerRadius: 8 ) )
                                }
                                .buttonStyle( .plain )
                            }
                            .padding( .vertical, 4 )
                        }
                    }
                }
                else if let item = editItem
                {
                    EditPhotoSection( item: item )
                }

                Section( "Item" )
                {
                    TextField( "Title (e.g. Xbox 365)", text: $title )
                    TextField( "Description", text: $descriptionText, axis: .vertical )
                        .lineLimit( 2...4 )
                }
                Section( "Details" )
                {
                    ListValuePicker(
                        category: ListValue.Category.owner,
                        label: "Owner",
                        selection: $owner
                    )
                }
                Section( "Links" )
                {
                    if let item = editItem
                    {
                        EditLinksSection( item: item )
                    }
                    else
                    {
                        ForEach( pendingLinks ) { linked in
                            HStack
                            {
                                ItemRowView( item: linked )
                                Spacer()
                                Button
                                {
                                    pendingLinks.removeAll { $0.uid == linked.uid }
                                } label: {
                                    Image( systemName: "minus.circle.fill" )
                                        .foregroundStyle( .red )
                                }
                                .buttonStyle( .plain )
                            }
                        }
                        Button { showLinkPicker = true } label: {
                            Label( "Add Link", systemImage: "link" )
                        }
                    }
                }
                Section( "Location" )
                {
                    Button { showLocationPicker = true } label: {
                        LabeledContent( "Stored in" ) { Text( locationDisplayName ) }
                    }
                    .buttonStyle( .plain )
                    .foregroundStyle( selectedLocation == nil ? .secondary : .primary )
                }
                Section( "Tags" )
                {
                    TagEditorView( tags: $tags )
                }
            }
            .navigationTitle( editItem == nil ? "New Item" : "Edit Item" )
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
                            ( editItem == nil && selectedLocation == nil )
                        )
                }
            }
            .onAppear
            {
                loadExisting()
                #if canImport(UIKit)
                if editItem == nil { showCamera = true }
                #endif
            }
            .confirmationDialog( "Add Photo", isPresented: $showPhotoOptions )
            {
                #if canImport(UIKit)
                Button( "Camera" ) { showCamera = true }
                #endif
                Button( "Photo Library" ) { showLibrary = true }
            }
            #if canImport(UIKit)
            .sheet( isPresented: $showCamera )
            {
                CameraPickerView
                {
                    image in
                    if let data = image.jpegData( compressionQuality: 0.7 )
                    {
                        capturedPhotos.append( data )
                    }
                }
            }
            #endif
            .photosPicker(
                isPresented: $showLibrary,
                selection: $librarySelection,
                maxSelectionCount: 20,
                matching: .images
            )
            .onChange( of: librarySelection )
            {
                loadLibraryPhotos()
            }
            .sheet( isPresented: $showLocationPicker )
            {
                ItemLocationPickerView( selection: $selectedLocation, showNewBox: true )
            }
            .sheet( isPresented: $showLinkPicker )
            {
                LinkedItemSelectorView( exclude: pendingLinks ) { pendingLinks.append( $0 ) }
            }
        }
    }

    private var locationDisplayName: String
    {
        guard let loc = selectedLocation else { return "Tap to select…" }
        switch loc
        {
        case .box( let b ):   return b.title
        case .room( let r ):  return r.title
        case .house( let h ): return h.title
        }
    }

    private func loadExisting()
    {
        guard let item = editItem else { return }
        title = item.title
        descriptionText = item.descriptionText
        owner = item.owner
        tags = item.tags

        if      let box   = item.storageBox { selectedLocation = .box( box )     }
        else if let room  = item.room       { selectedLocation = .room( room )   }
        else if let house = item.house      { selectedLocation = .house( house ) }
    }

    private func loadLibraryPhotos()
    {
        Task
        {
            for pickerItem in librarySelection
            {
                if let data = try? await pickerItem.loadTransferable( type: Data.self )
                {
                    await MainActor.run { capturedPhotos.append( data ) }
                }
            }
            await MainActor.run { librarySelection = [] }
        }
    }

    private func save()
    {
        let item = editItem ?? Item()
        item.title = title.trimmingCharacters( in: .whitespaces )
        item.descriptionText = descriptionText
        item.owner = owner
        item.tags = tags
        item.modifiedAt = Date()

        item.storageBox = nil
        item.room = nil
        item.house = nil

        if let loc = selectedLocation
        {
            switch loc
            {
            case .house( let h ): item.house = h
            case .room( let r ):  item.room = r
            case .box( let b ):   item.storageBox = b
            }
        }

        if editItem == nil
        {
            modelContext.insert( item )

            for (index, data) in capturedPhotos.enumerated()
            {
                let photo = Photo( jpegData: data, sortOrder: index )
                modelContext.insert( photo )
                photo.item = item
            }

            for linked in pendingLinks
            {
                let link = ItemLink( source: item, target: linked )
                modelContext.insert( link )
            }
        }

        dismiss()
    }
}

private struct EditPhotoSection: View
{
    @Bindable var item: Item
    @Environment( \.modelContext ) private var modelContext
    @State private var showOptions  = false
    @State private var showCamera   = false
    @State private var showLibrary  = false
    @State private var libSelection: [ PhotosPickerItem ] = []

    private var sortedPhotos: [ Photo ]
    {
        ( item.photos ?? [] ).sorted { $0.sortOrder < $1.sortOrder }
    }

    var body: some View
    {
        Section( "Photos" )
        {
            ScrollView( .horizontal, showsIndicators: false )
            {
                HStack( spacing: 8 )
                {
                    ForEach( sortedPhotos ) { photo in
                        PhotoThumbnailView( data: photo.jpegData )
                            .onLongPressGesture { modelContext.delete( photo ) }
                    }
                    Button { showOptions = true } label: {
                        Image( systemName: "plus" )
                            .frame( width: 72, height: 72 )
                            .background( Color.secondary.opacity( 0.15 ) )
                            .clipShape( RoundedRectangle( cornerRadius: 8 ) )
                    }
                    .buttonStyle( .plain )
                }
                .padding( .vertical, 4 )
            }
        }
        .confirmationDialog( "Add Photo", isPresented: $showOptions )
        {
            #if canImport(UIKit)
            Button( "Camera" ) { showCamera = true }
            #endif
            Button( "Photo Library" ) { showLibrary = true }
        }
        #if canImport(UIKit)
        .sheet( isPresented: $showCamera )
        {
            CameraPickerView { image in
                if let data = image.jpegData( compressionQuality: 0.7 ) { addPhoto( data: data ) }
            }
        }
        #endif
        .photosPicker(
            isPresented: $showLibrary,
            selection: $libSelection,
            maxSelectionCount: 20,
            matching: .images
        )
        .onChange( of: libSelection ) { loadPhotos() }
    }

    private func addPhoto( data: Data )
    {
        let photo = Photo( jpegData: data, sortOrder: sortedPhotos.count )
        modelContext.insert( photo )
        photo.item = item
    }

    private func loadPhotos()
    {
        Task
        {
            for p in libSelection
            {
                if let data = try? await p.loadTransferable( type: Data.self )
                {
                    await MainActor.run { addPhoto( data: data ) }
                }
            }
            await MainActor.run { libSelection = [] }
        }
    }
}

private struct EditLinksSection: View
{
    @Bindable var item: Item
    @Environment( \.modelContext ) private var modelContext
    @State private var showPicker = false

    var body: some View
    {
        ForEach( item.linkedItems ) { linked in
            HStack
            {
                ItemRowView( item: linked )
                Spacer()
                Button
                {
                    removeLink( to: linked )
                } label: {
                    Image( systemName: "minus.circle.fill" )
                        .foregroundStyle( .red )
                }
                .buttonStyle( .plain )
            }
        }
        Button { showPicker = true } label: {
            Label( "Add Link", systemImage: "link" )
        }
        .sheet( isPresented: $showPicker )
        {
            ItemLinkPickerView( sourceItem: item )
        }
    }

    private func removeLink( to target: Item )
    {
        if let link = item.outgoingLinks?.first( where: { $0.targetItem == target } )
        {
            modelContext.delete( link )
        }
        else if let link = item.incomingLinks?.first( where: { $0.sourceItem == target } )
        {
            modelContext.delete( link )
        }
    }
}
