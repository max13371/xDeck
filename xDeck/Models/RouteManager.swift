//
//  RouteManager.swift
//  xDeck
//
//  Created by Максим on 3/6/25.
//

import Foundation
import CoreData
import SwiftUI
import MapKit

class RouteManager: ObservableObject {
    @Published var currentRoute: Route?
    @Published var routePoints: [RoutePoint] = []
    @Published var currentLocation: RoutePoint?
    
    private let context: NSManagedObjectContext
    private let dateFormatter = ISO8601DateFormatter()
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    // Получение маршрута для посылки
    func getRouteForPackage(_ package: Package) -> Route? {
        if let existingRoute = package.route as? Route {
            self.currentRoute = existingRoute
            loadRoutePoints(for: existingRoute)
            return existingRoute
        }
        return nil
    }
    
    // Создание нового маршрута для посылки
    func createRouteForPackage(_ package: Package) -> Route? {
        // Проверяем, существует ли уже маршрут
        if let existingRoute = package.route as? Route {
            return existingRoute
        }
        
        let newRoute = Route(context: context)
        newRoute.id = UUID()
        newRoute.lastUpdated = dateFormatter.string(from: Date())
        newRoute.package = package
        
        // Создаем начальную и конечную точки маршрута
        createInitialRoutePoints(for: newRoute, package: package)
        
        do {
            try context.save()
            self.currentRoute = newRoute
            loadRoutePoints(for: newRoute)
            return newRoute
        } catch {
            print("Ошибка при создании маршрута: \(error)")
            return nil
        }
    }
    
    // Создание начальных точек маршрута
    private func createInitialRoutePoints(for route: Route, package: Package) {
        // Точка отправления (склад)
        let startPoint = RoutePoint(context: context)
        startPoint.id = UUID()
        startPoint.order = 0
        startPoint.locationName = "Склад отправления"
        startPoint.latitude = 55.7558 // Примерные координаты Москвы
        startPoint.longitude = 37.6173
        startPoint.status = "Отправлено"
        startPoint.departureDate = dateFormatter.string(from: Date())
        startPoint.isCurrentLocation = true
        startPoint.route = route
        
        // Промежуточная точка (сортировочный центр)
        let middlePoint = RoutePoint(context: context)
        middlePoint.id = UUID()
        middlePoint.order = 1
        middlePoint.locationName = "Сортировочный центр"
        middlePoint.latitude = 55.8304 // Примерные координаты к северу от Москвы
        middlePoint.longitude = 37.4963
        middlePoint.status = "Ожидание"
        middlePoint.isCurrentLocation = false
        middlePoint.route = route
        
        // Точка назначения (адрес получателя)
        let endPoint = RoutePoint(context: context)
        endPoint.id = UUID()
        endPoint.order = 2
        endPoint.locationName = package.address ?? "Адрес получателя"
        endPoint.latitude = package.latitude
        endPoint.longitude = package.longitude
        endPoint.status = "Ожидание"
        endPoint.isCurrentLocation = false
        endPoint.route = route
        
        // Рассчитываем общее расстояние маршрута
        calculateTotalDistance(for: route)
    }
    
    // Загрузка точек маршрута
    private func loadRoutePoints(for route: Route) {
        guard let points = route.routePoints as? Set<RoutePoint> else {
            routePoints = []
            currentLocation = nil
            return
        }
        
        // Сортируем точки по порядку
        routePoints = Array(points).sorted { $0.order < $1.order }
        
        // Находим текущее местоположение
        currentLocation = routePoints.first { $0.isCurrentLocation }
    }
    
    // Обновление статуса точки маршрута
    func updateRoutePointStatus(_ point: RoutePoint, status: String, description: String? = nil) -> Bool {
        point.status = status
        point.statusDescription = description
        
        if status == "Прибыло" {
            point.arrivalDate = dateFormatter.string(from: Date())
        } else if status == "Отправлено" {
            point.departureDate = dateFormatter.string(from: Date())
        }
        
        do {
            try context.save()
            return true
        } catch {
            print("Ошибка при обновлении статуса точки маршрута: \(error)")
            return false
        }
    }
    
    // Перемещение посылки к следующей точке маршрута
    func moveToNextPoint() -> Bool {
        guard let route = currentRoute,
              let currentPoint = currentLocation,
              let points = route.routePoints as? Set<RoutePoint> else {
            return false
        }
        
        // Сортируем точки по порядку
        let sortedPoints = Array(points).sorted { $0.order < $1.order }
        
        // Находим индекс текущей точки
        guard let currentIndex = sortedPoints.firstIndex(of: currentPoint),
              currentIndex < sortedPoints.count - 1 else {
            return false
        }
        
        // Обновляем статус текущей точки
        currentPoint.isCurrentLocation = false
        updateRoutePointStatus(currentPoint, status: "Завершено")
        
        // Перемещаемся к следующей точке
        let nextPoint = sortedPoints[currentIndex + 1]
        nextPoint.isCurrentLocation = true
        updateRoutePointStatus(nextPoint, status: "Прибыло")
        
        // Обновляем текущее местоположение
        currentLocation = nextPoint
        
        // Обновляем дату последнего обновления маршрута
        route.lastUpdated = dateFormatter.string(from: Date())
        
        // Если достигли конечной точки, обновляем статус посылки
        if currentIndex + 1 == sortedPoints.count - 1 {
            if let package = route.package as? Package {
                let packageManager = PackageManager(context: context)
                packageManager.updatePackageStatus(package, status: "Доставлен")
            }
        }
        
        do {
            try context.save()
            return true
        } catch {
            print("Ошибка при перемещении к следующей точке: \(error)")
            return false
        }
    }
    
    // Добавление новой точки маршрута
    func addRoutePoint(locationName: String, latitude: Double, longitude: Double, order: Int16) -> RoutePoint? {
        guard let route = currentRoute else { return nil }
        
        // Создаем новую точку
        let newPoint = RoutePoint(context: context)
        newPoint.id = UUID()
        newPoint.locationName = locationName
        newPoint.latitude = latitude
        newPoint.longitude = longitude
        newPoint.order = order
        newPoint.status = "Ожидание"
        newPoint.isCurrentLocation = false
        newPoint.route = route
        
        // Обновляем порядок существующих точек
        if let points = route.routePoints as? Set<RoutePoint> {
            for point in points where point.order >= order {
                point.order += 1
            }
        }
        
        // Пересчитываем общее расстояние
        calculateTotalDistance(for: route)
        
        do {
            try context.save()
            loadRoutePoints(for: route)
            return newPoint
        } catch {
            print("Ошибка при добавлении точки маршрута: \(error)")
            return nil
        }
    }
    
    // Удаление точки маршрута
    func removeRoutePoint(_ point: RoutePoint) -> Bool {
        guard let route = point.route as? Route,
              let points = route.routePoints as? Set<RoutePoint> else { return false }
        
        // Нельзя удалить начальную или конечную точку
        let sortedPoints = Array(points).sorted { $0.order < $1.order }
        if point.order == 0 || point.order == sortedPoints.count - 1 {
            return false
        }
        
        // Обновляем порядок оставшихся точек
        for p in points where p.order > point.order {
            p.order -= 1
        }
        
        // Удаляем точку
        context.delete(point)
        
        // Пересчитываем общее расстояние
        calculateTotalDistance(for: route)
        
        do {
            try context.save()
            loadRoutePoints(for: route)
            return true
        } catch {
            print("Ошибка при удалении точки маршрута: \(error)")
            return false
        }
    }
    
    // Расчет общего расстояния маршрута
    private func calculateTotalDistance(for route: Route) {
        guard let points = route.routePoints as? Set<RoutePoint>, points.count > 1 else {
            route.totalDistance = 0
            return
        }
        
        // Сортируем точки по порядку
        let sortedPoints = Array(points).sorted { $0.order < $1.order }
        var totalDistance: Double = 0
        
        for i in 0..<sortedPoints.count - 1 {
            let startLocation = CLLocation(latitude: sortedPoints[i].latitude, longitude: sortedPoints[i].longitude)
            let endLocation = CLLocation(latitude: sortedPoints[i + 1].latitude, longitude: sortedPoints[i + 1].longitude)
            
            totalDistance += startLocation.distance(from: endLocation) / 1000 // в километрах
        }
        
        route.totalDistance = totalDistance
    }
    
    // Получение полилинии для отображения маршрута на карте
    func getRoutePolyline() -> MKPolyline? {
        guard !routePoints.isEmpty else { return nil }
        
        let coordinates = routePoints.map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }
        return MKPolyline(coordinates: coordinates, count: coordinates.count)
    }
    
    // Получение региона карты, охватывающего весь маршрут
    func getMapRegion() -> MKCoordinateRegion? {
        guard !routePoints.isEmpty else { return nil }
        
        var minLat = routePoints[0].latitude
        var maxLat = routePoints[0].latitude
        var minLon = routePoints[0].longitude
        var maxLon = routePoints[0].longitude
        
        for point in routePoints {
            minLat = min(minLat, point.latitude)
            maxLat = max(maxLat, point.latitude)
            minLon = min(minLon, point.longitude)
            maxLon = max(maxLon, point.longitude)
        }
        
        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )
        
        let span = MKCoordinateSpan(
            latitudeDelta: (maxLat - minLat) * 1.5,
            longitudeDelta: (maxLon - minLon) * 1.5
        )
        
        return MKCoordinateRegion(center: center, span: span)
    }
} 