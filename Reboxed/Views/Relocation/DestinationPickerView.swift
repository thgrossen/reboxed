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
                        DisclosureGroup
                        {
                            let rooms = ( house.rooms ?? [] ).sorted { $0.sortOrder < $1.sortOrder }
                            if rooms.isEmpty
                            {
                                Text( "No rooms — will arrive at place level" )
                                    .font( .caption )
                                    .foregroundStyle( .secondary )
                                    .padding( .leading )
                            }
                            else
                            {
                                Button( "Anywhere in \( house.title )" )
                                {
                                    destinationHouse = house
                                    destinationRoom = nil
                                    dismiss()
                                }
                                ForEach( rooms ) { room in
                                    Button( room.title )
                                    {
                                        destinationHouse = house
                                        destinationRoom = room
                                        dismiss()
                                    }
                                    .padding( .leading )
                                }
                            }
                        } label: {
                            HouseRowView( house: house )
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
