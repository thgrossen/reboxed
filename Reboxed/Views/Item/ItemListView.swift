/*******************************************************************************
 * The MIT License (MIT)
 *
 * Copyright (c) 2026, Thomas Grossen
 ******************************************************************************/

import SwiftUI
import SwiftData

struct ItemListView: View
{
    @Environment( \.modelContext ) private var modelContext
    @Query( sort: \Item.title ) private var items: [ Item ]
    @State private var showAddItem        = false
    @State private var searchText         = ""
    @State private var selectedIDs: Set<PersistentIdentifier> = []
    @State private var showLabelPrint     = false
    @State private var showDeleteConfirm  = false
    #if os(iOS)
    @State private var editMode           = EditMode.inactive
    private var isSelecting: Bool { editMode == .active }
    #endif

    private var filteredItems: [ Item ]
    {
        guard searchText.isEmpty == false
        else { return items }
        return items.filter
        {
            $0.title.localizedCaseInsensitiveContains( searchText ) ||
            $0.descriptionText.localizedCaseInsensitiveContains( searchText ) ||
            $0.tags.contains { $0.localizedCaseInsensitiveContains( searchText ) }
        }
    }

    private var selectedItems: [ Item ]
    {
        filteredItems.filter { selectedIDs.contains( $0.id ) }
    }

    var body: some View
    {
        NavigationStack
        {
            Group
            {
                if items.isEmpty
                {
                    EmptyStateView(
                        icon: "tag",
                        title: "No Items",
                        message: "Add items to your boxes, rooms, or places."
                    )
                }
                else
                {
                    List( selection: $selectedIDs )
                    {
                        ForEach( filteredItems ) { item in
                            NavigationLink( value: item )
                            {
                                ItemRowView( item: item )
                            }
                            #if os(iOS)
                            .swipeActions( edge: .leading )
                            {
                                Button
                                {
                                    editMode = .active
                                    selectedIDs.insert( item.id )
                                } label: {
                                    Label( "Select", systemImage: "checkmark.circle" )
                                }
                                .tint( .blue )
                            }
                            #endif
                        }
                        .onDelete( perform: deleteItems )
                    }
                    .searchable( text: $searchText, prompt: "Filter items…" )
                    #if os(iOS)
                    .environment( \.editMode, $editMode )
                    .safeAreaInset( edge: .bottom )
                    {
                        if isSelecting
                        {
                            HStack
                            {
                                Button
                                {
                                    showLabelPrint = true
                                } label: {
                                    Label( "Print Labels", systemImage: "printer" )
                                }
                                .disabled( selectedItems.isEmpty )

                                Spacer()

                                Text( selectedItems.isEmpty ? "" : "\( selectedItems.count ) selected" )
                                    .font( .caption )
                                    .foregroundStyle( .secondary )

                                Spacer()

                                Button( role: .destructive )
                                {
                                    showDeleteConfirm = true
                                } label: {
                                    Label( "Delete", systemImage: "trash" )
                                }
                                .disabled( selectedItems.isEmpty )
                            }
                            .padding( .horizontal, 16 )
                            .padding( .vertical, 12 )
                            .background( .bar )
                        }
                    }
                    #endif
                }
            }
            .navigationTitle( "Items" )
            .navigationDestination( for: Item.self ) { ItemDetailView( item: $0 ) }
            .toolbar
            {
                #if os(iOS)
                ToolbarItem( placement: .primaryAction )
                {
                    if isSelecting == false
                    {
                        Button { showAddItem = true } label: {
                            Image( systemName: "plus" )
                        }
                    }
                    else
                    {
                        Button( "Cancel" )
                        {
                            editMode = .inactive
                            selectedIDs = []
                        }
                    }
                }
                #else
                ToolbarItem( placement: .primaryAction )
                {
                    Button { showAddItem = true } label: {
                        Image( systemName: "plus" )
                    }
                }
                #endif
            }
            .sheet( isPresented: $showAddItem ) { ItemFormView() }
            .sheet( isPresented: $showLabelPrint )
            {
                LabelPrintView(
                    entries: selectedItems.map
                    {
                        ( uid: $0.uid, title: $0.title, number: nil )
                    }
                )
            }
            .confirmationDialog(
                "Delete \( selectedItems.count ) item\( selectedItems.count == 1 ? "" : "s" )?",
                isPresented: $showDeleteConfirm,
                titleVisibility: .visible
            )
            {
                Button( "Delete", role: .destructive )
                {
                    selectedItems.forEach { modelContext.delete( $0 ) }
                    selectedIDs = []
                    #if os(iOS)
                    editMode = .inactive
                    #endif
                }
            }
        }
    }

    private func deleteItems( at offsets: IndexSet )
    {
        offsets.map { filteredItems[ $0 ] }.forEach { modelContext.delete( $0 ) }
    }
}
