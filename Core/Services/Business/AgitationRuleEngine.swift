//
//  AgitationRuleEngine.swift
//  AnalogProcess
//
//  Created by Maxim Eliseyev on 18.09.2025.
//

import Foundation
import SwiftData

// MARK: - Legacy Types for Compatibility

public enum AgitationModeType: String, CaseIterable, Codable {
    case orwo = "orwo"
    case xtol = "xtol"
    case rae = "rae"
    case fixer = "fixer"
    case continuous = "continuous"
    case still = "still"
    case custom = "custom"
}

public struct AgitationPhase {
    public let agitationType: PhaseAgitationType
    public let description: String

    public init(agitationType: PhaseAgitationType, description: String = "") {
        self.agitationType = agitationType
        self.description = description.isEmpty ? agitationType.defaultDescription : description
    }

    public enum PhaseAgitationType: Equatable, Codable {
        case continuous
        case still
        case cycle(agitationSeconds: Int, restSeconds: Int)
        case periodic(intervalSeconds: Int)
        case custom(description: String)

        public var defaultDescription: String {
            switch self {
            case .continuous:
                return String(localized: "agitationContinuous")
            case .still:
                return String(localized: "agitationStill")
            case .cycle(let agitation, let rest):
                return String(format: String(localized: "agitationCycleFormat"), "\(agitation)", "\(rest)")
            case .periodic(let interval):
                return String(format: String(localized: "agitationPeriodicFormat"), "\(interval)")
            case .custom(let description):
                return description
            }
        }
    }
}

// MARK: - Rule Engine

/// Движок для интерпретации правил агитации
class AgitationRuleEngine {

    /// Находит применимое правило для данной минуты
    static func findApplicableRule(for minute: Int, totalMinutes: Int, rules: [AgitationRule]) -> AgitationRule? {
        // Сначала обрабатываем особый случай для RAE: "каждые 5 минут после 10-й"
        let filteredRules = rules.compactMap { rule -> AgitationRule? in
            if rule.condition.type == .afterMinute,
               let threshold = rule.condition.values.first,
               minute > threshold {

                // Для RAE: проверяем, что это 15, 20, 25, 30... (каждые 5 минут после 10)
                if minute >= 15 && (minute - 10) % 5 == 0 {
                    return rule
                }
                return nil
            }

            return rule.condition.matches(minute: minute, totalMinutes: totalMinutes) ? rule : nil
        }

        // Сортируем по приоритету (больше = выше приоритет)
        return filteredRules.max(by: { $0.priority < $1.priority })
    }

    /// Интерпретирует правило в фазу агитации
    static func interpretRule(_ rule: AgitationRule, minute: Int, totalMinutes: Int) -> AgitationPhase {
        switch rule.action {
        case .continuous:
            return AgitationPhase(agitationType: .continuous)

        case .still:
            return AgitationPhase(agitationType: .still)

        case .cycle:
            return AgitationPhase(
                agitationType: .cycle(
                    agitationSeconds: rule.agitationSeconds,
                    restSeconds: rule.restSeconds
                )
            )

        case .periodic:
            return AgitationPhase(
                agitationType: .periodic(intervalSeconds: rule.intervalSeconds)
            )

        case .rotations:
            let rotationsCount = rule.rotations
            // Переводим обороты в описательный формат
            let description = rotationsCount == 1 ?
                String(localized: "1 rotation") :
                String(format: String(localized: "%d rotations"), rotationsCount)
            return AgitationPhase(
                agitationType: .custom(description: description)
            )
        }
    }

    /// Основной метод: получает фазу агитации для заданной минуты
    static func getAgitationPhase(for minute: Int, totalMinutes: Int, rules: [AgitationRule]) -> AgitationPhase {
        guard let rule = findApplicableRule(for: minute, totalMinutes: totalMinutes, rules: rules) else {
            // Fallback: неподвижность
            return AgitationPhase(agitationType: .still)
        }

        return interpretRule(rule, minute: minute, totalMinutes: totalMinutes)
    }
}

// MARK: - New AgitationMode Implementation

/// Новая упрощенная модель режима агитации на основе данных
public struct AgitationMode: Identifiable, Equatable {
    public var id: String { name }
    public let name: String
    public let localizedNameKey: String
    public let isCustom: Bool
    private let rules: [AgitationRule]

    public init(name: String, localizedNameKey: String, isCustom: Bool = false, rules: [AgitationRule]) {
        self.name = name
        self.localizedNameKey = localizedNameKey
        self.isCustom = isCustom
        self.rules = rules
    }

    /// Создание из данных
    public init(from data: AgitationModeData) {
        self.name = data.name
        self.localizedNameKey = data.localizedNameKey
        self.isCustom = data.isCustom
        self.rules = data.decodedRules
    }

    public static func == (lhs: AgitationMode, rhs: AgitationMode) -> Bool {
        return lhs.name == rhs.name && lhs.isCustom == rhs.isCustom
    }

    public var localizedName: String {
        String(localized: String.LocalizationValue(localizedNameKey))
    }

    /// Основной метод получения агитации для минуты
    public func getAgitationForMinuteWithTotal(_ minute: Int, totalMinutes: Int) -> AgitationPhase {
        return AgitationRuleEngine.getAgitationPhase(for: minute, totalMinutes: totalMinutes, rules: rules)
    }

    /// Compatibility method
    public func getAgitationForMinute(_ minute: Int) -> AgitationPhase {
        return getAgitationForMinuteWithTotal(minute, totalMinutes: Int.max)
    }

    public var description: String {
        return localizedName
    }

    public var type: AgitationModeType {
        switch name {
        case "ORWO": return .orwo
        case "XTOL": return .xtol
        case "RAE": return .rae
        case "Fixer": return .fixer
        case "Continuous": return .continuous
        case "Still": return .still
        default: return .custom
        }
    }
}

// MARK: - Service Layer

/// Сервис для работы с режимами агитации на основе данных
class AgitationModeDataService {
    private let modelContext: ModelContext?

    init(modelContext: ModelContext? = nil) {
        self.modelContext = modelContext
    }

    /// Получает все предустановленные режимы
    var presets: [AgitationMode] {
        let githubService = GitHubAgitationService.shared

        if githubService.hasCachedData {
            return githubService.getBuiltInModes()
        } else {
            // Fallback к заводским настройкам если GitHub недоступен
            return githubService.getFallbackModes()
        }
    }

    /// Получает все режимы (только предустановленные)
    var allModes: [AgitationMode] {
        return presets // Используем только предустановленные из GitHub
    }


    /// Инициализация базы данных с предустановленными режимами
    func initializePresetModes() {
        guard let modelContext = modelContext else { return }

        do {
            // Проверяем, есть ли уже данные
            let fetchDescriptor = FetchDescriptor<AgitationModeData>()
            let existingModes = try modelContext.fetch(fetchDescriptor)

            if existingModes.isEmpty {
                // Добавляем предустановленные режимы
                let presetModes = AgitationModeDataFactory.createAllPredefinedModes()
                for mode in presetModes {
                    modelContext.insert(mode)
                }
                try modelContext.save()
            }
        } catch {
            print("Failed to initialize preset modes: \(error)")
        }
    }
}

// MARK: - Legacy Support

extension AgitationMode {
    /// Для обратной совместимости - все режимы (предустановленные + пользовательские)
    static var presets: [AgitationMode] {
        return AgitationModeDataService().allModes
    }

    /// Для совместимости - только предустановленные
    static var systemPresets: [AgitationMode] {
        return AgitationModeDataService().presets
    }


    /// Безопасное получение первого режима агитации
    /// Если presets пустой, это критическая ошибка - приложение должно всегда иметь предустановленные режимы
    static var safeFirst: AgitationMode {
        guard let first = presets.first else {
            fatalError("No agitation presets available - this is a critical application error")
        }
        return first
    }
}
