//
//  AutoCompleteManagerView.swift
//  AnalogProcess
//
//  Created by Maxim Eliseyev on 25.09.2025.
//

import SwiftUI

/// Generic View для работы с AutoCompleteManager
struct AutoCompleteManagerView<T: AutoCompleteItem>: View {
    @ObservedObject var manager: AutoCompleteManager<T>
    let onSelect: (T) -> Void
    let onDismiss: () -> Void

    var body: some View {
        if manager.isShowingSuggestions && !manager.suggestions.isEmpty {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(manager.suggestions.indices, id: \.self) { index in
                    let suggestion = manager.suggestions[index]
                    Button(action: {
                        onSelect(suggestion)
                    }) {
                        HStack {
                            Text(suggestion.displayText)
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

                    if index != manager.suggestions.count - 1 {
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

/// Convenience версия для String AutoCompleteManager
struct StringAutoCompleteView: View {
    @ObservedObject var manager: AutoCompleteManager<String>
    let onSelect: (String) -> Void
    let onDismiss: () -> Void

    var body: some View {
        AutoCompleteManagerView(
            manager: manager,
            onSelect: onSelect,
            onDismiss: onDismiss
        )
    }
}

#Preview {
    VStack {
        StringAutoCompleteView(
            manager: .forStaticData(["Ilford HP5+", "Kodak Tri-X 400", "Fujifilm Neopan 400"]),
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