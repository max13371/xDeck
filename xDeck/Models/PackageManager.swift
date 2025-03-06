//
//  PackageManager.swift
//  xDeck
//
//  Created by Максим on 3/6/25.
//

import Foundation
import CoreData
import SwiftUI

class PackageManager: ObservableObject {
    @Published var packages: [Package] = []
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func getPackagesByUser(_ user: User) -> [Package] {
        let fetchRequest: NSFetchRequest<Package> = Package.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "user == %@", user)
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Package.creationDate, ascending: false)]
        
        do {
            let packages = try context.fetch(fetchRequest)
            return packages
        } catch {
            print("Ошибка при получении посылок: \(error)")
            return []
        }
    }
    
    func getPackageByTrackingNumber(_ trackingNumber: String) -> Package? {
        let fetchRequest: NSFetchRequest<Package> = Package.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "trackingNumber == %@", trackingNumber)
        
        do {
            let packages = try context.fetch(fetchRequest)
            return packages.first
        } catch {
            print("Ошибка при поиске посылки: \(error)")
            return nil
        }
    }
    
    func createPackage(for user: User, recipientName: String, recipientPhone: String, address: String, latitude: Double, longitude: Double) -> Package? {
        let newPackage = Package(context: context)
        newPackage.id = UUID()
        newPackage.trackingNumber = generateTrackingNumber()
        newPackage.recipientName = recipientName
        newPackage.recipientPhone = recipientPhone
        newPackage.address = address
        newPackage.latitude = latitude
        newPackage.longitude = longitude
        newPackage.status = "Ожидает отправки"
        
        // Конвертируем дату в строку
        let dateFormatter = ISO8601DateFormatter()
        newPackage.creationDate = dateFormatter.string(from: Date())
        
        // Дата доставки остается как есть, это нормальная дата
        newPackage.deliveryDate = Calendar.current.date(byAdding: .day, value: 7, to: Date())
        
        newPackage.user = user
        
        do {
            try context.save()
            return newPackage
        } catch {
            print("Ошибка при создании посылки: \(error)")
            return nil
        }
    }
    
    func updatePackageStatus(_ package: Package, status: String) -> Bool {
        package.status = status
        
        do {
            try context.save()
            return true
        } catch {
            print("Ошибка при обновлении статуса: \(error)")
            return false
        }
    }
    
    func cancelPackage(_ package: Package) -> Bool {
        package.status = "Отменен"
        package.isCancelled = true
        package.cancelDate = Date()
        
        do {
            try context.save()
            return true
        } catch {
            print("Ошибка при отмене посылки: \(error)")
            return false
        }
    }
    
    func deletePackage(_ package: Package) -> Bool {
        // Удаляем связанные уведомления
        if let notifications = package.notifications as? Set<Notification> {
            for notification in notifications {
                context.delete(notification)
            }
        }
        
        // Удаляем сам пакет
        context.delete(package)
        
        do {
            try context.save()
            return true
        } catch {
            print("Ошибка при удалении посылки: \(error)")
            return false
        }
    }
    
    private func generateTrackingNumber() -> String {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let numbers = "0123456789"
        
        let randomLetters = String((0..<2).map { _ in letters.randomElement()! })
        let randomNumbers = String((0..<9).map { _ in numbers.randomElement()! })
        
        return "\(randomLetters)\(randomNumbers)"
    }
} 