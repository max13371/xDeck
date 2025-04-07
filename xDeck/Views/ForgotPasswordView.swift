//
//  ForgotPasswordView.swift
//  xDeck
//
//  Created by Максим on 3/6/25.
//

import SwiftUI

struct ForgotPasswordView: View {
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var email: String = ""
    @State private var showAlert: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    @State private var showResetPassword: Bool = false
    @State private var resetToken: String = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 25) {
                // Заголовок
                VStack(spacing: 10) {
                    Image(systemName: "lock.open.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .foregroundColor(.blue)
                    
                    Text("Восстановление пароля")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Введите email, указанный при регистрации")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                }
                .padding(.top, 40)
                
                // Форма ввода email
                VStack(spacing: 20) {
                    TextField("Email", text: $email)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .keyboardType(.emailAddress)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .padding(.horizontal)
                    
                    Button {
                        resetPassword()
                    } label: {
                        Text("Восстановить пароль")
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
                }
                
                Spacer()
                
                // Кнопка возврата к экрану входа
                Button {
                    dismiss()
                } label: {
                    Text("Вернуться ко входу")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
                .padding(.bottom, 30)
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text(alertTitle),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK")) {
                        if case .success = authManager.resetPasswordStatus {
                            showResetPassword = true
                        }
                    }
                )
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showResetPassword) {
                ResetPasswordView(email: email, token: resetToken)
                    .environmentObject(authManager)
            }
            .onChange(of: authManager.resetPasswordStatus) { newStatus in
                switch newStatus {
                case .success:
                    alertTitle = "Успешно"
                    alertMessage = "Теперь вы можете установить новый пароль."
                    resetToken = UUID().uuidString // Поскольку мы не отправляем код по email, используем временно сгенерированный токен
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
    
    private func resetPassword() {
        if email.isEmpty {
            alertTitle = "Ошибка"
            alertMessage = "Пожалуйста, введите email"
            showAlert = true
            return
        }
        
        _ = authManager.initiatePasswordReset(email: email)
    }
} 