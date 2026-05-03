/*******************************************************************************
 * The MIT License (MIT)
 *
 * Copyright (c) 2026, Thomas Grossen
 ******************************************************************************/

import SwiftUI

struct EmptyStateView: View
{
    let icon: String
    let title: String
    let message: String

    var body: some View
    {
        ContentUnavailableView(
            title,
            systemImage: icon,
            description: Text( message )
        )
    }
}
