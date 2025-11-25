//
//  ModelProtocols.swift
//  AnalogProcess
//
//  Created by Maxim Eliseyev on 14.01.2025.
//

import Foundation
import SwiftData

// MARK: - Base Model Protocols

/// Базовый протокол для всех моделей с идентификатором и именем
public protocol BaseModel {
    var id: String { get set }
    var name: String { get set }
}

/// Протокол для моделей с производителем
public protocol ManufacturerModel: BaseModel {
    var manufacturer: String { get set }
}

/// Протокол для моделей с типом
public protocol TypedModel: BaseModel {
    var type: String { get set }
}

/// Протокол для полных моделей пленок и проявителей
public protocol CatalogModel: ManufacturerModel, TypedModel {
}

// MARK: - Specific Model Protocols

/// Протокол для моделей пленок
public protocol FilmModel: CatalogModel {
    var defaultISO: Int32 { get set }

    // Backward compatibility computed properties
    var iso: Int { get }
    var brand: String { get }
}

/// Протокол для моделей проявителей
public protocol DeveloperModel: CatalogModel {
    var defaultDilution: String? { get set }

    // Backward compatibility computed properties
    var dilution: String? { get }
    var brand: String { get }
}

/// Протокол для моделей фиксажей
public protocol FixerModel: BaseModel {
    var time: Int32 { get set }
    var warning: String? { get set }
}

/// Протокол для моделей времени проявки
public protocol DevelopmentTimeModel: BaseModel {
    var iso: Int32 { get set }
    var time: Int32 { get set }
    var dilution: String? { get set }
}

/// Протокол для моделей мультипликаторов температуры
public protocol TemperatureModel {
    var temperature: Int { get set }
    var multiplier: Double { get set }
}

// MARK: - Conversion Protocols

/// Протокол для конвертации между GitHub и SwiftData моделями
public protocol GitHubConvertible {
    associatedtype GitHubType: Codable
    associatedtype SwiftDataType: BaseModel

    func toSwiftData(id: String) -> SwiftDataType
    static func fromGitHub(_ data: GitHubType, id: String) -> SwiftDataType
}

/// Протокол для обновления существующих SwiftData моделей
public protocol Updatable {
    associatedtype UpdateSource

    func update(from source: UpdateSource) -> Bool
}

// MARK: - Generic Extensions

/// Общие методы для моделей с backward compatibility
extension FilmModel {
    public var iso: Int { Int(defaultISO) }
    public var brand: String { manufacturer }
}

extension DeveloperModel {
    public var dilution: String? { defaultDilution }
    public var brand: String { manufacturer }
}

// MARK: - Type Aliases

/// Type alias для удобства работы с GitHub конвертируемыми моделями
public typealias ConvertibleModel = BaseModel & GitHubConvertible & Updatable

/// Type alias для полных каталоговых моделей
public typealias FullCatalogModel = CatalogModel & GitHubConvertible & Updatable