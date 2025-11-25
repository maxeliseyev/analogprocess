//
//  SwiftDataFilm.swift
//  AnalogProcess
//
//  Created by Maxim Eliseyev on 11.08.2025.
//

import Foundation
import SwiftData


// MARK: - SwiftData Film Model
@Model
public final class SwiftDataFilm: FilmModel {
    public var id: String = UUID().uuidString
    public var name: String = ""
    public var manufacturer: String = ""
    public var type: String = ""
    public var defaultISO: Int32 = 400
    
    // Relationships
    @Relationship(deleteRule: .cascade, inverse: \SwiftDataDevelopmentTime.film)
    public var developmentTimes: [SwiftDataDevelopmentTime]? = []
    
    public init() {
        // Default values are set in property declarations
    }

    public init(id: String, name: String, manufacturer: String, type: String, defaultISO: Int32) {
        self.id = id
        self.name = name
        self.manufacturer = manufacturer
        self.type = type
        self.defaultISO = defaultISO
    }
}
