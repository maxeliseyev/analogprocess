//
//  CoachMarksService.swift
//  AnalogProcess
//
//  Created by Maxim Eliseyev on 21.09.2025.
//

import SwiftUI

// 1. Data model for a single coach mark
struct CoachMark {
    let title: LocalizedStringKey
    let text: LocalizedStringKey
    let viewId: String // An identifier to link to a specific view
}

// 2. Service to manage the presentation of coach marks
@MainActor
class CoachMarksService: ObservableObject {
    @Published var isShowing: Bool = false
    
    private var marks: [CoachMark] = []
    private var currentMarkIndex: Int = 0
    
    func prepare(for marks: [CoachMark]) {
        self.marks = marks
        self.currentMarkIndex = 0
    }
    
    func start() {
        guard !marks.isEmpty else { return }
        isShowing = true
        showNextMark()
    }
    
    func showNextMark() {
        guard currentMarkIndex < marks.count else {
            finish()
            return
        }
        
        let mark = marks[currentMarkIndex]
        print("Showing coach mark: \(mark.title) for view \(mark.viewId)")
        
        // Here you would add the logic to show the actual SSCoachMark view
        // For now, we just print to the console.
        
        currentMarkIndex += 1
        // In a real implementation, you would call showNextMark() in the completion handler of the previous mark.
    }
    
    func finish() {
        isShowing = false
        marks = []
        currentMarkIndex = 0
        print("Finished showing coach marks.")
    }
}

// 3. ViewModifier to attach coach marks to a view
struct CoachMarks: ViewModifier {
    @StateObject private var service = CoachMarksService()
    let marks: [CoachMark]
    
    func body(content: Content) -> some View {
        content
            .environmentObject(service)
            .onAppear {
                service.prepare(for: marks)
                // In a real implementation, you might want to trigger this based on a specific condition,
                // e.g., first app launch.
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { // Delay to ensure views are loaded
                    service.start()
                }
            }
        // Here you would overlay the actual coach mark view if service.isShowing is true
    }
}

extension View {
    func coachMarks(marks: [CoachMark]) -> some View {
        self.modifier(CoachMarks(marks: marks))
    }
}
