//
//  TimerProgressView.swift
//  Film Lab
//
//  Created by Maxim Eliseyev on 12.07.2025.
//

import SwiftUI

struct TimerProgressView: View {
    let progress: Double
    let displayMinutes: Int
    let displaySeconds: Int
    let isInAgitationPhase: Bool
    let agitationTimeRemaining: Int
    let isRunning: Bool
    
    @State private var rotationAngle: Double = 0

    /// Безопасное значение progress, защищённое от NaN
    private var safeProgress: CGFloat {
        let progressValue = progress
        guard progressValue.isFinite && !progressValue.isNaN else {
            return 0.0
        }
        return CGFloat(max(0.0, min(1.0, progressValue)))
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 8)
                .opacity(0.3)
                .foregroundColor(.gray)
            
            Circle()
                .trim(from: 0.0, to: safeProgress)
                .stroke(style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .foregroundColor(isInAgitationPhase && isRunning ? .orange : .blue)
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1), value: progress)
            
            if isInAgitationPhase && isRunning {
                AgitationArrowsView(rotationAngle: $rotationAngle)
                    .onAppear {
                        withAnimation(.linear(duration: 5).repeatForever(autoreverses: false)) {
                            rotationAngle = 360
                        }
                    }
                    .onDisappear {
                        rotationAngle = 0
                    }
            }
            
            VStack(spacing: 8) {
                Text("\(displayMinutes):\(String(format: "%02d", displaySeconds))")
                    .font(.system(size: 48, weight: .bold, design: .monospaced))
                    .foregroundColor(.primary)
            }
        }
        .frame(width: 300, height: 300)
    }
}

// MARK: - Agitation Arrows View

struct AgitationArrowsView: View {
    @Binding var rotationAngle: Double
    
    var body: some View {
        ZStack {
            ForEach(0..<5, id: \.self) { index in
                Image(systemName: "fish.fill")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.orange)
                    .offset(y: -100)
                    .rotationEffect(.degrees(Double(index) * 72 + rotationAngle))
            }
        }
    }
}



struct TimerProgressView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            TimerProgressView(
                progress: 0.3,
                displayMinutes: 5,
                displaySeconds: 45,
                isInAgitationPhase: true,
                agitationTimeRemaining: 30,
                isRunning: true
            )
            
            TimerProgressView(
                progress: 0.7,
                displayMinutes: 2,
                displaySeconds: 15,
                isInAgitationPhase: false,
                agitationTimeRemaining: 0,
                isRunning: false
            )
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
} 
