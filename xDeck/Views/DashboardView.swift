//
//  DashboardView.swift
//  xDeck
//
//  Created by Максим on 3/6/25.
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var packageManager: PackageManager
    @EnvironmentObject var notificationManager: NotificationManager
    
    @State private var packages: [Package] = []
    @State private var selectedPackage: Package?
    @State private var showPackageDetails: Bool = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Приветствие
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Привет, \(authManager.currentUser?.name ?? "Пользователь")!")
                                .font(.title)
                                .fontWeight(.bold)
                            
                            Text("Добро пожаловать в систему отслеживания посылок")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "shippingbox.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50, height: 50)
                            .foregroundColor(.blue)
                    }
                    .padding(.horizontal)
                    
                    // Статистика
                    HStack(spacing: 15) {
                        StatCard(
                            title: "Активные",
                            value: "\(packages.filter { $0.status != "Доставлен" && $0.status != "Отменен" }.count)",
                            icon: "shippingbox",
                            color: .blue
                        )
                        
                        StatCard(
                            title: "Доставлено",
                            value: "\(packages.filter { $0.status == "Доставлен" }.count)",
                            icon: "checkmark.circle",
                            color: .green
                        )
                        
                        StatCard(
                            title: "Отменено",
                            value: "\(packages.filter { $0.status == "Отменен" }.count)",
                            icon: "xmark.circle",
                            color: .red
                        )
                    }
                    .padding(.horizontal)
                    
                    // Последние посылки
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            Text("Последние посылки")
                                .font(.headline)
                            
                            Spacer()
                            
                            NavigationLink(destination: PackagesView()) {
                                Text("Все")
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                            }
                        }
                        
                        if packages.isEmpty {
                            VStack(spacing: 10) {
                                Image(systemName: "shippingbox.and.arrow.point.up.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 60, height: 60)
                                    .foregroundColor(.gray.opacity(0.5))
                                
                                Text("У вас пока нет посылок")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                
                                Text("Нажмите на кнопку «Создать» внизу экрана, чтобы создать новую посылку")
                                    .font(.subheadline)
                                    .foregroundColor(.gray.opacity(0.8))
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 30)
                        } else {
                            ForEach(packages.prefix(3)) { package in
                                PackageCard(package: package) {
                                    selectedPackage = package
                                    showPackageDetails = true
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Последние уведомления
                    if let user = authManager.currentUser {
                        let notifications = notificationManager.getNotifications(for: user).prefix(2)
                        
                        if !notifications.isEmpty {
                            VStack(alignment: .leading, spacing: 15) {
                                HStack {
                                    Text("Последние уведомления")
                                        .font(.headline)
                                    
                                    Spacer()
                                    
                                    NavigationLink(destination: NotificationsView()) {
                                        Text("Все")
                                            .font(.subheadline)
                                            .foregroundColor(.blue)
                                    }
                                }
                                
                                ForEach(Array(notifications), id: \.self) { notification in
                                    NotificationCard(notification: notification) {
                                        notificationManager.markAsRead(notification)
                                        if let package = notification.package as? Package {
                                            selectedPackage = package
                                            showPackageDetails = true
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationBarHidden(true)
            .onAppear {
                loadPackages()
            }
            .sheet(isPresented: $showPackageDetails) {
                if let package = selectedPackage {
                    PackageDetailView(package: package)
                        .environmentObject(packageManager)
                }
            }
        }
    }
    
    private func loadPackages() {
        if let user = authManager.currentUser {
            packages = packageManager.getPackagesByUser(user)
        }
    }
}

struct StatCard: View {
    var title: String
    var value: String
    var icon: String
    var color: Color
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 15)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
    }
} 