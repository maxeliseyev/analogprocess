//
//  GitHubProcessPreset.swift
//  AnalogProcess
//
//  Created by Maxim Eliseyev on 25.09.2025.
//

import Foundation

struct GitHubProcessPresetResponse: Codable {
    let presets: [GitHubProcessPreset]
}

struct GitHubProcessPreset: Codable {
    let name: String
    let description: String
    let stages: [GitHubStagingStage]
}

struct GitHubStagingStage: Codable {
    let name: String
    let description: String
    let iconName: String
    let color: String
    let duration: TimeInterval
    let temperature: Int
}
