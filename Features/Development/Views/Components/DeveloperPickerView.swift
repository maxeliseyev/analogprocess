//
//  SwiftDataDeveloperPickerView.swift
//  AnalogProcess
//
//  Created by Maxim Eliseyev on 11.08.2025.
//

import SwiftUI
import SwiftData

struct DeveloperPickerView: View {
    // MARK: - SwiftData Properties
    let developers: [SwiftDataDeveloper]
    @Binding var selectedDeveloper: SwiftDataDeveloper?
    @Binding var selectedDilution: String
    let onDismiss: () -> Void
    let onDeveloperSelected: ((SwiftDataDeveloper) -> Void)?

    // MARK: - Computed Properties

    private var developerItems: [DeveloperItem] {
        developers.map { DeveloperItem(developer: $0) }
    }

    private var selectedDeveloperItem: DeveloperItem? {
        selectedDeveloper.flatMap { developer in
            developerItems.first { $0.developer.id == developer.id }
        }
    }

    var body: some View {
        BasePickerView(
            selectedValue: Binding(
                get: {
                    selectedDeveloperItem ?? (developerItems.first ?? DeveloperItem(developer: SwiftDataDeveloper()))
                },
                set: { newDeveloperItem in
                    selectedDeveloper = newDeveloperItem.developer
                    selectedDilution = newDeveloperItem.developer.defaultDilution ?? ""
                    onDeveloperSelected?(newDeveloperItem.developer)
                }
            ),
            items: developerItems,
            title: LocalizedStringKey("selectDeveloper"),
            enableSearch: true,
            onDismiss: onDismiss
        )
    }
}
