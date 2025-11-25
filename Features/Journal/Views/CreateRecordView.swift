//
//  CreateRecordView.swift
//  Film Lab
//
//  Created by Maxim Eliseyev on 12.07.2025.
//

import SwiftUI

struct CreateRecordView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: CreateRecordViewModel
    
    // Параметры для предзаполнения из калькулятора
    let prefillData: JournalRecord?
    let isEditing: Bool
    let onUpdate: ((JournalRecord) -> Void)?
    
    // Дополнительные параметры для передачи данных из калькулятора
    let calculatorTemperature: Int?
    let calculatorCoefficient: String?
    let calculatorProcess: String?
    
    // Управление фокусом для клавиатуры
    @FocusState private var focusedField: FocusedField?
    
    enum FocusedField: Hashable {
        case name
        case filmName
        case developerName
        case process
        case dilution
        case temperature
        case minutes
        case seconds
        case comment
    }
    
    init(swiftDataService: SwiftDataService, prefillData: JournalRecord? = nil, isEditing: Bool = false, onUpdate: ((JournalRecord) -> Void)? = nil, calculatorTemperature: Int? = nil, calculatorCoefficient: String? = nil, calculatorProcess: String? = nil) {
        self._viewModel = StateObject(wrappedValue: CreateRecordViewModel(swiftDataService: swiftDataService))
        self.prefillData = prefillData
        self.isEditing = isEditing
        self.onUpdate = onUpdate
        self.calculatorTemperature = calculatorTemperature
        self.calculatorCoefficient = calculatorCoefficient
        self.calculatorProcess = calculatorProcess
    }
    
    var body: some View {
        NavigationStack {
            KeyboardAwareView {
                ZStack {
                    Color.black.ignoresSafeArea()
                    
                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 16) {
                            Text(LocalizedStringKey("journalRecordBasicInfo"))
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            VStack(spacing: 12) {
                                TextField(LocalizedStringKey("journalRecordName"), text: $viewModel.name)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .focused($focusedField, equals: .name)
                                    .submitLabel(.next)
                                    .onSubmit {
                                        focusedField = .filmName
                                    }
                                
                                // Поле Film с автодополнением
                                VStack(alignment: .leading, spacing: 0) {
                                    TextField(LocalizedStringKey("journalRecordFilm"), text: $viewModel.filmName)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .focused($focusedField, equals: .filmName)
                                        .submitLabel(.next)
                                        .onSubmit {
                                            focusedField = .developerName
                                        }
                                        .onChange(of: viewModel.filmName) { _, _ in
                                            viewModel.updateFilmSuggestions()
                                        }
                                        .onTapGesture {
                                            viewModel.updateFilmSuggestions()
                                        }
                                        .onChange(of: focusedField) { _, newValue in
                                            if newValue != .filmName {
                                                viewModel.hideFilmSuggestions()
                                            }
                                        }
                                    
                                    AutoCompleteManagerView(
                                        manager: viewModel.filmAutoCompleteManager,
                                        onSelect: { item in
                                            viewModel.selectFilmSuggestion(item)
                                            focusedField = .developerName
                                        },
                                        onDismiss: {
                                            viewModel.hideFilmSuggestions()
                                        }
                                    )
                                    .zIndex(1)
                                }
                                
                                // Поле Developer с автодополнением
                                VStack(alignment: .leading, spacing: 0) {
                                    TextField(LocalizedStringKey("journalRecordDeveloper"), text: $viewModel.developerName)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .focused($focusedField, equals: .developerName)
                                        .submitLabel(.next)
                                        .onSubmit {
                                            focusedField = .process
                                        }
                                        .onChange(of: viewModel.developerName) { _, _ in
                                            viewModel.updateDeveloperSuggestions()
                                        }
                                        .onTapGesture {
                                            viewModel.updateDeveloperSuggestions()
                                        }
                                        .onChange(of: focusedField) { _, newValue in
                                            if newValue != .developerName {
                                                viewModel.hideDeveloperSuggestions()
                                            }
                                        }
                                    
                                    AutoCompleteManagerView(
                                        manager: viewModel.developerAutoCompleteManager,
                                        onSelect: { item in
                                            viewModel.selectDeveloperSuggestion(item)
                                            focusedField = .process
                                        },
                                        onDismiss: {
                                            viewModel.hideDeveloperSuggestions()
                                        }
                                    )
                                    .zIndex(1)
                                }
                                
                                Button(action: {
                                    // Скрываем клавиатуру перед открытием пикера
                                    focusedField = nil
                                    viewModel.showISOPicker = true
                                }) {
                                    HStack {
                                        Text("\(viewModel.iso)")
                                            .foregroundColor(.primary)
                                        Spacer()
                                        Image(systemName: "chevron.down")
                                            .foregroundColor(.secondary)
                                            .font(.caption)
                                    }
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                                }
                                .sheet(isPresented: $viewModel.showISOPicker) {
                                    ISOPickerView(
                                        iso: $viewModel.iso,
                                        onDismiss: { viewModel.showISOPicker = false },
                                        availableISOs: viewModel.getAvailableISOs()
                                    )
                                }
                                
                                TextField(LocalizedStringKey("journalRecordProcess"), text: $viewModel.process)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .focused($focusedField, equals: .process)
                                    .submitLabel(.next)
                                    .onSubmit {
                                        focusedField = .dilution
                                    }
                                
                                TextField(LocalizedStringKey("journalRecordDilution"), text: $viewModel.dilution)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .focused($focusedField, equals: .dilution)
                                    .submitLabel(.next)
                                    .onSubmit {
                                        focusedField = .temperature
                                    }
                                
                                HStack {
                                    TextField("", value: $viewModel.temperature, format: .number)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .frame(width: 80)
                                        .focused($focusedField, equals: .temperature)
                                        .keyboardType(.decimalPad)
                                        .submitLabel(.next)
                                        .onSubmit {
                                            focusedField = .minutes
                                        }
                                    Text("\(NSLocalizedString("journalRecordTemperature", comment: "")) \(NSLocalizedString("degreesCelsius", comment: ""))")
                                        .foregroundColor(.secondary)
                                }
                                
                                HStack {
                                    TextField("", value: $viewModel.minutes, format: .number)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .frame(width: 80)
                                        .focused($focusedField, equals: .minutes)
                                        .keyboardType(.numberPad)
                                        .submitLabel(.next)
                                        .onSubmit {
                                            focusedField = .seconds
                                        }
                                        .onChange(of: viewModel.minutes) { oldValue, newValue in
                                            if newValue < 0 {
                                                viewModel.minutes = 0
                                            }
                                        }
                                    Text(LocalizedStringKey("min"))
                                        .foregroundColor(.secondary)
                                    TextField("", value: $viewModel.seconds, format: .number)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .frame(maxWidth: .infinity)
                                        .focused($focusedField, equals: .seconds)
                                        .keyboardType(.numberPad)
                                        .submitLabel(.next)
                                        .onSubmit {
                                            focusedField = .comment
                                        }
                                        .onChange(of: viewModel.seconds) { oldValue, newValue in
                                            if newValue > 59 {
                                                viewModel.seconds = 59
                                            } else if newValue < 0 {
                                                viewModel.seconds = 0
                                            }
                                        }
                                    Text(LocalizedStringKey("sec"))
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text(LocalizedStringKey("journalRecordComment"))
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            TextField(LocalizedStringKey("journalRecordCommentPlaceholder"), text: $viewModel.comment, axis: .vertical)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .lineLimit(3...6)
                                .focused($focusedField, equals: .comment)
                                .submitLabel(.done)
                                .onSubmit {
                                    focusedField = nil
                                }
                        }
                        
                        VStack(alignment: .leading, spacing: 16) {
                            DatePicker(
                                LocalizedStringKey("journalRecordDate"),
                                selection: $viewModel.date,
                                displayedComponents: [.date, .hourAndMinute]
                            )
                        }
                        .padding()
                    }
                    .navigationTitle(isEditing ? LocalizedStringKey("editRecord") : LocalizedStringKey("journalCreateRecord"))
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(LocalizedStringKey("cancel")) {
                                dismiss()
                            }
                        }
                        
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(LocalizedStringKey("save")) {
                                // Скрываем клавиатуру перед сохранением
                                focusedField = nil
                                if isEditing {
                                    let updatedRecord = viewModel.createJournalRecord()
                                    onUpdate?(updatedRecord)
                                } else {
                                    viewModel.saveRecord()
                                }
                                dismiss()
                            }
                            .disabled(!viewModel.isValid)
                        }
                        
                        // Добавляем кнопку "Готово" на клавиатуру
                        ToolbarItemGroup(placement: .keyboard) {
                            Spacer()
                            Button(LocalizedStringKey("done")) {
                                focusedField = nil
                            }
                        }
                    }
                    // Добавляем обработчик нажатия вне текстовых полей для скрытия клавиатуры и автодополнения
                    .onTapGesture {
                        focusedField = nil
                        viewModel.hideFilmSuggestions()
                        viewModel.hideDeveloperSuggestions()
                    }
                    .onAppear {
                        if let prefillData = prefillData {
                            viewModel.prefill(with: prefillData)
                        } else if let calculatorTemperature = calculatorTemperature {
                            // Если переданы данные из калькулятора, заполняем только температуру и процесс
                            viewModel.temperature = calculatorTemperature
                            if let calculatorProcess = calculatorProcess {
                                viewModel.process = calculatorProcess
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    let container = SwiftDataPersistence.preview.modelContainer
    let githubService = GitHubDataService()
    let swiftDataService = SwiftDataService(githubDataService: githubService, modelContainer: container)
    let autoSyncService = AutoSyncService(swiftDataService: swiftDataService)
    let presetService = PresetService(swiftDataService: swiftDataService)

    CreateRecordView(
        swiftDataService: swiftDataService,
        prefillData: nil,
        isEditing: false,
        onUpdate: nil,
        calculatorTemperature: nil,
        calculatorCoefficient: nil,
        calculatorProcess: nil
    )
    .modelContainer(container)
    .environmentObject(githubService)
    .environmentObject(swiftDataService)
    .environmentObject(autoSyncService)
    .environmentObject(presetService)
} 
