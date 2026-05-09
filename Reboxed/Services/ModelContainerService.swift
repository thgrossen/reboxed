/*******************************************************************************
 * The MIT License (MIT)
 *
 * Copyright (c) 2026, Thomas Grossen
 ******************************************************************************/

import SwiftData
import Foundation

@MainActor
enum ModelContainerService
{
    private static let cloudKitContainer = "iCloud.me.grossen.Reboxed"

    static func makeContainer() throws -> ModelContainer
    {
        let schema = Schema( [
            House.self,
            Room.self,
            StorageBox.self,
            Item.self,
            ItemLink.self,
            Photo.self,
            ListValue.self,
            BoxSizePreset.self
        ] )
        #if DEBUG
        let config = ModelConfiguration( schema: schema )
        #else
        let config = ModelConfiguration(
            schema: schema,
            cloudKitDatabase: .private( cloudKitContainer )
        )
        #endif
        return try ModelContainer( for: schema, configurations: [ config ] )
    }

    static func makeInMemoryContainer() throws -> ModelContainer
    {
        let schema = Schema( [
            House.self,
            Room.self,
            StorageBox.self,
            Item.self,
            ItemLink.self,
            Photo.self,
            ListValue.self,
            BoxSizePreset.self
        ] )
        let config = ModelConfiguration( schema: schema, isStoredInMemoryOnly: true )
        return try ModelContainer( for: schema, configurations: [ config ] )
    }

    static func seedDefaultsIfNeeded( context: ModelContext )
    {
        let boxTypeDescriptor = FetchDescriptor<ListValue>(
            predicate: #Predicate { $0.category == "boxType" }
        )
        let existingBoxTypes = ( try? context.fetch( boxTypeDescriptor ) ) ?? []
        if existingBoxTypes.isEmpty
        {
            for entry in ListValue.defaultBoxTypes
            {
                context.insert( ListValue(
                    category: ListValue.Category.boxType,
                    value: entry.value,
                    sortOrder: entry.order,
                    isSeeded: true
                ) )
            }
        }

        let sizeDescriptor = FetchDescriptor<BoxSizePreset>(
            predicate: #Predicate { $0.isSeeded == true }
        )
        let existingSizes = ( try? context.fetch( sizeDescriptor ) ) ?? []
        if existingSizes.isEmpty
        {
            for ( index, entry ) in BoxSizePreset.defaults.enumerated()
            {
                context.insert( BoxSizePreset(
                    title: entry.title,
                    lengthCm: entry.l,
                    widthCm: entry.w,
                    heightCm: entry.h,
                    sortOrder: index,
                    isSeeded: true
                ) )
            }
        }

        try? context.save()
    }
}
