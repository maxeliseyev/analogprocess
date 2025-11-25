//
//  ThemeManager.swift
//  Film Lab
//
//  Created by Maxim Eliseyev on 12.07.2025.
//

import SwiftUI

// MARK: - Main Theme Manager
@MainActor
class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    @Published var colorScheme: ColorScheme? = nil
    
    private init() {}
    
    // MARK: - Background Colors
    var primaryBackground: Color {
        switch colorScheme {
        case .light: return .white
        case .dark: return .black
        case nil: return .white
        @unknown default: return .white
        }
    }
    
    var secondaryBackground: Color {
        Color.gray.opacity(0.1)
    }
    
    var cardBackground: Color {
        Color.gray.opacity(0.1)
    }
    
    var parameterCardBackground: Color {
        switch colorScheme {
        case .light: return Color.gray.opacity(0.2)
        case .dark: return Color.gray.opacity(0.3)
        case nil: return Color.gray.opacity(0.2)
        @unknown default: return Color.gray.opacity(0.2)
        }
    }
    
    // MARK: - Text Colors
    var primaryText: Color {
        switch colorScheme {
        case .light: return .black
        case .dark: return .white
        case nil: return .black
        @unknown default: return .black
        }
    }
    
    var secondaryText: Color {
        .gray
    }
    
    var captionText: Color {
        switch colorScheme {
        case .light: return Color.gray.opacity(0.7)
        case .dark: return .gray
        case nil: return Color.gray.opacity(0.7)
        @unknown default: return Color.gray.opacity(0.7)
        }
    }
    
    // MARK: - Accent Colors
    var primaryAccent: Color { .blue }
    var secondaryAccent: Color { .orange }
    var successAccent: Color { .green }
    var warningAccent: Color { .orange }
    var dangerAccent: Color { .red }
    var purpleAccent: Color { .purple }
    
    // MARK: - Button Colors
    var primaryButtonBackground: Color { .blue }
    var primaryButtonText: Color { .white }
    var secondaryButtonBackground: Color { .green }
    var secondaryButtonText: Color { .white }
    
    // MARK: - Selection Colors
    var selectionBackground: Color { Color.blue.opacity(0.15) }
    var selectionBorder: Color { .blue }
    
    // MARK: - Timer Colors
    var timerActiveBackground: Color { .blue }
    var timerInactiveBackground: Color { Color.gray.opacity(0.3) }
    var agitationBackground: Color { .orange }
}

// MARK: - Non-Isolated Theme Manager for Environment
class NonIsolatedThemeManager: ObservableObject {
    @Published var colorScheme: ColorScheme? = .dark
    
    init() {}
}

// MARK: - Theme Environment Key
struct ThemeKey: EnvironmentKey {
    static let defaultValue = NonIsolatedThemeManager()
}

extension EnvironmentValues {
    var theme: NonIsolatedThemeManager {
        get { self[ThemeKey.self] }
        set { self[ThemeKey.self] = newValue }
    }
} 
