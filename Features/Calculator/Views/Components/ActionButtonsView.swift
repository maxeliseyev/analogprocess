//
//  ActionButtonsView.swift
//  Film Lab
//
//  Created by Maxim Eliseyev on 11.07.2025.
//

import SwiftUI

struct ActionButtonsView: View {
    let onCalculate: () -> Void
    let onSave: () -> Void
    let showSaveButton: Bool
    
    var body: some View {
        VStack(spacing: 10) {
            Button(action: onCalculate) {
                Text(LocalizedStringKey("calculateButton"))
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            
            if showSaveButton {
                Button(action: onSave) {
                    Text(LocalizedStringKey("saveButton"))
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
            }
        }
    }
}

struct ActionButtonsView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ActionButtonsView(
                onCalculate: {},
                onSave: {},
                showSaveButton: false
            )
            
            ActionButtonsView(
                onCalculate: {},
                onSave: {},
                showSaveButton: true
            )
        }
        .padding()
    }
} 