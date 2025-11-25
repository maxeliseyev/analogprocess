import Foundation
import SwiftUI

public enum StageType: String, Codable {
    case prebath
    case develop
    case stopBath
    case bleach
    case fixer
    case wash
    case stabilize
    case unknown
}

public struct StagingStage: Identifiable, Hashable, Codable {
    public var id = UUID()
    public var name: String
    public let description: String
    public let iconName: String
    public let color: String
    public var isEnabled: Bool = true
    public var duration: TimeInterval = 0
    public var temperature: Int = 20
    // Store selected agitation preset as localization key to avoid cross-feature dependency
    public var agitationPresetKey: String? = nil

    public init(name: String, description: String, iconName: String, color: String, isEnabled: Bool = true, duration: TimeInterval = 0, temperature: Int = 20, agitationPresetKey: String? = nil) {
        self.name = name
        self.description = description
        self.iconName = iconName
        self.color = color
        self.isEnabled = isEnabled
        self.duration = duration
        self.temperature = temperature
        self.agitationPresetKey = agitationPresetKey
    }

    public var type: StageType {
        switch name {
        case "stagingDevelopName": return .develop
        case "stagingFixerName": return .fixer
        case "stagingBleachName": return .bleach
        case "stagingStopBathName": return .stopBath
        case "stagingPrebathName": return .prebath
        case "stagingWashName": return .wash
        case "stagingStabilizeName": return .stabilize
        default: return .unknown
        }
    }
    
}
