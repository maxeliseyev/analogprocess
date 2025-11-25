//
//  FilmLabApp.swift
//  Film Lab
//
//  Created by Maxim Eliseyev on 11.07.2025.
//

import SwiftUI
import SwiftData
import Foundation

@main
struct AnalogProcessApp: App {
    @StateObject private var githubDataService: GitHubDataService
    @StateObject private var swiftDataService: SwiftDataService
    @StateObject private var autoSyncService: AutoSyncService
    @StateObject private var presetService: PresetService
    
    private let modelContainer: ModelContainer
    
    @State private var colorScheme: ColorScheme? = nil
    @StateObject private var themeManager = ThemeManager.shared
    
    init() {
        let persistence = SwiftDataPersistence()
        self.modelContainer = persistence.modelContainer
        
        let githubService = GitHubDataService()
        let swiftDataService = SwiftDataService(githubDataService: githubService, modelContainer: self.modelContainer)
        let autoSyncService = AutoSyncService(swiftDataService: swiftDataService)
        let presetService = PresetService(swiftDataService: swiftDataService)

        _githubDataService = StateObject(wrappedValue: githubService)
        _swiftDataService = StateObject(wrappedValue: swiftDataService)
        _autoSyncService = StateObject(wrappedValue: autoSyncService)
        _presetService = StateObject(wrappedValue: presetService)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(colorScheme: $colorScheme)
                .modelContainer(modelContainer)
                .environmentObject(githubDataService)
                .environmentObject(swiftDataService)
                .environmentObject(autoSyncService)
                .environmentObject(presetService)
                .environment(\.theme, NonIsolatedThemeManager())
                .preferredColorScheme(colorScheme)
                .onAppear {
                    // Устанавливаем темную тему по умолчанию
                    if colorScheme == nil {
                        colorScheme = .dark
                    }
                    
                    // Синхронизируем colorScheme с ThemeManager
                    Task { @MainActor in
                        themeManager.colorScheme = colorScheme
                    }
                    
                    // Запускаем автоматическую синхронизацию данных
                    autoSyncService.performAutoSyncOnAppLaunch()
                }
                .onChange(of: colorScheme) { _, newValue in
                    Task { @MainActor in
                        themeManager.colorScheme = newValue
                    }
                }
        }
    }
}
