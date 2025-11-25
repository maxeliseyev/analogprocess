//
//  AgitationModeData.swift
//  AnalogProcess
//
//  Created by Maxim Eliseyev on 18.09.2025.
//

import Foundation
import SwiftData

// MARK: - Agitation Action Types

public enum AgitationAction: String, Codable, CaseIterable {
    case continuous = "continuous"
    case still = "still"
    case cycle = "cycle"
    case periodic = "periodic"
    case rotations = "rotations"
}

// MARK: - Rule Conditions

/// Condition for applying an agitation rule
public struct AgitationRuleCondition: Codable {
    public let type: ConditionType
    public let values: [Int]

    public init(type: ConditionType, values: [Int]) {
        self.type = type
        self.values = values
    }

    public enum ConditionType: String, Codable {
        case exactMinutes = "exact_minutes"      // exact minutes: [1, 5, 10]
        case minuteRange = "minute_range"        // range: [1, 5] = minutes 1-5
        case firstMinute = "first_minute"        // first minute
        case lastMinute = "last_minute"          // last minute
        case everyNMinutes = "every_n_minutes"   // every N minutes: [5] = every 5 minutes
        case afterMinute = "after_minute"        // after minute N: [10] = after the 10th minute
        case defaultCondition = "default"       // default for all others
    }

    public func matches(minute: Int, totalMinutes: Int) -> Bool {
        switch type {
        case .exactMinutes:
            return values.contains(minute)
        case .minuteRange:
            guard values.count >= 2 else { return false }
            return minute >= values[0] && minute <= values[1]
        case .firstMinute:
            return minute == 1
        case .lastMinute:
            return minute == totalMinutes
        case .everyNMinutes:
            guard let interval = values.first, interval > 0 else { return false }
            return minute % interval == 0
        case .afterMinute:
            guard let threshold = values.first else { return false }
            return minute > threshold
        case .defaultCondition:
            return true
        }
    }
}

/// Agitation rule for specific conditions
public struct AgitationRule: Codable, Identifiable {
    public let id: UUID
    public let priority: Int                    // rule priority (higher value = higher priority)
    public let condition: AgitationRuleCondition
    public let action: AgitationAction
    public let parameters: [String: Int]        // parameters: agitation_seconds, rest_seconds, rotations, etc.

    public var agitationSeconds: Int { parameters["agitation_seconds"] ?? 30 }
    public var restSeconds: Int { parameters["rest_seconds"] ?? 30 }
    public var rotations: Int { parameters["rotations"] ?? 1 }
    public var intervalSeconds: Int { parameters["interval_seconds"] ?? 10 }

    public init(priority: Int, condition: AgitationRuleCondition, action: AgitationAction, parameters: [String: Int]) {
        self.id = UUID()
        self.priority = priority
        self.condition = condition
        self.action = action
        self.parameters = parameters
    }
}

// MARK: - Agitation Rule Data Model (SwiftData)

@Model
public class AgitationRuleData {
    var priority: Int
    var conditionType: String // AgitationRuleCondition.ConditionType as String
    var conditionValues: String // [Int] as JSON String for simplicity
    var action: String // AgitationAction as String
    var parameters: String // [String: Int] as JSON String

    @Relationship(inverse: \AgitationModeData.rules)
    var agitationMode: AgitationModeData?

    public init(priority: Int, conditionType: AgitationRuleCondition.ConditionType, conditionValues: [Int], action: AgitationAction, parameters: [String: Int]) {
        self.priority = priority
        self.conditionType = conditionType.rawValue
        self.action = action.rawValue

        // Encoding array to JSON string
        if let valuesData = try? JSONEncoder().encode(conditionValues),
           let valuesString = String(data: valuesData, encoding: .utf8) {
            self.conditionValues = valuesString
        } else {
            self.conditionValues = "[]"
        }

        // Encoding parameters to JSON string
        if let paramsData = try? JSONEncoder().encode(parameters),
           let paramsString = String(data: paramsData, encoding: .utf8) {
            self.parameters = paramsString
        } else {
            self.parameters = "{}"
        }
    }

    /// Converts SwiftData model back to business-logic model
    public func toAgitationRule() -> AgitationRule {
        let condition = AgitationRuleCondition(
            type: AgitationRuleCondition.ConditionType(rawValue: conditionType) ?? .defaultCondition,
            values: decodedConditionValues
        )

        return AgitationRule(
            priority: priority,
            condition: condition,
            action: AgitationAction(rawValue: action) ?? .still,
            parameters: decodedParameters
        )
    }

    private var decodedConditionValues: [Int] {
        guard let data = conditionValues.data(using: .utf8) else { return [] }
        return (try? JSONDecoder().decode([Int].self, from: data)) ?? []
    }

    private var decodedParameters: [String: Int] {
        guard let data = parameters.data(using: .utf8) else { return [:] }
        return (try? JSONDecoder().decode([String: Int].self, from: data)) ?? [:]
    }
}

// MARK: - Agitation Mode Data Model

@Model
public class AgitationModeData {
    @Attribute(.unique) var name: String
    var localizedNameKey: String
    var isCustom: Bool

    // Using SwiftData relationships instead of JSON serialization
    @Relationship(deleteRule: .cascade)
    var rules: [AgitationRuleData] = []

    public init(name: String, localizedNameKey: String, isCustom: Bool = false, rules: [AgitationRule] = []) {
        self.name = name
        self.localizedNameKey = localizedNameKey
        self.isCustom = isCustom

        // Creating AgitationRuleData from business rules
        self.rules = rules.map { rule in
            AgitationRuleData(
                priority: rule.priority,
                conditionType: rule.condition.type,
                conditionValues: rule.condition.values,
                action: rule.action,
                parameters: rule.parameters
            )
        }
    }

    /// Gets business-logic rules from SwiftData models
    var decodedRules: [AgitationRule] {
        return rules.map { $0.toAgitationRule() }
    }

    /// Sets new rules, replacing existing ones
    func setRules(_ newRules: [AgitationRule]) {
        // Removing existing rules
        rules.removeAll()

        // Creating new AgitationRuleData
        rules = newRules.map { rule in
            AgitationRuleData(
                priority: rule.priority,
                conditionType: rule.condition.type,
                conditionValues: rule.condition.values,
                action: rule.action,
                parameters: rule.parameters
            )
        }
    }

    /// Adds a new rule
    func addRule(_ rule: AgitationRule) {
        let ruleData = AgitationRuleData(
            priority: rule.priority,
            conditionType: rule.condition.type,
            conditionValues: rule.condition.values,
            action: rule.action,
            parameters: rule.parameters
        )
        rules.append(ruleData)
    }
}

// MARK: - Migration Helpers

extension AgitationModeData {
    /// Creates AgitationModeData from a GitHub JSON model (for migration)
    static func from(githubModel: Any) -> AgitationModeData? {
        // TODO: Implement GitHub JSON parsing when needed
        return nil
    }

    /// Creates AgitationModeData from a Codable struct (simplified version)
    static func from(name: String, localizedKey: String, isCustom: Bool = false, rulesData: [[String: Any]]) -> AgitationModeData {
        var rules: [AgitationRule] = []

        for ruleData in rulesData {
            if let priority = ruleData["priority"] as? Int,
               let conditionTypeString = ruleData["condition_type"] as? String,
               let conditionType = AgitationRuleCondition.ConditionType(rawValue: conditionTypeString),
               let conditionValues = ruleData["condition_values"] as? [Int],
               let actionString = ruleData["action"] as? String,
               let action = AgitationAction(rawValue: actionString),
               let parameters = ruleData["parameters"] as? [String: Int] {

                let condition = AgitationRuleCondition(type: conditionType, values: conditionValues)
                let rule = AgitationRule(priority: priority, condition: condition, action: action, parameters: parameters)
                rules.append(rule)
            }
        }

        return AgitationModeData(name: name, localizedNameKey: localizedKey, isCustom: isCustom, rules: rules)
    }
}

// MARK: - Predefined Modes Factory

struct AgitationModeDataFactory {

    static func createORWO() -> AgitationModeData {
        let rules = [
            // First and last minutes: 45 sec agitation, 15 sec rest
            AgitationRule(
                priority: 10,
                condition: AgitationRuleCondition(type: .firstMinute, values: []),
                action: .cycle,
                parameters: ["agitation_seconds": 45, "rest_seconds": 15]
            ),
            AgitationRule(
                priority: 10,
                condition: AgitationRuleCondition(type: .lastMinute, values: []),
                action: .cycle,
                parameters: ["agitation_seconds": 45, "rest_seconds": 15]
            ),
            // All other minutes: 15 sec agitation, 45 sec rest
            AgitationRule(
                priority: 1,
                condition: AgitationRuleCondition(type: .defaultCondition, values: []),
                action: .cycle,
                parameters: ["agitation_seconds": 15, "rest_seconds": 45]
            )
        ]

        return AgitationModeData(
            name: "ORWO",
            localizedNameKey: "agitationOrwoName",
            rules: rules
        )
    }

    static func createRAE() -> AgitationModeData {
        let rules = [
            // 1st minute: continuous
            AgitationRule(
                priority: 10,
                condition: AgitationRuleCondition(type: .exactMinutes, values: [1]),
                action: .continuous,
                parameters: [:]
            ),
            // 2nd minute: every 10 seconds
            AgitationRule(
                priority: 10,
                condition: AgitationRuleCondition(type: .exactMinutes, values: [2]),
                action: .periodic,
                parameters: ["interval_seconds": 10]
            ),
            // 3rd minute: 2 rotations
            AgitationRule(
                priority: 10,
                condition: AgitationRuleCondition(type: .exactMinutes, values: [3]),
                action: .rotations,
                parameters: ["rotations": 2]
            ),
            // 4-5 minutes: 1 rotation per minute
            AgitationRule(
                priority: 10,
                condition: AgitationRuleCondition(type: .minuteRange, values: [4, 5]),
                action: .rotations,
                parameters: ["rotations": 1]
            ),
            // 7th and 10th minutes: 1 rotation each
            AgitationRule(
                priority: 10,
                condition: AgitationRuleCondition(type: .exactMinutes, values: [7, 10]),
                action: .rotations,
                parameters: ["rotations": 1]
            ),
            // After the 10th minute, every 5 minutes: 1 rotation (15, 20, 25, 30...)
            AgitationRule(
                priority: 9,
                condition: AgitationRuleCondition(type: .afterMinute, values: [10]),
                action: .rotations,
                parameters: ["rotations": 1]
            ),
            // Default: still
            AgitationRule(
                priority: 1,
                condition: AgitationRuleCondition(type: .defaultCondition, values: []),
                action: .still,
                parameters: [:]
            )
        ]

        // But for the "every 5 minutes after the 10th" rule, additional logic is needed
        return AgitationModeData(
            name: "RAE",
            localizedNameKey: "agitationRaeName",
            rules: rules
        )
    }

    static func createXTOL() -> AgitationModeData {
        let rules = [
            AgitationRule(
                priority: 1,
                condition: AgitationRuleCondition(type: .defaultCondition, values: []),
                action: .cycle,
                parameters: ["agitation_seconds": 5, "rest_seconds": 25]
            )
        ]

        return AgitationModeData(
            name: "XTOL",
            localizedNameKey: "agitationXtolName",
            rules: rules
        )
    }

    static func createFixer() -> AgitationModeData {
        let rules = [
            // First minute: continuous
            AgitationRule(
                priority: 10,
                condition: AgitationRuleCondition(type: .firstMinute, values: []),
                action: .continuous,
                parameters: [:]
            ),
            // All other time: still
            AgitationRule(
                priority: 1,
                condition: AgitationRuleCondition(type: .defaultCondition, values: []),
                action: .still,
                parameters: [:]
            )
        ]

        return AgitationModeData(
            name: "Fixer",
            localizedNameKey: "agitationFixerName",
            rules: rules
        )
    }

    static func createContinuous() -> AgitationModeData {
        let rules = [
            AgitationRule(
                priority: 1,
                condition: AgitationRuleCondition(type: .defaultCondition, values: []),
                action: .continuous,
                parameters: [:]
            )
        ]

        return AgitationModeData(
            name: "Continuous",
            localizedNameKey: "agitationContinuousName",
            rules: rules
        )
    }

    static func createStill() -> AgitationModeData {
        let rules = [
            AgitationRule(
                priority: 1,
                condition: AgitationRuleCondition(type: .defaultCondition, values: []),
                action: .still,
                parameters: [:]
            )
        ]

        return AgitationModeData(
            name: "Still",
            localizedNameKey: "agitationStillName",
            rules: rules
        )
    }

    static func createAllPredefinedModes() -> [AgitationModeData] {
        return [
            createORWO(),
            createXTOL(),
            createRAE(),
            createFixer(),
            createContinuous(),
            createStill()
        ]
    }
}