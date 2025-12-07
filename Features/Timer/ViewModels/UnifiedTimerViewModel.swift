//
//  UnifiedTimerViewModel.swift
//  AnalogProcess
//
//  Created by Maxim Eliseyev on 18.09.2025.
//

import SwiftUI
import Combine
import Foundation
import os.log

@MainActor
class UnifiedTimerViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var currentStageIndex = 0
    @Published var isRunning = false
    @Published var isTimerFinished = false
    @Published var progress: Double = 0.0
    @Published var displayMinutes = 0
    @Published var displaySeconds = 0
    @Published var selectedAgitationMode: AgitationMode?
    @Published var showAgitationSelection = false

    // MARK: - Agitation Properties
    @Published var shouldAgitate = false
    @Published var isInAgitationPhase = false
    @Published var agitationTimeRemaining = 0
    @Published var currentMinute = 0
    @Published var currentAgitationPhase: AgitationPhase.PhaseAgitationType?

    // MARK: - Timer Control Properties (for single timer mode)
    @Published var showManualTimeInput = false
    @Published var showFixingTimer = false
    @Published var fixingMinutes: Int = 5
    @Published var fixingSeconds: Int = 0

    // MARK: - Private Properties
    private let stages: [TimerStage]
    private let isMultiStage: Bool
    private var timer: Timer?
    private var totalSeconds: Int = 0
    private var remainingSeconds: Int = 0
    private var timerTickCount: Int = 0

    // MARK: - Computed Properties

    var currentStage: TimerStage? {
        guard currentStageIndex < stages.count else { return nil }
        return stages[currentStageIndex]
    }

    var hasNextStage: Bool {
        return isMultiStage && currentStageIndex < stages.count - 1
    }

    var currentTotalMinutes: Int {
        get { totalSeconds / 60 }
        set {
            totalSeconds = newValue * 60 + (totalSeconds % 60)
            updateDisplay()
        }
    }

    var currentTotalSeconds: Int {
        get { totalSeconds % 60 }
        set {
            totalSeconds = (totalSeconds / 60) * 60 + newValue
            updateDisplay()
        }
    }

    // MARK: - Initialization

    // Инициализатор для режима стадий
    init(stagingStages: [StagingStage]) {
        Logger.logTimer("ViewModel init - Multi-stage mode with \(stagingStages.count) stages", type: .info)

        self.stages = stagingStages.map { TimerStage(from: $0) }
        self.isMultiStage = true
        setupCurrentStage()

        Logger.logTimer("ViewModel initialized for multi-stage mode", type: .info)
    }

    // Инициализатор для одиночного таймера
    init(duration: TimeInterval, name: String) {
        Logger.logTimer("ViewModel init - Single timer mode: '\(name)', duration: \(duration)s", type: .info)

        self.stages = [TimerStage(duration: duration, name: name)]
        self.isMultiStage = false
        setupCurrentStage()

        Logger.logTimer("ViewModel initialized for single timer mode", type: .info)
    }

    // MARK: - Public Methods

    func startPauseTimer() {
        Logger.logTimer("startPauseTimer called - isRunning: \(isRunning)", type: .default)

        if isRunning {
            Logger.logTimer("Pausing timer", type: .default)
            pauseTimer()
        } else {
            Logger.logTimer("Starting timer", type: .default)
            startTimer()
        }
    }

    func resetTimer() {
        Logger.logTimer("resetTimer called", type: .default)

        pauseTimer()
        timerTickCount = 0
        setupCurrentStage()

        Logger.logTimer("Timer reset completed - remainingSeconds: \(remainingSeconds), totalSeconds: \(totalSeconds)", type: .info)
    }

    func startNextStage() {
        Logger.logTimer("startNextStage called - current stage: \(currentStageIndex)", type: .default)

        guard hasNextStage else {
            Logger.logTimer("No next stage available", type: .info)
            return
        }

        currentStageIndex += 1
        Logger.logTimer("Moving to stage \(currentStageIndex)", type: .info)

        isTimerFinished = false
        setupCurrentStage()
        startTimer()

        Logger.logTimer("Next stage started successfully", type: .info)
    }

    func selectAgitationMode(_ mode: AgitationMode) {
        Logger.logAgitation("selectAgitationMode called - new mode: \(mode.name)", type: .default)

        selectedAgitationMode = mode
        showAgitationSelection = false
        setupAgitation()

        Logger.logAgitation("Agitation mode changed - shouldAgitate: \(shouldAgitate), currentAgitationPhase: \(String(describing: currentAgitationPhase))", type: .info)
    }

    /// Вызывается после установки режима ажитации в TimerView
    func setupAgitationAfterModeSet() {
        Logger.logAgitation("setupAgitationAfterModeSet called - mode: \(selectedAgitationMode?.name ?? "none")", type: .default)
        setupAgitation()
    }

    func presentManualTimeInput() {
        showManualTimeInput = true
    }

    func updateTimerTime(minutes: Int, seconds: Int) {
        Logger.logTimer("updateTimerTime called - minutes: \(minutes), seconds: \(seconds)", type: .default)

        stopTimer()
        totalSeconds = minutes * 60 + seconds
        remainingSeconds = totalSeconds
        currentMinute = 1
        timerTickCount = 0

        Logger.logTimer("Timer updated - totalSeconds: \(totalSeconds)", type: .info)

        setupAgitation()
        showManualTimeInput = false

        Logger.logTimer("Manual time update completed", type: .info)
    }

    func startFixingTimer() {
        fixingMinutes = 5
        fixingSeconds = 0
        showFixingTimer = true
    }

    func startFixingTimerWithTime(minutes: Int, seconds: Int) {
        Logger.logTimer("startFixingTimerWithTime called - minutes: \(minutes), seconds: \(seconds)", type: .default)

        remainingSeconds = minutes * 60 + seconds
        totalSeconds = minutes * 60 + seconds
        currentMinute = 1
        isTimerFinished = false
        timerTickCount = 0

        Logger.logTimer("Fixing timer setup - totalSeconds: \(totalSeconds)", type: .info)

        let agitationService = AgitationModeDataService()
        let fixerMode = agitationService.presets.first { $0.name == "Fixer" }
        selectedAgitationMode = fixerMode

        Logger.logTimer("Fixer agitation mode applied: \(fixerMode?.name ?? "none")", type: .info)

        setupAgitation()

        showFixingTimer = false

        Logger.logTimer("Fixing timer setup completed", type: .info)
    }

    // MARK: - Private Methods

    private func setupCurrentStage() {
        Logger.logTimer("setupCurrentStage BEGIN", type: .default)

        guard let stage = currentStage else {
            Logger.logTimer("ERROR: No current stage found", type: .error)
            return
        }

        Logger.logTimer("Stage info - name: \(stage.name), duration: \(stage.duration)s", type: .info)

        totalSeconds = Int(stage.duration)
        remainingSeconds = totalSeconds
        currentMinute = 1 // Устанавливаем начальную минуту

        if isMultiStage {
            // В режиме стадий используем ажитацию из стадии
            selectedAgitationMode = stage.agitationMode
            Logger.logTimer("Multi-stage mode - agitation from stage: \(stage.agitationMode?.name ?? "none")", type: .info)
        } else {
            Logger.logTimer("Single mode - agitation: \(selectedAgitationMode?.name ?? "none")", type: .info)
        }

        updateDisplay()
        updateProgress()
        setupAgitation()

        Logger.logTimer("setupCurrentStage END - totalSeconds: \(totalSeconds), remainingSeconds: \(remainingSeconds)", type: .default)
    }

    private func startTimer() {
        let startTimestamp = Date()
        Logger.logTimer("startTimer BEGIN", type: .default)
        Logger.logTimer("State before start - remainingSeconds: \(remainingSeconds), totalSeconds: \(totalSeconds)", type: .info)

        // Сбрасываем счетчик тиков при запуске
        timerTickCount = 0
        Logger.logTimer("Tick counter reset to 0", type: .debug)

        isRunning = true
        Logger.logTimer("isRunning set to true", type: .debug)

        let beforeTimerCreation = Date()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            Logger.logTimer("Timer fired - isValid: \(timer.isValid)", type: .debug)

            Task { @MainActor in
                let beforeUpdate = Date()
                self?.updateTimer()
                let afterUpdate = Date()
                let updateDuration = afterUpdate.timeIntervalSince(beforeUpdate)
                if updateDuration > 0.01 {
                    Logger.logTimer("WARNING: updateTimer took \(String(format: "%.3f", updateDuration))s", type: .error)
                }
            }
        }
        let afterTimerCreation = Date()
        let timerCreationDelay = afterTimerCreation.timeIntervalSince(beforeTimerCreation)
        Logger.logTimer("Timer object created (creation took \(String(format: "%.3f", timerCreationDelay))s)", type: .info)
        Logger.logTimer("Timer scheduled on RunLoop - isValid: \(timer?.isValid ?? false)", type: .info)

        setupAgitation()

        let endTimestamp = Date()
        let totalStartDelay = endTimestamp.timeIntervalSince(startTimestamp)
        Logger.logTimer("startTimer END (total duration: \(String(format: "%.3f", totalStartDelay))s)", type: .default)
    }

    private func pauseTimer() {
        Logger.logTimer("pauseTimer called - total ticks: \(timerTickCount), remainingSeconds: \(remainingSeconds)", type: .default)

        isRunning = false
        timer?.invalidate()
        timer = nil
        // Не останавливаем ажитацию при паузе - только приостанавливаем

        Logger.logTimer("Timer paused successfully", type: .info)
    }

    private func stopTimer() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }

    private func updateTimer() {
        timerTickCount += 1

        // Логируем первые 5 тиков и каждый 10-й после этого
        let shouldLog = timerTickCount <= 5 || timerTickCount % 10 == 0
        if shouldLog {
            Logger.logTimer("Tick #\(timerTickCount) - remainingSeconds: \(remainingSeconds)", type: .debug)
        }

        guard remainingSeconds > 0 else {
            Logger.logTimer("Timer finished at tick #\(timerTickCount)", type: .info)
            finishTimer()
            return
        }

        remainingSeconds -= 1
        updateDisplay()
        updateProgress()
        updateCurrentMinute()
        updateAgitation()

        if shouldLog {
            Logger.logTimer("Tick #\(timerTickCount) completed - new remainingSeconds: \(remainingSeconds)", type: .debug)
        }
    }

    private func updateCurrentMinute() {
        let elapsedMinutes = (totalSeconds - remainingSeconds) / 60
        currentMinute = elapsedMinutes + 1
    }

    private func updateDisplay() {
        displayMinutes = remainingSeconds / 60
        displaySeconds = remainingSeconds % 60
    }

    private func updateProgress() {
        guard totalSeconds > 0 else {
            progress = 0.0
            return
        }

        let elapsedSeconds = totalSeconds - remainingSeconds
        let newProgress = Double(elapsedSeconds) / Double(totalSeconds)

        // Защита от NaN и некорректных значений
        if newProgress.isFinite && !newProgress.isNaN {
            progress = max(0.0, min(1.0, newProgress))
        } else {
            progress = 0.0
        }
    }

    private func finishTimer() {
        Logger.logTimer("finishTimer called - total ticks: \(timerTickCount)", type: .default)

        isRunning = false
        isTimerFinished = true
        timer?.invalidate()
        timer = nil
        stopAgitation()

        Logger.logTimer("Timer finished successfully", type: .info)

        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedback.impactOccurred()
    }

    // MARK: - Agitation Methods

    private func setupAgitation() {
        guard let mode = selectedAgitationMode else {
            Logger.logAgitation("No agitation mode selected - disabling agitation", type: .info)
            shouldAgitate = false
            return
        }

        Logger.logAgitation("setupAgitation BEGIN - mode: \(mode.name)", type: .default)
        shouldAgitate = true

        // Убеждаемся что минута >= 1 для корректной работы агитации
        let minute = max(1, currentMinute)
        let totalMinutes = max(1, totalSeconds / 60) // Убеждаемся что общее время >= 1 минуты

        Logger.logAgitation("Parameters - currentMinute: \(minute), totalMinutes: \(totalMinutes), remainingSeconds: \(remainingSeconds)", type: .info)

        let agitationPhase = mode.getAgitationForMinuteWithTotal(minute, totalMinutes: totalMinutes)
        currentAgitationPhase = agitationPhase.agitationType

        Logger.logAgitation("Phase determined: \(currentAgitationPhase!)", type: .info)

        switch currentAgitationPhase! {
        case .continuous:
            isInAgitationPhase = true
            agitationTimeRemaining = 0
            Logger.logAgitation("Continuous agitation mode activated", type: .info)
        case .still:
            isInAgitationPhase = false
            agitationTimeRemaining = 0
            Logger.logAgitation("Still mode - no agitation", type: .info)
        case .cycle(let agitation, let rest):
            isInAgitationPhase = true
            agitationTimeRemaining = agitation
            Logger.logAgitation("Cycle mode - agitation: \(agitation)s, rest: \(rest)s", type: .info)
        case .periodic(let interval):
            isInAgitationPhase = true
            agitationTimeRemaining = interval
            Logger.logAgitation("Periodic mode - interval: \(interval)s", type: .info)
        case .custom:
            isInAgitationPhase = false
            agitationTimeRemaining = 0
            Logger.logAgitation("Custom agitation mode", type: .info)
        }

        Logger.logAgitation("setupAgitation END - isInAgitationPhase: \(isInAgitationPhase), agitationTimeRemaining: \(agitationTimeRemaining)", type: .default)
    }

    private func updateAgitation() {
        guard shouldAgitate, let mode = selectedAgitationMode else { return }

        let newPhase = mode.getAgitationForMinuteWithTotal(currentMinute, totalMinutes: totalSeconds / 60).agitationType
        if newPhase != currentAgitationPhase {
            currentAgitationPhase = newPhase
            setupAgitation()
        }

        guard let phase = currentAgitationPhase else { return }

        // Вычисляем максимальную длительность агитации, которая поместится до конца таймера
        let maxPossibleDuration = max(0, remainingSeconds - 1)

        switch phase {
        case .continuous:
            break

        case .still:
            break

        case .cycle(let agitation, let rest):
            if agitationTimeRemaining == 1 {
                let oldPhase = isInAgitationPhase ? "Agitation" : "Rest"

                if isInAgitationPhase {
                    // Переключаемся на отдых только если rest поместится до конца таймера
                    if rest <= maxPossibleDuration {
                        isInAgitationPhase = false
                        agitationTimeRemaining = rest

                        Logger.logAgitation("Phase switch: \(oldPhase) -> Rest (time: \(agitationTimeRemaining)s)", type: .default)

                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()
                    } else {
                        // Отдых не поместится, заканчиваем ажитацию
                        agitationTimeRemaining = 0
                        isInAgitationPhase = false
                    }
                } else {
                    // Переключаемся на ажитацию только если agitation поместится до конца таймера
                    if agitation <= maxPossibleDuration {
                        isInAgitationPhase = true
                        agitationTimeRemaining = agitation

                        Logger.logAgitation("Phase switch: \(oldPhase) -> Agitation (time: \(agitationTimeRemaining)s)", type: .default)

                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()
                    } else {
                        // Ажитация не поместится, остаемся в покое
                        agitationTimeRemaining = 0
                    }
                }
            } else {
                agitationTimeRemaining = max(0, agitationTimeRemaining - 1)
            }

        case .periodic(let interval):
            if agitationTimeRemaining == 1 {
                // Начинаем новый цикл только если interval поместится до конца таймера
                if interval <= maxPossibleDuration {
                    agitationTimeRemaining = interval

                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                } else {
                    // Новый цикл не поместится, заканчиваем агитацию
                    agitationTimeRemaining = 0
                    isInAgitationPhase = false
                }
            } else {
                agitationTimeRemaining = max(0, agitationTimeRemaining - 1)
            }

        case .custom:
            break
        }
    }

    private func stopAgitation() {
        shouldAgitate = false
        isInAgitationPhase = false
    }

    func getPhaseDescription(_ phase: AgitationPhase.PhaseAgitationType) -> String {
        switch phase {
        case .continuous:
            return String(localized: "continuousAgitation")
        case .still:
            return String(localized: "agitationStill")
        case .cycle(let agitation, let rest):
            return String(format: String(localized: "cycleAgitationFormat"), "\(agitation)", "\(rest)")
        case .periodic(let interval):
            return String(format: String(localized: "periodicAgitationFormat"), "\(interval)")
        case .custom(let description):
            return description
        }
    }

    deinit {
        timer?.invalidate()
    }
}
