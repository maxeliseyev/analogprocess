//
//  SwiftDataJournalViewModel.swift
//  AnalogProcess
//
//  Created by Maxim Eliseyev on 11.08.2025.
//

import SwiftUI
import SwiftData
import Combine

@MainActor
class JournalViewModel: ObservableObject {
    @Published var errorMessage: String?
    
    // MARK: - Dependencies
    let swiftDataService: SwiftDataService
    private var cancellables = Set<AnyCancellable>()
    private var notificationCenter = NotificationCenter.default
    
    init(swiftDataService: SwiftDataService,) {
        self.swiftDataService = swiftDataService
    }
    
    deinit {
        notificationCenter.removeObserver(self)
    }
    
    // MARK: - Methods
    
    func deleteRecord(_ record: SwiftDataJournalRecord) {
        swiftDataService.deleteCalculationRecord(record)
    }
    
    func clearError() {
        errorMessage = nil
    }
}
