//
//  UnifiedTimerViewModel.swift
//  AnalogProcess
//
//  Created by Maxim Eliseyev on 18.09.2025.
//

import SwiftUI
import Combine
import Foundation

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
        self.stages = stagingStages.map { TimerStage(from: $0) }
        self.isMultiStage = true
        setupCurrentStage()
    }

    // Инициализатор для одиночного таймера
    init(duration: TimeInterval, name: String) {
        self.stages = [TimerStage(duration: duration, name: name)]
        self.isMultiStage = false
        setupCurrentStage()
    }

    // MARK: - Public Methods

    func startPauseTimer() {
        if isRunning {
            pauseTimer()
        } else {
            startTimer()
        }
    }

    func resetTimer() {
        pauseTimer()
        setupCurrentStage()
    }

    func startNextStage() {
        guard hasNextStage else { return }

        currentStageIndex += 1
        isTimerFinished = false
        setupCurrentStage()
        startTimer()
    }

    func selectAgitationMode(_ mode: AgitationMode) {
        print("🎯 [selectAgitationMode] Selected: \(mode.name)")
        selectedAgitationMode = mode
        showAgitationSelection = false
        setupAgitation()
        print("📊 [selectAgitationMode] Result - shouldAgitate: \(shouldAgitate), currentAgitationPhase: \(String(describing: currentAgitationPhase))")
    }

    /// Вызывается после установки режима ажитации в TimerView
    func setupAgitationAfterModeSet() {
        print("🔧 [setupAgitationAfterModeSet] Called")
        setupAgitation()
    }

    func presentManualTimeInput() {
        showManualTimeInput = true
    }

    func updateTimerTime(minutes: Int, seconds: Int) {
        stopTimer()
        totalSeconds = minutes * 60 + seconds
        remainingSeconds = totalSeconds
        currentMinute = 1
        setupAgitation()
        showManualTimeInput = false
    }

    func startFixingTimer() {
        fixingMinutes = 5
        fixingSeconds = 0
        showFixingTimer = true
    }

    func startFixingTimerWithTime(minutes: Int, seconds: Int) {
        remainingSeconds = minutes * 60 + seconds
        totalSeconds = minutes * 60 + seconds
        currentMinute = 1
        isTimerFinished = false

        let agitationService = AgitationModeDataService()
        let fixerMode = agitationService.presets.first { $0.name == "Fixer" }
        selectedAgitationMode = fixerMode
        setupAgitation()

        showFixingTimer = false
    }

    // MARK: - Private Methods

    private func setupCurrentStage() {
        guard let stage = currentStage else { return }

        totalSeconds = Int(stage.duration)
        remainingSeconds = totalSeconds
        currentMinute = 1 // Устанавливаем начальную минуту

        if isMultiStage {
            // В режиме стадий используем ажитацию из стадии
            selectedAgitationMode = stage.agitationMode
        }
        // В одиночном режиме ажитация выбирается пользователем

        updateDisplay()
        updateProgress()
        setupAgitation()
    }

    private func startTimer() {
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateTimer()
            }
        }

        setupAgitation()
    }

    private func pauseTimer() {
        isRunning = false
        timer?.invalidate()
        timer = nil
        // Не останавливаем ажитацию при паузе - только приостанавливаем
    }

    private func stopTimer() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }

    private func updateTimer() {
        guard remainingSeconds > 0 else {
            finishTimer()
            return
        }

        remainingSeconds -= 1
        updateDisplay()
        updateProgress()
        updateCurrentMinute()
        updateAgitation()
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
        isRunning = false
        isTimerFinished = true
        timer?.invalidate()
        timer = nil
        stopAgitation()

        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedback.impactOccurred()
    }

    // MARK: - Agitation Methods

    private func setupAgitation() {
        guard let mode = selectedAgitationMode else {
            shouldAgitate = false
            return
        }

        shouldAgitate = true
        // Убеждаемся что минута >= 1 для корректной работы агитации
        let minute = max(1, currentMinute)
        let totalMinutes = max(1, totalSeconds / 60) // Убеждаемся что общее время >= 1 минуты

        print("🔍 [setupAgitation] minute: \(minute), totalMinutes: \(totalMinutes), mode: \(mode.name)")

        let agitationPhase = mode.getAgitationForMinuteWithTotal(minute, totalMinutes: totalMinutes)
        currentAgitationPhase = agitationPhase.agitationType

        print("✅ [setupAgitation] Found phase: \(currentAgitationPhase!)")

        switch currentAgitationPhase! {
        case .continuous:
            isInAgitationPhase = true
            agitationTimeRemaining = 0
        case .still:
            isInAgitationPhase = false
            agitationTimeRemaining = 0
        case .cycle(let agitation, _):
            isInAgitationPhase = true
            agitationTimeRemaining = agitation
        case .periodic(let interval):
            isInAgitationPhase = true
            agitationTimeRemaining = interval
        case .custom:
            isInAgitationPhase = false
            agitationTimeRemaining = 0
        }
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

                        print("🔄 [\(Date())] Переключение режима: \(oldPhase) → Rest (время: \(agitationTimeRemaining)s)")

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

                        print("🔄 [\(Date())] Переключение режима: \(oldPhase) → Agitation (время: \(agitationTimeRemaining)s)")

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
