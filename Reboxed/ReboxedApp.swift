/*******************************************************************************
 * The MIT License (MIT)
 *
 * Copyright (c) 2026, Thomas Grossen
 ******************************************************************************/

import SwiftUI
import SwiftData

@main
struct ReboxedApp: App
{
    let container: ModelContainer

    init()
    {
        do
        {
            container = try ModelContainerService.makeContainer()
            ModelContainerService.seedDefaultsIfNeeded( context: container.mainContext )
        }
        catch
        {
            fatalError( "Failed to create ModelContainer: \( error )" )
        }
    }

    var body: some Scene
    {
        WindowGroup
        {
            ContentView()
        }
        .modelContainer( container )

        #if os(macOS)
        Settings
        {
            Text( "Settings" )
        }
        #endif
    }
}
