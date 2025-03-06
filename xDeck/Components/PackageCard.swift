//
//  PackageCard.swift
//  xDeck
//
//  Created by Максим on 3/6/25.
//

import SwiftUI

struct PackageCard: View {
    var package: Package
    var onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(package.trackingNumber ?? "Нет номера")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text(package.recipientName ?? "Не указано")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    StatusBadge(status: package.status ?? "Неизвестно")
                }
                
                HStack {
                    Image(systemName: "location")
                        .foregroundColor(.gray)
                        .font(.caption)
                    
                    Text(package.address ?? "Не указан")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
                
                HStack {
                    if let dateString = package.creationDate {
                        HStack(spacing: 4) {
                            Image(systemName: "calendar")
                                .foregroundColor(.gray)
                                .font(.caption2)
                            
                            Text(dateString)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                        .font(.caption)
                }
            }
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct StatusBadge: View {
    var status: String
    
    var body: some View {
        Text(status)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background {
                Capsule()
                    .fill(statusColor.opacity(0.2))
            }
            .foregroundColor(statusColor)
    }
    
    private var statusColor: Color {
        switch status.lowercased() {
        case "доставлен":
            return .green
        case "в пути":
            return .blue
        case "отменен":
            return .red
        case "ожидает отправки":
            return .orange
        default:
            return .gray
        }
    }
} 