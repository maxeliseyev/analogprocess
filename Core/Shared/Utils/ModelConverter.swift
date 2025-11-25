//
//  ModelConverter.swift
//  AnalogProcess
//
//  Created by Maxim Eliseyev on 14.01.2025.
//

import Foundation
import SwiftData

// MARK: - Generic Model Converter

/// Утилитный класс для конвертации между различными типами моделей
public final class ModelConverter {

    // MARK: - Film Conversion

    /// Создает SwiftDataFilm из GitHubFilmData
    public static func createSwiftDataFilm(id: String, from data: GitHubFilmData) -> SwiftDataFilm {
        return SwiftDataFilm(
            id: id,
            name: data.name,
            manufacturer: data.manufacturer,
            type: data.type,
            defaultISO: Int32(data.defaultISO)
        )
    }

    /// Обновляет SwiftDataFilm данными из GitHubFilmData
    public static func updateSwiftDataFilm(_ entity: SwiftDataFilm, with data: GitHubFilmData) -> Bool {
        var hasChanges = false

        if entity.name != data.name {
            entity.name = data.name
            hasChanges = true
        }
        if entity.manufacturer != data.manufacturer {
            entity.manufacturer = data.manufacturer
            hasChanges = true
        }
        if entity.type != data.type {
            entity.type = data.type
            hasChanges = true
        }
        if entity.defaultISO != Int32(data.defaultISO) {
            entity.defaultISO = Int32(data.defaultISO)
            hasChanges = true
        }

        return hasChanges
    }

    // MARK: - Developer Conversion

    /// Создает SwiftDataDeveloper из GitHubDeveloperData
    public static func createSwiftDataDeveloper(id: String, from data: GitHubDeveloperData) -> SwiftDataDeveloper {
        return SwiftDataDeveloper(
            id: id,
            name: data.name,
            manufacturer: data.manufacturer,
            type: data.type,
            defaultDilution: data.defaultDilution
        )
    }

    /// Обновляет SwiftDataDeveloper данными из GitHubDeveloperData
    public static func updateSwiftDataDeveloper(_ entity: SwiftDataDeveloper, with data: GitHubDeveloperData) -> Bool {
        var hasChanges = false

        if entity.name != data.name {
            entity.name = data.name
            hasChanges = true
        }
        if entity.manufacturer != data.manufacturer {
            entity.manufacturer = data.manufacturer
            hasChanges = true
        }
        if entity.type != data.type {
            entity.type = data.type
            hasChanges = true
        }
        if entity.defaultDilution != data.defaultDilution {
            entity.defaultDilution = data.defaultDilution
            hasChanges = true
        }

        return hasChanges
    }

    // MARK: - Fixer Conversion

    /// Создает SwiftDataFixer из GitHubFixerData
    public static func createSwiftDataFixer(id: String, from data: GitHubFixerData) -> SwiftDataFixer {
        return SwiftDataFixer(
            id: id,
            name: data.name,
            type: data.type.rawValue,
            time: data.time,
            warning: data.warning
        )
    }

    /// Обновляет SwiftDataFixer данными из GitHubFixerData
    public static func updateSwiftDataFixer(_ entity: SwiftDataFixer, with data: GitHubFixerData) -> Bool {
        var hasChanges = false

        if entity.name != data.name {
            entity.name = data.name
            hasChanges = true
        }
        if entity.type != data.type.rawValue {
            entity.type = data.type.rawValue
            hasChanges = true
        }
        if entity.time != data.time {
            entity.time = data.time
            hasChanges = true
        }
        if entity.warning != data.warning {
            entity.warning = data.warning
            hasChanges = true
        }

        return hasChanges
    }

    // MARK: - Temperature Multiplier Conversion

    /// Создает SwiftDataTemperatureMultiplier из данных GitHub
    public static func createTemperatureMultiplier(temperature: Int, multiplier: Double) -> SwiftDataTemperatureMultiplier {
        return SwiftDataTemperatureMultiplier(temperature: temperature, multiplier: multiplier)
    }

    // MARK: - Journal Record Conversion

    /// Создает SwiftDataJournalRecord из JournalRecord
    public static func createSwiftDataJournalRecord(from record: JournalRecord) -> SwiftDataJournalRecord {
        return SwiftDataJournalRecord(
            recordID: record.id.uuidString,
            comment: record.comment,
            date: record.date,
            developerName: record.developerName,
            dilution: record.dilution,
            filmName: record.filmName,
            iso: record.iso ?? Int32(AppConstants.ISO.defaultFilmISO),
            temperature: record.temperature ?? 20,
            time: Int32(record.time ?? 0)
        )
    }

    /// Создает JournalRecord из SwiftDataJournalRecord
    public static func createJournalRecord(from record: SwiftDataJournalRecord) -> JournalRecord {
        return JournalRecord(
            date: record.date ?? Date(),
            name: record.name,
            filmName: record.filmName,
            developerName: record.developerName,
            iso: record.iso,
            process: record.process,
            dilution: record.dilution,
            temperature: record.temperature,
            time: Int(record.time),
            comment: record.comment
        )
    }
}

// MARK: - Generic Helper Functions

extension ModelConverter {

    /// Generic функция для сравнения и обновления опциональных свойств
    public static func updateOptionalProperty<T: Equatable>(
        current: inout T?,
        new: T?,
        hasChanges: inout Bool
    ) {
        if current != new {
            current = new
            hasChanges = true
        }
    }

    /// Generic функция для сравнения и обновления обязательных свойств
    public static func updateRequiredProperty<T: Equatable>(
        current: inout T,
        new: T,
        hasChanges: inout Bool
    ) {
        if current != new {
            current = new
            hasChanges = true
        }
    }

    /// Создает уникальный key для составных моделей
    public static func makeCompositeKey(_ components: String...) -> String {
        return components.joined(separator: "_")
    }
}