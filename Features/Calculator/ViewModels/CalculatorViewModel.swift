//
//  SwiftDataCalculatorViewModel.swift
//  AnalogProcess
//
//  Created by Maxim Eliseyev on 11.08.2025.
//

import SwiftUI
import SwiftData

@MainActor
class CalculatorViewModel: ObservableObject {
    // MARK: - Input Properties
    @Published var minutes = ""
    @Published var seconds = ""
    @Published var coefficient = "1.33" {
        didSet {
            // Автоматически пересчитываем при изменении коэффициента
            if isValidInput {
                calculateTime()
            }
        }
    }
    @Published var temperature: Int = 20 {
        didSet {
            // Автоматически пересчитываем при изменении температуры
            if isValidInput {
                calculateTime()
            }
        }
    }
    
    // MARK: - Push Mode Properties
    @Published var isPushMode = true {
        didSet {
            // Автоматически пересчитываем при изменении режима
            if isValidInput {
                calculateTime()
            }
        }
    }
    @Published var pushSteps = 3 {
        didSet {
            // Автоматически пересчитываем при изменении количества шагов
            if isValidInput {
                calculateTime()
            }
        }
    }
    
    // MARK: - UI States
    @Published var coefficientAutoCompleteManager: AutoCompleteManager<String>
    @Published var showResult = false
    @Published var showTimer = false
    @Published var showSaveDialog = false
    
    // MARK: - Results
    @Published var pushResults: [ProcessStep] = []
    @Published var selectedTimerLabel = ""
    @Published var selectedTimerMinutes = 0
    @Published var selectedTimerSeconds = 0
    @Published var selectedResult: ProcessStep?
    
    /// Results to display in UI: base time (+0) and only the selected step (last), according to `pushSteps`.
    var displayResults: [ProcessStep] {
        guard !pushResults.isEmpty, let base = pushResults.first else { return [] }
        guard let last = pushResults.last else { return [base] }
        if base.id == last.id {
            return [base]
        }
        return [base, last]
    }
    
    // MARK: - Dependencies
    private let swiftDataService: SwiftDataService
    private let calculator = DevelopmentCalculator()

    init(swiftDataService: SwiftDataService) {
        self.swiftDataService = swiftDataService
        let standardCoefficients = ["1.33", "1.25", "1.5", "1.67", "2.0", "2.5", "3.0"]
        self.coefficientAutoCompleteManager = .forStaticData(standardCoefficients)
    }
    
    // MARK: - Public Methods
    
    func getTemperatureMultiplier() -> Double {
        return swiftDataService.getTemperatureMultiplier(for: temperature)
    }
    
    // MARK: - Computed Properties
    
    var isValidInput: Bool {
        guard let min = Int(minutes), min >= 0,
              let sec = Int(seconds), sec >= 0, sec < 60,
              let coeff = Double(coefficient), coeff > 0 else {
            return false
        }
        return true
    }
    
    // MARK: - Autocomplete Methods

    func updateCoefficientSuggestions() {
        coefficientAutoCompleteManager.updateSuggestions(for: coefficient)
    }

    func selectCoefficientSuggestion(_ coefficient: String) {
        self.coefficient = coefficientAutoCompleteManager.selectSuggestion(coefficient)
    }

    func hideCoefficientSuggestions() {
        coefficientAutoCompleteManager.hideSuggestions()
    }
    
    // MARK: - Calculation Methods
    
    func calculateTime() {
        guard isValidInput else { return }
        
        guard let min = Int(minutes), min >= 0,
              let sec = Int(seconds), sec >= 0, sec < 60,
              let coeff = Double(coefficient), coeff > 0 else {
            return
        }
        
        // Применяем температурный коэффициент
        let temperatureMultiplier = swiftDataService.getTemperatureMultiplier(for: temperature)
        let adjustedMinutes = Int(Double(min) * temperatureMultiplier)
        let adjustedSeconds = Int(Double(sec) * temperatureMultiplier)
        
        // Нормализуем время (секунды не должны превышать 59)
        let totalAdjustedSeconds = adjustedMinutes * 60 + adjustedSeconds
        let normalizedMinutes = totalAdjustedSeconds / 60
        let normalizedSeconds = totalAdjustedSeconds % 60
        
        pushResults = calculator.calculateResults(
            minutes: normalizedMinutes,
            seconds: normalizedSeconds,
            coefficient: coeff,
            temperature: Double(temperature),
            isPushMode: isPushMode,
            steps: pushSteps
        )
        
        showResult = true
    }
    
    // MARK: - Timer Methods
    
    func startTimer(_ label: String, _ minutes: Int, _ seconds: Int) {
        selectedTimerLabel = label
        selectedTimerMinutes = minutes
        selectedTimerSeconds = seconds
        showResult = false // Закрываем sheet с результатами
        showTimer = true // Активируем навигацию к таймеру
    }
    
    // MARK: - Record Management Methods
    
    func saveRecord() {
        guard let selectedResult = selectedResult else { return }
        
        let totalSeconds = selectedResult.totalSeconds
        
        swiftDataService.saveRecord(
            filmName: "Расчетное время",
            developerName: "Пользовательский расчет",
            dilution: "Коэффициент: \(coefficient), Температура: \(temperature)°C",
            temperature: temperature,
            iso: AppConstants.ISO.defaultISO,
            calculatedTime: totalSeconds,
            notes: "Расчет: \(selectedResult.label) - \(selectedResult.formattedTime)"
        )
        
        showSaveDialog = false
    }
    
    func loadRecord(_ record: SwiftDataJournalRecord) {
        let totalSeconds = Int(record.time)
        
        self.minutes = "\(totalSeconds / 60)"
        self.seconds = "\(totalSeconds % 60)"
        self.temperature = record.temperature
        coefficient = "1.33" // Используем стандартный коэффициент
        isPushMode = true
        pushSteps = 3
        
        calculateTime()
    }
    
    func deleteRecord(_ record: SwiftDataJournalRecord) {
        swiftDataService.deleteCalculationRecord(record)
    }
    
    func createPrefillData() -> (name: String, temperature: Int, coefficient: String, time: Int, comment: String, process: String)? {
        guard let selectedResult = selectedResult else { return nil }
        
        let totalSeconds = selectedResult.totalSeconds
        
        let name = "Расчетное время"
        let temperature = self.temperature
        let coefficient = self.coefficient
        let time = totalSeconds
        let comment = "Расчет: \(selectedResult.label) - \(selectedResult.formattedTime)"
        let process = "Пользовательский расчет"
        
        return (name, temperature, coefficient, time, comment, process)
    }
}