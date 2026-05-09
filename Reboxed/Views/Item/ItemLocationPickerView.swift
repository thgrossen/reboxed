/*******************************************************************************
 * The MIT License (MIT)
 *
 * Copyright (c) 2026, Thomas Grossen
 ******************************************************************************/

import SwiftUI
import SwiftData

struct ItemLocationPickerView: View
{
    @Binding var selection: ItemLocation?
    var includeBoxes: Bool  = true
    var showNewBox: Bool    = false
    @Environment( \.dismiss ) private var dismiss
    @Query( sort: \House.title )      private var houses:   [ House ]
    @Query( sort: \StorageBox.title ) private var allBoxes: [ StorageBox ]

    @State private var presentNewBox = false

    var body: some View
    {
        NavigationStack
        {
            List
            {
                if includeBoxes
                {
                    Section( "Boxes" )
                    {
                        ForEach( allBoxes ) { box in
                            Button
                            {
                                selection = .box( box )
                                dismiss()
                            } label: {
                                VStack( alignment: .leading, spacing: 2 )
                                {
                                    Text( box.title )
                                    if box.currentLocationName.isEmpty == false
                                    {
                                        Text( box.currentLocationName )
                                            .font( .caption )
                                            .foregroundStyle( .secondary )
                                    }
                                }
                            }
                            .foregroundStyle( .primary )
                        }
                        if showNewBox
                        {
                            Button
                            {
                                presentNewBox = true
                            } label: {
                                Label( "New Box", systemImage: "plus" )
                            }
                        }
                    }
                }
                Section( "Locations" )
                {
                    ForEach( houses ) { house in
                        if house.hasRooms == false
                        {
                            Button
                            {
                                selection = .house( house )
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
                                    Button
                                    {
                                        selection = .room( room )
                                        dismiss()
                                    } label: {
                                        Text( room.title )
                                    }
                                    .foregroundStyle( .primary )
                                }
                            } label: {
                                HouseRowView( house: house )
                            }
                        }
                    }
                }
            }
            .navigationTitle( "Choose Location" )
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
            .sheet( isPresented: $presentNewBox )
            {
                BoxFormView()
            }
        }
    }
}
