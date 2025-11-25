import Foundation
import SwiftData

/// A structure to hold a preset configuration for a development process.
struct ProcessPreset {
    let name: String
    let description: String
    let stages: [StagingStage]
}

/// A service to provide predefined process presets.
@MainActor
class PresetService: ObservableObject {
    
    private let swiftDataService: SwiftDataService
    
    @Published var presets: [ProcessPreset] = []
    
    init(swiftDataService: SwiftDataService) {
        self.swiftDataService = swiftDataService
        loadPresets()
    }
    
    func loadPresets() {
        let storedPresets = swiftDataService.getProcessPresets()
        if storedPresets.isEmpty {
            // No presets in DB yet - they will be synced from GitHub
            // during the next sync cycle in SwiftDataService
            self.presets = []
        } else {
            self.presets = storedPresets.map { $0.toProcessPreset() }
        }
    }

    
    static func createDefaultPresets() -> [ProcessPreset] {
        // Fallback empty presets if JSON loading fails completely
        return []
    }

    nonisolated static func getAvailablePresets() -> [ProcessPreset] {
        // This is used when PresetService instance is not available
        // Since presets are now loaded from GitHub, return empty array
        // The proper way is to inject PresetService as dependency
        return []
    }
}