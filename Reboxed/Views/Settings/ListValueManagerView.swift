/*******************************************************************************
 * The MIT License (MIT)
 *
 * Copyright (c) 2026, Thomas Grossen
 ******************************************************************************/

import SwiftUI
import SwiftData

struct ListValueManagerView: View
{
    let category: String
    let title: String
    @Environment( \.modelContext ) private var modelContext
    @Query private var allValues: [ ListValue ]
    @State private var showAdd = false
    @State private var newValue = ""

    private var values: [ ListValue ]
    {
        allValues
            .filter { $0.category == category }
            .sorted { $0.sortOrder < $1.sortOrder }
    }

    var body: some View
    {
        List
        {
            ForEach( values ) { item in
                Text( item.value )
            }
            .onDelete { offsets in
                offsets.forEach { modelContext.delete( values[ $0 ] ) }
            }
        }
        .navigationTitle( title )
        #if os(iOS)
        .navigationBarTitleDisplayMode( .inline )
        #endif
        .toolbar
        {
            ToolbarItem( placement: .primaryAction )
            {
                Button { showAdd = true } label: {
                    Image( systemName: "plus" )
                }
            }
            #if os(iOS)
            ToolbarItem( placement: .navigationBarTrailing )
            {
                EditButton()
            }
            #endif
        }
        .alert( "New \( title )", isPresented: $showAdd )
        {
            TextField( "Value", text: $newValue )
            Button( "Add" ) { saveNew() }
            Button( "Cancel", role: .cancel ) { newValue = "" }
        }
    }

    private func saveNew()
    {
        let trimmed = newValue.trimmingCharacters( in: .whitespaces )
        guard trimmed.isEmpty == false else { return }
        let maxOrder = values.map( \.sortOrder ).max() ?? -1
        modelContext.insert( ListValue( category: category, value: trimmed, sortOrder: maxOrder + 1 ) )
        newValue = ""
    }
}
