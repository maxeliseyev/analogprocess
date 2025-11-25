//
//  TimerTabView.swift
//  Film Lab
//
//  Created by Maxim Eliseyev on 12.07.2025.
//

import SwiftUI

struct TimerTabView: View {
    @State private var timerMinutes = 0
    @State private var timerSeconds = 0
    @State private var showManualTimeInput = false
    @State private var selectedAgitationMode: AgitationMode?
    @State private var showAgitationSelection = false

    var onStartTimer: (Int, Int, AgitationMode?) -> Void

    private var isTimeSet: Bool {
        return !(timerMinutes == 0 && timerSeconds == 0)
    }

    private var isAgitationButtonDisabled: Bool {
        return !isTimeSet
    }

    private var isStartButtonDisabled: Bool {
        return !isTimeSet || selectedAgitationMode == nil
    }

    private func getDisabledButtonMessage() -> LocalizedStringKey {
        if !isTimeSet {
            return "setTimeToStartTimer"
        } else if selectedAgitationMode == nil {
            return "selectAgitationModeToStartTimer"
        } else {
            return ""
        }
    }

    var body: some View {
        VStack(spacing: 20) {
            Text(LocalizedStringKey("selectDevelopmentParameters"))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            VStack(spacing: 8) {
                Button(action: {
                    showManualTimeInput = true
                }) {
                    VStack(spacing: 5) {
                        Text("\(timerMinutes):\(String(format: "%02d", timerSeconds))")
                            .font(.system(size: 48, weight: .bold, design: .monospaced))
                            .foregroundColor(.primary)
                            .padding(.vertical, 10)
                        
                        Text(LocalizedStringKey("tapToChangeTime"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.vertical)
            
                Button(action: {
                    if !isAgitationButtonDisabled {
                        showAgitationSelection = true
                    }
                }) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                            .font(.title2)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(LocalizedStringKey("agitationMode"))
                                .font(.headline)
                            Text(selectedAgitationMode?.name ?? String(localized: "agitationModeNotSelected"))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .foregroundColor(isAgitationButtonDisabled ? .secondary : .primary)
                    .if(isAgitationButtonDisabled, transform: { view in
                        view.timerSelectorButtonDisabledStyle()
                    })
                    .if(!isAgitationButtonDisabled, transform: { view in
                        view.timerSelectorButtonStyle()
                    })
                }
                .disabled(isAgitationButtonDisabled)
                
                if isAgitationButtonDisabled {
                    Text(LocalizedStringKey("setTimeFirstToSelectAgitation"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.vertical, 8)
                        .multilineTextAlignment(.center)
                }
                
                Button(action: {
                    onStartTimer(timerMinutes, timerSeconds, selectedAgitationMode)
                }) {
                    HStack {
                        Image(systemName: "timer")
                            .font(.title2)
                        Text(LocalizedStringKey("startTimer"))
                            .font(.headline)
                        Spacer()
                    }
                    .foregroundColor(isStartButtonDisabled ? .secondary : .primary)
                    .if(isStartButtonDisabled, transform: { view in
                        view.timerActionButtonDisabledStyle()
                    })
                    .if(!isStartButtonDisabled, transform: { view in
                        view.timerActionButtonStyle()
                    })
                }
                .disabled(isStartButtonDisabled)
                
                if isStartButtonDisabled {
                    Text(LocalizedStringKey("setAgitationModeFirstToStartTimer"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.vertical, 8)
                        .multilineTextAlignment(.center)
                }
                
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .navigationTitle(LocalizedStringKey("timer"))
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showManualTimeInput) {
            ManualTimeInputView(
                minutes: $timerMinutes,
                seconds: $timerSeconds,
                onApply: {
                    showManualTimeInput = false
                },
                onCancel: {
                    showManualTimeInput = false
                }
            )
            .presentationDetents([.medium])
        }
        .sheet(isPresented: $showAgitationSelection) {
            AgitationSelectionView(
                selectedMode: Binding(
                    get: {
                        selectedAgitationMode ?? AgitationMode.safeFirst
                    },
                    set: { newMode in
                        selectedAgitationMode = newMode
                        showAgitationSelection = false
                    }
                )
            )
        }
    }
}

// MARK: - Previews

struct TimerTabView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationStack {
                TimerTabView(onStartTimer: { _, _, _ in })
            }
            .preferredColorScheme(.light)

            NavigationStack {
                TimerTabView(onStartTimer: { _, _, _ in })
            }
            .preferredColorScheme(.dark)
        }
    }
}
