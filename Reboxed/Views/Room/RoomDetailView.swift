/*******************************************************************************
 * The MIT License (MIT)
 *
 * Copyright (c) 2026, Thomas Grossen
 ******************************************************************************/

import SwiftUI
import SwiftData

struct RoomDetailView: View
{
    @Bindable var room: Room
    @Environment( \.modelContext ) private var modelContext
    @State private var showEdit = false
    @State private var showAddBox = false
    @State private var showAddItem = false
    @State private var showLabelPrint = false

    private var sortedBoxes: [ StorageBox ]
    {
        ( room.boxes ?? [] ).sorted { $0.title < $1.title }
    }

    private var directItems: [ Item ]
    {
        ( room.directItems ?? [] ).sorted { $0.title < $1.title }
    }

    var body: some View
    {
        List
        {
            if room.descriptionText.isEmpty == false
            {
                Section
                {
                    Text( room.descriptionText ).foregroundStyle( .secondary )
                }
            }

            Section( "QR Code" )
            {
                HStack( spacing: 16 )
                {
                    QRCodeView( uid: room.uid, size: 80 )
                    VStack( alignment: .leading, spacing: 4 )
                    {
                        Text( room.uid )
                            .font( .system( .caption, design: .monospaced ) )
                            .foregroundStyle( .secondary )
                        Button( "Print Label" ) { showLabelPrint = true }
                    }
                }
            }

            Section
            {
                ForEach( sortedBoxes ) { box in
                    NavigationLink( value: box )
                    {
                        BoxRowView( box: box )
                    }
                }
                .onDelete( perform: deleteBoxes )
                Button { showAddBox = true } label: {
                    Label( "Add Box", systemImage: "plus" )
                }
            } header: {
                Text( "Boxes (\( sortedBoxes.count ))" )
            }

            Section
            {
                ForEach( directItems ) { item in
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
                Text( "Direct Items (\( directItems.count ))" )
            }
        }
        .navigationTitle( room.title.isEmpty ? "Room" : room.title )
        .toolbar
        {
            ToolbarItem( placement: .primaryAction )
            {
                Button( "Edit" ) { showEdit = true }
            }
        }
        .sheet( isPresented: $showEdit )
        {
            RoomFormView( house: room.house ?? House(), room: room )
        }
        .sheet( isPresented: $showAddBox )
        {
            BoxFormView( location: .room( room ) )
        }
        .sheet( isPresented: $showAddItem )
        {
            ItemFormView( location: .room( room ) )
        }
        .sheet( isPresented: $showLabelPrint )
        {
            LabelPrintView( entries: [ ( uid: room.uid, title: room.title ) ] )
        }
    }

    private func deleteBoxes( at offsets: IndexSet )
    {
        for index in offsets { modelContext.delete( sortedBoxes[ index ] ) }
    }

    private func deleteItems( at offsets: IndexSet )
    {
        for index in offsets { modelContext.delete( directItems[ index ] ) }
    }
}
