//
//  RouteMapView.swift
//  xDeck
//
//  Created by Максим on 3/6/25.
//

import SwiftUI
import MapKit

struct RouteMapView: View {
    @EnvironmentObject var routeManager: RouteManager
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 55.7558, longitude: 37.6173),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    
    @State private var selectedPoint: RoutePoint?
    @State private var showPointDetails = false
    @State private var showAddPointSheet = false
    @State private var isAnimating = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Map(coordinateRegion: $region, annotationItems: routeManager.routePoints) { point in
                MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: point.latitude, longitude: point.longitude)) {
                    RoutePointMarker(point: point, isSelected: selectedPoint == point, isCurrentLocation: point.isCurrentLocation)
                        .onTapGesture {
                            selectedPoint = point
                            showPointDetails = true
                        }
                }
            }
            .overlay(
                Group {
                    if let polyline = routeManager.getRoutePolyline() {
                        PolylineView(polyline: polyline)
                            .stroke(Color.blue, lineWidth: 4)
                    }
                }
            )
            .edgesIgnoringSafeArea(.all)
            
            // Панель с информацией о маршруте
            VStack(spacing: 0) {
                // Заголовок
                HStack {
                    Text("Маршрут доставки")
                        .font(.headline)
                    
                    Spacer()
                    
                    if let route = routeManager.currentRoute {
                        let distance: Double = route.totalDistance
                        Text(String(format: "%.1f км", distance))
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                
                // Список точек маршрута
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(routeManager.routePoints) { point in
                            RoutePointCard(point: point, isCurrentLocation: point.isCurrentLocation)
                                .onTapGesture {
                                    selectedPoint = point
                                    showPointDetails = true
                                    
                                    // Центрируем карту на выбранной точке
                                    withAnimation {
                                        region = MKCoordinateRegion(
                                            center: CLLocationCoordinate2D(latitude: point.latitude, longitude: point.longitude),
                                            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                                        )
                                    }
                                }
                        }
                        
                        // Кнопка добавления новой точки
                        Button {
                            showAddPointSheet = true
                        } label: {
                            VStack(spacing: 10) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(.blue)
                                
                                Text("Добавить точку")
                                    .font(.caption)
                                    .foregroundColor(.primary)
                            }
                            .frame(width: 100, height: 100)
                            .background {
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(Color(.systemBackground))
                                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                }
                .background(Color(.systemBackground))
                
                // Кнопка перемещения к следующей точке
                if let currentLocation = routeManager.currentLocation,
                   let currentRoute = routeManager.currentRoute,
                   let _ = currentRoute.routePoints as? Set<RoutePoint>,
                   let currentIndex = routeManager.routePoints.firstIndex(of: currentLocation),
                   currentIndex < routeManager.routePoints.count - 1 {
                    
                    Button {
                        moveToNextPoint()
                    } label: {
                        Text("Переместить к следующей точке")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background {
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(Color.blue)
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 10)
                    }
                }
            }
            .background {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: -5)
            }
            .sheet(isPresented: $showPointDetails) {
                if let point = selectedPoint {
                    RoutePointDetailView(point: point)
                        .environmentObject(routeManager)
                }
            }
            .sheet(isPresented: $showAddPointSheet) {
                AddRoutePointView()
                    .environmentObject(routeManager)
            }
        }
        .onAppear {
            // Устанавливаем регион карты, охватывающий весь маршрут
            if let mapRegion = routeManager.getMapRegion() {
                region = mapRegion
            }
            
            // Запускаем анимацию маршрута
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeInOut(duration: 1.0)) {
                    isAnimating = true
                }
            }
        }
    }
    
    private func moveToNextPoint() {
        // Анимация перемещения
        withAnimation(.spring()) {
            if routeManager.moveToNextPoint(), let currentLocation = routeManager.currentLocation {
                // Центрируем карту на новой текущей точке
                region = MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: currentLocation.latitude, longitude: currentLocation.longitude),
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )
            }
        }
    }
}

// Маркер точки маршрута на карте
struct RoutePointMarker: View {
    var point: RoutePoint
    var isSelected: Bool
    var isCurrentLocation: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .fill(isCurrentLocation ? Color.blue : Color.gray)
                .frame(width: isSelected ? 24 : 20, height: isSelected ? 24 : 20)
                .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 2)
            
            if isCurrentLocation {
                Circle()
                    .stroke(Color.blue.opacity(0.5), lineWidth: 4)
                    .frame(width: 30, height: 30)
            }
            
            if isSelected {
                Circle()
                    .stroke(Color.blue, lineWidth: 2)
                    .frame(width: 32, height: 32)
            }
        }
        .overlay(
            Text("\(point.order + 1)")
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(.white)
        )
    }
}

// Карточка точки маршрута
struct RoutePointCard: View {
    var point: RoutePoint
    var isCurrentLocation: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Circle()
                    .fill(isCurrentLocation ? Color.blue : Color.gray)
                    .frame(width: 12, height: 12)
                
                Text("\(point.order + 1). \(point.locationName ?? "")")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
            }
            
            Text(point.status ?? "")
                .font(.caption)
                .foregroundColor(statusColor)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background {
                    Capsule()
                        .fill(statusColor.opacity(0.2))
                }
            
            if let dateString = point.arrivalDate ?? point.departureDate {
                Text(dateString)
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .frame(width: 180, height: 100)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(isCurrentLocation ? Color.blue.opacity(0.5) : Color.clear, lineWidth: 2)
        )
    }
    
    private var statusColor: Color {
        switch point.status?.lowercased() {
        case "отправлено":
            return .blue
        case "прибыло":
            return .green
        case "ожидание":
            return .orange
        case "завершено":
            return .gray
        default:
            return .gray
        }
    }
}

// Представление для отображения полилинии маршрута
struct PolylineView: Shape {
    let polyline: MKPolyline
    
    func path(in rect: CGRect) -> Path {
        let points = polyline.points()
        let count = polyline.pointCount
        
        var path = Path()
        
        if count > 0 {
            let firstPoint = points[0]
            let firstCGPoint = CGPoint(
                x: CGFloat(firstPoint.x),
                y: CGFloat(firstPoint.y)
            )
            path.move(to: firstCGPoint)
            
            for i in 1..<count {
                let point = points[i]
                let cgPoint = CGPoint(
                    x: CGFloat(point.x),
                    y: CGFloat(point.y)
                )
                path.addLine(to: cgPoint)
            }
        }
        
        return path
    }
}

// Представление для добавления новой точки маршрута
struct AddRoutePointView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var routeManager: RouteManager
    
    @State private var locationName = ""
    @State private var latitude = ""
    @State private var longitude = ""
    @State private var order: Int16 = 1
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Информация о точке")) {
                    TextField("Название местоположения", text: $locationName)
                    
                    TextField("Широта", text: $latitude)
                        .keyboardType(.decimalPad)
                    
                    TextField("Долгота", text: $longitude)
                        .keyboardType(.decimalPad)
                }
                
                Section(header: Text("Порядок в маршруте")) {
                    Stepper("Позиция: \(order + 1)", value: $order, in: 1...Int16(routeManager.routePoints.count))
                }
                
                Section {
                    Button("Добавить точку") {
                        addRoutePoint()
                    }
                    .disabled(locationName.isEmpty || latitude.isEmpty || longitude.isEmpty)
                }
            }
            .navigationTitle("Новая точка маршрута")
            .navigationBarItems(trailing: Button("Отмена") {
                dismiss()
            })
        }
    }
    
    private func addRoutePoint() {
        guard let lat = Double(latitude), let lon = Double(longitude) else { return }
        
        if routeManager.addRoutePoint(locationName: locationName, latitude: lat, longitude: lon, order: order) != nil {
            dismiss()
        }
    }
}

// Детальное представление точки маршрута
struct RoutePointDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var routeManager: RouteManager
    
    var point: RoutePoint
    
    @State private var showDeleteAlert = false
    @State private var newStatus = ""
    @State private var statusDescription = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Информация о точке")) {
                    HStack {
                        Text("Название")
                        Spacer()
                        Text(point.locationName ?? "")
                            .foregroundColor(.gray)
                    }
                    
                    HStack {
                        Text("Координаты")
                        Spacer()
                        Text("\(String(format: "%.4f", point.latitude)), \(String(format: "%.4f", point.longitude))")
                            .foregroundColor(.gray)
                    }
                    
                    HStack {
                        Text("Порядок")
                        Spacer()
                        Text("\(point.order + 1)")
                            .foregroundColor(.gray)
                    }
                }
                
                Section(header: Text("Статус")) {
                    HStack {
                        Text("Текущий статус")
                        Spacer()
                        Text(point.status ?? "")
                            .foregroundColor(statusColor)
                    }
                    
                    if let description = point.statusDescription, !description.isEmpty {
                        HStack {
                            Text("Описание")
                            Spacer()
                            Text(description)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    if let arrivalDate = point.arrivalDate {
                        HStack {
                            Text("Дата прибытия")
                            Spacer()
                            Text(arrivalDate)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    if let departureDate = point.departureDate {
                        HStack {
                            Text("Дата отправления")
                            Spacer()
                            Text(departureDate)
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                Section(header: Text("Обновить статус")) {
                    Picker("Новый статус", selection: $newStatus) {
                        Text("Выберите статус").tag("")
                        Text("Ожидание").tag("Ожидание")
                        Text("Прибыло").tag("Прибыло")
                        Text("Отправлено").tag("Отправлено")
                        Text("Завершено").tag("Завершено")
                    }
                    
                    TextField("Описание статуса", text: $statusDescription)
                    
                    Button("Обновить статус") {
                        updateStatus()
                    }
                    .disabled(newStatus.isEmpty)
                }
                
                if point.order != 0 && point.order != Int16(routeManager.routePoints.count - 1) {
                    Section {
                        Button("Удалить точку") {
                            showDeleteAlert = true
                        }
                        .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Детали точки маршрута")
            .navigationBarItems(trailing: Button("Готово") {
                dismiss()
            })
            .alert(isPresented: $showDeleteAlert) {
                Alert(
                    title: Text("Удалить точку маршрута?"),
                    message: Text("Вы уверены, что хотите удалить эту точку из маршрута? Это действие нельзя отменить."),
                    primaryButton: .destructive(Text("Удалить")) {
                        if routeManager.removeRoutePoint(point) {
                            dismiss()
                        }
                    },
                    secondaryButton: .cancel(Text("Отмена"))
                )
            }
        }
    }
    
    private func updateStatus() {
        if !newStatus.isEmpty {
            if routeManager.updateRoutePointStatus(point, status: newStatus, description: statusDescription.isEmpty ? nil : statusDescription) {
                dismiss()
            }
        }
    }
    
    private var statusColor: Color {
        switch point.status?.lowercased() {
        case "отправлено":
            return .blue
        case "прибыло":
            return .green
        case "ожидание":
            return .orange
        case "завершено":
            return .gray
        default:
            return .gray
        }
    }
} 