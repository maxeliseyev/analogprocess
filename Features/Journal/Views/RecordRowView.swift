//
//  RecordRowView.swift
//  Film Lab
//
//  Created by Maxim Eliseyev on 11.07.2025.
//

import SwiftUI
import SwiftData

struct RecordRowView: View {
    let record: SwiftDataJournalRecord
    let onTap: () -> Void
    
    private var minutes: Int {
        Int(record.time) / 60
    }
    
    private var seconds: Int {
        Int(record.time) % 60
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Название записи
            HStack {
                if let name = record.name, !name.isEmpty {
                    Text(name)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                } else {
                    Text(String(format: String(localized: "filmPlusDeveloper"), record.filmName ?? String(localized: "unknownFilm"), record.developerName ?? String(localized: "unknownDeveloper")))
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                if let date = record.date {
                    Text(date, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
}
