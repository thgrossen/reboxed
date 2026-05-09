/*******************************************************************************
 * The MIT License (MIT)
 *
 * Copyright (c) 2026, Thomas Grossen
 ******************************************************************************/

import SwiftUI

struct BoxRowView: View
{
    let box: StorageBox

    var body: some View
    {
        HStack
        {
            Image( systemName: "shippingbox.fill" )
                .foregroundStyle( .tint )
                .frame( width: 28 )
            VStack( alignment: .leading, spacing: 2 )
            {
                HStack( spacing: 4 )
                {
                    if box.boxNumber > 0
                    {
                        Text( "\( box.boxNumber )" )
                            .font( .caption.bold() )
                            .foregroundStyle( .tint )
                    }
                    Text( box.title.isEmpty ? "Unnamed Box" : box.title )
                }
                HStack( spacing: 6 )
                {
                    if box.boxType.isEmpty == false
                    {
                        Text( box.boxType )
                            .font( .caption )
                            .padding( .horizontal, 6 )
                            .padding( .vertical, 2 )
                            .background( .secondary.opacity( 0.15 ), in: Capsule() )
                            .foregroundStyle( .secondary )
                    }
                    let count = box.items?.count ?? 0
                    Text( "\( count ) item\( count == 1 ? "" : "s" )" )
                        .font( .caption )
                        .foregroundStyle( .secondary )
                }
            }
        }
        .padding( .vertical, 2 )
    }
}
