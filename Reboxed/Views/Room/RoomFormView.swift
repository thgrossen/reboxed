/*******************************************************************************
 * The MIT License (MIT)
 *
 * Copyright (c) 2026, Thomas Grossen
 ******************************************************************************/

import SwiftUI
import SwiftData

struct RoomFormView: View
{
    var house: House? = nil
    var room: Room? = nil
    @Environment( \.modelContext ) private var modelContext
    @Environment( \.dismiss ) private var dismiss

    @State private var title = ""
    @State private var descriptionText = ""
    @State private var floor = 0
    @State private var selectedHouse: House? = nil
    @State private var showHousePicker = false

    var body: some View
    {
        NavigationStack
        {
            Form
            {
                if room == nil
                {
                    Section( "Place" )
                    {
                        Button { showHousePicker = true } label: {
                            LabeledContent( "In" )
                            {
                                Text( selectedHouse?.title ?? "Tap to select…" )
                            }
                        }
                        .buttonStyle( .plain )
                        .foregroundStyle( selectedHouse == nil ? .secondary : .primary )
                    }
                }
                Section( "Name" )
                {
                    TextField( "Room name (e.g. Living Room)", text: $title )
                    TextField( "Description", text: $descriptionText, axis: .vertical )
                        .lineLimit( 2...4 )
                    Stepper( "Floor \( floor )", value: $floor )
                }
            }
            .navigationTitle( room == nil ? "New Room" : "Edit Room" )
            #if os(iOS)
            .navigationBarTitleDisplayMode( .inline )
            #endif
            .toolbar
            {
                ToolbarItem( placement: .cancellationAction )
                {
                    Button( "Cancel" ) { dismiss() }
                }
                ToolbarItem( placement: .confirmationAction )
                {
                    Button( "Save" ) { save() }
                        .disabled(
                            title.trimmingCharacters( in: .whitespaces ).isEmpty ||
                            ( room == nil && selectedHouse == nil )
                        )
                }
            }
            .onAppear
            {
                title = room?.title ?? ""
                descriptionText = room?.descriptionText ?? ""
                floor = room?.floor ?? 0
                selectedHouse = house
            }
            .sheet( isPresented: $showHousePicker )
            {
                HousePickerView( selection: $selectedHouse, onlyWithRooms: true )
            }
        }
    }

    private func save()
    {
        if let existing = room
        {
            existing.title = title.trimmingCharacters( in: .whitespaces )
            existing.descriptionText = descriptionText
            existing.floor = floor
            existing.modifiedAt = Date()
        }
        else
        {
            guard let house = selectedHouse else { return }
            let newRoom = Room()
            newRoom.title = title.trimmingCharacters( in: .whitespaces )
            newRoom.descriptionText = descriptionText
            newRoom.floor = floor
            newRoom.house = house
            newRoom.sortOrder = ( house.rooms?.count ?? 0 )
            modelContext.insert( newRoom )
        }
        dismiss()
    }
}
