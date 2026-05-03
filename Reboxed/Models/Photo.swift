/*******************************************************************************
 * The MIT License (MIT)
 *
 * Copyright (c) 2026, Thomas Grossen
 ******************************************************************************/

import Foundation
import SwiftData

@Model
final class Photo
{
    var jpegData:   Data    = Data()
    var sortOrder:  Int     = 0
    var createdAt:  Date    = Date()

    var house:      House?
    var room:       Room?
    var storageBox: StorageBox?
    var item:       Item?

    init( jpegData: Data, sortOrder: Int = 0 )
    {
        self.jpegData  = jpegData
        self.sortOrder = sortOrder
    }
}
