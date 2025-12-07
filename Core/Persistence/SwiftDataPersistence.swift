//
//  SwiftDataPersistence.swift
//  AnalogProcess
//
//  Created by Maxim Eliseyev on 11.08.2025.
//

import SwiftData
import SwiftUI
import os.log

struct SwiftDataPersistence {
    static let shared = SwiftDataPersistence()
    
    @MainActor
    static let preview: SwiftDataPersistence = {
        let result = SwiftDataPersistence(inMemory: true)
        let modelContext = result.modelContainer.mainContext
//        TestDataFactory.createSampleData(modelContext: modelContext)
        return result
    }()
    
    let modelContainer: ModelContainer

    init(inMemory: Bool = false) {
        Logger.logPersistence("Starting SwiftData initialization (inMemory: \(inMemory))", type: .info)

        // Trying to initialize the main configuration
        do {
            // Using a unified configuration manager
            let (schema, modelConfiguration) = SwiftDataConfigurationManager.createPrimaryConfiguration(inMemory: inMemory)

            // Validating the schema
            let missingEntities = SwiftDataConfigurationManager.validateSchema(schema)
            if !missingEntities.isEmpty {
                Logger.logPersistence("Schema validation warning - missing entities: \(missingEntities)", type: .error)
            }

            Logger.logPersistence("Using schema v1.1 with entities: \(SwiftDataSchemas.entityNames(for: schema))", type: .info)
            Logger.logPersistence(inMemory ? "Using in-memory configuration" : "Using on-disk storage", type: .info)

            self.modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
            return  // Successful initialization
        } catch {
            Logger.logPersistence("SwiftData initialization failed: \(error)", type: .error)

            // Detailed error analysis
            if let swiftDataError = error as? SwiftDataError {
                Logger.logPersistence("SwiftData error details: \(swiftDataError)", type: .error)
                Logger.logPersistence("SwiftData error localizedDescription: \(swiftDataError.localizedDescription)", type: .error)
            }

            // Checking if the error is related to the models
            Logger.logPersistence("Checking schema before fallback", type: .info)
            let currentSchema = SwiftDataSchemas.current
            for entity in currentSchema.entities {
                Logger.logPersistence("Entity: \(entity.name)", type: .debug)
            }

            // Using a strategic fallback approach
            let recoveryStrategies: [SwiftDataRecoveryStrategy] = [
                .resetDatabase,  // First, try to reset the database with the full schema
                .useMemory,      // Then in-memory with the full schema
                .useMinimalSchema, // Then the minimal schema
                .useJournalOnly    // And finally, only the journal
            ]

            for strategy in recoveryStrategies {
                Logger.logPersistence("Attempting recovery strategy: \(strategy.description)", type: .default)

                do {
                    // Special handling for resetDatabase
                    if strategy == .resetDatabase {
                        let url = URL.applicationSupportDirectory.appending(path: "default.store")
                        if FileManager.default.fileExists(atPath: url.path()) {
                            try FileManager.default.removeItem(at: url)
                            Logger.logPersistence("Removed corrupted database", type: .info)
                        }
                    }

                    let (schema, configuration) = SwiftDataConfigurationManager.createFallbackConfiguration(strategy: strategy)
                    let container = try ModelContainer(for: schema, configurations: [configuration])

                    Logger.logPersistence("Recovery successful using \(strategy.description)", type: .info)
                    Logger.logPersistence("Using entities: \(SwiftDataSchemas.entityNames(for: schema))", type: .info)

                    self.modelContainer = container
                    return  // Successful recovery

                } catch {
                    Logger.logPersistence("Recovery strategy '\(strategy.description)' failed: \(error)", type: .error)
                    continue
                }
            }

        // If all recovery strategies have failed, create an emergency configuration
        Logger.logPersistence("All recovery strategies failed - using emergency configuration", type: .error)
        let (emergencySchema, emergencyConfig) = SwiftDataConfigurationManager.createFallbackConfiguration(strategy: .useMemory)
        do {
            self.modelContainer = try ModelContainer(for: emergencySchema, configurations: [emergencyConfig])
            Logger.logPersistence("Emergency in-memory configuration successful", type: .info)
        } catch {
            // Last attempt with a minimal schema
            let minimalSchema = Schema([SwiftDataJournalRecord.self])
            let minimalConfig = ModelConfiguration(schema: minimalSchema, isStoredInMemoryOnly: true)
            self.modelContainer = try! ModelContainer(for: minimalSchema, configurations: [minimalConfig])
            Logger.logPersistence("Ultra-minimal emergency configuration - journal only", type: .error)
        }
        }
    }
}
