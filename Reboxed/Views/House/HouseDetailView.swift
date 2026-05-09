/*******************************************************************************
 * The MIT License (MIT)
 *
 * Copyright (c) 2026, Thomas Grossen
 ******************************************************************************/

import SwiftUI
import SwiftData

struct HouseDetailView: View
{
    @Bindable var house: House
    @Environment( \.modelContext ) private var modelContext
    @State private var showEdit = false
    @State private var showAddRoom = false
    @State private var showAddBox = false
    @State private var showAddItem = false

    private var sortedRooms: [ Room ]
    {
        ( house.rooms ?? [] ).sorted { $0.sortOrder < $1.sortOrder }
    }

    var body: some View
    {
        List
        {
            // Info section
            if house.descriptionText.isEmpty == false
            {
                Section
                {
                    Text( house.descriptionText )
                        .foregroundStyle( .secondary )
                }
            }

            if house.street.isEmpty == false || house.city.isEmpty == false
            {
                Section( "Address" )
                {
                    VStack( alignment: .leading, spacing: 2 )
                    {
                        if house.street.isEmpty == false { Text( house.street ) }
                        Text( [ house.postalCode, house.city ].filter { $0.isEmpty == false }.joined( separator: " " ) )
                        if house.country.isEmpty == false { Text( house.country ) }
                    }
                    .font( .body )
                }
            }

            Section( "Details" )
            {
                LabeledContent( "Has Rooms", value: house.hasRooms ? "Yes" : "No" )
            }

            // Rooms
            Section
            {
                ForEach( sortedRooms ) { room in
                    NavigationLink( value: room )
                    {
                        RoomRowView( room: room )
                    }
                }
                .onDelete( perform: deleteRooms )
                if house.hasRooms
                {
                    Button { showAddRoom = true } label: {
                        Label( "Add Room", systemImage: "plus" )
                    }
                }
            } header: {
                Text( "Rooms (\( sortedRooms.count ))" )
            }

            // Direct boxes (no room)
            let boxes = ( house.directBoxes ?? [] ).sorted { $0.title < $1.title }
            if boxes.isEmpty == false || showAddBox
            {
                Section
                {
                    ForEach( boxes ) { box in
                        NavigationLink( value: box )
                        {
                            BoxRowView( box: box )
                        }
                    }
                    .onDelete( perform: deleteDirectBoxes )
                    Button { showAddBox = true } label: {
                        Label( "Add Box", systemImage: "plus" )
                    }
                } header: {
                    Text( "Direct Boxes (\( boxes.count ))" )
                }
            }
            else
            {
                Section
                {
                    Button { showAddBox = true } label: {
                        Label( "Add Box (no room)", systemImage: "plus" )
                    }
                } header: {
                    Text( "Direct Boxes" )
                }
            }

            // Arriving items (relocation)
            let arriving = ( house.arrivingBoxes ?? [] ).count + ( house.arrivingItems ?? [] ).count
            if arriving > 0
            {
                Section( "Arriving Here (\( arriving ))" )
                {
                    NavigationLink( "View Relocation Dashboard" )
                    {
                        RelocationDashboardView()
                    }
                }
            }
        }
        .navigationTitle( house.title.isEmpty ? "Place" : house.title )
        .toolbar
        {
            ToolbarItem( placement: .primaryAction )
            {
                Button( "Edit" ) { showEdit = true }
            }
        }
        .sheet( isPresented: $showEdit ) { HouseFormView( mode: .edit( house ) ) }
        .sheet( isPresented: $showAddRoom ) { RoomFormView( house: house ) }
        .sheet( isPresented: $showAddBox ) { BoxFormView( location: .house( house ) ) }
        .sheet( isPresented: $showAddItem ) { ItemFormView( location: .house( house ) ) }
    }

    private func deleteRooms( at offsets: IndexSet )
    {
        let sorted = sortedRooms
        for index in offsets { modelContext.delete( sorted[ index ] ) }
    }

    private func deleteDirectBoxes( at offsets: IndexSet )
    {
        let sorted = ( house.directBoxes ?? [] ).sorted { $0.title < $1.title }
        for index in offsets { modelContext.delete( sorted[ index ] ) }
    }
}
