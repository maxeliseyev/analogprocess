//
//  AutoSyncStatusView.swift
//  AnalogProcess
//
//  Created by Maxim Eliseyev on 12.07.2025.
//

import SwiftUI

struct AutoSyncStatusView: View {
    @ObservedObject var autoSyncService: AutoSyncService
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: statusIcon)
                .foregroundColor(statusColor)
                .font(.system(size: 14, weight: .medium))
            
            Text(statusText)
                .font(.caption)
                .foregroundColor(statusColor)
            
            if autoSyncService.isAutoSyncing {
                ProgressView()
                    .scaleEffect(0.6)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
    
    // MARK: - Computed Properties
    
    private var statusIcon: String {
        if !autoSyncService.isAutoSyncEnabled {
            return "toggle.off"
        }
        
        switch autoSyncService.autoSyncStatus {
        case .idle:
            return "clock"
        case .checking:
            return "magnifyingglass"
        case .syncing:
            return "arrow.clockwise"
        case .completed:
            return "checkmark.circle"
        case .failed:
            return "exclamationmark.triangle"
        case .noInternet:
            return "wifi.slash"
        case .tooSoon:
            return "clock.badge.checkmark"
        }
    }
    
    private var statusColor: Color {
        if !autoSyncService.isAutoSyncEnabled {
            return .gray
        }
        
        switch autoSyncService.autoSyncStatus {
        case .idle, .checking:
            return .secondary
        case .syncing:
            return .blue
        case .completed:
            return .green
        case .failed:
            return .red
        case .noInternet:
            return .orange
        case .tooSoon:
            return .blue
        }
    }
    
    private var statusText: String {
        if !autoSyncService.isAutoSyncEnabled {
            return NSLocalizedString("settingsAutoSyncDisabled", comment: "")
        }
        
        switch autoSyncService.autoSyncStatus {
        case .idle:
            return NSLocalizedString("settingsAutoSyncReady", comment: "")
        case .checking:
            return NSLocalizedString("settingsAutoSyncChecking", comment: "")
        case .syncing:
            return NSLocalizedString("settingsAutoSyncInProgress", comment: "")
        case .completed:
            return NSLocalizedString("settingsAutoSyncCompleted", comment: "")
        case .failed(let error):
            return String(format: NSLocalizedString("settingsAutoSyncFailed", comment: ""), error)
        case .noInternet:
            return NSLocalizedString("settingsAutoSyncNoInternet", comment: "")
        case .tooSoon:
            return NSLocalizedString("settingsAutoSyncTooSoon", comment: "")
        }
    }
}

