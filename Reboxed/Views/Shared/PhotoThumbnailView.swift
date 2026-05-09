/*******************************************************************************
 * The MIT License (MIT)
 *
 * Copyright (c) 2026, Thomas Grossen
 ******************************************************************************/

import SwiftUI

struct PhotoThumbnailView: View
{
    let data: Data
    var size: CGFloat = 72

    var body: some View
    {
        #if canImport(UIKit)
        if let image = UIImage( data: data )
        {
            Image( uiImage: image )
                .resizable()
                .scaledToFill()
                .frame( width: size, height: size )
                .clipShape( RoundedRectangle( cornerRadius: 8 ) )
        }
        #elseif canImport(AppKit)
        if let image = NSImage( data: data )
        {
            Image( nsImage: image )
                .resizable()
                .scaledToFill()
                .frame( width: size, height: size )
                .clipShape( RoundedRectangle( cornerRadius: 8 ) )
        }
        #endif
    }
}
