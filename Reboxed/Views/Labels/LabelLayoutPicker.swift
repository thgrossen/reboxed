/*******************************************************************************
 * The MIT License (MIT)
 *
 * Copyright (c) 2026, Thomas Grossen
 ******************************************************************************/

import SwiftUI

enum LabelLayout: Int, CaseIterable, Identifiable
{
    case two = 2, four = 4, six = 6, eight = 8, twelve = 12, sixteen = 16

    var id: Int { rawValue }

    var columns: Int
    {
        switch self
        {
        case .two: return 1
        case .four, .six, .eight: return 2
        case .twelve: return 3
        case .sixteen: return 4
        }
    }

    var rows: Int { rawValue / columns }

    var displayName: String { "\( rawValue )/page" }

    static let a4Width: CGFloat = 595
    static let a4Height: CGFloat = 842
    static let margin: CGFloat = 36
    static let gap: CGFloat = 4

    var labelWidth: CGFloat
    {
        ( Self.a4Width - Self.margin * 2 - Self.gap * CGFloat( columns - 1 ) ) / CGFloat( columns )
    }
    var labelHeight: CGFloat
    {
        ( Self.a4Height - Self.margin * 2 - Self.gap * CGFloat( rows - 1 ) ) / CGFloat( rows )
    }
}

struct LabelLayoutPicker: View
{
    @Binding var selection: LabelLayout

    var body: some View
    {
        ScrollView( .horizontal, showsIndicators: false )
        {
            HStack( spacing: 8 )
            {
                ForEach( LabelLayout.allCases ) { layout in
                    Button( layout.displayName )
                    {
                        selection = layout
                    }
                    .buttonStyle( .bordered )
                    .tint( selection == layout ? Color.accentColor : Color.secondary )
                }
            }
            .padding( .horizontal )
        }
    }
}
