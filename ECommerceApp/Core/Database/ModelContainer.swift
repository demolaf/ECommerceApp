//
//  ModelContainer.swift
//  ECommerceApp
//
//  Created by Ademola Fadumo on 21/06/2025.
//

import CoreData
import Foundation

actor ModelContainer {
    init(forInAppPreview: Bool = false) {
        persistentContainer = NSPersistentContainer(name: "ECommerceApp")

        debugPrint(persistentContainer.persistentStoreDescriptions.first!.url!.absoluteString)

        if forInAppPreview {
            // Here is how you set the container’s location to a temporary location where you can insert,
            // change and delete values and none of it will persist. This means every time you run the app
            // with forPreview set to true, the data will disappear and not persist.
            persistentContainer.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }

        persistentContainer.loadPersistentStores { _, _ in }

        // if forInAppPreview {
        //     // If forPreview is true then we want to load up some mock data. Do this AFTER you call loadPersistentStores.
        //     ModelContainer.addMockData(moc: persistentContainer.viewContext)
        // }
    }

    static let shared = ModelContainer()

    let persistentContainer: NSPersistentContainer
}
