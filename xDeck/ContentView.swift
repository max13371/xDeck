//
//  ContentView.swift
//  xDeck
//
//  Created by Максим on 3/6/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var notificationManager: NotificationManager
    @EnvironmentObject var packageManager: PackageManager
    @EnvironmentObject var routeManager: RouteManager
    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        ZStack {
            if authManager.isAuthenticated {
                HomeView()
            } else {
                LoginView()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        ContentView()
            .environment(\.managedObjectContext, context)
            .environmentObject(AuthManager(context: context))
            .environmentObject(NotificationManager(context: context))
            .environmentObject(PackageManager(context: context))
            .environmentObject(RouteManager(context: context))
    }
}
