//
//  RecordDetailView.swift
//  Film Lab
//
//  Created by Maxim Eliseyev on 12.07.2025.
//

import SwiftUI
import SwiftData

struct RecordDetailView: View {
    let record: SwiftDataJournalRecord
    let swiftDataService: SwiftDataService
    let onEdit: () -> Void
    let onDelete: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    
    private var minutes: Int {
        Int(record.time) / 60
    }
    
    private var seconds: Int {
        Int(record.time) % 60
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    dateSection
                    
                    basicInfoSection
                    
                    if let comment = record.comment, !comment.isEmpty {
                        commentSection
                    }
                }
                .padding()
                .frame(width: .infinity)
            }
            .navigationTitle(record.name ?? String(localized: "recordDetails"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(LocalizedStringKey("close")) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: {
                            showingEditSheet = true
                        }) {
                            Label(LocalizedStringKey("edit"), systemImage: "pencil")
                        }
                        
                        Button(role: .destructive, action: {
                            showingDeleteAlert = true
                        }) {
                            Label(LocalizedStringKey("delete"), systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            CreateRecordView(
                swiftDataService: swiftDataService,
                prefillData: createJournalRecord(),
                isEditing: true,
                onUpdate: { updatedRecord in
                    // Здесь можно добавить логику обновления записи
                    print("Record updated: \(updatedRecord.name ?? "Unknown")")
                },
                calculatorTemperature: nil,
                calculatorCoefficient: nil,
                calculatorProcess: nil
            )
        }
        .alert(LocalizedStringKey("deleteRecord"), isPresented: $showingDeleteAlert) {
            Button(LocalizedStringKey("cancel"), role: .cancel) { }
            Button(LocalizedStringKey("delete"), role: .destructive) {
                onDelete()
                dismiss()
            }
        } message: {
            Text(LocalizedStringKey("deleteRecordConfirmation"))
        }
    }
    
    private var basicInfoSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            VStack(alignment: .leading, spacing: 12) {
                
                Text(record.filmName ?? String(localized: "unknownFilm"))
                    .font(.body)
                    .foregroundColor(.primary)
                Text(record.developerName ?? String(localized: "unknownDeveloper"))
                    .font(.body)
                    .foregroundColor(.primary)
                Text("\(record.iso)")
                    .font(.body)
                    .foregroundColor(.primary)
                
                if let dilution = record.dilution, !dilution.isEmpty {
                    Text(dilution)
                        .font(.body)
                        .foregroundColor(.primary)
                }
                
                Text("\(record.temperature)\(String(localized: "degreesCelsius"))")
                    .font(.body)
                    .foregroundColor(.primary)
                
                if record.time > 0 {
                    Text("\(String(format: "%d:%02d", minutes, seconds))")
                        .font(.body)
                        .foregroundColor(.primary)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var commentSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(record.comment ?? "")
                .font(.body)
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var dateSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            if let date = record.date {
                Text(formatDate(date))
                    .font(.body)
                    .foregroundColor(.primary)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm"
        return formatter.string(from: date)
    }
    
    private func createJournalRecord() -> JournalRecord {
        return JournalRecord(
            date: record.date ?? Date(),
            name: record.name,
            filmName: record.filmName,
            developerName: record.developerName,
            iso: record.iso,
            process: "Редактирование",
            dilution: record.dilution,
            temperature: record.temperature,
            time: Int(record.time),
            comment: record.comment
        )
    }
}
