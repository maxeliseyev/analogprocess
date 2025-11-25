//
//  TemperaturePickerView.swift
//  Film Lab
//
//  Created by Maxim Eliseyev on 12.07.2025.
//

import SwiftUI

struct TemperaturePickerView: View {
    @Binding var temperature: Int
    let onDismiss: () -> Void
    
    private let temperatures = Array(15...30)
    
    private var temperatureItems: [TemperatureItem] {
        temperatures.map { TemperatureItem(temperature: $0) }
    }
    
    private var selectedTemperatureItem: TemperatureItem {
        TemperatureItem(temperature: temperature)
    }
    
    var body: some View {
        BasePickerView(
            selectedValue: Binding(
                get: {
                    selectedTemperatureItem
                },
                set: { newTemperatureItem in
                    temperature = newTemperatureItem.temperature
                }
            ),
            items: temperatureItems,
            title: LocalizedStringKey("selectTemperature"),
            onDismiss: onDismiss
        )
    }
    
    
    struct TemperaturePickerView_Previews: PreviewProvider {
        static var previews: some View {
            TemperaturePickerView(
                temperature: .constant(20),
                onDismiss: {}
            )
        }
    }
}

