//
//  SwiftDataPersistence.swift
//  AnalogProcess
//
//  Created by Maxim Eliseyev on 11.08.2025.
//

import SwiftData
import SwiftUI

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
        print("🚀 Starting SwiftData initialization (inMemory: \(inMemory))")

        // Trying to initialize the main configuration
        do {
            // Using a unified configuration manager
            let (schema, modelConfiguration) = SwiftDataConfigurationManager.createPrimaryConfiguration(inMemory: inMemory)

            // Validating the schema
            let missingEntities = SwiftDataConfigurationManager.validateSchema(schema)
            if !missingEntities.isEmpty {
                print("⚠️ Schema validation warning - missing entities: \(missingEntities)")
            }

            print("📋 Using schema v1.1 with entities: \(SwiftDataSchemas.entityNames(for: schema))")
            print(inMemory ? "🔧 Using in-memory configuration" : "💿 Using on-disk storage")

            self.modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
            return  // Successful initialization
        } catch {
            print("SwiftData initialization failed: \(error)")

            // Detailed error analysis
            if let swiftDataError = error as? SwiftDataError {
                print("SwiftData error details: \(swiftDataError)")
                print("SwiftData error localizedDescription: \(swiftDataError.localizedDescription)")
            }

            // Checking if the error is related to the models
            print("🔍 Checking schema before fallback:")
            let currentSchema = SwiftDataSchemas.current
            for entity in currentSchema.entities {
                print("   - Entity: \(entity.name)")
            }

            // Using a strategic fallback approach
            let recoveryStrategies: [SwiftDataRecoveryStrategy] = [
                .resetDatabase,  // First, try to reset the database with the full schema
                .useMemory,      // Then in-memory with the full schema
                .useMinimalSchema, // Then the minimal schema
                .useJournalOnly    // And finally, only the journal
            ]

            for strategy in recoveryStrategies {
                print("⚠️ Attempting recovery strategy: \(strategy.description)")

                do {
                    // Special handling for resetDatabase
                    if strategy == .resetDatabase {
                        let url = URL.applicationSupportDirectory.appending(path: "default.store")
                        if FileManager.default.fileExists(atPath: url.path()) {
                            try FileManager.default.removeItem(at: url)
                            print("🗑️ Removed corrupted database")
                        }
                    }

                    let (schema, configuration) = SwiftDataConfigurationManager.createFallbackConfiguration(strategy: strategy)
                    let container = try ModelContainer(for: schema, configurations: [configuration])

                    print("✅ Recovery successful using \(strategy.description)")
                    print("📋 Using entities: \(SwiftDataSchemas.entityNames(for: schema))")

                    self.modelContainer = container
                    return  // Successful recovery

                } catch {
                    print("❌ Recovery strategy '\(strategy.description)' failed: \(error)")
                    continue
                }
            }

        // If all recovery strategies have failed, create an emergency configuration
        print("💥 All recovery strategies failed - using emergency configuration")
        let (emergencySchema, emergencyConfig) = SwiftDataConfigurationManager.createFallbackConfiguration(strategy: .useMemory)
        do {
            self.modelContainer = try ModelContainer(for: emergencySchema, configurations: [emergencyConfig])
            print("🆘 Emergency in-memory configuration successful")
        } catch {
            // Last attempt with a minimal schema
            let minimalSchema = Schema([SwiftDataJournalRecord.self])
            let minimalConfig = ModelConfiguration(schema: minimalSchema, isStoredInMemoryOnly: true)
            self.modelContainer = try! ModelContainer(for: minimalSchema, configurations: [minimalConfig])
            print("🆘🆘 Ultra-minimal emergency configuration - journal only")
        }
        }
    }
}
