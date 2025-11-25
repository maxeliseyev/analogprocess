//
//  SwiftDataDevelopmentSetupView.swift
//  AnalogProcess
//
//  Created by Maxim Eliseyev on 11.08.2025.
//

import SwiftUI
import SwiftData


struct DevelopmentSetupView: View {
    @StateObject var viewModel: DevelopmentSetupViewModel
    @Environment(\.dismiss) private var dismiss
    
    let isFromStageEditor: Bool
    let stageType: StageType?
    
    init(viewModel: DevelopmentSetupViewModel, isFromStageEditor: Bool = false, stageType: StageType? = nil) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.isFromStageEditor = isFromStageEditor
        self.stageType = stageType
    }
    
    // MARK: - Computed Views
    private var mainContentView: some View {
        VStack(spacing: 30) {
            modeSelectionPicker
            DevelopmentParametersView(viewModel: viewModel)
            calculatedTimeSection

            if !isFromStageEditor {
                Spacer()
            }
        }
    }
    
    @ViewBuilder
    private var modeSelectionPicker: some View {
        if !isFromStageEditor {
            Picker("Process Mode", selection: $viewModel.selectedMode) {
                ForEach(ProcessMode.allCases, id: \.self) { mode in
                    Text(mode.localizedName).tag(mode)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal, 20)
            .onChange(of: viewModel.selectedMode) { _, newMode in
                viewModel.updateMode(newMode)
            }
        }
    }
    
    @ViewBuilder
    private var calculatedTimeSection: some View {
        if let calculatedTime = viewModel.calculatedTime {
            if isFromStageEditor {
                VStack {
                    stageEditorCalculatorButton(calculatedTime: calculatedTime)
                    saveButtonSection
                }
            } else {
                CalculatedTimeSection(
                    time: calculatedTime,
                    temperature: viewModel.temperature,
                    filmName: viewModel.selectedFilmName,
                    developerName: viewModel.selectedMode == .developing ? viewModel.selectedDeveloperName : "Fixing",
                    onCalculatorTap: { handleCalculatorTap(calculatedTime: calculatedTime) },
                    onTimerTap: { handleTimerTap(calculatedTime: calculatedTime) }
                )
            }
        }
    }
    
    private func stageEditorCalculatorButton(calculatedTime: Int) -> some View {
        VStack(spacing: 8) {
            Button(action: { handleCalculatorTap(calculatedTime: calculatedTime) }) {
                HStack {
                    Image(systemName: "plus.forwardslash.minus")
                        .font(.system(size: 18, design: .monospaced))
                    Text("\(calculatedTime / 60):\(String(format: "%02d", calculatedTime % 60))")
                        .font(.system(size: 18, design: .monospaced))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .padding(.horizontal, 16)
                .background(.orange)
                .cornerRadius(12)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    @ViewBuilder
    private var saveButtonSection: some View {
        if let calculatedTime = viewModel.calculatedTime {
            Button(action: {
                NotificationCenter.default.post(
                    name: Notification.Name("DevelopmentCalculatedTime"),
                    object: nil,
                    userInfo: ["seconds": calculatedTime]
                )
                dismiss()
            }) {
                HStack {
                    Image(systemName: "checkmark")
                    Text(LocalizedStringKey("save"))
                        .font(.headline)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(.blue)
                .cornerRadius(10)
            }
            .padding(.horizontal, 16)
        }
    }

    // MARK: - Helper Methods
    private func handleCalculatorTap(calculatedTime: Int) {
        NotificationCenter.default.post(
            name: Notification.Name("DevelopmentCalculatedTime"),
            object: nil,
            userInfo: ["seconds": calculatedTime]
        )
        viewModel.navigateToCalculator = true
    }
    
    private func handleTimerTap(calculatedTime: Int) {
        NotificationCenter.default.post(
            name: Notification.Name("DevelopmentCalculatedTime"),
            object: nil,
            userInfo: ["seconds": calculatedTime]
        )
        viewModel.navigateToTimer = true
    }
    
    // MARK: - Sheet Views
    private var filmPickerSheet: some View {
        FilmPickerView(
            films: viewModel.films,
            selectedFilm: Binding(
                get: { viewModel.selectedFilm },
                set: { viewModel.selectedFilm = $0 }
            ),
            iso: Binding(
                get: { Int32(viewModel.iso) },
                set: { viewModel.iso = Int($0) }
            ),
            onDismiss: { viewModel.showFilmPicker = false },
            onFilmSelected: { film in
                viewModel.selectFilm(film)
            }
        )
    }
    
    private var developerPickerSheet: some View {
        DeveloperPickerView(
            developers: viewModel.developers,
            selectedDeveloper: Binding(
                get: { viewModel.selectedDeveloper },
                set: { viewModel.selectedDeveloper = $0 }
            ),
            selectedDilution: $viewModel.selectedDilution,
            onDismiss: { viewModel.showDeveloperPicker = false },
            onDeveloperSelected: { developer in
                viewModel.selectDeveloper(developer)
            }
        )
    }
    
    private var dilutionPickerSheet: some View {
        DilutionPickerView(
            dilutions: viewModel.dilutionOptions,
            selectedDilution: $viewModel.selectedDilution,
            onDismiss: { viewModel.showDilutionPicker = false },
            isDisabled: viewModel.selectedFilm == nil || viewModel.selectedDeveloper == nil || viewModel.isDilutionSelectionLocked,
            onDilutionSelected: { dilution in
                viewModel.selectDilution(dilution)
            }
        )
    }
    
    private var fixerPickerSheet: some View {
        FixerPickerView(
            swiftDataFixers: viewModel.fixers,
            selectedSwiftDataFixer: Binding(
                get: { viewModel.selectedFixer },
                set: { viewModel.selectedFixer = $0 }
            ),
            onDismiss: { viewModel.showFixerPicker = false },
            onSwiftDataFixerSelected: { fixer in
                viewModel.selectFixer(fixer)
            }
        )
    }
    
    private var isoPickerSheet: some View {
        ISOPickerView(
            iso: Binding(
                get: { Int32(viewModel.iso) },
                set: { viewModel.iso = Int($0) }
            ),
            onDismiss: { viewModel.showISOPicker = false },
            availableISOs: viewModel.isoOptions
        )
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground).ignoresSafeArea()
                mainContentView
            }
        }
        .sheet(isPresented: $viewModel.showFilmPicker) {
            filmPickerSheet
        }
        .sheet(isPresented: $viewModel.showDeveloperPicker) {
            developerPickerSheet
        }
        .sheet(isPresented: $viewModel.showDilutionPicker) {
            dilutionPickerSheet
        }
        .sheet(isPresented: $viewModel.showFixerPicker) {
            fixerPickerSheet
        }
        .sheet(isPresented: $viewModel.showISOPicker) {
            isoPickerSheet
        }
        .navigationDestination(isPresented: $viewModel.navigateToCalculator) {
            if let calculatedTime = viewModel.calculatedTime {
                CalculatorView(
                    swiftDataService: viewModel.dataService,
                    initialTime: calculatedTime,
                    initialTemperature: viewModel.temperature,
                    isFromStageEditor: isFromStageEditor
                )
            }
        }
        .navigationDestination(isPresented: $viewModel.navigateToTimer) {
            if let calculatedTime = viewModel.calculatedTime {
                let minutes = calculatedTime / 60
                let seconds = calculatedTime % 60
                let timerLabel = "\(viewModel.selectedFilmName) / \(viewModel.selectedDeveloperName)"
                
                TimerView(
                    timerLabel: timerLabel,
                    totalMinutes: minutes,
                    totalSeconds: seconds
                )
            }
        }
        .navigationTitle(LocalizedStringKey("developmentSetup"))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.reloadData()
            
            // Устанавливаем правильный режим при открытии из редактора стадии
            if isFromStageEditor, let stageType = stageType {
                switch stageType {
                case .fixer:
                    viewModel.selectedMode = .fixer
                case .develop:
                    viewModel.selectedMode = .developing
                default:
                    break
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("DismissCalculatorView"))) { _ in
            // Закрываем калькулятор и возвращаемся к DevelopmentSetupView
            viewModel.navigateToCalculator = false
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("DismissDevelopmentSetupView"))) { _ in
            // Закрываем DevelopmentSetupView и возвращаемся к StageEditorSheet
            if isFromStageEditor {
                dismiss()
            }
        }
    }
}

struct DevelopmentSetupView_Previews: PreviewProvider {
    @MainActor static var previews: some View {
        let container = SwiftDataPersistence.preview.modelContainer
        let githubService = GitHubDataService()
        let swiftDataService = SwiftDataService(githubDataService: githubService, modelContainer: container)
        let viewModel = DevelopmentSetupViewModel(dataService: swiftDataService)
        
        return DevelopmentSetupView(viewModel: viewModel)
    }
}