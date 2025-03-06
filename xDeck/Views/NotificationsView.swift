//
//  NotificationsView.swift
//  xDeck
//
//  Created by Максим on 3/6/25.
//

import SwiftUI

struct NotificationsView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var notificationManager: NotificationManager
    @EnvironmentObject var packageManager: PackageManager
    
    @State private var notifications: [Notification] = []
    @State private var selectedPackage: Package?
    @State private var showPackageDetails: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
                if notifications.isEmpty {
                    VStack(spacing: 15) {
                        Image(systemName: "bell.slash")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 70, height: 70)
                            .foregroundColor(.gray.opacity(0.5))
                        
                        Text("Нет уведомлений")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        Text("Здесь будут отображаться уведомления о статусе ваших посылок")
                            .font(.subheadline)
                            .foregroundColor(.gray.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(notifications, id: \.self) { notification in
                            NotificationCard(notification: notification) {
                                notificationManager.markAsRead(notification)
                                if let package = notification.package as? Package {
                                    selectedPackage = package
                                    showPackageDetails = true
                                }
                            }
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 5, leading: 15, bottom: 5, trailing: 15))
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Уведомления")
            .toolbar {
                if !notifications.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            markAllAsRead()
                        } label: {
                            Text("Прочитать все")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .onAppear {
                loadNotifications()
            }
            .sheet(isPresented: $showPackageDetails) {
                if let package = selectedPackage {
                    PackageDetailView(package: package)
                        .environmentObject(packageManager)
                }
            }
        }
    }
    
    private func loadNotifications() {
        if let user = authManager.currentUser {
            notifications = notificationManager.getNotifications(for: user)
        }
    }
    
    private func markAllAsRead() {
        if let user = authManager.currentUser {
            notificationManager.markAllAsRead(for: user)
            loadNotifications()
        }
    }
} 