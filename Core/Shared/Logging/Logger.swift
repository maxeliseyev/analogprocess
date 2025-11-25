
//
//  Logger.swift
//  AnalogProcess
//
//  Created by Maxim Eliseyev on 25.09.2025.
//

import Foundation

public enum LogLevel: String {
    case debug = "🐛 DEBUG"
    case info = "ℹ️ INFO"
    case error = "‼️ ERROR"
}

public struct Logger {
    public static func log(_ level: LogLevel, _ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        #if DEBUG
        let fileName = (file as NSString).lastPathComponent
        print("\(level.rawValue) [\(fileName):\(line) \(function)] - \(message)")
        #else
        if level == .error {
            // In production, only log errors. Or use a more sophisticated logging framework.
            let fileName = (file as NSString).lastPathComponent
            print("\(level.rawValue) [\(fileName):\(line) \(function)] - \(message)")
        }
        #endif
    }
}
