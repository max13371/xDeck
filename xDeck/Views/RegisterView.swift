//
//  RegisterView.swift
//  xDeck
//
//  Created by Максим on 3/6/25.
//

import SwiftUI

struct RegisterView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authManager: AuthManager
    
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var phone: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    // Заголовок
                    VStack(spacing: 10) {
                        Text("Создание аккаунта")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Заполните форму для регистрации")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 20)
                    
                    // Форма регистрации
                    VStack(spacing: 20) {
                        CustomTextField(
                            icon: "person",
                            title: "Имя",
                            hint: "Введите ваше имя",
                            value: $name
                        )
                        
                        CustomTextField(
                            icon: "envelope",
                            title: "Email",
                            hint: "Введите ваш email",
                            value: $email
                        )
                        
                        CustomTextField(
                            icon: "phone",
                            title: "Телефон",
                            hint: "Введите ваш телефон",
                            value: $phone
                        )
                        
                        CustomTextField(
                            icon: "lock",
                            title: "Пароль",
                            hint: "Введите пароль",
                            value: $password,
                            isSecure: true
                        )
                        
                        CustomTextField(
                            icon: "lock.shield",
                            title: "Подтверждение пароля",
                            hint: "Повторите пароль",
                            value: $confirmPassword,
                            isSecure: true
                        )
                        
                        if showError {
                            Text(errorMessage)
                                .font(.caption)
                                .foregroundColor(.red)
                                .padding(.top, 5)
                        }
                        
                        Button {
                            register()
                        } label: {
                            Text("Зарегистрироваться")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 15)
                                .background {
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill(Color.blue)
                                }
                        }
                        .padding(.top, 10)
                    }
                    .padding(.horizontal, 30)
                }
                .padding(.bottom, 30)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.primary)
                    }
                }
            }
        }
    }
    
    private func register() {
        // Валидация полей
        if name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty {
            showError = true
            errorMessage = "Пожалуйста, заполните все обязательные поля"
            return
        }
        
        if password != confirmPassword {
            showError = true
            errorMessage = "Пароли не совпадают"
            return
        }
        
        if !isValidEmail(email) {
            showError = true
            errorMessage = "Пожалуйста, введите корректный email"
            return
        }
        
        // Регистрация
        if authManager.register(name: name, email: email, password: password, phone: phone) {
            dismiss()
        } else {
            showError = true
            errorMessage = "Ошибка при регистрации. Возможно, пользователь с таким email уже существует."
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
} 