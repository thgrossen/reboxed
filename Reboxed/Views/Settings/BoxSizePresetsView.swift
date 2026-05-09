/*******************************************************************************
 * The MIT License (MIT)
 *
 * Copyright (c) 2026, Thomas Grossen
 ******************************************************************************/

import SwiftUI
import SwiftData

struct BoxSizePresetsView: View
{
    @Environment( \.modelContext ) private var modelContext
    @Query( sort: \BoxSizePreset.sortOrder ) private var presets: [ BoxSizePreset ]
    @State private var showAdd = false

    var body: some View
    {
        List
        {
            ForEach( presets ) { preset in
                VStack( alignment: .leading, spacing: 2 )
                {
                    if preset.title.isEmpty == false
                    {
                        Text( preset.title )
                            .fontWeight( .medium )
                    }
                    Text( "\( preset.lengthCm.formatted( .number ) ) × \( preset.widthCm.formatted( .number ) ) × \( preset.heightCm.formatted( .number ) ) cm" )
                        .font( .caption )
                        .foregroundStyle( .secondary )
                }
            }
            .onDelete { offsets in
                offsets.forEach { modelContext.delete( presets[ $0 ] ) }
            }
        }
        .navigationTitle( "Box Sizes" )
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
        .sheet( isPresented: $showAdd )
        {
            BoxSizePresetFormView()
        }
    }
}
