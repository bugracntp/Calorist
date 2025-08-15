//
//  CaloristApp.swift
//  Calorist
//
//  Created by Bugra Cantepe on 15.08.2025.
//

import SwiftUI

@main
struct CaloristApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
