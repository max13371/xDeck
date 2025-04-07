//
//  ResetPasswordView.swift
//  xDeck
//
//  Created by Максим on 3/6/25.
//

import SwiftUI

struct ResetPasswordView: View {
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) private var dismiss
    @Environment(\.presentationMode) var presentationMode
    
    var email: String
    var token: String
    
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    @State private var showAlert: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 25) {
                // Заголовок
                VStack(spacing: 10) {
                    Image(systemName: "lock.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .foregroundColor(.blue)
                    
                    Text("Создание нового пароля")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Придумайте новый надежный пароль")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                }
                .padding(.top, 40)
                
                // Форма ввода нового пароля
                VStack(spacing: 20) {
                    SecureField("Новый пароль", text: $newPassword)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .padding(.horizontal)
                    
                    SecureField("Подтвердите пароль", text: $confirmPassword)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .padding(.horizontal)
                    
                    Button {
                        setNewPassword()
                    } label: {
                        Text("Сохранить новый пароль")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background {
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(Color.blue)
                            }
                            .padding(.horizontal)
                    }
                    .disabled(newPassword.isEmpty || confirmPassword.isEmpty)
                }
                
                Spacer()
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text(alertTitle),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK")) {
                        if case .success = authManager.resetPasswordStatus {
                            dismiss()
                            // Закрываем также экран ForgotPasswordView
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                )
            }
            .navigationBarTitle("Новый пароль", displayMode: .inline)
            .navigationBarItems(leading: Button("Отмена") {
                dismiss()
            })
            .onChange(of: authManager.resetPasswordStatus) { newStatus in
                switch newStatus {
                case .success:
                    alertTitle = "Успешно"
                    alertMessage = "Ваш пароль был успешно изменен. Теперь вы можете войти с новым паролем."
                    showAlert = true
                case .error(let message):
                    alertTitle = "Ошибка"
                    alertMessage = message
                    showAlert = true
                case .idle:
                    break
                }
            }
        }
    }
    
    private func setNewPassword() {
        // Проверка совпадения паролей
        if newPassword != confirmPassword {
            alertTitle = "Ошибка"
            alertMessage = "Пароли не совпадают"
            showAlert = true
            return
        }
        
        // Проверка длины пароля
        if newPassword.count < 6 {
            alertTitle = "Ошибка"
            alertMessage = "Пароль должен содержать не менее 6 символов"
            showAlert = true
            return
        }
        
        // Сброс пароля
        _ = authManager.resetPassword(email: email, token: token, newPassword: newPassword)
    }
} 