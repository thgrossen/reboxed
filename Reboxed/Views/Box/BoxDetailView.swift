/*******************************************************************************
 * The MIT License (MIT)
 *
 * Copyright (c) 2026, Thomas Grossen
 ******************************************************************************/

import SwiftData
import SwiftUI

struct BoxDetailView: View
{
    @Bindable var box: StorageBox
    @Environment( \.modelContext ) private var modelContext
    @State private var showEdit = false
    @State private var showAddItem = false
    @State private var showLabelPrint = false
    @State private var showDestinationPicker = false

    private var sortedItems: [ Item ]
    {
        ( self.box.items ?? [] ).sorted { $0.title < $1.title }
    }

    var body: some View
    {
        List
        {
            if box.descriptionText.isEmpty == false
            {
                Section
                {
                    Text( box.descriptionText ).foregroundStyle( .secondary )
                }
            }

            Section( "Location" )
            {
                Text( box.currentLocationName.isEmpty ? "—" : box.currentLocationName )
                    .foregroundStyle( box.currentLocationName.isEmpty ? .secondary : .primary )
            }

            Section( "Details" )
            {
                if box.boxType.isEmpty == false
                {
                    LabeledContent( "Type", value: box.boxType )
                }
                if box.owner.isEmpty == false
                {
                    LabeledContent( "Owner", value: box.owner )
                }
                if box.tags.isEmpty == false
                {
                    TagsView( tags: box.tags )
                }
                if box.lengthCm > 0 || box.widthCm > 0 || box.heightCm > 0
                {
                    LabeledContent( "Dimensions" )
                    {
                        Text( "\( box.lengthCm.formatted( .number ) ) × \( box.widthCm.formatted( .number ) ) × \( box.heightCm.formatted( .number ) ) cm" )
                    }
                }
                if box.isHeavy
                {
                    LabeledContent( "Heavy", value: "Yes" )
                }
                if box.isFragile
                {
                    LabeledContent( "Fragile", value: "Yes" )
                }
            }

            Section( "QR Code" )
            {
                HStack( spacing: 16 )
                {
                    QRCodeView( uid: box.uid, size: 90 )
                    VStack( alignment: .leading, spacing: 4 )
                    {
                        if box.boxNumber > 0
                        {
                            Text( "\( box.boxNumber )" )
                                .font( .system( size: 48, weight: .bold, design: .rounded ) )
                        }
                        Text( box.uid )
                            .font( .system( .caption, design: .monospaced ) )
                            .foregroundStyle( .secondary )
                        Button( "Print Label" ) { showLabelPrint = true }
                    }
                }
            }

            Section( "Destination" )
            {
                if let dest = box.destinationHouse
                {
                    HStack
                    {
                        VStack( alignment: .leading )
                        {
                            Text( "→ \( dest.title )" )
                            if let room = box.destinationRoom
                            {
                                Text( room.title ).font( .caption ).foregroundStyle( .secondary )
                            }
                        }
                        Spacer()
                        Button( "Change" ) { showDestinationPicker = true }
                            .buttonStyle( .borderless )
                        Button( "Clear" )
                        {
                            box.destinationHouse = nil
                            box.destinationRoom = nil
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
                ForEach( sortedItems ) { item in
                    NavigationLink( value: item )
                    {
                        ItemRowView( item: item )
                    }
                }
                .onDelete( perform: deleteItems )
                Button { showAddItem = true } label: {
                    Label( "Add Item", systemImage: "plus" )
                }
            } header: {
                Text( "Contents (\( sortedItems.count ))" )
            }
        }
        .navigationTitle( box.title.isEmpty ? "Box" : box.title )
        .toolbar
        {
            ToolbarItem( placement: .primaryAction )
            {
                Button( "Edit" ) { showEdit = true }
            }
        }
        .sheet( isPresented: $showEdit )
        {
            BoxFormView( editBox: box )
        }
        .sheet( isPresented: $showAddItem )
        {
            ItemFormView( location: .box( box ) )
        }
        .sheet( isPresented: $showLabelPrint )
        {
            LabelPrintView( entries: [ ( uid: box.uid, title: box.title, number: box.boxNumber > 0 ? box.boxNumber : nil ) ] )
        }
        .sheet( isPresented: $showDestinationPicker )
        {
            DestinationPickerView(
                destinationHouse: Binding( get: { box.destinationHouse }, set: { box.destinationHouse = $0 } ),
                destinationRoom: Binding( get: { box.destinationRoom }, set: { box.destinationRoom = $0 } )
            )
        }
    }

    private func deleteItems( at offsets: IndexSet )
    {
        for index in offsets { self.modelContext.delete( self.sortedItems[ index ] ) }
    }
}
