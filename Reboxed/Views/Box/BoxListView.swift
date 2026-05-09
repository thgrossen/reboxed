/*******************************************************************************
 * The MIT License (MIT)
 *
 * Copyright (c) 2026, Thomas Grossen
 ******************************************************************************/

import SwiftUI
import SwiftData

struct BoxListView: View
{
    @Environment( \.modelContext ) private var modelContext
    @Query( sort: \StorageBox.boxNumber ) private var boxes: [ StorageBox ]
    @State private var showAddBox         = false
    @State private var searchText         = ""
    @State private var selectedIDs: Set<PersistentIdentifier> = []
    @State private var showLabelPrint     = false
    @State private var showDeleteConfirm  = false
    #if os(iOS)
    @State private var editMode           = EditMode.inactive
    private var isSelecting: Bool { editMode == .active }
    #endif

    private var filteredBoxes: [ StorageBox ]
    {
        guard searchText.isEmpty == false
        else { return boxes }
        return boxes.filter
        {
            $0.title.localizedCaseInsensitiveContains( searchText ) ||
            $0.descriptionText.localizedCaseInsensitiveContains( searchText ) ||
            ( $0.boxNumber > 0 && "\( $0.boxNumber )".hasPrefix( searchText ) )
        }
    }

    private var selectedBoxes: [ StorageBox ]
    {
        filteredBoxes.filter { selectedIDs.contains( $0.id ) }
    }

    var body: some View
    {
        NavigationStack
        {
            Group
            {
                if boxes.isEmpty
                {
                    EmptyStateView(
                        icon: "shippingbox",
                        title: "No Boxes",
                        message: "Add a box to start organising your items."
                    )
                }
                else
                {
                    List( selection: $selectedIDs )
                    {
                        ForEach( filteredBoxes ) { box in
                            NavigationLink( value: box )
                            {
                                BoxRowView( box: box )
                            }
                            #if os(iOS)
                            .swipeActions( edge: .leading )
                            {
                                Button
                                {
                                    editMode = .active
                                    selectedIDs.insert( box.id )
                                } label: {
                                    Label( "Select", systemImage: "checkmark.circle" )
                                }
                                .tint( .blue )
                            }
                            #endif
                        }
                        .onDelete( perform: deleteBoxes )
                    }
                    .searchable( text: $searchText, prompt: "Filter boxes…" )
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
                                .disabled( selectedBoxes.isEmpty )

                                Spacer()

                                Text( selectedBoxes.isEmpty ? "" : "\( selectedBoxes.count ) selected" )
                                    .font( .caption )
                                    .foregroundStyle( .secondary )

                                Spacer()

                                Button( role: .destructive )
                                {
                                    showDeleteConfirm = true
                                } label: {
                                    Label( "Delete", systemImage: "trash" )
                                }
                                .disabled( selectedBoxes.isEmpty )
                            }
                            .padding( .horizontal, 16 )
                            .padding( .vertical, 12 )
                            .background( .bar )
                        }
                    }
                    #endif
                }
            }
            .navigationTitle( "Boxes" )
            .navigationDestination( for: StorageBox.self ) { BoxDetailView( box: $0 ) }
            .navigationDestination( for: Item.self ) { ItemDetailView( item: $0 ) }
            .toolbar
            {
                #if os(iOS)
                ToolbarItem( placement: .primaryAction )
                {
                    if isSelecting == false
                    {
                        Button { showAddBox = true } label: {
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
                    Button { showAddBox = true } label: {
                        Image( systemName: "plus" )
                    }
                }
                #endif
            }
            .sheet( isPresented: $showAddBox ) { BoxFormView() }
            .sheet( isPresented: $showLabelPrint )
            {
                LabelPrintView(
                    entries: selectedBoxes.map
                    {
                        ( uid: $0.uid, title: $0.title, number: $0.boxNumber > 0 ? $0.boxNumber : nil )
                    }
                )
            }
            .confirmationDialog(
                "Delete \( selectedBoxes.count ) box\( selectedBoxes.count == 1 ? "" : "es" )?",
                isPresented: $showDeleteConfirm,
                titleVisibility: .visible
            )
            {
                Button( "Delete", role: .destructive )
                {
                    selectedBoxes.forEach { modelContext.delete( $0 ) }
                    selectedIDs = []
                    #if os(iOS)
                    editMode = .inactive
                    #endif
                }
            }
        }
    }

    private func deleteBoxes( at offsets: IndexSet )
    {
        offsets.map { filteredBoxes[ $0 ] }.forEach { modelContext.delete( $0 ) }
    }
}
