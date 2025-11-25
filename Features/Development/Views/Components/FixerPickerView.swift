//
//  SwiftDataFixerPickerView.swift
//  AnalogProcess
//
//  Created by Maxim Eliseyev on 11.08.2025.
//

import SwiftUI
import SwiftData

struct FixerPickerView: View {
    // MARK: - SwiftData Properties
    let swiftDataFixers: [SwiftDataFixer]
    @Binding var selectedSwiftDataFixer: SwiftDataFixer?

    // MARK: - Shared Properties
    let onDismiss: () -> Void
    let onSwiftDataFixerSelected: (SwiftDataFixer) -> Void

    private var fixerItems: [FixerItem] {
        swiftDataFixers.map { FixerItem(fixer: $0) }
    }

    private var selectedFixerItem: FixerItem? {
        selectedSwiftDataFixer.flatMap { fixer in
            fixerItems.first { $0.fixer.id == fixer.id }
        }
    }

    var body: some View {
        BasePickerView(
            selectedValue: Binding(
                get: {
                    selectedFixerItem ?? fixerItems.first ?? FixerItem(fixer: SwiftDataFixer(id: "", name: "", type: "", time: 0))
                },
                set: { newFixerItem in
                    selectedSwiftDataFixer = newFixerItem.fixer
                    onSwiftDataFixerSelected(newFixerItem.fixer)
                }
            ),
            items: fixerItems,
            title: LocalizedStringKey("fixerSelection"),
            enableSearch: true,
            onDismiss: onDismiss
        )
    }
}

// MARK: - Preview
struct FixerPickerView_Previews: PreviewProvider {
    static var previews: some View {
        FixerPickerView(
            swiftDataFixers: [],
            selectedSwiftDataFixer: .constant(nil as SwiftDataFixer?),
            onDismiss: {},
            onSwiftDataFixerSelected: { _ in }
        )
    }
}
