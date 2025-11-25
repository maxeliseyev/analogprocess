//
//  AgitationIndicatorView.swift
//  Film Lab
//
//  Created by Maxim Eliseyev on 12.07.2025.
//

import SwiftUI
import Foundation

struct AgitationIndicatorView: View {
    let shouldAgitate: Bool
    let selectedAgitationMode: AgitationMode?
    let isInAgitationPhase: Bool
    let agitationTimeRemaining: Int
    let currentMinute: Int
    let currentAgitationPhase: AgitationPhase.PhaseAgitationType?

    
    var body: some View {
            if shouldAgitate && selectedAgitationMode != nil {
                VStack(spacing: 8) {
                    HStack {
                        Text(isInAgitationPhase ? LocalizedStringKey("agitation") : LocalizedStringKey("rest"))
                            .font(.headline)
                            .foregroundColor(isInAgitationPhase ? .orange : .blue)
                            .fontWeight(.bold)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(isInAgitationPhase ? .orange.opacity(0.1) : .blue.opacity(0.1))
                    .cornerRadius(20)
                    
                    VStack(spacing: 4) {
                        Text(String(format: String(localized: "minuteLabel"), "\(currentMinute)"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if let phase = currentAgitationPhase {
                            Text(getPhaseDescription(phase))
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                }
            }
        }
    
    private func getPhaseDescription(_ phase: AgitationPhase.PhaseAgitationType) -> String {
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
}

