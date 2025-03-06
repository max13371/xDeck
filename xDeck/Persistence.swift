//
//  Persistence.swift
//  xDeck
//
//  Created by Максим on 3/6/25.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        // Создаем тестового пользователя
        let testUser = User(context: viewContext)
        testUser.id = UUID()
        testUser.name = "Тестовый Пользователь"
        testUser.email = "test@example.com"
        testUser.password = "password123"
        testUser.phone = "+7 (999) 123-45-67"
        
        // Создаем тестовые посылки
        for i in 0..<5 {
            let newPackage = Package(context: viewContext)
            newPackage.id = UUID()
            newPackage.trackingNumber = generateTrackingNumber()
            
            // Преобразуем даты в строки ISO 8601
            let dateCreation = Date().addingTimeInterval(-Double(i * 86400))
            let dateDelivery = Date().addingTimeInterval(Double((5 - i) * 86400))
            
            let dateFormatter = ISO8601DateFormatter()
            newPackage.creationDate = dateFormatter.string(from: dateCreation)
            
            // Обычные даты остаются как есть
            newPackage.deliveryDate = dateDelivery
            
            newPackage.recipientName = "Получатель \(i+1)"
            newPackage.recipientPhone = "+7 (999) \(100+i)-\(200+i)-\(300+i)"
            newPackage.address = "ул. Примерная, д. \(i+1), кв. \(i*10+1)"
            newPackage.status = ["Создан", "В обработке", "Отправлен", "В пути", "Доставлен"][i % 5]
            newPackage.latitude = 55.751244 + Double(i) * 0.01
            newPackage.longitude = 37.618423 + Double(i) * 0.01
            newPackage.user = testUser
            
            // Создаем уведомление для посылки
            let notification = Notification(context: viewContext)
            notification.id = UUID()
            notification.title = "Обновление статуса"
            notification.message = "Статус вашей посылки \(newPackage.trackingNumber ?? "") изменен на \(newPackage.status ?? "")"
            
            // Дата уведомления как строка
            notification.date = dateFormatter.string(from: Date().addingTimeInterval(-Double(i * 3600)))
            
            notification.isRead = i > 2
            notification.package = newPackage
            notification.user = testUser
        }
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentCloudKitContainer

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "xDeck")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}

// Функция для генерации трек-номера
func generateTrackingNumber() -> String {
    let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    let numbers = "0123456789"
    
    let randomLetters = String((0..<2).map { _ in letters.randomElement()! })
    let randomNumbers = String((0..<9).map { _ in numbers.randomElement()! })
    
    return "\(randomLetters)\(randomNumbers)"
}
