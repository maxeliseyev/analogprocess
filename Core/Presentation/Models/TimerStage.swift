//
//  TimerStage.swift
//  AnalogProcess
//
//  Created by Maxim Eliseyev on 18.09.2025.
//

import Foundation

struct TimerStage {
    let duration: TimeInterval
    let agitationMode: AgitationMode?
    let name: String

    // Инициализатор из StagingStage
    init(from stagingStage: StagingStage) {
        self.duration = stagingStage.duration
        self.name = stagingStage.name

        // Находим режим агитации по ключу из стадии
        if let key = stagingStage.agitationPresetKey {
            // Сначала пробуем найти по локализованному названию
            self.agitationMode = AgitationMode.presets.first {
                $0.name == String(localized: String.LocalizationValue(key))
            }

            // Если не нашли по локализованному названию, пробуем найти по ключу
            ?? AgitationMode.presets.first { $0.name == key }
            ?? AgitationMode.safeFirst
        } else {
            // Если нет настроек ажитации, используем режим Still
            self.agitationMode = AgitationMode.presets.first { $0.type == .still }
            ?? AgitationMode.safeFirst
        }
    }

    // Инициализатор для одиночного таймера
    init(duration: TimeInterval, name: String, agitationMode: AgitationMode? = nil) {
        self.duration = duration
        self.name = name
        self.agitationMode = agitationMode
    }
}