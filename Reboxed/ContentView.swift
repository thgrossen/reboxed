/*******************************************************************************
 * The MIT License (MIT)
 *
 * Copyright (c) 2026, Thomas Grossen
 ******************************************************************************/

import SwiftUI

struct ContentView: View
{
    var body: some View
    {
        #if os(iOS)
        iPhoneRootView()
        #elseif os(macOS)
        iPadMacRootView()
        #endif
    }
}
