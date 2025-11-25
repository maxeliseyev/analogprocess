//
//  DevelopmentCalculator.swift
//  AnalogProcess
//
//  Created by Maxim Eliseyev on 11.07.2025.
//

import Foundation

// MARK: - Development Calculator Protocol
public protocol DevelopmentCalculating {
    func calculateResults(
        minutes: Int,
        seconds: Int,
        coefficient: Double,
        temperature: Double,
        isPushMode: Bool,
        steps: Int
    ) -> [ProcessStep]
}

// MARK: - Development Calculator Implementation
public class DevelopmentCalculator: DevelopmentCalculating {
    
    /// Округляет время до ближайшей 1/4 минуты (15 секунд)
    public func roundToQuarterMinute(_ totalSeconds: Int) -> Int {
        let quarterMinuteSeconds = 15
        return Int(round(Double(totalSeconds) / Double(quarterMinuteSeconds))) * quarterMinuteSeconds
    }
    
    /// Округляет время до ближайшей 1/4 минуты (15 секунд) и возвращает кортеж
    private func roundToQuarterMinuteComponents(_ totalSeconds: Int) -> (minutes: Int, seconds: Int) {
        let roundedSeconds = Int(round(Double(totalSeconds) / Double(AppConstants.Time.quarterMinuteSeconds))) * AppConstants.Time.quarterMinuteSeconds
        let minutes = roundedSeconds / AppConstants.Time.secondsPerMinute
        let seconds = roundedSeconds % AppConstants.Time.secondsPerMinute
        
        return (minutes: minutes, seconds: seconds)
    }
    
    public func calculateResults(
        minutes: Int,
        seconds: Int,
        coefficient: Double,
        temperature: Double,
        isPushMode: Bool,
        steps: Int
    ) -> [ProcessStep] {
        
        let baseSeconds = minutes * AppConstants.Time.secondsPerMinute + seconds
        var results: [ProcessStep] = []
        
        // Базовое время (+0) - округляем
        let baseRounded = roundToQuarterMinuteComponents(baseSeconds)
        results.append(ProcessStep(
            label: "+0",
            minutes: baseRounded.minutes,
            seconds: baseRounded.seconds
        ))
        
        if isPushMode {
            results.append(contentsOf: calculatePushProcess(baseSeconds: baseSeconds, coefficient: coefficient, steps: steps))
        } else {
            results.append(contentsOf: calculatePullProcess(baseSeconds: baseSeconds, coefficient: coefficient, steps: steps))
        }
        
        return results
    }
    
    private func calculatePushProcess(baseSeconds: Int, coefficient: Double, steps: Int) -> [ProcessStep] {
        var results: [ProcessStep] = []
        
        for i in 1...steps {
            let multiplier = pow(coefficient, Double(i))
            let adjustedSeconds = Int(Double(baseSeconds) * multiplier)
            
            // Округляем результат до 1/4 минуты
            let rounded = roundToQuarterMinuteComponents(adjustedSeconds)
            
            results.append(ProcessStep(
                label: "push +\(i)",
                minutes: rounded.minutes,
                seconds: rounded.seconds
            ))
        }
        
        return results
    }
    
    private func calculatePullProcess(baseSeconds: Int, coefficient: Double, steps: Int) -> [ProcessStep] {
        var results: [ProcessStep] = []
        
        for i in 1...steps {
            let divisor = pow(coefficient, Double(i))
            let adjustedSeconds = Int(Double(baseSeconds) / divisor)
            
            // Округляем результат до 1/4 минуты
            let rounded = roundToQuarterMinuteComponents(adjustedSeconds)
            
            results.append(ProcessStep(
                label: "pull -\(i)",
                minutes: rounded.minutes,
                seconds: rounded.seconds
            ))
        }
        
        return results
    }
}
