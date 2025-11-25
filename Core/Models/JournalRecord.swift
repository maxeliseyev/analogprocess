//
//  JournalRecord.swift
//  Film Lab
//
//  Created by Maxim Eliseyev on 12.07.2025.
//

import Foundation
import SwiftData

public struct JournalRecord {
    public let id = UUID()
    public var date: Date
    public var name: String?
    public var filmName: String?
    public var developerName: String?
    public var iso: Int32?
    public var process: String?
    public var dilution: String?
    public var temperature: Int?
    public var time: Int?
    public var comment: String?
    
    public init(
        date: Date = Date(),
        name: String? = nil,
        filmName: String? = nil,
        developerName: String? = nil,
        iso: Int32? = nil,
        process: String? = nil,
        dilution: String? = nil,
        temperature: Int? = nil,
        time: Int? = nil,
        comment: String? = nil
    ) {
        self.date = date
        self.name = name
        self.filmName = filmName
        self.developerName = developerName
        self.iso = iso
        self.process = process
        self.dilution = dilution
        self.temperature = temperature
        self.time = time
        self.comment = comment
    }
    
    // MARK: - Conversion Methods

    public func toCalculationRecord(context: ModelContext) -> SwiftDataJournalRecord {
        return ModelConverter.createSwiftDataJournalRecord(from: self)
    }

    public static func fromCalculationRecord(_ record: SwiftDataJournalRecord) -> JournalRecord {
        return ModelConverter.createJournalRecord(from: record)
    }
} 
