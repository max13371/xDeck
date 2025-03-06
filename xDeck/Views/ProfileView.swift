//
//  ProfileView.swift
//  xDeck
//
//  Created by Максим on 3/6/25.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authManager: AuthManager
    
    @State private var showLogoutAlert = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    // Аватар и имя
                    VStack(spacing: 15) {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100, height: 100)
                            .foregroundColor(.blue)
                        
                        Text(authManager.currentUser?.name ?? "Пользователь")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text(authManager.currentUser?.email ?? "")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 20)
                    
                    // Информация о пользователе
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Личная информация")
                            .font(.headline)
                        
                        HStack {
                            Image(systemName: "envelope")
                                .foregroundColor(.gray)
                                .frame(width: 30)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Email")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                
                                Text(authManager.currentUser?.email ?? "Не указан")
                                    .font(.body)
                            }
                        }
                        
                        HStack {
                            Image(systemName: "phone")
                                .foregroundColor(.gray)
                                .frame(width: 30)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Телефон")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                
                                Text(authManager.currentUser?.phone ?? "Не указан")
                                    .font(.body)
                            }
                        }
                    }
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color(.systemBackground))
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    }
                    .padding(.horizontal)
                    
                    // Настройки
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Настройки")
                            .font(.headline)
                        
                        Button {
                            // Действие для настроек уведомлений
                        } label: {
                            HStack {
                                Image(systemName: "bell")
                                    .foregroundColor(.gray)
                                    .frame(width: 30)
                                
                                Text("Уведомления")
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                                    .font(.caption)
                            }
                            .padding(.vertical, 8)
                        }
                        
                        Divider()
                        
                        Button {
                            // Действие для настроек приватности
                        } label: {
                            HStack {
                                Image(systemName: "lock")
                                    .foregroundColor(.gray)
                                    .frame(width: 30)
                                
                                Text("Приватность")
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                                    .font(.caption)
                            }
                            .padding(.vertical, 8)
                        }
                        
                        Divider()
                        
                        Button {
                            // Действие для настроек языка
                        } label: {
                            HStack {
                                Image(systemName: "globe")
                                    .foregroundColor(.gray)
                                    .frame(width: 30)
                                
                                Text("Язык")
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Text("Русский")
                                    .foregroundColor(.gray)
                                    .font(.subheadline)
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                                    .font(.caption)
                            }
                            .padding(.vertical, 8)
                        }
                    }
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color(.systemBackground))
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    }
                    .padding(.horizontal)
                    
                    // Кнопка выхода
                    Button {
                        showLogoutAlert = true
                    } label: {
                        HStack {
                            Image(systemName: "arrow.right.square")
                            Text("Выйти из аккаунта")
                        }
                        .fontWeight(.semibold)
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .stroke(Color.red, lineWidth: 1)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    .alert(isPresented: $showLogoutAlert) {
                        Alert(
                            title: Text("Выйти из аккаунта?"),
                            message: Text("Вы уверены, что хотите выйти из аккаунта?"),
                            primaryButton: .destructive(Text("Выйти")) {
                                authManager.logout()
                            },
                            secondaryButton: .cancel(Text("Отмена"))
                        )
                    }
                    
                    // Версия приложения
                    Text("Версия 1.0.0")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.top, 20)
                }
                .padding(.bottom, 30)
            }
            .navigationTitle("Профиль")
        }
    }
} 