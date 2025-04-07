//
//  LoginView.swift
//  xDeck
//
//  Created by Максим on 3/6/25.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authManager: AuthManager
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showRegister: Bool = false
    @State private var showForgotPassword: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Логотип и заголовок
                VStack(spacing: 15) {
                    Image(systemName: "shippingbox.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .foregroundColor(.blue)
                    
                    Text("xDeck")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Система отслеживания посылок")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.top, 50)
                
                // Форма входа
                VStack(spacing: 20) {
                    CustomTextField(
                        icon: "envelope",
                        title: "Email",
                        hint: "Введите ваш email",
                        value: $email
                    )
                    
                    CustomTextField(
                        icon: "lock",
                        title: "Пароль",
                        hint: "Введите ваш пароль",
                        value: $password,
                        isSecure: true
                    )
                    
                    if showError {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.top, 5)
                    }
                    
                    // Ссылка на восстановление пароля
                    HStack {
                        Spacer()
                        Button {
                            showForgotPassword = true
                        } label: {
                            Text("Забыли пароль?")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.top, 5)
                    
                    Button {
                        login()
                    } label: {
                        Text("Войти")
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
                    
                    Button {
                        showRegister = true
                    } label: {
                        Text("Нет аккаунта? Зарегистрироваться")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                    .padding(.top, 5)
                }
                .padding(.horizontal, 30)
                
                Spacer()
                
                // Демо-режим
                VStack {
                    Text("Для демонстрации")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Button {
                        createDemoAccount()
                    } label: {
                        Text("Создать демо-аккаунт")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.bottom, 30)
            }
            .sheet(isPresented: $showRegister) {
                RegisterView()
                    .environmentObject(authManager)
            }
            .sheet(isPresented: $showForgotPassword) {
                ForgotPasswordView()
                    .environmentObject(authManager)
            }
        }
    }
    
    private func login() {
        if email.isEmpty || password.isEmpty {
            showError = true
            errorMessage = "Пожалуйста, заполните все поля"
            return
        }
        
        if !authManager.login(email: email, password: password) {
            showError = true
            errorMessage = "Неверный email или пароль"
        }
    }
    
    private func createDemoAccount() {
        let demoEmail = "demo@example.com"
        let demoPassword = "password"
        
        // Проверяем, существует ли уже демо-аккаунт
        if authManager.login(email: demoEmail, password: demoPassword) {
            return
        }
        
        // Создаем новый демо-аккаунт
        if authManager.register(name: "Демо Пользователь", email: demoEmail, password: demoPassword) {
            // Аккаунт создан и пользователь автоматически авторизован
        } else {
            showError = true
            errorMessage = "Ошибка при создании демо-аккаунта"
        }
    }
} 