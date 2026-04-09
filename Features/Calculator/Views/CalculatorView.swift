//
//  CalculatorView.swift
//  Film Lab
//
//  Created by Maxim Eliseyev on 12.07.2025.
//

import SwiftUI
import CoreData

struct CalculatorView: View {
    @StateObject private var viewModel: CalculatorViewModel
    let swiftDataService: SwiftDataService
    let onStartTimer: ((String, Int, Int) -> Void)?
    
    // Параметры для режима редактора стадии
    let isFromStageEditor: Bool
    @Environment(\.dismiss) private var dismiss
    
    // Управление фокусом для клавиатуры
    @FocusState private var focusedField: FocusedField?
    @State private var showTemperaturePicker = false
    
    enum FocusedField: Hashable {
        case minutes
        case seconds
        case coefficient
    }
    
    init(swiftDataService: SwiftDataService, initialTime: Int? = nil, initialTemperature: Int = 20, isFromStageEditor: Bool = false, onStartTimer: ((String, Int, Int) -> Void)? = nil) {
        let vm = CalculatorViewModel(swiftDataService: swiftDataService)
        if let time = initialTime {
            let minutes = time / 60
            let seconds = time % 60
            vm.minutes = "\(minutes)"
            vm.seconds = "\(seconds)"
            vm.temperature = initialTemperature
        }
        _viewModel = StateObject(wrappedValue: vm)
        self.swiftDataService = swiftDataService
        self.isFromStageEditor = isFromStageEditor
        self.onStartTimer = onStartTimer
    }
    
    var body: some View {
        KeyboardAwareView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 15) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(LocalizedStringKey("baseTime"))
                            .font(.headline)
                        
                        HStack {
                            TextField(LocalizedStringKey("minutes"), text: $viewModel.minutes)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.numberPad)
                                .focused($focusedField, equals: .minutes)
                                .submitLabel(.next)
                                .onSubmit {
                                    focusedField = .seconds
                                }
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(minutesInvalid ? Color.red : Color.clear, lineWidth: 1.5)
                                )
                            
                            Text(LocalizedStringKey("min"))
                            
                            TextField(LocalizedStringKey("seconds"), text: $viewModel.seconds)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.numberPad)
                                .focused($focusedField, equals: .seconds)
                                .submitLabel(.next)
                                .onSubmit {
                                    focusedField = .coefficient
                                }
                                .onChange(of: viewModel.seconds) { _, newValue in
                                    if let sec = Int(newValue), sec > 59 {
                                        viewModel.seconds = "59"
                                    }
                                }
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(secondsInvalid ? Color.red : Color.clear, lineWidth: 1.5)
                                )
                            
                            Text(LocalizedStringKey("sec"))
                        }
                        
                        if minutesInvalid || secondsInvalid {
                            Text(minutesInvalid
                                 ? LocalizedStringKey("minutesInvalidHint")
                                 : LocalizedStringKey("secondsInvalidHint"))
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(LocalizedStringKey("ratio"))
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 0) {
                            HStack {
                                TextField("1.33", text: $viewModel.coefficient)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .keyboardType(.decimalPad)
                                    .focused($focusedField, equals: .coefficient)
                                    .submitLabel(.done)
                                    .onSubmit {
                                        focusedField = nil
                                    }
                                    .onChange(of: viewModel.coefficient) { _, _ in
                                        viewModel.updateCoefficientSuggestions()
                                    }
                                    .onTapGesture {
                                        viewModel.updateCoefficientSuggestions()
                                    }
                                    .onChange(of: focusedField) { _, newValue in
                                        if newValue != .coefficient {
                                            viewModel.hideCoefficientSuggestions()
                                            if let val = Double(viewModel.coefficient) {
                                                viewModel.coefficient = String(format: "%.2f", val)
                                            }
                                        }
                                    }
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 6)
                                            .stroke(coefficientInvalid ? Color.red : Color.clear, lineWidth: 1.5)
                                    )
                                
                                Text(LocalizedStringKey("standardRatio"))
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                            StringAutoCompleteView(
                                manager: viewModel.coefficientAutoCompleteManager,
                                onSelect: { suggestion in
                                    viewModel.selectCoefficientSuggestion(suggestion)
                                    focusedField = nil
                                },
                                onDismiss: {
                                    viewModel.hideCoefficientSuggestions()
                                }
                            )
                            .zIndex(1)
                        }
                        
                        if coefficientInvalid {
                            Text(LocalizedStringKey("coefficientInvalidHint"))
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(LocalizedStringKey("processType"))
                            .font(.headline)
                        
                        Picker(LocalizedStringKey("processType"), selection: $viewModel.isPushMode) {
                            Text(LocalizedStringKey("pull")).tag(false)
                            Text(LocalizedStringKey("push")).tag(true)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(LocalizedStringKey("numberOfSteps"))
                            .font(.headline)
                        
                        HStack {
                            Stepper(value: $viewModel.pushSteps, in: 1...5) {
                                Text("\(viewModel.pushSteps)")
                                    .font(.title2)
                                    .fontWeight(.medium)
                            }
                            
                            Spacer()
                            
                            Text(LocalizedStringKey("from1to5"))
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(LocalizedStringKey("temperature"))
                            .font(.headline)
                        
                        Button(action: {
                            focusedField = nil
                            showTemperaturePicker = true
                        }) {
                            HStack {
                                Text("\(viewModel.temperature)°C")
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                                    .font(.caption)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                
                // Inline results — показываются сразу при наличии валидных данных
                if !viewModel.pushResults.isEmpty {
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(LocalizedStringKey("results"))
                                .font(.headline)
                            
                            Spacer()
                            
                            let temperatureMultiplier = viewModel.getTemperatureMultiplier()
                            if temperatureMultiplier != 1.0 {
                                Text("×\(String(format: "%.2f", temperatureMultiplier))")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        let base = viewModel.pushResults.first
                        let calculated = viewModel.pushResults.last
                        
                        if let base = base {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("+0")
                                        .monospacedBodyStyle()
                                    Text(base.formattedTime)
                                        .monospacedTitleStyle()
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                
                                if isFromStageEditor {
                                    Button(action: { saveCalculatedTime(result: base) }) {
                                        HStack {
                                            Image(systemName: "checkmark")
                                            Text(LocalizedStringKey("save"))
                                        }
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(Color.blue)
                                        .cornerRadius(8)
                                    }
                                } else {
                                    HStack(spacing: 12) {
                                        Button(action: {
                                            viewModel.startTimer(base.label, base.minutes, base.seconds)
                                            onStartTimer?(base.label, base.minutes, base.seconds)
                                        }) {
                                            Image(systemName: "timer")
                                                .primaryIconButtonStyle()
                                        }
                                        
                                        Button(action: {
                                            viewModel.selectedResult = base
                                            viewModel.showSaveDialog = true
                                        }) {
                                            Image(systemName: "square.and.arrow.down")
                                                .secondaryIconButtonStyle()
                                        }
                                    }
                                }
                            }
                            .cardStyle()
                        }
                        
                        if let calculated = calculated, base?.id != calculated.id {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(calculated.label)
                                        .monospacedBodyStyle()
                                    Text(calculated.formattedTime)
                                        .monospacedTitleStyle()
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                
                                if isFromStageEditor {
                                    Button(action: { saveCalculatedTime(result: calculated) }) {
                                        HStack {
                                            Image(systemName: "checkmark")
                                            Text(LocalizedStringKey("save"))
                                        }
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(Color.blue)
                                        .cornerRadius(8)
                                    }
                                } else {
                                    HStack(spacing: 12) {
                                        Button(action: {
                                            viewModel.startTimer(calculated.label, calculated.minutes, calculated.seconds)
                                            onStartTimer?(calculated.label, calculated.minutes, calculated.seconds)
                                        }) {
                                            Image(systemName: "timer")
                                                .primaryIconButtonStyle()
                                        }
                                        
                                        Button(action: {
                                            viewModel.selectedResult = calculated
                                            viewModel.showSaveDialog = true
                                        }) {
                                            Image(systemName: "square.and.arrow.down")
                                                .secondaryIconButtonStyle()
                                        }
                                    }
                                }
                            }
                            .cardStyle()
                        }
                    }
                }
                
                Spacer(minLength: 0)
            }
            .padding()
        }
        .navigationTitle(LocalizedStringKey("calculator"))
        .navigationBarTitleDisplayMode(.inline)
        // Добавляем обработчик нажатия вне текстовых полей для скрытия клавиатуры и автодополнения
        .onTapGesture {
            focusedField = nil
            viewModel.hideCoefficientSuggestions()
        }
        .sheet(isPresented: $viewModel.showSaveDialog) {
            if let prefillData = viewModel.createPrefillData() {
                CreateRecordView(
                    swiftDataService: swiftDataService,
                    prefillData: nil,
                    isEditing: false,
                    onUpdate: nil,
                    calculatorTemperature: prefillData.temperature,
                    calculatorCoefficient: prefillData.coefficient,
                    calculatorProcess: prefillData.process
                )
            }
        }
        .navigationDestination(isPresented: $viewModel.showTimer) {
            TimerView(
                timerLabel: viewModel.selectedTimerLabel,
                totalMinutes: viewModel.selectedTimerMinutes,
                totalSeconds: viewModel.selectedTimerSeconds
            )
        }
        .sheet(isPresented: $showTemperaturePicker) {
            TemperaturePickerView(
                temperature: $viewModel.temperature,
                onDismiss: { showTemperaturePicker = false }
            )
        }


    }
    
    // MARK: - Validation
    
    private var minutesInvalid: Bool {
        !viewModel.minutes.isEmpty && Int(viewModel.minutes) == nil
    }
    
    private var secondsInvalid: Bool {
        guard !viewModel.seconds.isEmpty else { return false }
        guard let sec = Int(viewModel.seconds) else { return true }
        return sec > 59
    }
    
    private var coefficientInvalid: Bool {
        guard !viewModel.coefficient.isEmpty else { return false }
        guard let val = Double(viewModel.coefficient) else { return true }
        return val < 0.5 || val > 4.0
    }
    
    private func saveCalculatedTime(result: ProcessStep) {
        let totalSeconds = result.minutes * 60 + result.seconds
        
        NotificationCenter.default.post(
            name: Notification.Name("DevelopmentCalculatedTime"),
            object: nil,
            userInfo: ["seconds": totalSeconds]
        )
        
        dismiss()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            NotificationCenter.default.post(
                name: Notification.Name("DismissCalculatorView"),
                object: nil
            )
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            NotificationCenter.default.post(
                name: Notification.Name("DismissDevelopmentSetupView"),
                object: nil
            )
        }
    }
}

// MARK: - Preview
struct CalculatorView_Previews: PreviewProvider {
    static var previews: some View {
        let container = SwiftDataPersistence.preview.modelContainer
        let githubService = GitHubDataService()
        let swiftDataService = SwiftDataService(githubDataService: githubService, modelContainer: container)
        
        ZStack {
            Color.black.ignoresSafeArea()
            CalculatorView(swiftDataService: swiftDataService, onStartTimer: { label, minutes, seconds in
                print("Start timer: \(label) \(minutes):\(seconds)")
            })
        }
        .previewDisplayName("Calculator")
    }
}