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
    
    @StateObject private var authManager = AuthManager(context: PersistenceController.shared.container.viewContext)
    @StateObject private var packageManager = PackageManager(context: PersistenceController.shared.container.viewContext)
    @StateObject private var notificationManager = NotificationManager(context: PersistenceController.shared.container.viewContext)
    @StateObject private var routeManager = RouteManager(context: PersistenceController.shared.container.viewContext)

    var body: some Scene {
        WindowGroup {
            if authManager.isAuthenticated {
                HomeView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .environmentObject(authManager)
                    .environmentObject(packageManager)
                    .environmentObject(notificationManager)
                    .environmentObject(routeManager)
            } else {
                LoginView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .environmentObject(authManager)
            }
        }
    }
}
