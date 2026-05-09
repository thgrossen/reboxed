/*******************************************************************************
 * The MIT License (MIT)
 *
 * Copyright (c) 2026, Thomas Grossen
 ******************************************************************************/

import Foundation
import SwiftData

@Model
final class BoxSizePreset
{
    var title:     String = ""
    var lengthCm:  Double = 0
    var widthCm:   Double = 0
    var heightCm:  Double = 0
    var sortOrder: Int    = 0
    var isSeeded:  Bool   = false
    var createdAt: Date   = Date()

    init( title: String = "", lengthCm: Double, widthCm: Double, heightCm: Double,
          sortOrder: Int = 0, isSeeded: Bool = false )
    {
        self.title     = title
        self.lengthCm  = lengthCm
        self.widthCm   = widthCm
        self.heightCm  = heightCm
        self.sortOrder = sortOrder
        self.isSeeded  = isSeeded
    }

    var displayName: String
    {
        let dims = "\( lengthCm.formatted( .number ) )×\( widthCm.formatted( .number ) )×\( heightCm.formatted( .number ) ) cm"
        return title.isEmpty ? dims : "\( title ) (\( dims ))"
    }
}

extension BoxSizePreset
{
    static let defaults: [ ( title: String, l: Double, w: Double, h: Double ) ] = [
        ( "Small",       30, 20,  20 ),
        ( "Medium",      40, 30,  30 ),
        ( "Large",       60, 40,  40 ),
        ( "Extra Large", 60, 60,  40 ),
        ( "Wardrobe",    50, 50, 100 ),
    ]
}
