//
//  ISOPickerView.swift
//  Film Lab
//
//  Created by Maxim Eliseyev on 12.07.2025.
//

import SwiftUI

struct ISOPickerView: View {
    @Binding var iso: Int32
    let onDismiss: () -> Void
    let availableISOs: [Int]
    
    private let allISOs = AppConstants.ISO.allValues
    
    private var items: [ISOItem] {
        allISOs.map { isoValue in
            ISOItem(value: isoValue, isAvailable: availableISOs.contains(isoValue))
        }
    }
    
    private var selectedItem: ISOItem {
        ISOItem(value: Int(iso), isAvailable: true)
    }
    
    var body: some View {
        BasePickerView(
            selectedValue: Binding(
                get: { selectedItem },
                set: { iso = Int32($0.value) }
            ),
            items: items,
            title: LocalizedStringKey("selectISO"),
            onDismiss: onDismiss
        )
    }
}

struct ISOPickerView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ISOPickerView(
                iso: .constant(400),
                onDismiss: {},
                availableISOs: AppConstants.ISO.availableFilmISOs
            )
            
            ISOPickerView(
                iso: .constant(400),
                onDismiss: {},
                availableISOs: []
            )
        }
    }
} 
