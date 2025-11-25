//
//  DilutionPickerView.swift
//  Film Lab
//
//  Created by Maxim Eliseyev on 12.07.2025.
//

import SwiftUI

struct DilutionPickerView: View {
    let dilutions: [String]
    @Binding var selectedDilution: String
    let onDismiss: () -> Void
    let isDisabled: Bool
    let onDilutionSelected: ((String) -> Void)?

    private var dilutionItems: [DilutionItem] {
        dilutions.map { DilutionItem(dilution: $0, isDisabled: isDisabled || dilutions.count <= 1) }
    }

    private var selectedDilutionItem: DilutionItem {
        DilutionItem(dilution: selectedDilution, isDisabled: false)
    }

    var body: some View {
        BasePickerView(
            selectedValue: Binding(
                get: {
                    selectedDilutionItem
                },
                set: { newDilutionItem in
                    selectedDilution = newDilutionItem.dilution
                    onDilutionSelected?(newDilutionItem.dilution)
                }
            ),
            items: dilutionItems,
            title: LocalizedStringKey("selectDilution"),
            onDismiss: onDismiss
        )
    }


    struct DilutionPickerView_Previews: PreviewProvider {
        static var previews: some View {
            Group {
                DilutionPickerView(
                    dilutions: ["1:1", "1:2", "1:4"],
                    selectedDilution: .constant("1:1"),
                    onDismiss: {},
                    isDisabled: false,
                    onDilutionSelected: { _ in }
                )
                
                DilutionPickerView(
                    dilutions: [],
                    selectedDilution: .constant(""),
                    onDismiss: {},
                    isDisabled: false,
                    onDilutionSelected: { _ in }
                )
                
                DilutionPickerView(
                    dilutions: [],
                    selectedDilution: .constant(""),
                    onDismiss: {},
                    isDisabled: true,
                    onDilutionSelected: { _ in }
                )
            }
        }
    }
}
