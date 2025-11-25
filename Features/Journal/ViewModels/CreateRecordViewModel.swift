//
//  CreateRecordViewModel.swift
//  Analog Process
//
//  Created by Maxim Eliseyev on 06.08.2025.
//

import SwiftUI

@MainActor
class CreateRecordViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var filmName: String = ""
    @Published var developerName: String = ""
    @Published var iso: Int32 = Int32(AppConstants.ISO.defaultISO)
    @Published var dilution: String = ""
    @Published var temperature: Int = 20
    @Published var process: String = ""
    @Published var minutes: Int = 0
    @Published var seconds: Int = 0
    @Published var comment: String = ""
    @Published var date: Date = Date()
    
    @Published var showISOPicker = false
    
    // Автодополнение
    @Published var filmAutoCompleteManager: AutoCompleteManager<FilmAutoCompleteItem>
    @Published var developerAutoCompleteManager: AutoCompleteManager<DeveloperAutoCompleteItem>

    private let swiftDataService: SwiftDataService

    init(swiftDataService: SwiftDataService) {
        self.swiftDataService = swiftDataService
        self.filmAutoCompleteManager = .forFilms(swiftDataService: swiftDataService)
        self.developerAutoCompleteManager = .forDevelopers(swiftDataService: swiftDataService)
    }
    
    @Published var validationErrors: [ValidationError] = []

    var isValid: Bool {
        validationErrors.isEmpty
    }

    func validate() {
        var errors: [ValidationError] = []
        errors.append(contentsOf: ValidationManager.validateNotEmpty(field: filmName, fieldName: "Film Name"))
        errors.append(contentsOf: ValidationManager.validateNotEmpty(field: developerName, fieldName: "Developer Name"))
        self.validationErrors = errors
    }
    
    // Конвертация времени в секунды
    private var totalSeconds: Int {
        return minutes * 60 + seconds
    }
    
    // MARK: - Autocomplete Methods

    func updateFilmSuggestions() {
        filmAutoCompleteManager.updateSuggestions(for: filmName)
    }

    func updateDeveloperSuggestions() {
        developerAutoCompleteManager.updateSuggestions(for: developerName)
    }

    func selectFilmSuggestion(_ item: FilmAutoCompleteItem) {
        filmName = filmAutoCompleteManager.selectSuggestion(item)
    }

    func selectDeveloperSuggestion(_ item: DeveloperAutoCompleteItem) {
        developerName = developerAutoCompleteManager.selectSuggestion(item)
    }

    func hideFilmSuggestions() {
        filmAutoCompleteManager.hideSuggestions()
    }

    func hideDeveloperSuggestions() {
        developerAutoCompleteManager.hideSuggestions()
    }
    
    func prefill(with record: JournalRecord) {
        name = record.name ?? ""
        filmName = record.filmName ?? ""
        developerName = record.developerName ?? ""
        iso = record.iso ?? Int32(AppConstants.ISO.defaultFilmISO)
        process = record.process ?? "push +1"
        dilution = record.dilution ?? ""
                    temperature = record.temperature ?? 20
        
        // Конвертируем секунды обратно в минуты и секунды
        let totalSeconds = record.time ?? 0
        minutes = totalSeconds / 60
        seconds = totalSeconds % 60
        
        comment = record.comment ?? ""
        date = record.date
    }
    
    func saveRecord() {
        validate()
        guard isValid else { return }
        
        swiftDataService.saveRecord(
            filmName: filmName.trimmingCharacters(in: .whitespacesAndNewlines),
            developerName: developerName.trimmingCharacters(in: .whitespacesAndNewlines),
            dilution: dilution.trimmingCharacters(in: .whitespacesAndNewlines),
            temperature: temperature,
            iso: Int(iso),
            calculatedTime: totalSeconds,
            notes: comment.trimmingCharacters(in: .whitespacesAndNewlines)
        )
    }
    
    func createJournalRecord() -> JournalRecord {
        return JournalRecord(
            date: date,
            name: name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : name.trimmingCharacters(in: .whitespacesAndNewlines),
            filmName: filmName.trimmingCharacters(in: .whitespacesAndNewlines),
            developerName: developerName.trimmingCharacters(in: .whitespacesAndNewlines),
            iso: iso,
            process: process.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : process.trimmingCharacters(in: .whitespacesAndNewlines),
            dilution: dilution.trimmingCharacters(in: .whitespacesAndNewlines),
            temperature: temperature,
            time: totalSeconds,
            comment: comment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : comment.trimmingCharacters(in: .whitespacesAndNewlines)
        )
    }
    
    func getAvailableISOs() -> [Int] {
        // Для журнала возвращаем все стандартные ISO значения
        return AppConstants.ISO.allValues
    }
}
