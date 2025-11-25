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
                            
                            Text(LocalizedStringKey("min"))
                            
                            TextField(LocalizedStringKey("seconds"), text: $viewModel.seconds)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.numberPad)
                                .focused($focusedField, equals: .seconds)
                                .submitLabel(.next)
                                .onSubmit {
                                    focusedField = .coefficient
                                }
                            
                            Text(LocalizedStringKey("sec"))
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
                                        }
                                    }
                                
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
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                
                Spacer()
                                
                Button(action: {
                    // Скрываем клавиатуру перед расчетом
                    focusedField = nil
                    viewModel.calculateTime()
                }) {
                    Text(LocalizedStringKey("calculateButton"))
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.isValidInput ? Color.blue : Color.gray)
                        .cornerRadius(10)
                }
                .disabled(!viewModel.isValidInput)
                
                
                
            }
            .padding()
        }
        .navigationTitle(LocalizedStringKey("calculator"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
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
        .sheet(isPresented: $viewModel.showResult) {
            if isFromStageEditor {
                // Используем специальный view для режима Staging
                StagingCalculationResultView(
                    results: viewModel.pushResults,
                    viewModel: viewModel
                )
            } else {
                // Обычный режим - показываем стандартный результат
                let base = viewModel.pushResults.first
                let calculated = viewModel.pushResults.last
                                VStack(spacing: 16) {
                        // Отступ от верхнего индикатора перетаскивания шита
                        Spacer().frame(height: 8)
                        Text(LocalizedStringKey("results"))
                            .font(.headline)
                            .padding(.top, 4)
                        
                        // Информация о температурном коэффициенте
                        let temperatureMultiplier = viewModel.getTemperatureMultiplier()
                        if temperatureMultiplier != 1.0 {
                            Text("Температурный коэффициент: ×\(String(format: "%.2f", temperatureMultiplier))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                        }
                    
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            if let base = base {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("+0")
                                            .monospacedBodyStyle()
                                        Text(base.formattedTime)
                                            .monospacedTitleStyle()
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    
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
                                            viewModel.showResult = false
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                                viewModel.showSaveDialog = true
                                            }
                                        }) {
                                            Image(systemName: "square.and.arrow.down")
                                                .secondaryIconButtonStyle()
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
                                            viewModel.showResult = false
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                                viewModel.showSaveDialog = true
                                            }
                                        }) {
                                            Image(systemName: "square.and.arrow.down")
                                                .secondaryIconButtonStyle()
                                        }
                                    }
                                }
                                .cardStyle()
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .presentationDetents([.fraction(0.33)])
                .presentationDragIndicator(.visible)
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
    
    // MARK: - Private Methods
    
    private func saveCalculatedTime() {
        // Берем первый результат (базовое время)
        if let firstResult = viewModel.pushResults.first {
            let totalSeconds = firstResult.minutes * 60 + firstResult.seconds
            
            // Отправляем уведомление с рассчитанным временем
            NotificationCenter.default.post(
                name: Notification.Name("DevelopmentCalculatedTime"),
                object: nil,
                userInfo: ["seconds": totalSeconds]
            )
            
            // Закрываем калькулятор
            dismiss()
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