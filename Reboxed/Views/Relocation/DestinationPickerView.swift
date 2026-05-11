/*******************************************************************************
 * The MIT License (MIT)
 *
 * Copyright (c) 2026, Thomas Grossen
 ******************************************************************************/

import SwiftUI
import SwiftData

struct DestinationPickerView: View
{
    @Binding var destinationHouse: House?
    @Binding var destinationRoom: Room?
    @Environment( \.dismiss ) private var dismiss
    @Query( sort: \House.title ) private var houses: [ House ]
    @State private var selectedHouse: House?

    var body: some View
    {
        NavigationStack
        {
            List
            {
                Section
                {
                    Button( "No destination (clear)" )
                    {
                        destinationHouse = nil
                        destinationRoom = nil
                        dismiss()
                    }
                    .foregroundStyle( .red )
                }
                Section( "Select a place" )
                {
                    ForEach( houses ) { house in
                        if house.hasRooms == false
                        {
                            Button
                            {
                                destinationHouse = house
                                destinationRoom  = nil
                                dismiss()
                            } label: {
                                HouseRowView( house: house )
                            }
                            .foregroundStyle( .primary )
                        }
                        else
                        {
                            DisclosureGroup
                            {
                                let rooms = ( house.rooms ?? [] ).sorted { $0.sortOrder < $1.sortOrder }
                                ForEach( rooms ) { room in
                                    Button( room.title )
                                    {
                                        destinationHouse = house
                                        destinationRoom  = room
                                        dismiss()
                                    }
                                }
                            } label: {
                                HouseRowView( house: house )
                            }
                        }
                    }
                }
            }
            .navigationTitle( "Set Destination" )
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
        }
    }
}
