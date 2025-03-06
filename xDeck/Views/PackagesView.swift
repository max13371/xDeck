//
//  PackagesView.swift
//  xDeck
//
//  Created by Максим on 3/6/25.
//

import SwiftUI

struct PackagesView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var packageManager: PackageManager
    
    @State private var packages: [Package] = []
    @State private var filteredPackages: [Package] = []
    @State private var selectedPackage: Package?
    @State private var showPackageDetails: Bool = false
    
    @State private var searchText: String = ""
    @State private var showFilterSheet: Bool = false
    @State private var selectedFilter: PackageFilter = .all
    @State private var selectedSortOption: SortOption = .dateDesc
    @State private var startDate: Date = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
    @State private var endDate: Date = Date()
    
    // Для преобразования дат в строки и обратно
    private let dateFormatter = ISO8601DateFormatter()
    
    enum PackageFilter: String, CaseIterable, Identifiable {
        case all = "Все"
        case active = "Активные"
        case delivered = "Доставленные"
        case cancelled = "Отмененные"
        case dateRange = "По датам"
        
        var id: String { self.rawValue }
    }
    
    enum SortOption: String, CaseIterable, Identifiable {
        case dateDesc = "Сначала новые"
        case dateAsc = "Сначала старые"
        
        var id: String { self.rawValue }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Поисковая строка
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Поиск по трек-номеру", text: $searchText)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    if !searchText.isEmpty {
                        Button {
                            searchText = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 15)
                .background {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color.gray.opacity(0.1))
                }
                .padding(.horizontal)
                
                // Фильтры и сортировка
                HStack {
                    Button {
                        showFilterSheet = true
                    } label: {
                        HStack {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                            Text(selectedFilter.rawValue)
                        }
                        .font(.subheadline)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background {
                            Capsule()
                                .fill(Color.blue.opacity(0.1))
                        }
                        .foregroundColor(.blue)
                    }
                    
                    Spacer()
                    
                    Menu {
                        ForEach(SortOption.allCases) { option in
                            Button {
                                selectedSortOption = option
                                applyFiltersAndSort()
                            } label: {
                                HStack {
                                    Text(option.rawValue)
                                    if selectedSortOption == option {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack {
                            Image(systemName: "arrow.up.arrow.down")
                            Text("Сортировка")
                        }
                        .font(.subheadline)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background {
                            Capsule()
                                .fill(Color.gray.opacity(0.1))
                        }
                        .foregroundColor(.primary)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 5)
                
                // Список посылок
                if filteredPackages.isEmpty {
                    VStack(spacing: 15) {
                        Image(systemName: "shippingbox.and.arrow.point.up.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 70, height: 70)
                            .foregroundColor(.gray.opacity(0.5))
                        
                        Text("Посылки не найдены")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        Text("Попробуйте изменить параметры фильтрации или создайте новую посылку")
                            .font(.subheadline)
                            .foregroundColor(.gray.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(filteredPackages) { package in
                            PackageCard(package: package) {
                                selectedPackage = package
                                showPackageDetails = true
                            }
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 5, leading: 15, bottom: 5, trailing: 15))
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    deletePackage(package)
                                } label: {
                                    Label("Удалить", systemImage: "trash")
                                }
                                
                                if !package.isCancelled && package.status != "Доставлен" {
                                    Button(role: .cancel) {
                                        cancelPackage(package)
                                    } label: {
                                        Label("Отменить", systemImage: "xmark.circle")
                                    }
                                    .tint(.orange)
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Мои посылки")
            .onAppear {
                loadPackages()
            }
            .onChange(of: searchText) { _ in
                applyFiltersAndSort()
            }
            .sheet(isPresented: $showFilterSheet) {
                FilterView(
                    selectedFilter: $selectedFilter,
                    startDate: $startDate,
                    endDate: $endDate,
                    onApply: {
                        applyFiltersAndSort()
                    }
                )
            }
            .sheet(isPresented: $showPackageDetails) {
                if let package = selectedPackage {
                    PackageDetailView(package: package)
                        .environmentObject(packageManager)
                }
            }
        }
    }
    
    private func loadPackages() {
        if let user = authManager.currentUser {
            packages = packageManager.getPackagesByUser(user)
            applyFiltersAndSort()
        }
    }
    
    private func deletePackage(_ package: Package) {
        if packageManager.deletePackage(package) {
            // Обновляем список после удаления
            if let index = filteredPackages.firstIndex(of: package) {
                filteredPackages.remove(at: index)
            }
            if let index = packages.firstIndex(of: package) {
                packages.remove(at: index)
            }
        }
    }
    
    private func cancelPackage(_ package: Package) {
        if packageManager.cancelPackage(package) {
            // Обновляем список после отмены
            loadPackages()
        }
    }
    
    private func applyFiltersAndSort() {
        var result = packages
        
        // Применяем поиск
        if !searchText.isEmpty {
            result = result.filter { package in
                guard let trackingNumber = package.trackingNumber else { return false }
                return trackingNumber.lowercased().contains(searchText.lowercased())
            }
        }
        
        // Применяем фильтр
        switch selectedFilter {
        case .all:
            break // Показываем все
        case .active:
            result = result.filter { package in
                guard let status = package.status else { return false }
                return status != "Доставлен" && status != "Отменен"
            }
        case .delivered:
            result = result.filter { package in
                guard let status = package.status else { return false }
                return status == "Доставлен"
            }
        case .cancelled:
            result = result.filter { package in
                return package.isCancelled
            }
        case .dateRange:
            result = result.filter { package in
                guard let creationDateString = package.creationDate else { return false }
                
                // Преобразуем строковую дату в Date для сравнения
                if let creationDate = dateFormatter.date(from: creationDateString) {
                    let startOfDay = Calendar.current.startOfDay(for: startDate)
                    let endOfDay = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: endDate) ?? endDate
                    
                    return creationDate >= startOfDay && creationDate <= endOfDay
                }
                return false
            }
        }
        
        // Применяем сортировку
        switch selectedSortOption {
        case .dateDesc:
            result.sort { (package1, package2) -> Bool in
                guard let dateStr1 = package1.creationDate, 
                      let dateStr2 = package2.creationDate else { return false }
                
                // Для строковых дат в формате ISO 8601 можно применить лексикографическое сравнение
                return dateStr1 > dateStr2
            }
        case .dateAsc:
            result.sort { (package1, package2) -> Bool in
                guard let dateStr1 = package1.creationDate, 
                      let dateStr2 = package2.creationDate else { return false }
                
                return dateStr1 < dateStr2
            }
        }
        
        filteredPackages = result
    }
}

struct FilterView: View {
    @Binding var selectedFilter: PackagesView.PackageFilter
    @Binding var startDate: Date
    @Binding var endDate: Date
    var onApply: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Фильтр")) {
                    ForEach(PackagesView.PackageFilter.allCases) { filter in
                        Button {
                            selectedFilter = filter
                        } label: {
                            HStack {
                                Text(filter.rawValue)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                if selectedFilter == filter {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                }
                
                if selectedFilter == .dateRange {
                    Section(header: Text("Диапазон дат")) {
                        DatePicker("С", selection: $startDate, displayedComponents: .date)
                        DatePicker("По", selection: $endDate, displayedComponents: .date)
                    }
                }
            }
            .navigationTitle("Фильтры")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Применить") {
                        onApply()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
} 