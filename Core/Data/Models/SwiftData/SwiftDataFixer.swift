//
//  SwiftDataFixer.swift
//  AnalogProcess
//
//  Created by Maxim Eliseyev on 11.08.2025.
//

import Foundation
import SwiftData


// MARK: - SwiftData Fixer Model
@Model
public final class SwiftDataFixer: FixerModel {
    @Attribute(.unique) public var id: String
    public var name: String
    public var type: String
    public var time: Int32
    public var warning: String?
    
    public init(id: String, name: String, type: String, time: Int32, warning: String? = nil) {
        self.id = id
        self.name = name
        self.type = type
        self.time = time
        self.warning = warning
    }
}
