/*******************************************************************************
 * The MIT License (MIT)
 *
 * Copyright (c) 2026, Thomas Grossen
 ******************************************************************************/

import SwiftUI
import SwiftData

struct HouseFormView: View
{
    enum Mode
    {
        case create
        case edit( House )
    }

    let mode: Mode
    @Environment( \.modelContext ) private var modelContext
    @Environment( \.dismiss ) private var dismiss

    @State private var title = ""
    @State private var descriptionText = ""
    @State private var hasRooms = true
    @State private var street = ""
    @State private var postalCode = ""
    @State private var city = ""
    @State private var country = ""

    private var isEditing: Bool
    {
        if case .edit = mode { return true }
        return false
    }

    var body: some View
    {
        NavigationStack
        {
            Form
            {
                Section( "Name" )
                {
                    TextField( "Title (e.g. Main Home, Storage Unit)", text: $title )
                    TextField( "Description", text: $descriptionText, axis: .vertical )
                        .lineLimit( 2...4 )
                    Toggle( "Has Rooms", isOn: $hasRooms )
                }
                Section( "Address" )
                {
                    TextField( "Street & number", text: $street )
                    HStack
                    {
                        TextField( "Postal code", text: $postalCode )
                            .frame( maxWidth: 120 )
                        TextField( "City", text: $city )
                    }
                    TextField( "Country", text: $country )
                }
            }
            .navigationTitle( isEditing ? "Edit Place" : "New Place" )
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
                        .disabled( title.trimmingCharacters( in: .whitespaces ).isEmpty )
                }
            }
            .onAppear { loadExisting() }
        }
    }

    private func loadExisting()
    {
        guard case .edit( let house ) = mode else { return }
        title = house.title
        descriptionText = house.descriptionText
        hasRooms = house.hasRooms
        street = house.street
        postalCode = house.postalCode
        city = house.city
        country = house.country
    }

    private func save()
    {
        switch mode
        {
        case .create:
            let house = House()
            house.title = title.trimmingCharacters( in: .whitespaces )
            house.descriptionText = descriptionText
            house.hasRooms = hasRooms
            house.street = street
            house.postalCode = postalCode
            house.city = city
            house.country = country
            modelContext.insert( house )
        case .edit( let house ):
            house.title = title.trimmingCharacters( in: .whitespaces )
            house.descriptionText = descriptionText
            house.hasRooms = hasRooms
            house.street = street
            house.postalCode = postalCode
            house.city = city
            house.country = country
            house.modifiedAt = Date()
        }
        dismiss()
    }
}
