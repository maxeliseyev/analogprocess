//
//  SwiftDataPersistenceTest.swift
//  AnalogProcess
//
//  Created by Maxim Eliseyev on 25.09.2025.
//

import XCTest
import SwiftData
@testable import AnalogProcess

class SwiftDataPersistenceTests: XCTestCase {

    var modelContainer: ModelContainer!

    @MainActor
    override func setUp() {
        super.setUp()
        modelContainer = TestDataFactory.createContainerWithSampleData()
    }

    override func tearDown() {
        modelContainer = nil
        super.tearDown()
    }

    @MainActor
    func testSampleDataIsLoaded() {
        let context = modelContainer.mainContext
        
        let filmDescriptor = FetchDescriptor<SwiftDataFilm>()
        let films = try! context.fetch(filmDescriptor)
        XCTAssertEqual(films.count, 1)
        XCTAssertEqual(films.first?.name, "Ilford HP5+")
        
        let devDescriptor = FetchDescriptor<SwiftDataDeveloper>()
        let developers = try! context.fetch(devDescriptor)
        XCTAssertEqual(developers.count, 1)
        XCTAssertEqual(developers.first?.name, "Kodak D-76")
        
        let timeDescriptor = FetchDescriptor<SwiftDataDevelopmentTime>()
        let times = try! context.fetch(timeDescriptor)
        XCTAssertEqual(times.count, 1)
        XCTAssertEqual(times.first?.time, 540)
    }
}
