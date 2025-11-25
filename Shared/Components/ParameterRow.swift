//
//  ParameterRow.swift
//  Film Lab
//
//  Created by Maxim Eliseyev on 12.07.2025.
//

import SwiftUI

struct ParameterRow: View {
    let label: String
    let value: String
    let onTap: () -> Void
    let isDisabled: Bool

    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .headlineTextStyle()
            
            Button(action: onTap) {
                HStack {
                    Text(value)
                        .bodyTextStyle()
                        .foregroundColor(isDisabled ? .secondary : .primary)
                    
                    Spacer()
                    
                    if !isDisabled {
                        Image(systemName: "chevron.down")
                            .chevronStyle()
                    }
                }
                .parameterCardStyle(isDisabled: isDisabled)
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(isDisabled)
        }
    }
}
