/*******************************************************************************
 * The MIT License (MIT)
 *
 * Copyright (c) 2026, Thomas Grossen
 ******************************************************************************/

import SwiftUI
import SwiftData

struct SidebarView: View
{
    @Environment( \.modelContext ) private var modelContext
    @Query( sort: \House.title ) private var houses: [ House ]
    @Binding var selectedHouse: House?
    @State private var showAddHouse = false
    @State private var showRelocation = false
    @State private var showSearch = false
    @State private var showScanner = false

    var body: some View
    {
        List( selection: $selectedHouse )
        {
            Section( "Places" )
            {
                ForEach( houses ) { house in
                    HouseRowView( house: house )
                        .tag( house )
                }
                .onDelete( perform: deleteHouses )
            }
        }
        .navigationTitle( "Reboxed" )
        .toolbar
        {
            ToolbarItem( placement: .primaryAction )
            {
                Button { showAddHouse = true } label: {
                    Image( systemName: "plus" )
                }
            }
            ToolbarItem
            {
                Button { showScanner = true } label: {
                    Image( systemName: "qrcode.viewfinder" )
                }
            }
        }
        .sheet( isPresented: $showAddHouse )
        {
            HouseFormView( mode: .create )
        }
        .sheet( isPresented: $showScanner )
        {
            ScannerView()
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
