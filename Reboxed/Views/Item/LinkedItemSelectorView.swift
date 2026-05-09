/*******************************************************************************
 * The MIT License (MIT)
 *
 * Copyright (c) 2026, Thomas Grossen
 ******************************************************************************/

import SwiftUI
import SwiftData

struct LinkedItemSelectorView: View
{
    var exclude: [ Item ] = []
    var onSelect: ( Item ) -> Void
    @Environment( \.dismiss ) private var dismiss
    @Query( sort: \Item.title ) private var allItems: [ Item ]
    @State private var searchText = ""

    private var candidates: [ Item ]
    {
        let excludedUIDs = Set( exclude.map( \.uid ) )
        let filtered = allItems.filter { excludedUIDs.contains( $0.uid ) == false }
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
                    onSelect( item )
                    dismiss()
                } label: {
                    ItemRowView( item: item )
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
