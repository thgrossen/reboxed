/*******************************************************************************
 * The MIT License (MIT)
 *
 * Copyright (c) 2026, Thomas Grossen
 ******************************************************************************/

import SwiftUI
import SwiftData

struct ItemLinksView: View
{
    @Bindable var item: Item
    @Environment( \.modelContext ) private var modelContext
    @Environment( \.dismiss ) private var dismiss
    @State private var showPicker = false

    var body: some View
    {
        NavigationStack
        {
            List
            {
                if item.linkedItems.isEmpty
                {
                    ContentUnavailableView(
                        "No Links",
                        systemImage: "link",
                        description: Text( "Link this item to others — e.g. a chair to its screws box." )
                    )
                }
                else
                {
                    ForEach( item.linkedItems ) { linked in
                        HStack
                        {
                            VStack( alignment: .leading )
                            {
                                Text( linked.title )
                                Text( linked.uid )
                                    .font( .caption )
                                    .foregroundStyle( .secondary )
                            }
                            Spacer()
                            Button( role: .destructive )
                            {
                                removeLink( to: linked )
                            } label: {
                                Image( systemName: "minus.circle.fill" )
                                    .foregroundStyle( .red )
                            }
                            .buttonStyle( .borderless )
                        }
                    }
                }
            }
            .navigationTitle( "Linked Items" )
            #if os(iOS)
            .navigationBarTitleDisplayMode( .inline )
            #endif
            .toolbar
            {
                ToolbarItem( placement: .primaryAction )
                {
                    Button { showPicker = true } label: {
                        Image( systemName: "plus" )
                    }
                }
                ToolbarItem( placement: .cancellationAction )
                {
                    Button( "Done" ) { dismiss() }
                }
            }
            .sheet( isPresented: $showPicker )
            {
                ItemLinkPickerView( sourceItem: item )
            }
        }
    }

    private func removeLink( to target: Item )
    {
        if let link = item.outgoingLinks?.first( where: { $0.targetItem == target } )
        {
            modelContext.delete( link )
        }
        else if let link = item.incomingLinks?.first( where: { $0.sourceItem == target } )
        {
            modelContext.delete( link )
        }
    }
}

struct ItemLinkPickerView: View
{
    let sourceItem: Item
    @Environment( \.modelContext ) private var modelContext
    @Environment( \.dismiss ) private var dismiss
    @Query( sort: \Item.title ) private var allItems: [ Item ]
    @State private var searchText = ""

    private var candidates: [ Item ]
    {
        let linked = Set( sourceItem.linkedItems.map( \.uid ) )
        let filtered = allItems.filter { $0.uid != sourceItem.uid && linked.contains( $0.uid ) == false }
        if searchText.isEmpty { return filtered }
        return filtered.filter
        {
            $0.title.localizedCaseInsensitiveContains( searchText ) ||
            $0.uid.localizedCaseInsensitiveContains( searchText )
        }
    }

    var body: some View
    {
        NavigationStack
        {
            List( candidates ) { item in
                Button
                {
                    let link = ItemLink( source: sourceItem, target: item )
                    modelContext.insert( link )
                    dismiss()
                } label: {
                    VStack( alignment: .leading )
                    {
                        Text( item.title )
                        Text( item.uid )
                            .font( .caption )
                            .foregroundStyle( .secondary )
                    }
                }
                .foregroundStyle( .primary )
            }
            .searchable( text: $searchText )
            .navigationTitle( "Link to Item" )
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
