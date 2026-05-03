/*******************************************************************************
 * The MIT License (MIT)
 *
 * Copyright (c) 2026, Thomas Grossen
 ******************************************************************************/

import Foundation
import SwiftData

@Model
final class ListValue
{
    var category:   String  = ""
    var value:      String  = ""
    var sortOrder:  Int     = 0
    var isSeeded:   Bool    = false
    var createdAt:  Date    = Date()

    init( category: String, value: String, sortOrder: Int = 0, isSeeded: Bool = false )
    {
        self.category  = category
        self.value     = value
        self.sortOrder = sortOrder
        self.isSeeded  = isSeeded
    }
}

extension ListValue
{
    enum Category
    {
        static let boxType  = "boxType"
        static let owner    = "owner"
    }

    static let defaultBoxTypes: [ ( value: String, order: Int ) ] = [
        ( "Carton", 0 ),
        ( "Rako",   1 ),
        ( "Bois",   2 ),
        ( "Autre",  3 ),
    ]
}
