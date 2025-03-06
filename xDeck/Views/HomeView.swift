//
//  HomeView.swift
//  xDeck
//
//  Created by Максим on 3/6/25.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var packageManager: PackageManager
    @EnvironmentObject var notificationManager: NotificationManager
    
    @State private var selectedTab: Int = 0
    @State private var showCreatePackage: Bool = false
    @State private var showTrackingSearch: Bool = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                DashboardView()
                    .environmentObject(authManager)
                    .environmentObject(packageManager)
                    .environmentObject(notificationManager)
                    .tabItem {
                        Image(systemName: "house")
                        Text("Главная")
                    }
                    .tag(0)
                
                PackagesView()
                    .environmentObject(authManager)
                    .environmentObject(packageManager)
                    .tabItem {
                        Image(systemName: "shippingbox")
                        Text("Посылки")
                    }
                    .tag(1)
                
                NotificationsView()
                    .environmentObject(authManager)
                    .environmentObject(packageManager)
                    .environmentObject(notificationManager)
                    .tabItem {
                        Image(systemName: "bell")
                        Text("Уведомления")
                    }
                    .badge(notificationManager.unreadCount)
                    .tag(2)
                
                ProfileView()
                    .environmentObject(authManager)
                    .tabItem {
                        Image(systemName: "person")
                        Text("Профиль")
                    }
                    .tag(3)
            }
            
            // Кнопки создания и отслеживания
            HStack(spacing: 20) {
                Button {
                    showCreatePackage = true
                } label: {
                    VStack(spacing: 5) {
                        Image(systemName: "plus")
                            .font(.title3)
                            .foregroundColor(.white)
                            .frame(width: 50, height: 50)
                            .background {
                                Circle()
                                    .fill(Color.blue)
                            }
                        
                        Text("Создать")
                            .font(.caption)
                            .foregroundColor(.primary)
                    }
                }
                
                Button {
                    showTrackingSearch = true
                } label: {
                    VStack(spacing: 5) {
                        Image(systemName: "magnifyingglass")
                            .font(.title3)
                            .foregroundColor(.white)
                            .frame(width: 50, height: 50)
                            .background {
                                Circle()
                                    .fill(Color.indigo)
                            }
                        
                        Text("Отследить")
                            .font(.caption)
                            .foregroundColor(.primary)
                    }
                }
            }
            .padding(.bottom, 80)
            .opacity(selectedTab == 0 ? 1 : 0)
            .animation(.easeInOut, value: selectedTab)
        }
        .sheet(isPresented: $showCreatePackage) {
            CreatePackageView()
                .environmentObject(authManager)
                .environmentObject(packageManager)
        }
        .sheet(isPresented: $showTrackingSearch) {
            TrackingSearchView()
                .environmentObject(packageManager)
        }
    }
} 