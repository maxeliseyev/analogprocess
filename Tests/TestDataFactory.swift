//
//  TestDataFactory.swift
//  AnalogProcess
//
//  Created by Maxim Eliseyev on 25.09.2025.
//

import Foundation
import SwiftData
@testable import AnalogProcess

class TestDataFactory {
    
    @MainActor
    static func createSampleData(modelContext: ModelContext) {
        let film = SwiftDataFilm()
        film.id = "test-film"
        film.name = "Ilford HP5+"
        film.manufacturer = "Ilford"
        film.type = "Black & White"
        film.defaultISO = 400

        let developer = SwiftDataDeveloper()
        developer.id = "test-developer"
        developer.name = "Kodak D-76"
        developer.manufacturer = "Kodak"
        developer.type = "powder"
        developer.defaultDilution = "1+1"
        
        let developmentTime = SwiftDataDevelopmentTime()
        developmentTime.dilution = "1+1"
        developmentTime.iso = 400
        developmentTime.time = 540
        developmentTime.developer = developer
        developmentTime.film = film
        
        modelContext.insert(film)
        modelContext.insert(developer)
        modelContext.insert(developmentTime)
        
        do {
            try modelContext.save()
        } catch {
            Logger.log(.error, "Failed to save sample data: \(error)")
        }
    }
    
    @MainActor
    static func createContainerWithSampleData() -> ModelContainer {
        let (schema, config) = SwiftDataConfigurationManager.createTestConfiguration()
        do {
            let container = try ModelContainer(for: schema, configurations: [config])
            createSampleData(modelContext: container.mainContext)
            return container
        } catch {
            fatalError("Failed to create test container with sample data: \(error)")
        }
    }
}
