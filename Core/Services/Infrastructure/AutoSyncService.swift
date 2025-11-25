//
//  AutoSyncService.swift
//  AnalogProcess
//
//  Created by Maxim Eliseyev on 12.07.2025.
//

import Foundation
import Network
import SwiftUI

@MainActor
public class AutoSyncService: ObservableObject {
    @Published var isAutoSyncing = false
    @Published var lastAutoSyncDate: Date?
    @Published var autoSyncStatus: AutoSyncStatus = .idle
    @Published var isAutoSyncEnabled: Bool = true
    @Published private(set) var isNetworkAvailable = false
    
    private let networkMonitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "AutoSyncService")
    private let swiftDataService: SwiftDataService
    
    // Минимальный интервал между автоматическими синхронизациями (24 часа)
    private let minSyncInterval: TimeInterval = 24 * 60 * 60
    
    public enum AutoSyncStatus: Equatable {
        case idle
        case checking
        case syncing
        case completed
        case failed(String)
        case noInternet
        case tooSoon
        
        public static func == (lhs: AutoSyncStatus, rhs: AutoSyncStatus) -> Bool {
            switch (lhs, rhs) {
            case (.idle, .idle):
                return true
            case (.checking, .checking):
                return true
            case (.syncing, .syncing):
                return true
            case (.completed, .completed):
                return true
            case (.noInternet, .noInternet):
                return true
            case (.tooSoon, .tooSoon):
                return true
            case (.failed(let lhsError), .failed(let rhsError)):
                return lhsError == rhsError
            default:
                return false
            }
        }
    }
    
    public init(swiftDataService: SwiftDataService) {
        self.swiftDataService = swiftDataService
        loadLastAutoSyncDate()
        loadAutoSyncEnabled()
        setupNetworkMonitoring()
    }
    
    deinit {
        networkMonitor.cancel()
    }
    
    // MARK: - Public Methods
    
    /// Запускает автоматическую синхронизацию при запуске приложения
    public func performAutoSyncOnAppLaunch() {
        guard isAutoSyncEnabled else {
            print("AutoSync: Auto-sync is disabled")
            return
        }
        
        Task {
            await checkAndSyncIfNeeded()
        }
    }
    
    /// Принудительная синхронизация (игнорирует ограничения по времени)
    public func forceAutoSync() async {
        await performSync()
    }
    
    // MARK: - Private Methods
    
    private func checkAndSyncIfNeeded() async {
        autoSyncStatus = .checking
        
        // Проверяем подключение к интернету
        guard isNetworkAvailable else {
            autoSyncStatus = .noInternet
            return
        }
        
        // Проверяем, не слишком ли рано для следующей синхронизации
        if let lastSync = lastAutoSyncDate {
            let timeSinceLastSync = Date().timeIntervalSince(lastSync)
            if timeSinceLastSync < minSyncInterval {
                autoSyncStatus = .tooSoon
                return
            }
        }
        
        // Выполняем синхронизацию
        await performSync()
    }
    
    private func performSync() async {
        autoSyncStatus = .syncing
        isAutoSyncing = true
        
        do {
            try await swiftDataService.syncDataFromGitHub()
            
            lastAutoSyncDate = Date()
            saveLastAutoSyncDate()
            autoSyncStatus = .completed
            
            print("AutoSync: Data synchronized successfully")
        } catch {
            autoSyncStatus = .failed(error.localizedDescription)
            print("AutoSync: Failed to sync data - \(error.localizedDescription)")
        }
        
        isAutoSyncing = false
    }
    
    // MARK: - Network Monitoring
    
    private func setupNetworkMonitoring() {
        networkMonitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                let isAvailable = path.status == .satisfied
                self?.isNetworkAvailable = isAvailable

                if isAvailable {
                    print("AutoSync: Internet connection is available.")
                    if self?.autoSyncStatus == .noInternet {
                        self?.autoSyncStatus = .idle
                    }
                } else {
                    print("AutoSync: Internet connection lost.")
                    self?.autoSyncStatus = .noInternet
                }
            }
        }
        networkMonitor.start(queue: queue)
    }
    
    // MARK: - Persistence
    
    private func loadLastAutoSyncDate() {
        if let date = UserDefaults.standard.object(forKey: AppConstants.UserDefaultsKeys.lastAutoSyncDate) as? Date {
            lastAutoSyncDate = date
        }
    }
    
    private func saveLastAutoSyncDate() {
        UserDefaults.standard.set(lastAutoSyncDate, forKey: AppConstants.UserDefaultsKeys.lastAutoSyncDate)
    }
    
    private func loadAutoSyncEnabled() {
        isAutoSyncEnabled = UserDefaults.standard.object(forKey: AppConstants.UserDefaultsKeys.autoSyncEnabled) as? Bool ?? true
    }
    
    public func setAutoSyncEnabled(_ enabled: Bool) {
        isAutoSyncEnabled = enabled
        UserDefaults.standard.set(enabled, forKey: AppConstants.UserDefaultsKeys.autoSyncEnabled)
    }
}
