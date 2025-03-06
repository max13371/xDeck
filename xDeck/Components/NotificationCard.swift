//
//  NotificationCard.swift
//  xDeck
//
//  Created by Максим on 3/6/25.
//

import SwiftUI

struct NotificationCard: View {
    var notification: Notification
    var onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: 15) {
                Circle()
                    .fill(notification.isRead ? Color.gray.opacity(0.3) : Color.blue)
                    .frame(width: 12, height: 12)
                    .padding(.top, 5)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(notification.title ?? "")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(notification.message ?? "")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .lineLimit(2)
                    
                    HStack {
                        if let dateString = notification.date {
                            Text(dateString)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        if let package = notification.package as? Package {
                            Text(package.trackingNumber ?? "")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
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