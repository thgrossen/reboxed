/*******************************************************************************
 * The MIT License (MIT)
 *
 * Copyright (c) 2026, Thomas Grossen
 ******************************************************************************/

import SwiftUI
import SwiftData
import PhotosUI

struct ItemDetailView: View
{
    @Bindable var item: Item
    @Environment( \.modelContext ) private var modelContext
    @State private var showEdit = false
    @State private var showLinks = false
    @State private var showLabelPrint = false
    @State private var showDestinationPicker = false
    @State private var showPhotoOptions = false
    @State private var showPhotoCamera = false
    @State private var showPhotoLibrary = false
    @State private var photoLibSelection: [ PhotosPickerItem ] = []

    private var sortedPhotos: [ Photo ]
    {
        ( item.photos ?? [] ).sorted { $0.sortOrder < $1.sortOrder }
    }

    var body: some View
    {
        List
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
                        Button { showPhotoOptions = true } label: {
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

            if item.descriptionText.isEmpty == false
            {
                Section
                {
                    Text( item.descriptionText ).foregroundStyle( .secondary )
                }
            }

            Section( "Details" )
            {
                if item.owner.isEmpty == false
                {
                    LabeledContent( "Owner", value: item.owner )
                }
                if item.tags.isEmpty == false
                {
                    TagsView( tags: item.tags )
                }
                if item.currentLocationName.isEmpty == false
                {
                    LabeledContent( "Location", value: item.currentLocationName )
                }
            }

            Section( "QR Code" )
            {
                HStack( spacing: 16 )
                {
                    QRCodeView( uid: item.uid, size: 90 )
                    VStack( alignment: .leading, spacing: 4 )
                    {
                        Text( item.uid )
                            .font( .system( .caption, design: .monospaced ) )
                            .foregroundStyle( .secondary )
                        Button( "Print Label" ) { showLabelPrint = true }
                    }
                }
            }

            Section( "Destination" )
            {
                if let dest = item.destinationHouse
                {
                    HStack
                    {
                        VStack( alignment: .leading )
                        {
                            Text( "→ \( dest.title )" )
                            if let room = item.destinationRoom
                            {
                                Text( room.title ).font( .caption ).foregroundStyle( .secondary )
                            }
                        }
                        Spacer()
                        Button( "Change" ) { showDestinationPicker = true }
                            .buttonStyle( .borderless )
                        Button( "Clear" )
                        {
                            item.destinationHouse = nil
                            item.destinationRoom = nil
                        }
                        .buttonStyle( .borderless )
                        .foregroundStyle( .red )
                    }
                }
                else
                {
                    Button { showDestinationPicker = true } label: {
                        Label( "Set Destination", systemImage: "arrow.triangle.swap" )
                    }
                }
            }

            Section
            {
                ForEach( item.linkedItems ) { linked in
                    NavigationLink( value: linked )
                    {
                        ItemRowView( item: linked )
                    }
                }
                Button { showLinks = true } label: {
                    Label( "Manage Links", systemImage: "link" )
                }
            } header: {
                Text( "Linked Items (\( item.linkedItems.count ))" )
            }
        }
        .navigationTitle( item.title.isEmpty ? "Item" : item.title )
        .toolbar
        {
            ToolbarItem( placement: .primaryAction )
            {
                Button( "Edit" ) { showEdit = true }
            }
        }
        .confirmationDialog( "Add Photo", isPresented: $showPhotoOptions )
        {
            #if canImport(UIKit)
            Button( "Camera" ) { showPhotoCamera = true }
            #endif
            Button( "Photo Library" ) { showPhotoLibrary = true }
        }
        #if canImport(UIKit)
        .sheet( isPresented: $showPhotoCamera )
        {
            CameraPickerView
            {
                image in
                if let data = image.jpegData( compressionQuality: 0.7 )
                {
                    addPhoto( data: data )
                }
            }
        }
        #endif
        .photosPicker(
            isPresented: $showPhotoLibrary,
            selection: $photoLibSelection,
            maxSelectionCount: 20,
            matching: .images
        )
        .onChange( of: photoLibSelection ) { loadLibraryPhotos() }
        .sheet( isPresented: $showEdit )
        {
            ItemFormView( editItem: item )
        }
        .sheet( isPresented: $showLinks )
        {
            ItemLinksView( item: item )
        }
        .sheet( isPresented: $showLabelPrint )
        {
            LabelPrintView( entries: [ ( uid: item.uid, title: item.title, number: nil ) ] )
        }
        .sheet( isPresented: $showDestinationPicker )
        {
            DestinationPickerView(
                destinationHouse: Binding( get: { item.destinationHouse }, set: { item.destinationHouse = $0 } ),
                destinationRoom: Binding( get: { item.destinationRoom }, set: { item.destinationRoom = $0 } )
            )
        }
    }

    private func addPhoto( data: Data )
    {
        let photo = Photo( jpegData: data, sortOrder: sortedPhotos.count )
        modelContext.insert( photo )
        photo.item = item
    }

    private func loadLibraryPhotos()
    {
        Task
        {
            for pickerItem in photoLibSelection
            {
                if let data = try? await pickerItem.loadTransferable( type: Data.self )
                {
                    await MainActor.run { addPhoto( data: data ) }
                }
            }
            await MainActor.run { photoLibSelection = [] }
        }
    }
}
