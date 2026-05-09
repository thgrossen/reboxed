/*******************************************************************************
 * The MIT License (MIT)
 *
 * Copyright (c) 2026, Thomas Grossen
 ******************************************************************************/

import SwiftUI
import SwiftData

struct HousePickerView: View
{
    @Binding var selection: House?
    var onlyWithRooms: Bool = false
    @Environment( \.dismiss ) private var dismiss
    @Query( sort: \House.title ) private var allHouses: [ House ]
    @State private var showAddHouse = false

    private var houses: [ House ]
    {
        onlyWithRooms ? allHouses.filter { $0.hasRooms } : allHouses
    }

    var body: some View
    {
        NavigationStack
        {
            List
            {
                Section
                {
                    Button
                    {
                        showAddHouse = true
                    } label: {
                        Label( "New Place", systemImage: "plus" )
                    }
                }
                Section( "Select a place" )
                {
                    ForEach( houses ) { house in
                        Button
                        {
                            selection = house
                            dismiss()
                        } label: {
                            HStack
                            {
                                Text( house.title )
                                Spacer()
                                if selection?.uid == house.uid
                                {
                                    Image( systemName: "checkmark" )
                                        .foregroundStyle( .tint )
                                }
                            }
                        }
                        .foregroundStyle( .primary )
                    }
                }
            }
            .navigationTitle( "Choose Place" )
            #if os(iOS)
            .navigationBarTitleDisplayMode( .inline )
            #endif
            .toolbar
            {
                ToolbarItem( placement: .cancellationAction )
                {
                    Button( "Cancel" ) { dismiss() }
                }
            }
            .sheet( isPresented: $showAddHouse )
            {
                HouseFormView( mode: .create )
            }
        }
    }
}
