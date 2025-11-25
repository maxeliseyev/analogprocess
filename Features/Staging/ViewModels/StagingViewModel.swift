import Foundation
import SwiftUI
import Combine


class StagingViewModel: ObservableObject {
    @Published var allStages: [StagingStage] = []
    @Published var selectedStages: [StagingStage] = []
    @Published var selectedStage: StagingStage?
    @Published var isEditing = false

    @Published var availablePresets: [ProcessPreset] = []
    private let presetService: PresetService

    private var cancellables = Set<AnyCancellable>()

    init(presetService: PresetService) {
        self.presetService = presetService
        // Initialize with empty arrays, will be populated in setupPresetUpdates
        self.availablePresets = []
        self.allStages = []
        loadSelectedStages()
        setupBindings()

        // Schedule preset setup on main actor
        Task { @MainActor in
            await self.setupPresetUpdates()
        }
    }

    @MainActor
    private func setupPresetUpdates() async {
        // Listen for preset updates from the service
        presetService.$presets
            .receive(on: DispatchQueue.main)
            .sink { [weak self] presets in
                self?.availablePresets = presets
                if !presets.isEmpty {
                    self?.allStages = self?.createAllStagesFromPresets() ?? []
                }
            }
            .store(in: &cancellables)

        // Initialize with current presets
        self.availablePresets = presetService.presets
        self.allStages = createAllStagesFromPresets()
    }

    private func createAllStagesFromPresets() -> [StagingStage] {
        var uniqueStages: [StagingStage] = []
        var stageTypes: Set<String> = Set()

        // Collect all unique stage types from all presets
        for preset in availablePresets {
            for stage in preset.stages {
                if !stageTypes.contains(stage.name) {
                    var basicStage = stage
                    basicStage.duration = 0
                    basicStage.temperature = 20
                    uniqueStages.append(basicStage)
                    stageTypes.insert(stage.name)
                }
            }
        }

        // If no presets are available yet, return basic fallback stages
        if uniqueStages.isEmpty {
            return createFallbackStages()
        }

        return uniqueStages
    }

    private func createFallbackStages() -> [StagingStage] {
        return [
            StagingStage(name: "stagingPrebathName", description: "stagingPrebathDescription", iconName: "drop.fill", color: "blue"),
            StagingStage(name: "stagingDevelopName", description: "stagingDevelopDescription", iconName: "flask.fill", color: "orange"),
            StagingStage(name: "stagingStopBathName", description: "stagingStopBathDescription", iconName: "stop.fill", color: "red"),
            StagingStage(name: "stagingBleachName", description: "stagingBleachDescription", iconName: "flask", color: "yellow"),
            StagingStage(name: "stagingFixerName", description: "stagingFixerDescription", iconName: "shield.fill", color: "purple"),
            StagingStage(name: "stagingWashName", description: "stagingWashDescription", iconName: "drop", color: "cyan"),
            StagingStage(name: "stagingStabilizeName", description: "stagingStabilizeDescription", iconName: "leaf.fill", color: "green")
        ]
    }
    
    private func setupBindings() {
        // Автоматически сохраняем состояние при изменении selectedStages
        $selectedStages
            .sink { [weak self] stages in
                self?.saveSelectedStages()
            }
            .store(in: &cancellables)
    }
    
    func loadPreset(preset: ProcessPreset) {
        // Replace current stages with preset stages
        selectedStages = preset.stages
    }
    
    private func loadSelectedStages() {
        guard let data = UserDefaults.standard.data(forKey: AppConstants.UserDefaultsKeys.selectedStages),
              let stages = try? JSONDecoder().decode([StagingStage].self, from: data) else {
            return
        }
        selectedStages = stages
    }
    
    private func saveSelectedStages() {
        guard let data = try? JSONEncoder().encode(selectedStages) else { return }
        UserDefaults.standard.set(data, forKey: AppConstants.UserDefaultsKeys.selectedStages)
    }
    
    func addStage(_ stage: StagingStage) {
        var newStage = stage
        newStage.id = UUID()
        selectedStages.append(newStage)
    }
    
    func duplicateStage(_ stage: StagingStage) {
        var duplicatedStage = stage
        duplicatedStage.id = UUID()
        selectedStages.append(duplicatedStage)
    }
    
    func removeStage(at index: Int) {
        guard index >= 0 && index < selectedStages.count else { return }
        selectedStages.remove(at: index)
    }
    
    func updateStage(_ stage: StagingStage) {
        if let index = selectedStages.firstIndex(where: { $0.id == stage.id }) {
            selectedStages[index] = stage
        }
    }
    
    func getAvailableStages() -> [StagingStage] {
        // Возвращаем все стадии - они больше не исчезают из списка
        return allStages
    }
    
    func updateStageDuration(_ stage: StagingStage, duration: TimeInterval) {
        if let index = selectedStages.firstIndex(where: { $0.id == stage.id }) {
            selectedStages[index].duration = duration
        }
    }
    
    func updateStageTemperature(_ stage: StagingStage, temperature: Int) {
        if let index = selectedStages.firstIndex(where: { $0.id == stage.id }) {
            selectedStages[index].temperature = temperature
        }
    }
    
    func selectStage(_ stage: StagingStage) {
        selectedStage = stage
    }
    
    func getTotalDuration() -> TimeInterval {
        return selectedStages.reduce(0) { $0 + $1.duration }
    }
    
    func getEnabledStages() -> [StagingStage] {
        return selectedStages.filter { $0.isEnabled }
    }
    
    func startStagingTimer() {
        // Этот метод будет вызываться из StagingView
        // Логика показа TimerView в staging режиме находится в StagingView
    }
    
    func resetStages() {
        selectedStages = []
    }
} 
