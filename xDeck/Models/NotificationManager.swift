//
//  NotificationManager.swift
//  xDeck
//
//  Created by Максим on 3/6/25.
//

import Foundation
import CoreData
import SwiftUI

class NotificationManager: ObservableObject {
    @Published var unreadCount: Int = 0
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func getNotifications(for user: User) -> [Notification] {
        let fetchRequest: NSFetchRequest<Notification> = Notification.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "user == %@", user)
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Notification.date, ascending: false)]
        
        do {
            let notifications = try context.fetch(fetchRequest)
            updateUnreadCount(for: user)
            return notifications
        } catch {
            print("Ошибка при получении уведомлений: \(error)")
            return []
        }
    }
    
    func createNotification(for user: User, package: Package, title: String, message: String) -> Notification? {
        let newNotification = Notification(context: context)
        newNotification.id = UUID()
        newNotification.title = title
        newNotification.message = message
        
        // Преобразуем дату в строку
        let dateFormatter = ISO8601DateFormatter()
        newNotification.date = dateFormatter.string(from: Date())
        
        newNotification.isRead = false
        newNotification.package = package
        newNotification.user = user
        
        do {
            try context.save()
            updateUnreadCount(for: user)
            return newNotification
        } catch {
            print("Ошибка при создании уведомления: \(error)")
            return nil
        }
    }
    
    func markAsRead(_ notification: Notification) {
        notification.isRead = true
        
        do {
            try context.save()
            if let user = notification.user as? User {
                updateUnreadCount(for: user)
            }
        } catch {
            print("Ошибка при отметке уведомления как прочитанного: \(error)")
        }
    }
    
    func markAllAsRead(for user: User) {
        let fetchRequest: NSFetchRequest<Notification> = Notification.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "user == %@ AND isRead == %@", user, NSNumber(value: false))
        
        do {
            let notifications = try context.fetch(fetchRequest)
            for notification in notifications {
                notification.isRead = true
            }
            
            try context.save()
            updateUnreadCount(for: user)
        } catch {
            print("Ошибка при отметке всех уведомлений как прочитанных: \(error)")
        }
    }
    
    func deleteNotification(_ notification: Notification) {
        context.delete(notification)
        
        do {
            try context.save()
            if let user = notification.user as? User {
                updateUnreadCount(for: user)
            }
        } catch {
            print("Ошибка при удалении уведомления: \(error)")
        }
    }
    
    private func updateUnreadCount(for user: User) {
        let fetchRequest: NSFetchRequest<Notification> = Notification.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "user == %@ AND isRead == %@", user, NSNumber(value: false))
        
        do {
            let count = try context.count(for: fetchRequest)
            DispatchQueue.main.async {
                self.unreadCount = count
            }
        } catch {
            print("Ошибка при подсчете непрочитанных уведомлений: \(error)")
        }
    }
} 