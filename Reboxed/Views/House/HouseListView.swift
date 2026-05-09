/*******************************************************************************
 * The MIT License (MIT)
 *
 * Copyright (c) 2026, Thomas Grossen
 ******************************************************************************/

import SwiftUI
import SwiftData

struct HouseListView: View
{
    @Environment( \.modelContext ) private var modelContext
    @Query( sort: \House.title ) private var houses: [ House ]
    @State private var showAddHouse = false
    @State private var showAddRoom  = false
    @State private var showAddBox   = false
    @State private var showAddItem  = false

    var body: some View
    {
        NavigationStack
        {
            Group
            {
                if houses.isEmpty
                {
                    EmptyStateView(
                        icon: "house",
                        title: "No Places",
                        message: "Add a place, flat, or storage unit to get started."
                    )
                }
                else
                {
                    List
                    {
                        ForEach( houses ) { house in
                            NavigationLink( value: house )
                            {
                                HouseRowView( house: house )
                            }
                        }
                        .onDelete( perform: deleteHouses )
                    }
                }
            }
            .navigationTitle( "Places" )
            .navigationDestination( for: House.self ) { HouseDetailView( house: $0 ) }
            .navigationDestination( for: Room.self ) { RoomDetailView( room: $0 ) }
            .navigationDestination( for: StorageBox.self ) { BoxDetailView( box: $0 ) }
            .navigationDestination( for: Item.self ) { ItemDetailView( item: $0 ) }
            .toolbar
            {
                ToolbarItem( placement: .primaryAction )
                {
                    Menu
                    {
                        Button( "Place" )  { showAddHouse = true }
                        Button( "Room" )   { showAddRoom  = true }
                        Button( "Box" )    { showAddBox   = true }
                        Button( "Item" )   { showAddItem  = true }
                    } label: {
                        Image( systemName: "plus" )
                    }
                }
            }
            .sheet( isPresented: $showAddHouse ) { HouseFormView( mode: .create ) }
            .sheet( isPresented: $showAddRoom )  { RoomFormView() }
            .sheet( isPresented: $showAddBox )   { BoxFormView() }
            .sheet( isPresented: $showAddItem )  { ItemFormView() }
        }
    }

    private func deleteHouses( at offsets: IndexSet )
    {
        for index in offsets
        {
            modelContext.delete( houses[ index ] )
        }
    }
}
