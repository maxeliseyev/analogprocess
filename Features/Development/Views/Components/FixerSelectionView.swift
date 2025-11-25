//
//  FixerSelectionView.swift
//  Film Lab
//
//  Created by Maxim Eliseyev on 12.07.2025.
//

import SwiftUI

struct FixerSelectionView: View {
    let fixers: [SwiftDataFixer]
    @Binding var selectedFixer: SwiftDataFixer?
    let onFixerPickerTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(LocalizedStringKey("fixer"))
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: onFixerPickerTap) {
                    HStack {
                        Text(selectedFixer?.name ?? String(localized: String.LocalizationValue("selectFixer")))
                            .foregroundColor(selectedFixer != nil ? .primary : .secondary)
                        
                        Image(systemName: "chevron.down")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            if let selectedFixer = selectedFixer {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(getFixerTypeDisplayName(selectedFixer.type))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("\(selectedFixer.time / 60) мин")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(4)
                    }
                    

                    
                    if let warning = selectedFixer.warning {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                                .font(.caption)
                            
                            Text(warning)
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(4)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
    
    private func getFixerTypeDisplayName(_ type: String) -> String {
        switch type {
        case "rapid":
            return "Быстрый фиксаж"
        case "acid":
            return "Кислый фиксаж"
        case "neutral":
            return "Нейтральный фиксаж"
        default:
            return type
        }
    }
}

// MARK: - Preview
struct FixerSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        FixerSelectionView(
            fixers: [],
            selectedFixer: .constant(nil),
            onFixerPickerTap: {}
        )
        .padding()
    }
}
