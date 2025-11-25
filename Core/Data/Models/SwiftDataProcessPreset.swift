//
//  SwiftDataProcessPreset.swift
//  AnalogProcess
//
//  Created by Maxim Eliseyev on 25.09.2025.
//

import Foundation
import SwiftData

@Model
final class SwiftDataProcessPreset {
    @Attribute(.unique) var name: String
    var presetDescription: String
    @Relationship(deleteRule: .cascade) var stages: [SwiftDataStagingStage] = []

    init(name: String, description: String, stages: [SwiftDataStagingStage] = []) {
        self.name = name
        self.presetDescription = description
        self.stages = stages
    }
}

@Model
final class SwiftDataStagingStage {
    var name: String
    var stageDescription: String
    var iconName: String
    var color: String
    var duration: TimeInterval
    var temperature: Int
    var preset: SwiftDataProcessPreset?

    init(name: String, description: String, iconName: String, color: String, duration: TimeInterval, temperature: Int) {
        self.name = name
        self.stageDescription = description
        self.iconName = iconName
        self.color = color
        self.duration = duration
        self.temperature = temperature
    }
}

extension SwiftDataProcessPreset {
    func toProcessPreset() -> ProcessPreset {
        let stages = self.stages.map { $0.toStagingStage() }
        return ProcessPreset(name: self.name, description: self.presetDescription, stages: stages)
    }
}

extension SwiftDataStagingStage {
    func toStagingStage() -> StagingStage {
        return StagingStage(name: self.name, description: self.stageDescription, iconName: self.iconName, color: self.color, duration: self.duration, temperature: self.temperature)
    }
}