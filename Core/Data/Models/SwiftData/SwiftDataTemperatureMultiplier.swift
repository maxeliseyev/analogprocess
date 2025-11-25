//
//  SwiftDataTemperatureMultiplier.swift
//  AnalogProcess
//
//  Created by Maxim Eliseyev on 11.08.2025.
//

import Foundation
import SwiftData

// MARK: - SwiftData TemperatureMultiplier Model
@Model
public final class SwiftDataTemperatureMultiplier: TemperatureModel {
    @Attribute(.unique) public var id: String = UUID().uuidString
    public var temperature: Int
    public var multiplier: Double
    
    public init(temperature: Int, multiplier: Double) {
        self.temperature = temperature
        self.multiplier = multiplier
    }
}