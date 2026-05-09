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

    // 1 and 4 → landscape page; 2 and 8 → portrait page
    var isLandscape: Bool { labelsPerPage == 1 || labelsPerPage == 4 }

    var pageWidth:  CGFloat { isLandscape ? paperSize.portraitHeight : paperSize.portraitWidth }
    var pageHeight: CGFloat { isLandscape ? paperSize.portraitWidth  : paperSize.portraitHeight }

    // 1 → 1×1  2 → 1×2  4 → 2×2  8 → 2×4
    var columns: Int { labelsPerPage <= 2 ? 1 : 2 }
    var rows:    Int { labelsPerPage / max( 1, columns ) }

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
