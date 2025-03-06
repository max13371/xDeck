//
//  TrackingSearchView.swift
//  xDeck
//
//  Created by Максим on 3/6/25.
//

import SwiftUI

struct TrackingSearchView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var packageManager: PackageManager
    
    @State private var trackingNumber: String = ""
    @State private var isSearching: Bool = false
    @State private var foundPackage: Package?
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 25) {
                // Заголовок
                VStack(spacing: 10) {
                    Image(systemName: "magnifyingglass.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .foregroundColor(.indigo)
                    
                    Text("Отследить посылку")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Введите трек-номер для отслеживания посылки")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .padding(.top, 30)
                
                // Поле ввода трек-номера
                CustomTextField(
                    icon: "number",
                    title: "Трек-номер",
                    hint: "Введите трек-номер посылки",
                    value: $trackingNumber
                )
                .padding(.horizontal, 25)
                
                if showError {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.top, 5)
                }
                
                // Кнопка поиска
                Button {
                    searchPackage()
                } label: {
                    HStack {
                        if isSearching {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .padding(.trailing, 5)
                        } else {
                            Image(systemName: "magnifyingglass")
                                .padding(.trailing, 5)
                        }
                        
                        Text("Отследить")
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(Color.indigo)
                    }
                }
                .padding(.horizontal, 25)
                .disabled(trackingNumber.isEmpty || isSearching)
                .opacity(trackingNumber.isEmpty || isSearching ? 0.6 : 1)
                
                // Результат поиска
                if let package = foundPackage {
                    VStack(spacing: 15) {
                        Text("Посылка найдена")
                            .font(.headline)
                            .foregroundColor(.green)
                        
                        PackageCard(package: package) {
                            dismiss()
                        }
                        .padding(.horizontal, 25)
                    }
                    .padding(.top, 20)
                }
                
                Spacer()
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
    
    private func searchPackage() {
        if trackingNumber.isEmpty {
            showError = true
            errorMessage = "Пожалуйста, введите трек-номер"
            return
        }
        
        isSearching = true
        showError = false
        
        // Имитация задержки сети
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            foundPackage = packageManager.getPackageByTrackingNumber(trackingNumber)
            
            if foundPackage == nil {
                showError = true
                errorMessage = "Посылка с указанным трек-номером не найдена"
            }
            
            isSearching = false
        }
    }
} 