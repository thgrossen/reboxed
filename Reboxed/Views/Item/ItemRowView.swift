/*******************************************************************************
 * The MIT License (MIT)
 *
 * Copyright (c) 2026, Thomas Grossen
 ******************************************************************************/

import SwiftUI

struct ItemRowView: View
{
    let item: Item

    var body: some View
    {
        HStack
        {
            Image( systemName: "cube.box" )
                .foregroundStyle( .tint )
                .frame( width: 28 )
            VStack( alignment: .leading, spacing: 2 )
            {
                Text( item.title.isEmpty ? "Unnamed Item" : item.title )
                if item.currentLocationName.isEmpty == false
                {
                    Text( item.currentLocationName )
                        .font( .caption )
                        .foregroundStyle( .secondary )
                }
            }
        }
        .padding( .vertical, 2 )
    }
}
