//
//  TimeInputView.swift
//  Film Lab
//
//  Created by Maxim Eliseyev on 11.07.2025.
//

import SwiftUI

struct TimeInputView: View {
    @Binding var minutes: String
    @Binding var seconds: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(LocalizedStringKey("basicTimeLabel"))
                .font(.headline)
            
            HStack {
                TextField(LocalizedStringKey("minutes"), text: $minutes)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                    .onChange(of: minutes) { _, newValue in
                        let filtered = newValue.filter { $0.isNumber }
                        if let intValue = Int(filtered), intValue > 59 {
                            minutes = "59"
                        } else {
                            minutes = filtered
                        }
                    }

                Text(LocalizedStringKey("min"))

                TextField(LocalizedStringKey("seconds"), text: $seconds)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                    .onChange(of: seconds) { _, newValue in
                        let filtered = newValue.filter { $0.isNumber }
                        if let intValue = Int(filtered), intValue > 59 {
                            seconds = "59"
                        } else {
                            seconds = filtered
                        }
                    }

                Text(LocalizedStringKey("sec"))
            }
        }
    }
}

struct TimeInputView_Previews: PreviewProvider {
    static var previews: some View {
        TimeInputView(minutes: .constant("5"), seconds: .constant("30"))
            .padding()
    }
} 