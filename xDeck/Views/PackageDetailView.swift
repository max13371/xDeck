//
//  PackageDetailView.swift
//  xDeck
//
//  Created by Максим on 3/6/25.
//

import SwiftUI
import MapKit

struct PackageDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var packageManager: PackageManager
    @EnvironmentObject var routeManager: RouteManager
    
    var package: Package
    
    @State private var region = MKCoordinateRegion()
    @State private var showCancelAlert = false
    @State private var showDeleteAlert = false
    @State private var showRouteMap = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Заголовок и статус
                VStack(spacing: 10) {
                    HStack {
                        Text("Трек-номер")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        StatusBadge(status: package.status ?? "Неизвестно")
                    }
                    
                    Text(package.trackingNumber ?? "Нет номера")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color(.systemBackground))
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                }
                
                // Информация о получателе
                VStack(alignment: .leading, spacing: 15) {
                    Text("Информация о получателе")
                        .font(.headline)
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Имя")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            Text(package.recipientName ?? "Не указано")
                                .font(.body)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 5) {
                            Text("Телефон")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            Text(package.recipientPhone ?? "Не указан")
                                .font(.body)
                        }
                    }
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Адрес доставки")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Text(package.address ?? "Не указан")
                            .font(.body)
                    }
                }
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color(.systemBackground))
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                }
                
                // Даты
                VStack(alignment: .leading, spacing: 15) {
                    Text("Даты")
                        .font(.headline)
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Дата создания")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            if let dateString = package.creationDate {
                                Text(dateString)
                                    .font(.body)
                            } else {
                                Text("Не указана")
                                    .font(.body)
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 5) {
                            Text("Ожидаемая доставка")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            if let date = package.deliveryDate {
                                Text(date, style: .date)
                                    .font(.body)
                            } else {
                                Text("Не указана")
                                    .font(.body)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    
                    if package.isCancelled, let date = package.cancelDate {
                        Divider()
                        
                        HStack {
                            Image(systemName: "exclamationmark.triangle")
                                .foregroundColor(.red)
                            
                            Text("Заказ отменен")
                                .foregroundColor(.red)
                            
                            Spacer()
                            
                            Text(date, style: .date)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color(.systemBackground))
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                }
                
                // Карта
                VStack(alignment: .leading, spacing: 15) {
                    HStack {
                        Text("Местоположение")
                            .font(.headline)
                        
                        Spacer()
                        
                        Button {
                            prepareAndShowRouteMap()
                        } label: {
                            HStack {
                                Image(systemName: "map")
                                Text("Маршрут")
                            }
                            .font(.subheadline)
                            .foregroundColor(.blue)
                        }
                    }
                    
                    Map(coordinateRegion: $region, annotationItems: [MapLocation(package: package)]) { location in
                        MapMarker(coordinate: location.coordinate, tint: .blue)
                    }
                    .frame(height: 200)
                    .cornerRadius(12)
                }
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color(.systemBackground))
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                }
                
                // Кнопки действий
                VStack(spacing: 12) {
                    // Кнопка отмены заказа
                    if !package.isCancelled && package.status != "Доставлен" {
                        Button {
                            showCancelAlert = true
                        } label: {
                            Text("Отменить заказ")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 15)
                                .background {
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill(Color.orange)
                                }
                        }
                        .alert(isPresented: $showCancelAlert) {
                            Alert(
                                title: Text("Отменить заказ?"),
                                message: Text("Вы уверены, что хотите отменить этот заказ? Это действие нельзя отменить."),
                                primaryButton: .destructive(Text("Отменить заказ")) {
                                    packageManager.cancelPackage(package)
                                    dismiss()
                                },
                                secondaryButton: .cancel(Text("Отмена"))
                            )
                        }
                    }
                    
                    // Кнопка удаления заказа
                    Button {
                        showDeleteAlert = true
                    } label: {
                        Text("Удалить заказ")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background {
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(Color.red)
                            }
                    }
                    .alert(isPresented: $showDeleteAlert) {
                        Alert(
                            title: Text("Удалить заказ?"),
                            message: Text("Вы уверены, что хотите полностью удалить этот заказ? Это действие нельзя отменить, и все данные о заказе будут потеряны."),
                            primaryButton: .destructive(Text("Удалить")) {
                                if packageManager.deletePackage(package) {
                                    dismiss()
                                }
                            },
                            secondaryButton: .cancel(Text("Отмена"))
                        )
                    }
                }
                .padding(.horizontal)
            }
            .padding()
        }
        .navigationTitle("Детали посылки")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            setupRegion()
        }
        .sheet(isPresented: $showRouteMap) {
            RouteMapView()
                .environmentObject(routeManager)
        }
    }
    
    private func setupRegion() {
        let coordinate = CLLocationCoordinate2D(
            latitude: package.latitude,
            longitude: package.longitude
        )
        
        region = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    }
    
    private func prepareAndShowRouteMap() {
        // Проверяем, есть ли уже маршрут для этой посылки
        if routeManager.getRouteForPackage(package) == nil {
            // Если маршрута нет, создаем новый
            routeManager.createRouteForPackage(package)
        }
        
        // Показываем карту маршрута
        showRouteMap = true
    }
}

struct MapLocation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    
    init(package: Package) {
        self.coordinate = CLLocationCoordinate2D(
            latitude: package.latitude,
            longitude: package.longitude
        )
    }
} 