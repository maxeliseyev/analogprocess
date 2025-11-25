//
//  GitHubAgitationService.swift
//  AnalogProcess
//
//  Created by Maxim Eliseyev on 19.01.2025.
//

import Foundation

// MARK: - GitHub Agitation Service
public class GitHubAgitationService {
    public static let shared = GitHubAgitationService()

    private var cachedModes: [AgitationMode] = []
    private var lastUpdateDate: Date?

    private init() {}

    // MARK: - Public Methods

    /// Обновляет кеш режимов агитации из GitHub данных
    public func updateModes(from githubData: [String: GitHubAgitationModeData]) {
        cachedModes = githubData.map { (key, value) in
            convertToAgitationMode(id: key, githubMode: value)
        }.sorted { !$0.isCustom && $1.isCustom } // Сначала встроенные

        lastUpdateDate = Date()
        print("DEBUG: Updated \(cachedModes.count) agitation modes from GitHub")
    }

    /// Возвращает все доступные режимы агитации
    public func getAllModes() -> [AgitationMode] {
        return cachedModes
    }

    /// Возвращает только встроенные режимы агитации
    public func getBuiltInModes() -> [AgitationMode] {
        return cachedModes.filter { !$0.isCustom }
    }

    /// Получает конкретный режим по идентификатору
    public func getMode(by id: String) -> AgitationMode? {
        return cachedModes.first { $0.type.rawValue == id }
    }

    /// Получает режим по типу
    public func getMode(by type: AgitationModeType) -> AgitationMode? {
        return cachedModes.first { $0.type == type }
    }

    /// Проверяет, есть ли закешированные данные
    public var hasCachedData: Bool {
        return !cachedModes.isEmpty
    }

    /// Возвращает fallback режимы, если GitHub недоступен
    public func getFallbackModes() -> [AgitationMode] {
        return AgitationModeDataFactory.createAllPredefinedModes().map { agitationData in
            AgitationMode(from: agitationData)
        }
    }

    // MARK: - Private Methods

    private func convertToAgitationMode(id: String, githubMode: GitHubAgitationModeData) -> AgitationMode {
        let agitationRules = githubMode.rules.map { githubRule in
            convertToAgitationRule(githubRule: githubRule)
        }

        // Создаем AgitationModeData для совместимости
        let agitationModeData = AgitationModeData(
            name: githubMode.name,
            localizedNameKey: githubMode.localizedNameKey,
            isCustom: !githubMode.isBuiltIn,
            rules: agitationRules
        )

        return AgitationMode(from: agitationModeData)
    }

    private func convertToAgitationRule(githubRule: GitHubAgitationRule) -> AgitationRule {
        let condition = AgitationRuleCondition(
            type: convertConditionType(githubRule.condition.type),
            values: githubRule.condition.values
        )

        let action = convertAgitationAction(githubRule.action)

        return AgitationRule(
            priority: githubRule.priority,
            condition: condition,
            action: action,
            parameters: githubRule.parameters
        )
    }

    private func convertConditionType(_ githubType: String) -> AgitationRuleCondition.ConditionType {
        switch githubType {
        case "exact_minutes":
            return .exactMinutes
        case "minute_range":
            return .minuteRange
        case "first_minute":
            return .firstMinute
        case "last_minute":
            return .lastMinute
        case "every_n_minutes":
            return .everyNMinutes
        case "after_minute":
            return .afterMinute
        case "default":
            return .defaultCondition
        default:
            print("WARNING: Unknown condition type: \(githubType), defaulting to .defaultCondition")
            return .defaultCondition
        }
    }

    private func convertAgitationAction(_ githubAction: String) -> AgitationAction {
        switch githubAction {
        case "continuous":
            return .continuous
        case "still":
            return .still
        case "cycle":
            return .cycle
        case "periodic":
            return .periodic
        case "rotations":
            return .rotations
        default:
            print("WARNING: Unknown agitation action: \(githubAction), defaulting to .still")
            return .still
        }
    }
}
