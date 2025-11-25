//
//  SwiftDataJournalRecord.swift
//  AnalogProcess
//
//  Created by Maxim Eliseyev on 11.08.2025.
//

import Foundation
import SwiftData

// MARK: - SwiftData Journal Record Model
@Model
public final class SwiftDataJournalRecord {
    public var recordID: String = UUID().uuidString
    public var comment: String?
    public var date: Date?
    public var developerName: String?
    public var dilution: String?
    public var filmName: String?
    public var iso: Int32 = 400
    public var isSynced: Bool = false
    public var lastModified: Date?
    public var name: String?
    public var process: String?
    public var temperature: Int = 20
    public var time: Int32 = 0
    
    public init() {
        // Default values are set in property declarations
    }

    public init(
        recordID: String = UUID().uuidString,
        comment: String? = nil,
        date: Date? = nil,
        developerName: String? = nil,
        dilution: String? = nil,
        filmName: String? = nil,
        iso: Int32 = 400,
        isSynced: Bool = false,
        lastModified: Date? = nil,
        name: String? = nil,
        process: String? = nil,
        temperature: Int = 20,
        time: Int32 = 0
    ) {
        self.recordID = recordID
        self.comment = comment
        self.date = date
        self.developerName = developerName
        self.dilution = dilution
        self.filmName = filmName
        self.iso = iso
        self.isSynced = isSynced
        self.lastModified = lastModified
        self.name = name
        self.process = process
        self.temperature = temperature
        self.time = time
    }
}
