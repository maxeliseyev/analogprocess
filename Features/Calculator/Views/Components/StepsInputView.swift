//
//  StepsInputView.swift
//  Film Lab
//
//  Created by Maxim Eliseyev on 11.07.2025.
//

import SwiftUI

struct StepsInputView: View {
    @Binding var pushSteps: Int
    let isPushMode: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(LocalizedStringKey("pushSteps"))
                .font(.headline)
            
            HStack {
                Stepper(value: $pushSteps, in: 1...5) {
                    Text("\(pushSteps)")
                        .font(.title2)
                        .fontWeight(.medium)
                }
                
                Spacer()
                
                Text(LocalizedStringKey("from1to5"))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
}

struct StepsInputView_Previews: PreviewProvider {
    static var previews: some View {
        StepsInputView(pushSteps: .constant(3), isPushMode: true)
            .padding()
    }
} 