//
//  CoefficientInputView.swift
//  Film Lab
//
//  Created by Maxim Eliseyev on 11.07.2025.
//

import SwiftUI

struct RatioInputView: View {
    @Binding var ratio: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(LocalizedStringKey("ratio"))
                .font(.headline)
            
            HStack {
                TextField("1.33", text: $ratio)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.decimalPad)
                    .onChange(of: ratio) { _, newValue in
                        // 1. Replace comma with a dot
                        var correctedValue = newValue.replacingOccurrences(of: ",", with: ".")

                        // 2. Filter to allow only numbers and one dot
                        let components = correctedValue.components(separatedBy: ".")
                        if components.count > 2 {
                            correctedValue = components[0] + "." + components.dropFirst().joined()
                        }
                        let filtered = correctedValue.filter { "0123456789.".contains($0) }
                        if filtered != correctedValue {
                            correctedValue = filtered
                        }

                        // 3. Add leading zero if it starts with a dot
                        if correctedValue.starts(with: ".") {
                            correctedValue = "0" + correctedValue
                        }
                        
                        // 4. Clamp the value and limit length
                        if let doubleValue = Double(correctedValue) {
                            if doubleValue > 5.0 {
                                correctedValue = "5.0"
                            } else if doubleValue < 0.0 {
                                // Allow typing 0. something
                                correctedValue = String(correctedValue.prefix(4))
                            } else {
                                correctedValue = String(correctedValue.prefix(4))
                            }
                        } else if !correctedValue.isEmpty {
                            // Handle cases like "0." or invalid states
                            if correctedValue != "0." {
                                // It's not a valid number and not empty, reset or handle
                            }
                        }

                        // 5. Update the binding
                        if ratio != correctedValue {
                            ratio = correctedValue
                        }
                    }

                Text(LocalizedStringKey("standardRatio"))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
}

struct RatioInputView_Previews: PreviewProvider {
    static var previews: some View {
        RatioInputView(ratio: .constant("1.33"))
            .padding()
    }
} 
