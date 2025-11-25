//
//  ValidationManager.swift
//  AnalogProcess
//
//  Created by Maxim Eliseyev on 25.09.2025.
//

import Foundation

enum ValidationError: Error, LocalizedError {
    case emptyField(String)
    case invalidInteger(String)
    case invalidDouble(String)
    case valueOutOfRange(String, ClosedRange<Int>)
    case doubleOutOfRange(String, ClosedRange<Double>)
    case mustBePositive(String)

    var errorDescription: String? {
        switch self {
        case .emptyField(let fieldName):
            return String(format: String(localized: "validationErrorEmptyField"), fieldName)
        case .invalidInteger(let fieldName):
            return String(format: String(localized: "validationErrorInvalidInteger"), fieldName)
        case .invalidDouble(let fieldName):
            return String(format: String(localized: "validationErrorInvalidDouble"), fieldName)
        case .valueOutOfRange(let fieldName, let range):
            return String(format: String(localized: "validationErrorValueOutOfRange"), fieldName, range.lowerBound, range.upperBound)
        case .doubleOutOfRange(let fieldName, let range):
            return String(format: String(localized: "validationErrorDoubleOutOfRange"), fieldName, range.lowerBound, range.upperBound)
        case .mustBePositive(let fieldName):
            return String(format: String(localized: "validationErrorMustBePositive"), fieldName)
        }
    }
}

protocol Validator {
    func validate() -> [ValidationError]
}

struct ValidationManager {

    static func validate(validators: [Validator]) -> [ValidationError] {
        return validators.flatMap { $0.validate() }
    }
    
    static func validateNotEmpty(field: String, fieldName: String) -> [ValidationError] {
        if field.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return [.emptyField(fieldName)]
        }
        return []
    }
    
    static func validateInt(field: String, fieldName: String, range: ClosedRange<Int>? = nil) -> [ValidationError] {
        guard let intValue = Int(field) else {
            return [.invalidInteger(fieldName)]
        }
        if let range = range, !range.contains(intValue) {
            return [.valueOutOfRange(fieldName, range)]
        }
        return []
    }

    static func validateDouble(field: String, fieldName: String, range: ClosedRange<Double>? = nil, greaterThanZero: Bool = false) -> [ValidationError] {
        guard let doubleValue = Double(field) else {
            return [.invalidDouble(fieldName)]
        }

        if greaterThanZero && doubleValue <= 0 {
            return [.mustBePositive(fieldName)]
        }

        if let range = range, !range.contains(doubleValue) {
            return [.doubleOutOfRange(fieldName, range)]
        }

        return []
    }
}
