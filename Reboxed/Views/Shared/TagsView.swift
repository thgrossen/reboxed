/*******************************************************************************
 * The MIT License (MIT)
 *
 * Copyright (c) 2026, Thomas Grossen
 ******************************************************************************/

import SwiftUI

struct TagsView: View
{
    let tags: [ String ]

    var body: some View
    {
        if tags.isEmpty == false
        {
            ScrollView( .horizontal, showsIndicators: false )
            {
                HStack( spacing: 6 )
                {
                    ForEach( tags, id: \.self ) { tag in
                        Text( tag )
                            .font( .caption )
                            .padding( .horizontal, 8 )
                            .padding( .vertical, 4 )
                            .background( .tint.opacity( 0.15 ), in: Capsule() )
                            .foregroundStyle( .tint )
                    }
                }
                .padding( .vertical, 2 )
            }
        }
    }
}

struct TagEditorView: View
{
    @Binding var tags: [ String ]
    @State private var newTag = ""

    var body: some View
    {
        VStack( alignment: .leading, spacing: 8 )
        {
            TagsView( tags: tags )
            HStack
            {
                TextField( "Add tag…", text: $newTag )
                    #if os(iOS)
                    .textInputAutocapitalization( .never )
                    #endif
                    .onSubmit { addTag() }
                Button( "Add", action: addTag )
                    .disabled( newTag.trimmingCharacters( in: .whitespaces ).isEmpty )
            }
            if tags.isEmpty == false
            {
                ScrollView( .horizontal, showsIndicators: false )
                {
                    HStack
                    {
                        ForEach( tags, id: \.self ) { tag in
                            HStack( spacing: 2 )
                            {
                                Text( tag ).font( .caption )
                                Button
                                {
                                    tags.removeAll { $0 == tag }
                                } label: {
                                    Image( systemName: "xmark.circle.fill" )
                                        .font( .caption )
                                }
                            }
                            .padding( .horizontal, 8 )
                            .padding( .vertical, 4 )
                            .background( .tint.opacity( 0.15 ), in: Capsule() )
                            .foregroundStyle( .tint )
                        }
                    }
                }
            }
        }
    }

    private func addTag()
    {
        let trimmed = newTag.trimmingCharacters( in: .whitespaces )
        guard trimmed.isEmpty == false, tags.contains( trimmed ) == false else { return }
        tags.append( trimmed )
        newTag = ""
    }
}
