/*******************************************************************************
 * The MIT License (MIT)
 *
 * Copyright (c) 2026, Thomas Grossen
 ******************************************************************************/

import SwiftUI

struct iPhoneRootView: View
{
    @State private var selectedTab: Tab = .items

    enum Tab
    {
        case items, boxes, relocation, search, scanner, settings
    }

    var body: some View
    {
        TabView( selection: $selectedTab )
        {
            ItemListView()
                .tabItem { Label( "Items", systemImage: "tag.fill" ) }
                .tag( Tab.items )

            BoxListView()
                .tabItem { Label( "Boxes", systemImage: "shippingbox.fill" ) }
                .tag( Tab.boxes )

            RelocationDashboardView()
                .tabItem { Label( "Relocation", systemImage: "arrow.triangle.swap" ) }
                .tag( Tab.relocation )

            GlobalSearchView()
                .tabItem { Label( "Search", systemImage: "magnifyingglass" ) }
                .tag( Tab.search )

            ScannerView()
                .tabItem { Label( "Scan", systemImage: "qrcode.viewfinder" ) }
                .tag( Tab.scanner )

            SettingsView()
                .tabItem { Label( "Settings", systemImage: "gear" ) }
                .tag( Tab.settings )
        }
    }
}
