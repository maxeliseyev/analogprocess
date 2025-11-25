//
//  SwiftDataSchemas.swift
//  AnalogProcess
//
//  Created for schema versioning and migration management
//

import SwiftData
import Foundation

/// Manages SwiftData schema versions
enum SwiftDataSchemas {

    /// Version 1.0 - base schema without AgitationModeData
    static var v1_0: Schema {
        Schema([
            SwiftDataFilm.self,
            SwiftDataDeveloper.self,
            SwiftDataJournalRecord.self,
        ])
    }

    /// Version 1.1 - added support for custom agitation modes
    static var v1_1: Schema {
        Schema([
            SwiftDataFilm.self,
            SwiftDataDeveloper.self,
            SwiftDataJournalRecord.self,
            AgitationModeData.self,
        ])
    }

    /// Version 1.3 - normalized structure for AgitationModeData with a separate rules table
    static var v1_3: Schema {
        Schema([
            SwiftDataFilm.self,
            SwiftDataDeveloper.self,
            SwiftDataJournalRecord.self,
            AgitationModeData.self,
            AgitationRuleData.self,
        ])
    }

    /// Version 1.2 - full schema with all models
    static var v1_2: Schema {
        Schema([
            SwiftDataFilm.self,
            SwiftDataDeveloper.self,
            SwiftDataJournalRecord.self,
            AgitationModeData.self,
            SwiftDataDevelopmentTime.self,
            SwiftDataFixer.self,
            SwiftDataTemperatureMultiplier.self,
        ])
    }

    /// Version 1.4 - full schema with normalized agitation rules and presets
    static var v1_4: Schema {
        Schema([
            SwiftDataFilm.self,
            SwiftDataDeveloper.self,
            SwiftDataJournalRecord.self,
            AgitationModeData.self,
            AgitationRuleData.self,
            SwiftDataDevelopmentTime.self,
            SwiftDataFixer.self,
            SwiftDataTemperatureMultiplier.self,
            SwiftDataProcessPreset.self,
            SwiftDataStagingStage.self,
        ])
    }

    /// Current active schema - using v1.4 with presets
    static var current: Schema {
        return v1_4
    }

    /// Minimal schema for critical situations
    static var minimal: Schema {
        Schema([
            SwiftDataJournalRecord.self,
            AgitationModeData.self,
            AgitationRuleData.self,
        ])
    }

    /// Absolutely basic schema with only the journal
    static var journalOnly: Schema {
        Schema([
            SwiftDataJournalRecord.self,
        ])
    }

    /// Get a list of all entities as strings for logging
    static func entityNames(for schema: Schema) -> [String] {
        return schema.entities.map { $0.name }
    }
}

/// Recovery strategies for schema errors
enum SwiftDataRecoveryStrategy: CaseIterable {
    case useMemory
    case resetDatabase
    case useMinimalSchema
    case useJournalOnly
    case fatal

    var description: String {
        switch self {
        case .useMemory:
            return "Switching to in-memory storage"
        case .resetDatabase:
            return "Resetting the database and creating a new one"
        case .useMinimalSchema:
            return "Using minimal schema"
        case .useJournalOnly:
            return "Using only the journal"
        case .fatal:
            return "Critical error"
        }
    }

    var schema: Schema {
        switch self {
        case .useMemory, .resetDatabase:
            return SwiftDataSchemas.current
        case .useMinimalSchema:
            return SwiftDataSchemas.minimal
        case .useJournalOnly:
            return SwiftDataSchemas.journalOnly
        case .fatal:
            return SwiftDataSchemas.journalOnly // Fallback, although it should not be used
        }
    }

    var isInMemory: Bool {
        switch self {
        case .useMemory:
            return true
        default:
            return false
        }
    }
}

/// Manager for unified creation of SwiftData configurations
struct SwiftDataConfigurationManager {

    /// Creates the main configuration for local storage
    static func createPrimaryConfiguration(inMemory: Bool = false) -> (Schema, ModelConfiguration) {
        let schema = SwiftDataSchemas.current

        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: inMemory)

        return (schema, configuration)
    }

    /// Creates a fallback configuration for recovery
    static func createFallbackConfiguration(strategy: SwiftDataRecoveryStrategy) -> (Schema, ModelConfiguration) {
        let schema = strategy.schema

        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: strategy.isInMemory
        )

        return (schema, configuration)
    }

    /// Creates a test configuration (always in-memory)
    static func createTestConfiguration() -> (Schema, ModelConfiguration) {
        let schema = SwiftDataSchemas.minimal // Using minimal schema for tests

        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true
        )

        return (schema, configuration)
    }

    /// Validates the schema for completeness
    static func validateSchema(_ schema: Schema) -> [String] {
        var missingEntities: [String] = []

        let expectedEntities = [
            "SwiftDataFilm",
            "SwiftDataDeveloper",
            "SwiftDataJournalRecord",
            "AgitationModeData",
            "AgitationRuleData"
        ]

        let currentEntities = schema.entities.map { $0.name }

        for expected in expectedEntities {
            if !currentEntities.contains(expected) {
                missingEntities.append(expected)
            }
        }

        return missingEntities
    }

    /// More detailed schema validation with warnings
    static func performDetailedValidation(_ schema: Schema) -> SchemaValidationResult {
        var warnings: [String] = []
        var errors: [String] = []

        let expectedEntities = [
            "SwiftDataFilm",
            "SwiftDataDeveloper",
            "SwiftDataJournalRecord",
            "AgitationModeData",
            "AgitationRuleData",
            "SwiftDataDevelopmentTime",
            "SwiftDataFixer",
            "SwiftDataTemperatureMultiplier"
        ]

        let currentEntities = schema.entities.map { $0.name }

        // Checking critical entities
        let criticalEntities = ["SwiftDataJournalRecord"]
        for critical in criticalEntities {
            if !currentEntities.contains(critical) {
                errors.append("Missing critical entity: \(critical)")
            }
        }

        // Checking optional entities
        let optionalEntities = expectedEntities.filter { !criticalEntities.contains($0) }
        for optional in optionalEntities {
            if !currentEntities.contains(optional) {
                warnings.append("Missing optional entity: \(optional)")
            }
        }

        // Checking for unexpected entities
        for current in currentEntities {
            if !expectedEntities.contains(current) {
                warnings.append("Unexpected entity found: \(current)")
            }
        }

        return SchemaValidationResult(
            isValid: errors.isEmpty,
            errors: errors,
            warnings: warnings,
            entityCount: currentEntities.count
        )
    }

    /// Compares two schemas for compatibility
    static func compareSchemas(_ schema1: Schema, _ schema2: Schema) -> SchemaCompatibilityResult {
        let entities1 = Set(schema1.entities.map { $0.name })
        let entities2 = Set(schema2.entities.map { $0.name })

        let added = entities2.subtracting(entities1)
        let removed = entities1.subtracting(entities2)
        let common = entities1.intersection(entities2)

        let isCompatible = removed.isEmpty // Schemas are compatible if nothing is removed

        return SchemaCompatibilityResult(
            isCompatible: isCompatible,
            addedEntities: Array(added),
            removedEntities: Array(removed),
            commonEntities: Array(common)
        )
    }
}

/// Schema validation result
struct SchemaValidationResult {
    let isValid: Bool
    let errors: [String]
    let warnings: [String]
    let entityCount: Int

    var hasWarnings: Bool { !warnings.isEmpty }
    var hasErrors: Bool { !errors.isEmpty }
}

/// Schema comparison result
struct SchemaCompatibilityResult {
    let isCompatible: Bool
    let addedEntities: [String]
    let removedEntities: [String]
    let commonEntities: [String]

    var hasMigration: Bool { !addedEntities.isEmpty || !removedEntities.isEmpty }
}

