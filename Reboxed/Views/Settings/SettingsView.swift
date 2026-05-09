/*******************************************************************************
 * The MIT License (MIT)
 *
 * Copyright (c) 2026, Thomas Grossen
 ******************************************************************************/

import SwiftUI
import SwiftData

struct SettingsView: View
{
    @Environment( \.modelContext ) private var modelContext
    @State private var showPlaces                    = false
    @State private var showResetInventoryConfirm1    = false
    @State private var showResetInventoryConfirm2    = false
    @State private var showResetAllConfirm1          = false
    @State private var showResetAllConfirm2          = false

    var body: some View
    {
        NavigationStack
        {
            Form
            {
                Section( "Manage" )
                {
                    Button( "Places" ) { showPlaces = true }
                        .foregroundStyle( .primary )

                    NavigationLink( "Box Sizes" )
                    {
                        BoxSizePresetsView()
                    }
                    NavigationLink( "Owners" )
                    {
                        ListValueManagerView( category: ListValue.Category.owner, title: "Owners" )
                    }
                    NavigationLink( "Box Types" )
                    {
                        ListValueManagerView( category: ListValue.Category.boxType, title: "Box Types" )
                    }
                }

                Section
                {
                    Button( "Reset Inventory", role: .destructive )
                    {
                        showResetInventoryConfirm1 = true
                    }
                    Button( "Reset All Data", role: .destructive )
                    {
                        showResetAllConfirm1 = true
                    }
                } header: {
                    Text( "Danger Zone" )
                } footer: {
                    Text( "Reset Inventory deletes all places, rooms, boxes and items but keeps your configured lists (owners, box types, box sizes).\nReset All Data deletes everything." )
                }
            }
            .navigationTitle( "Settings" )
            .sheet( isPresented: $showPlaces )
            {
                HouseListView()
            }
            // Reset Inventory — step 1
            .confirmationDialog(
                "Reset Inventory?",
                isPresented: $showResetInventoryConfirm1,
                titleVisibility: .visible
            )
            {
                Button( "Yes, clear all inventory", role: .destructive )
                {
                    showResetInventoryConfirm2 = true
                }
                Button( "Cancel", role: .cancel ) { }
            } message: {
                Text( "This will permanently delete all places, rooms, boxes, and items. Your lists (owners, box types, box sizes) will be kept." )
            }
            // Reset Inventory — step 2
            .confirmationDialog(
                "Are you absolutely sure?",
                isPresented: $showResetInventoryConfirm2,
                titleVisibility: .visible
            )
            {
                Button( "Delete Inventory", role: .destructive )
                {
                    resetInventory()
                }
                Button( "Cancel", role: .cancel ) { }
            } message: {
                Text( "All places, rooms, boxes, items, and photos will be deleted forever. This cannot be undone." )
            }
            // Reset All — step 1
            .confirmationDialog(
                "Reset All Data?",
                isPresented: $showResetAllConfirm1,
                titleVisibility: .visible
            )
            {
                Button( "Yes, delete everything", role: .destructive )
                {
                    showResetAllConfirm2 = true
                }
                Button( "Cancel", role: .cancel ) { }
            } message: {
                Text( "This will permanently delete all your data including configured lists. This cannot be undone." )
            }
            // Reset All — step 2
            .confirmationDialog(
                "Are you absolutely sure?",
                isPresented: $showResetAllConfirm2,
                titleVisibility: .visible
            )
            {
                Button( "Delete All Data", role: .destructive )
                {
                    resetAllData()
                }
                Button( "Cancel", role: .cancel ) { }
            } message: {
                Text( "All places, rooms, boxes, items, photos, owners, box types, and box sizes will be deleted forever." )
            }
        }
    }

    private func resetInventory()
    {
        ( try? modelContext.fetch( FetchDescriptor<Item>() ) )?.forEach       { modelContext.delete( $0 ) }
        ( try? modelContext.fetch( FetchDescriptor<ItemLink>() ) )?.forEach   { modelContext.delete( $0 ) }
        ( try? modelContext.fetch( FetchDescriptor<Photo>() ) )?.forEach      { modelContext.delete( $0 ) }
        ( try? modelContext.fetch( FetchDescriptor<StorageBox>() ) )?.forEach { modelContext.delete( $0 ) }
        ( try? modelContext.fetch( FetchDescriptor<Room>() ) )?.forEach       { modelContext.delete( $0 ) }
        ( try? modelContext.fetch( FetchDescriptor<House>() ) )?.forEach      { modelContext.delete( $0 ) }
        try? modelContext.save()
    }

    private func resetAllData()
    {
        resetInventory()
        ( try? modelContext.fetch( FetchDescriptor<ListValue>() ) )?.forEach     { modelContext.delete( $0 ) }
        ( try? modelContext.fetch( FetchDescriptor<BoxSizePreset>() ) )?.forEach { modelContext.delete( $0 ) }
        try? modelContext.save()
    }
}
