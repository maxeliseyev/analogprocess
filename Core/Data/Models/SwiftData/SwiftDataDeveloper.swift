//
//  SwiftDataDeveloper.swift
//  AnalogProcess
//
//  Created by Maxim Eliseyev on 11.08.2025.
//

import Foundation
import SwiftData


// MARK: - SwiftData Developer Model
@Model
public final class SwiftDataDeveloper: DeveloperModel {
    public var id: String = UUID().uuidString
    public var name: String = ""
    public var manufacturer: String = ""
    public var type: String = ""
    public var defaultDilution: String?
    
    // Relationships
    @Relationship(deleteRule: .cascade, inverse: \SwiftDataDevelopmentTime.developer)
    public var developmentTimes: [SwiftDataDevelopmentTime]? = []
    
    public init() {
        // Default values are set in property declarations
    }

    public init(id: String, name: String, manufacturer: String, type: String, defaultDilution: String? = nil) {
        self.id = id
        self.name = name
        self.manufacturer = manufacturer
        self.type = type
        self.defaultDilution = defaultDilution
    }
}
