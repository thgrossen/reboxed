/*******************************************************************************
 * The MIT License (MIT)
 *
 * Copyright (c) 2026, Thomas Grossen
 ******************************************************************************/

import SwiftUI
import SwiftData

struct BoxSizePresetFormView: View
{
    @Environment( \.modelContext ) private var modelContext
    @Environment( \.dismiss ) private var dismiss
    @Query( sort: \BoxSizePreset.sortOrder ) private var existing: [ BoxSizePreset ]

    @State private var title     = ""
    @State private var lengthCm  = 0.0
    @State private var widthCm   = 0.0
    @State private var heightCm  = 0.0

    var body: some View
    {
        NavigationStack
        {
            Form
            {
                Section( "Name (optional)" )
                {
                    TextField( "e.g. IKEA KVARNVIK", text: $title )
                }
                Section( "Dimensions" )
                {
                    LabeledContent( "Length (cm)" )
                    {
                        TextField( "0", value: $lengthCm, format: .number )
                            .multilineTextAlignment( .trailing )
                            #if canImport(UIKit)
                            .keyboardType( .decimalPad )
                            #endif
                    }
                    LabeledContent( "Width (cm)" )
                    {
                        TextField( "0", value: $widthCm, format: .number )
                            .multilineTextAlignment( .trailing )
                            #if canImport(UIKit)
                            .keyboardType( .decimalPad )
                            #endif
                    }
                    LabeledContent( "Height (cm)" )
                    {
                        TextField( "0", value: $heightCm, format: .number )
                            .multilineTextAlignment( .trailing )
                            #if canImport(UIKit)
                            .keyboardType( .decimalPad )
                            #endif
                    }
                }
            }
            .navigationTitle( "New Size Preset" )
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
                        .disabled( lengthCm == 0 && widthCm == 0 && heightCm == 0 )
                }
            }
        }
    }

    private func save()
    {
        let preset = BoxSizePreset(
            title: title.trimmingCharacters( in: .whitespaces ),
            lengthCm: lengthCm,
            widthCm: widthCm,
            heightCm: heightCm,
            sortOrder: existing.count
        )
        modelContext.insert( preset )
        dismiss()
    }
}
