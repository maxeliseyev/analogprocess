//
//  AppPreview.swift
//  Created by Maxim Eliseyev on 12.07.2025.
//

import SwiftUI
import SwiftData


// MARK: - Main App Preview
struct AppPreview: View {
    @State private var colorScheme: ColorScheme? = nil
    
    var body: some View {
        let modelContainer = SwiftDataPersistence.preview.modelContainer
        let githubService = GitHubDataService()
        let swiftDataService = SwiftDataService(githubDataService: githubService, modelContainer: modelContainer)
        let autoSyncService = AutoSyncService(swiftDataService: swiftDataService)
        let presetService = PresetService(swiftDataService: swiftDataService)

        ContentView(colorScheme: $colorScheme)
            .modelContainer(modelContainer)
            .environmentObject(githubService)
            .environmentObject(swiftDataService)
            .environmentObject(autoSyncService)
            .environmentObject(presetService)
    }
}

// MARK: - Preview Provider
struct AppPreview_Previews: PreviewProvider {
    static var previews: some View {
        AppPreview()
            .previewDisplayName("Main App")
    }
} 
