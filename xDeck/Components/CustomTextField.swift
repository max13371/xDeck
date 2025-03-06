//
//  CustomTextField.swift
//  xDeck
//
//  Created by Максим on 3/6/25.
//

import SwiftUI

struct CustomTextField: View {
    var icon: String
    var title: String
    var hint: String
    @Binding var value: String
    var isSecure: Bool = false
    
    @State private var showPassword: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(.gray)
                
                if isSecure {
                    Group {
                        if showPassword {
                            TextField(hint, text: $value)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                        } else {
                            SecureField(hint, text: $value)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                        }
                    }
                    
                    Button {
                        showPassword.toggle()
                    } label: {
                        Image(systemName: showPassword ? "eye.slash" : "eye")
                            .foregroundColor(.gray)
                    }
                } else {
                    TextField(hint, text: $value)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 15)
            .background {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color.gray.opacity(0.1))
            }
        }
    }
} 