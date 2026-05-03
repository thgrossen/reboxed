/*******************************************************************************
 * The MIT License (MIT)
 *
 * Copyright (c) 2026, Thomas Grossen
 ******************************************************************************/

import SwiftUI

struct iPhoneRootView: View
{
    @State private var selectedTab: Tab = .houses

    enum Tab
    {
        case houses, relocation, search, scanner
    }

    var body: some View
    {
        TabView( selection: $selectedTab )
        {
            HouseListView()
                .tabItem { Label( "Houses", systemImage: "house.fill" ) }
                .tag( Tab.houses )

            RelocationDashboardView()
                .tabItem { Label( "Relocation", systemImage: "arrow.triangle.swap" ) }
                .tag( Tab.relocation )

            GlobalSearchView()
                .tabItem { Label( "Search", systemImage: "magnifyingglass" ) }
                .tag( Tab.search )

            ScannerView()
                .tabItem { Label( "Scan", systemImage: "qrcode.viewfinder" ) }
                .tag( Tab.scanner )
        }
    }
}
