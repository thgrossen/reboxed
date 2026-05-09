/*******************************************************************************
 * The MIT License (MIT)
 *
 * Copyright (c) 2026, Thomas Grossen
 ******************************************************************************/

import SwiftUI

enum PaperSize: String, CaseIterable
{
    case a4     = "A4"
    case a5     = "A5"
    case letter = "Letter"
    case legal  = "Legal"

    var portraitWidth: CGFloat
    {
        switch self
        {
        case .a4:     return 595
        case .a5:     return 420
        case .letter: return 612
        case .legal:  return 612
        }
    }

    var portraitHeight: CGFloat
    {
        switch self
        {
        case .a4:     return 842
        case .a5:     return 595
        case .letter: return 792
        case .legal:  return 1008
        }
    }
}

struct LabelLayoutConfig
{
    var labelsPerPage: Int
    var paperSize: PaperSize

    var isLandscape: Bool { labelsPerPage == 1 }

    var pageWidth:  CGFloat { isLandscape ? paperSize.portraitHeight : paperSize.portraitWidth }
    var pageHeight: CGFloat { isLandscape ? paperSize.portraitWidth  : paperSize.portraitHeight }

    var columns: Int
    {
        if labelsPerPage <= 3 { return 1 }
        if labelsPerPage <= 8 { return 2 }
        return 3
    }

    var rows: Int { Int( ceil( Double( labelsPerPage ) / Double( columns ) ) ) }

    static let margin: CGFloat = 36
    static let gap:    CGFloat = 4

    var labelWidth: CGFloat
    {
        ( pageWidth - Self.margin * 2 - Self.gap * CGFloat( columns - 1 ) ) / CGFloat( columns )
    }

    var labelHeight: CGFloat
    {
        ( pageHeight - Self.margin * 2 - Self.gap * CGFloat( rows - 1 ) ) / CGFloat( rows )
    }

    var orientationLabel: String
    {
        "\( paperSize.rawValue ) · \( isLandscape ? "Landscape" : "Portrait" )"
    }
}
