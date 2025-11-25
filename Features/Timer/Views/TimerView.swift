import SwiftUI

public enum TimerMode {
    case single(timerLabel: String, totalMinutes: Int, totalSeconds: Int, selectedAgitationMode: AgitationMode?)
    case staging(stages: [StagingStage])

    var navigationTitle: String {
        switch self {
        case .single(timerLabel: _, totalMinutes: _, totalSeconds: _, selectedAgitationMode: _):
            return "timer"
        case .staging(_):
            return "stagingSequentialStages"
        }
    }
}

public struct TimerView: View {
    let mode: TimerMode

    @StateObject private var viewModel: UnifiedTimerViewModel
    @Environment(\.dismiss) private var dismiss

    public init(mode: TimerMode) {
        self.mode = mode

        switch mode {
        case .single(timerLabel: let timerLabel, totalMinutes: let totalMinutes, totalSeconds: let totalSeconds, selectedAgitationMode: let selectedAgitationMode):
            let duration = TimeInterval(totalMinutes * 60 + totalSeconds)
            let viewModel = UnifiedTimerViewModel(duration: duration, name: timerLabel)
            if let agitationMode = selectedAgitationMode {
                viewModel.selectedAgitationMode = agitationMode
                viewModel.setupAgitationAfterModeSet() // Вызываем setup после установки режима
            }
            self._viewModel = StateObject(wrappedValue: viewModel)

        case .staging(let stages):
            self._viewModel = StateObject(wrappedValue: UnifiedTimerViewModel(stagingStages: stages))
        }
    }

    // Convenience initializer for simpler single timer creation
    public init(timerLabel: String, totalMinutes: Int, totalSeconds: Int, selectedAgitationMode: AgitationMode? = nil) {
        self.init(mode: .single(timerLabel: timerLabel, totalMinutes: totalMinutes, totalSeconds: totalSeconds, selectedAgitationMode: selectedAgitationMode))
    }

    // MARK: - Computed Properties (like old TimerView)
    private var timerLabel: String {
        switch mode {
        case .single(timerLabel: let label, totalMinutes: _, totalSeconds: _, selectedAgitationMode: _):
            return label
        case .staging(_):
            return viewModel.currentStage?.name ?? ""
        }
    }

    private var totalMinutes: Int {
        switch mode {
        case .single(timerLabel: _, totalMinutes: let minutes, totalSeconds: _, selectedAgitationMode: _):
            return minutes
        case .staging(_):
            return Int(viewModel.currentStage?.duration ?? 0) / 60
        }
    }

    private var totalSeconds: Int {
        switch mode {
        case .single(timerLabel: _, totalMinutes: _, totalSeconds: let seconds, selectedAgitationMode: _):
            return seconds
        case .staging(_):
            return Int(viewModel.currentStage?.duration ?? 0) % 60
        }
    }

    private var isStaging: Bool {
        if case .staging(_) = mode { return true }
        return false
    }

    private var stages: [StagingStage] {
        if case .staging(let stages) = mode { return stages }
        return []
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // Header - like old TimerView
                    if isStaging {
                        VStack(spacing: 8) {
                            TimerHeaderView(
                                timerLabel: LocalizedStringKey(timerLabel),
                                totalMinutes: totalMinutes,
                                totalSeconds: totalSeconds,
                                selectedAgitationMode: viewModel.selectedAgitationMode
                            )

                            Text(String(format: NSLocalizedString("stagingStageXofY", comment: ""), "\(viewModel.currentStageIndex + 1)", "\(stages.count)"))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    } else {
                        TimerHeaderView(
                            timerLabel: LocalizedStringKey(timerLabel),
                            totalMinutes: totalMinutes,
                            totalSeconds: totalSeconds,
                            selectedAgitationMode: viewModel.selectedAgitationMode
                        )
                    }
                    
                    TimerProgressView(
                        progress: viewModel.progress,
                        displayMinutes: viewModel.displayMinutes,
                        displaySeconds: viewModel.displaySeconds,
                        isInAgitationPhase: viewModel.isInAgitationPhase,
                        agitationTimeRemaining: viewModel.agitationTimeRemaining,
                        isRunning: viewModel.isRunning
                    )
                    
                    AgitationIndicatorView(
                        shouldAgitate: viewModel.shouldAgitate,
                        selectedAgitationMode: viewModel.selectedAgitationMode,
                        isInAgitationPhase: viewModel.isInAgitationPhase,
                        agitationTimeRemaining: viewModel.agitationTimeRemaining,
                        currentMinute: viewModel.currentMinute,
                        currentAgitationPhase: viewModel.currentAgitationPhase
                    )
                    
                    if viewModel.isTimerFinished {
                        if isStaging {
                            // Staging completion logic
                            VStack(spacing: 16) {
                                Text(LocalizedStringKey("stagingStageComplete"))
                                    .font(.headline)
                                    .foregroundColor(.green)

                                if viewModel.hasNextStage {
                                    Button(action: {
                                        viewModel.startNextStage()
                                    }) {
                                        HStack {
                                            Image(systemName: "arrow.right")
                                            Text(LocalizedStringKey("stagingGoToNextStage"))
                                                .font(.headline)
                                        }
                                        .foregroundColor(.white)
                                        .padding()
                                        .background(.blue)
                                        .cornerRadius(10)
                                    }
                                } else {
                                    VStack(spacing: 12) {
                                        Text(LocalizedStringKey("stagingAllStagesComplete"))
                                            .font(.headline)
                                            .foregroundColor(.green)

                                        Button(action: {
                                            dismiss()
                                        }) {
                                            Text(LocalizedStringKey("stagingFinish"))
                                                .font(.headline)
                                                .foregroundColor(.white)
                                                .padding()
                                                .background(.green)
                                                .cornerRadius(10)
                                        }
                                    }
                                }
                            }
                        } else {
                            // Single timer completion - like old TimerView
                            VStack(spacing: 16) {
                                Text(LocalizedStringKey("developmentCompleted"))
                                    .font(.headline)
                                    .foregroundColor(.green)

                                Button(action: {
                                    dismiss()
                                }) {
                                    HStack {
                                        Text(LocalizedStringKey("stagingFinish"))
                                            .font(.headline)
                                    }
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(.green)
                                    .cornerRadius(10)
                                }
                            }
                        }
                    } else {
                        TimerControlsView(
                            isRunning: viewModel.isRunning,
                            onStartPause: viewModel.startPauseTimer,
                            onReset: viewModel.resetTimer
                        )
                    }
                    
                    Spacer()
                }
            }
            .navigationTitle(LocalizedStringKey(mode.navigationTitle))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: AgitationSelectionView(
                        selectedMode: Binding(
                            get: { viewModel.selectedAgitationMode ?? AgitationMode.safeFirst },
                            set: { newMode in
                                viewModel.selectAgitationMode(newMode)
                            }
                        )
                    )) {
                        Image(systemName: "slider.horizontal.3")
                            .foregroundColor(.primary)
                            .font(.title2)
                    }
                }
            })
            .sheet(isPresented: $viewModel.showAgitationSelection) {
                AgitationSelectionView(
                    selectedMode: Binding(
                        get: { viewModel.selectedAgitationMode ?? AgitationMode.safeFirst },
                        set: { newMode in
                            viewModel.selectAgitationMode(newMode)
                        }
                    )
                )
            }
            .sheet(isPresented: $viewModel.showManualTimeInput) {
                ManualTimeInputView(
                    minutes: Binding(
                        get: { viewModel.currentTotalMinutes },
                        set: { viewModel.currentTotalMinutes = $0 }
                    ),
                    seconds: Binding(
                        get: { viewModel.currentTotalSeconds },
                        set: { viewModel.currentTotalSeconds = $0 }
                    ),
                    onApply: {
                        viewModel.updateTimerTime(
                            minutes: viewModel.currentTotalMinutes,
                            seconds: viewModel.currentTotalSeconds
                        )
                    },
                    onCancel: {
                        viewModel.showManualTimeInput = false
                    },
                    title: "setTimeManually"
                )
                .presentationDetents([.medium])
            }
            .sheet(isPresented: $viewModel.showFixingTimer) {
                ManualTimeInputView(
                    minutes: Binding(
                        get: { viewModel.fixingMinutes },
                        set: { viewModel.fixingMinutes = $0 }
                    ),
                    seconds: Binding(
                        get: { viewModel.fixingSeconds },
                        set: { viewModel.fixingSeconds = $0 }
                    ),
                    onApply: {
                        viewModel.startFixingTimerWithTime(
                            minutes: viewModel.fixingMinutes,
                            seconds: viewModel.fixingSeconds
                        )
                    },
                    onCancel: {
                        viewModel.showFixingTimer = false
                    },
                    title: "fixingTime"
                )
                .presentationDetents([.medium])
            }
        }
    }
}

// MARK: - Previews

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Основной превью - таймер в состоянии покоя
            TimerView(
                timerLabel: "Kodak Tri-X 400 + XTOL 1+1",
                totalMinutes: 8,
                totalSeconds: 30
            )
            .previewDisplayName("Timer - Idle State")
            
            // Таймер во время работы
            TimerView(
                timerLabel: "Ilford HP5+ + HC-110 B",
                totalMinutes: 6,
                totalSeconds: 45
            )
            .previewDisplayName("Timer - Running State")
            
            // Длинный таймер
            TimerView(
                timerLabel: "Foma 400 + Rodinal 1+50",
                totalMinutes: 15,
                totalSeconds: 0
            )
            .previewDisplayName("Timer - Long Development")
            
            // Короткий таймер
            TimerView(
                timerLabel: "Kodak T-Max 100 + D-76",
                totalMinutes: 2,
                totalSeconds: 30
            )
            .previewDisplayName("Timer - Short Development")
        }
        .preferredColorScheme(.dark)
        .previewLayout(.device)
    }
}
