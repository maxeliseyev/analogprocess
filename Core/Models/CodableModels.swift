//
//  CodableModels.swift
//  AnalogProcess
//
//  Created by Maxim Eliseyev on 12.07.2025.
//

import Foundation

// MARK: - GitHub Data Models (without id field)
public struct GitHubFilmData: Codable {
    public let name: String
    public let manufacturer: String
    public let defaultISO: Int
    public let type: String
    
    public init(name: String, manufacturer: String, defaultISO: Int, type: String) {
        self.name = name
        self.manufacturer = manufacturer
        self.defaultISO = defaultISO
        self.type = type
    }
}

public struct GitHubDeveloperData: Codable {
    public let name: String
    public let manufacturer: String
    public let type: String
    public let defaultDilution: String?
    
    public init(name: String, manufacturer: String, type: String, defaultDilution: String? = nil) {
        self.name = name
        self.manufacturer = manufacturer
        self.type = type
        self.defaultDilution = defaultDilution
    }
}

public struct GitHubFixerData: Codable {
    public let name: String
    public let type: FixerType
    public let time: Int32
    public let warning: String?
    
    public init(name: String, type: FixerType, time: Int32, warning: String? = nil) {
        self.name = name
        self.type = type
        self.time = time
        self.warning = warning
    }
}

// MARK: - Film Model
public struct FilmData: Codable, Identifiable {
    public let name: String
    public let brand: String
    public let iso: Int
    public let type: String
    public let description: String?
    
    // Computed property for Identifiable conformance
    public var id: String {
        // This will be set by the decoding context
        return ""
    }
    
    public init(name: String, brand: String, iso: Int, type: String, description: String? = nil) {
        self.name = name
        self.brand = brand
        self.iso = iso
        self.type = type
        self.description = description
    }
    
    // Backward compatibility
    public var manufacturer: String { brand }
    public var defaultISO: Int { iso }
}

// MARK: - Developer Model
public struct DeveloperData: Codable, Identifiable {
    public let name: String
    public let brand: String
    public let type: String
    public let description: String?
    public let dilution: String?
    
    // Computed property for Identifiable conformance
    public var id: String {
        // This will be set by the decoding context
        return ""
    }
    
    public init(name: String, brand: String, type: String, description: String? = nil, dilution: String? = nil) {
        self.name = name
        self.brand = brand
        self.type = type
        self.description = description
        self.dilution = dilution
    }
    
    // Backward compatibility
    public var manufacturer: String { brand }
    public var defaultDilution: String? { dilution }
}

// MARK: - Fixer Model
public struct FixerData: Codable, Identifiable {
    public let name: String
    public let type: FixerType
    public let time: Int
    public let warning: String?
    
    // Computed property for Identifiable conformance
    public var id: String {
        // This will be set by the decoding context
        return ""
    }
    
    public init(name: String, type: FixerType, time: Int, warning: String? = nil) {
        self.name = name
        self.type = type
        self.time = time
        self.warning = warning
    }
}

// MARK: - Fixer Type Enum
public enum FixerType: String, Codable, CaseIterable {
    case rapid = "rapid"
    case acid = "acid"
    case neutral = "neutral"
    
    public var displayName: String {
        switch self {
        case .rapid:
            return "Быстрый фиксаж"
        case .acid:
            return "Кислый фиксаж"
        case .neutral:
            return "Нейтральный фиксаж"
        }
    }
    
    public var localizedName: String {
        switch self {
        case .rapid:
            return "rapidFixer"
        case .acid:
            return "acidFixer"
        case .neutral:
            return "neutralFixer"
        }
    }
}

// MARK: - Development Time Model
public struct DevelopmentTimeData: Codable {
    public let filmId: String
    public let developerId: String
    public let iso: Int
    public let temperature: Int
    public let timeMinutes: Int
    public let timeSeconds: Int
    
    public init(filmId: String, developerId: String, iso: Int, temperature: Int, timeMinutes: Int, timeSeconds: Int) {
        self.filmId = filmId
        self.developerId = developerId
        self.iso = iso
        self.temperature = temperature
        self.timeMinutes = timeMinutes
        self.timeSeconds = timeSeconds
    }
}

// MARK: - Temperature Multiplier Model
public struct TemperatureMultiplierData: Codable {
    public let temperature: Int
    public let multiplier: Double
    
    public init(temperature: Int, multiplier: Double) {
        self.temperature = temperature
        self.multiplier = multiplier
    }
}

// MARK: - Process Step Model
public struct ProcessStep: Codable, Identifiable {
    public let id: UUID
    public let label: String
    public let minutes: Int
    public let seconds: Int
    
    public init(label: String, minutes: Int, seconds: Int) {
        self.id = UUID()
        self.label = label
        self.minutes = minutes
        self.seconds = seconds
    }
    
    public var totalSeconds: Int {
        return minutes * 60 + seconds
    }
    
    public var formattedTime: String {
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - GitHub Agitation Models
public struct GitHubAgitationRuleCondition: Codable {
    public let type: String
    public let values: [Int]

    public init(type: String, values: [Int]) {
        self.type = type
        self.values = values
    }
}

public struct GitHubAgitationRule: Codable {
    public let id: String
    public let priority: Int
    public let condition: GitHubAgitationRuleCondition
    public let action: String
    public let parameters: [String: Int]

    public init(id: String, priority: Int, condition: GitHubAgitationRuleCondition, action: String, parameters: [String: Int]) {
        self.id = id
        self.priority = priority
        self.condition = condition
        self.action = action
        self.parameters = parameters
    }
}

public struct GitHubAgitationModeData: Codable {
    public let name: String
    public let localizedNameKey: String
    public let description: String
    public let isBuiltIn: Bool
    public let rules: [GitHubAgitationRule]

    public init(name: String, localizedNameKey: String, description: String, isBuiltIn: Bool, rules: [GitHubAgitationRule]) {
        self.name = name
        self.localizedNameKey = localizedNameKey
        self.description = description
        self.isBuiltIn = isBuiltIn
        self.rules = rules
    }
}

public struct GitHubAgitationResponse: Codable {
    public let version: String
    public let updated: String
    public let modes: [String: GitHubAgitationModeData]
    public let enums: GitHubAgitationEnums?
    // Schema игнорируется при декодировании, так как содержит сложную структуру

    public init(version: String, updated: String, modes: [String: GitHubAgitationModeData], enums: GitHubAgitationEnums? = nil) {
        self.version = version
        self.updated = updated
        self.modes = modes
        self.enums = enums
    }

    private enum CodingKeys: String, CodingKey {
        case version, updated, modes, enums
        // schema намеренно исключена
    }
}

public struct GitHubAgitationEnums: Codable {
    public let agitationActions: [String]
    public let conditionTypes: [String]

    private enum CodingKeys: String, CodingKey {
        case agitationActions = "agitation_actions"
        case conditionTypes = "condition_types"
    }

    public init(agitationActions: [String], conditionTypes: [String]) {
        self.agitationActions = agitationActions
        self.conditionTypes = conditionTypes
    }
}

// MARK: - GitHub Data Response Models
public struct GitHubDataResponse: Codable {
    public let films: [String: GitHubFilmData]
    public let developers: [String: GitHubDeveloperData]
    public let fixers: [String: GitHubFixerData]
    public let developmentTimes: [String: [String: [String: [String: Int]]]]
    public let temperatureMultipliers: [String: Double]
    public let agitationModes: [String: GitHubAgitationModeData]
    
   let processPresets: [GitHubProcessPreset]

    init(films: [String: GitHubFilmData], developers: [String: GitHubDeveloperData], fixers: [String: GitHubFixerData], developmentTimes: [String: [String: [String: [String: Int]]]], temperatureMultipliers: [String: Double], agitationModes: [String: GitHubAgitationModeData], processPresets: [GitHubProcessPreset]) {
        self.films = films
        self.developers = developers
        self.fixers = fixers
        self.developmentTimes = developmentTimes
        self.temperatureMultipliers = temperatureMultipliers
        self.agitationModes = agitationModes
        self.processPresets = processPresets
    }
}
