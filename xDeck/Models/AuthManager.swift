//
//  AuthManager.swift
//  xDeck
//
//  Created by Максим on 3/6/25.
//

import Foundation
import CoreData
import SwiftUI

class AuthManager: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated: Bool = false
    @Published var authError: String?
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
        checkSavedUser()
    }
    
    private func checkSavedUser() {
        // В реальном приложении здесь была бы проверка сохраненного токена
        // и автоматическая авторизация пользователя
    }
    
    func login(email: String, password: String) -> Bool {
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "email == %@ AND password == %@", email, password)
        
        do {
            let users = try context.fetch(fetchRequest)
            if let user = users.first {
                self.currentUser = user
                self.isAuthenticated = true
                self.authError = nil
                
                // Сохраняем ID пользователя для автоматического входа
                UserDefaults.standard.set(user.id?.uuidString, forKey: "currentUserId")
                
                return true
            }
            self.authError = "Неверный email или пароль"
            return false
        } catch {
            self.authError = "Ошибка при входе: \(error.localizedDescription)"
            return false
        }
    }
    
    func register(name: String, email: String, password: String, phone: String? = nil) -> Bool {
        // Проверяем, существует ли пользователь с таким email
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "email == %@", email)
        
        do {
            let users = try context.fetch(fetchRequest)
            if !users.isEmpty {
                self.authError = "Пользователь с таким email уже существует"
                return false
            }
            
            // Создаем нового пользователя
            let newUser = User(context: context)
            newUser.id = UUID()
            newUser.name = name
            newUser.email = email
            newUser.password = password
            newUser.phone = phone
            
            try context.save()
            
            self.currentUser = newUser
            self.isAuthenticated = true
            self.authError = nil
            
            // Сохраняем ID пользователя для автоматического входа
            UserDefaults.standard.set(newUser.id?.uuidString, forKey: "currentUserId")
            
            return true
        } catch {
            self.authError = "Ошибка при регистрации: \(error.localizedDescription)"
            return false
        }
    }
    
    func logout() {
        self.currentUser = nil
        self.isAuthenticated = false
        UserDefaults.standard.removeObject(forKey: "currentUserId")
    }
    
    func updateUserProfile(name: String? = nil, phone: String? = nil) -> Bool {
        guard let user = currentUser else { return false }
        
        if let name = name, !name.isEmpty {
            user.name = name
        }
        
        if let phone = phone {
            user.phone = phone
        }
        
        do {
            try context.save()
            return true
        } catch {
            print("Ошибка при обновлении профиля: \(error)")
            return false
        }
    }
} 