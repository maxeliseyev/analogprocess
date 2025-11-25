//
//  SwiftDataDevelopmentTime.swift
//  AnalogProcess
//
//  Created by Maxim Eliseyev on 11.08.2025.
//

import Foundation
import SwiftData


// MARK: - SwiftData DevelopmentTime Model
@Model
public final class SwiftDataDevelopmentTime: DevelopmentTimeModel {
    public var id: String = UUID().uuidString
    public var name: String = ""
    public var dilution: String?
    public var iso: Int32 = 400
    public var time: Int32 = 0
    
    // Relationships
    public var developer: SwiftDataDeveloper?
    public var film: SwiftDataFilm?
    
    public init() {
        // Default values are set in property declarations
    }

    public init(dilution: String?, iso: Int32, time: Int32, developer: SwiftDataDeveloper? = nil, film: SwiftDataFilm? = nil) {
        self.name = ""
        self.dilution = dilution
        self.iso = iso
        self.time = time
        self.developer = developer
        self.film = film
    }
}
