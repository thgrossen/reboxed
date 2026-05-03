/*******************************************************************************
 * The MIT License (MIT)
 *
 * Copyright (c) 2026, Thomas Grossen
 ******************************************************************************/

import SwiftUI

struct iPadMacRootView: View
{
    @State private var selectedHouse: House?
    @State private var columnVisibility = NavigationSplitViewVisibility.all

    var body: some View
    {
        NavigationSplitView( columnVisibility: $columnVisibility )
        {
            SidebarView( selectedHouse: $selectedHouse )
        } detail: {
            if let house = selectedHouse
            {
                HouseDetailView( house: house )
            }
            else
            {
                EmptyStateView(
                    icon: "house",
                    title: "No House Selected",
                    message: "Select a house from the sidebar."
                )
            }
        }
    }
}
