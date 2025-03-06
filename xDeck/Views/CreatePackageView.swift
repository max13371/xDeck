//
//  CreatePackageView.swift
//  xDeck
//
//  Created by Максим on 3/6/25.
//

import SwiftUI
import MapKit

struct CreatePackageView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var packageManager: PackageManager
    
    @State private var recipientName: String = ""
    @State private var recipientPhone: String = ""
    @State private var address: String = ""
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 55.751244, longitude: 37.618423),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Информация о получателе
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Информация о получателе")
                            .font(.headline)
                        
                        CustomTextField(
                            icon: "person",
                            title: "Имя получателя",
                            hint: "Введите имя получателя",
                            value: $recipientName
                        )
                        
                        CustomTextField(
                            icon: "phone",
                            title: "Телефон получателя",
                            hint: "Введите телефон получателя",
                            value: $recipientPhone
                        )
                    }
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color(.systemBackground))
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    }
                    
                    // Адрес доставки
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Адрес доставки")
                            .font(.headline)
                        
                        CustomTextField(
                            icon: "location",
                            title: "Адрес",
                            hint: "Введите адрес доставки",
                            value: $address
                        )
                        
                        Text("Выберите точку на карте")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        Map(coordinateRegion: $region, interactionModes: .all)
                            .frame(height: 200)
                            .cornerRadius(12)
                            .overlay(
                                Image(systemName: "mappin")
                                    .font(.title)
                                    .foregroundColor(.red)
                            )
                    }
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color(.systemBackground))
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    }
                    
                    if showError {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.top, 5)
                    }
                    
                    Button {
                        createPackage()
                    } label: {
                        Text("Создать посылку")
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
                .padding()
            }
            .navigationTitle("Создание посылки")
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
    
    private func createPackage() {
        // Валидация полей
        if recipientName.isEmpty || recipientPhone.isEmpty || address.isEmpty {
            showError = true
            errorMessage = "Пожалуйста, заполните все поля"
            return
        }
        
        // Создание посылки
        if let user = authManager.currentUser {
            if packageManager.createPackage(
                for: user,
                recipientName: recipientName,
                recipientPhone: recipientPhone,
                address: address,
                latitude: region.center.latitude,
                longitude: region.center.longitude
            ) != nil {
                dismiss()
            } else {
                showError = true
                errorMessage = "Ошибка при создании посылки. Пожалуйста, попробуйте еще раз."
            }
        } else {
            showError = true
            errorMessage = "Ошибка авторизации. Пожалуйста, войдите в систему."
        }
    }
}