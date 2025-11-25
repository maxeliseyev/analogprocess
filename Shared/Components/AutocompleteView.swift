//
//  AutocompleteView.swift
//  Film Lab
//
//  Created by Maxim Eliseyev on 12.07.2025.
//

import SwiftUI

struct AutocompleteView: View {
    let suggestions: [String]
    let onSelect: (String) -> Void
    let onDismiss: () -> Void
    
    var body: some View {
        if !suggestions.isEmpty {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(suggestions, id: \.self) { suggestion in
                    Button(action: {
                        onSelect(suggestion)
                    }) {
                        HStack {
                            Text(suggestion)
                                .foregroundColor(.primary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                            
                            Spacer()
                        }
                        .background(Color(.systemGray6))
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                    .background(Color(.systemGray6))
                    
                    if suggestion != suggestions.last {
                        Divider()
                            .padding(.leading, 16)
                    }
                }
            }
            .background(Color(.systemBackground))
            .cornerRadius(8)
            .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 3)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(.systemGray4), lineWidth: 0.5)
            )
        }
    }
}

#Preview {
    VStack {
        AutocompleteView(
            suggestions: ["Ilford HP5+", "Kodak Tri-X 400", "Fujifilm Neopan 400"],
            onSelect: { suggestion in
                print("Selected: \(suggestion)")
            },
            onDismiss: {
                print("Dismiss")
            }
        )
        .padding()
        
        Spacer()
    }
    .background(Color(.systemBackground))
    .preferredColorScheme(.dark)
} 