/*******************************************************************************
 * The MIT License (MIT)
 *
 * Copyright (c) 2026, Thomas Grossen
 ******************************************************************************/

import SwiftUI

struct RoomRowView: View
{
    let room: Room

    var body: some View
    {
        HStack
        {
            Image( systemName: "square.split.2x1" )
                .foregroundStyle( .tint )
                .frame( width: 28 )
            VStack( alignment: .leading, spacing: 2 )
            {
                Text( room.title.isEmpty ? "Unnamed Room" : room.title )
                let boxCount = room.boxes?.count ?? 0
                let itemCount = room.directItems?.count ?? 0
                Text( "\( boxCount ) box\( boxCount == 1 ? "" : "es" ) · \( itemCount ) item\( itemCount == 1 ? "" : "s" )" )
                    .font( .caption )
                    .foregroundStyle( .secondary )
            }
        }
        .padding( .vertical, 2 )
    }
}
