//
//  xDeckApp.swift
//  xDeck
//
//  Created by Максим on 3/6/25.
//

import SwiftUI

@main
struct xDeckApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
