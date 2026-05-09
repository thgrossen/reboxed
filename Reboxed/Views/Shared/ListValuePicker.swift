/*******************************************************************************
 * The MIT License (MIT)
 *
 * Copyright (c) 2026, Thomas Grossen
 ******************************************************************************/

import SwiftUI
import SwiftData

struct ListValuePicker: View
{
    let category: String
    let label: String
    @Binding var selection: String
    @Query private var allValues: [ ListValue ]

    private var values: [ ListValue ]
    {
        allValues
            .filter { $0.category == category }
            .sorted { $0.sortOrder < $1.sortOrder }
    }

    var body: some View
    {
        Picker( label, selection: $selection )
        {
            Text( "None" ).tag( "" )
            ForEach( values ) { item in
                Text( item.value ).tag( item.value )
            }
        }
    }
}
