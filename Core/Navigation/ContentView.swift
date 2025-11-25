//
//  ContentView.swift
//  Film Lab
//
//  Created by Maxim Eliseyev on 11.07.2025.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var swiftDataService: SwiftDataService
    @Binding var colorScheme: ColorScheme?
    @State private var selectedTab = 0 // 0 - главный экран
    
    var body: some View {
        MainTabView(
            swiftDataService: swiftDataService,
            selectedTab: $selectedTab,
            colorScheme: $colorScheme
        )
    }
}
