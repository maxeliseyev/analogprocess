//
//  TimerHeaderView.swift
//  Film Lab
//
//  Created by Maxim Eliseyev on 12.07.2025.
//

import SwiftUI

struct TimerHeaderView: View {
    let timerLabel: LocalizedStringKey
    let totalMinutes: Int
    let totalSeconds: Int
    let selectedAgitationMode: AgitationMode?
    
    var body: some View {
        VStack(spacing: 10) {
            Text(timerLabel)
                .font(.title2)
                .fontWeight(.bold)
            
            Text("\(totalMinutes):\(String(format: "%02d", totalSeconds))")
                .font(.title3)
                .foregroundColor(.secondary)
            
            if let mode = selectedAgitationMode {
                Text(mode.name)
                    .captionTextStyle()
                    .foregroundColor(.blue)
            }
        }
        .padding(.top, 20)
    }
}

struct TimerHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        TimerHeaderView(
            timerLabel: "Проявка",
            totalMinutes: 8,
            totalSeconds: 30,
            selectedAgitationMode: nil
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
} 
