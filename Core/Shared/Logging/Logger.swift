
//
//  Logger.swift
//  AnalogProcess
//
//  Created by Maxim Eliseyev on 25.09.2025.
//

import Foundation
import os.log

public enum LogLevel: String {
    case debug = "DEBUG"
    case info = "INFO"
    case error = "ERROR"

    var osLogType: OSLogType {
        switch self {
        case .debug: return .debug
        case .info: return .info
        case .error: return .error
        }
    }
}

public struct Logger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.analogprocess"

    // Логгеры для разных категорий
    public static let timer = OSLog(subsystem: subsystem, category: "Timer")
    public static let agitation = OSLog(subsystem: subsystem, category: "Agitation")
    public static let persistence = OSLog(subsystem: subsystem, category: "Persistence")
    public static let sync = OSLog(subsystem: subsystem, category: "Sync")
    public static let navigation = OSLog(subsystem: subsystem, category: "Navigation")
    public static let ui = OSLog(subsystem: subsystem, category: "UI")
    public static let calculation = OSLog(subsystem: subsystem, category: "Calculation")
    public static let userAction = OSLog(subsystem: subsystem, category: "UserAction")
    public static let general = OSLog(subsystem: subsystem, category: "General")

    public static func log(_ level: LogLevel, _ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        let fileName = (file as NSString).lastPathComponent
        let logMessage = "[\(fileName):\(line) \(function)] - \(message)"

        #if DEBUG
        // В DEBUG режиме также выводим в консоль для удобства
        print("\(level.rawValue) \(logMessage)")
        #endif

        // Всегда логируем через OSLog (доступно в Console.app)
        os_log("%{public}@", log: general, type: level.osLogType, logMessage)
    }

    // Специализированные методы для логирования
    public static func logTimer(_ message: String, type: OSLogType = .default) {
        let timestamp = Date()
        os_log("[%{public}@] %{public}@", log: timer, type: type, timestamp.description, message)

        #if DEBUG
        print("[Timer] [\(timestamp)] \(message)")
        #endif
    }

    public static func logAgitation(_ message: String, type: OSLogType = .default) {
        let timestamp = Date()
        os_log("[%{public}@] %{public}@", log: agitation, type: type, timestamp.description, message)

        #if DEBUG
        print("[Agitation] [\(timestamp)] \(message)")
        #endif
    }

    public static func logPersistence(_ message: String, type: OSLogType = .default) {
        let timestamp = Date()
        os_log("[%{public}@] %{public}@", log: persistence, type: type, timestamp.description, message)

        #if DEBUG
        print("[Persistence] [\(timestamp)] \(message)")
        #endif
    }

    public static func logSync(_ message: String, type: OSLogType = .default) {
        let timestamp = Date()
        os_log("[%{public}@] %{public}@", log: sync, type: type, timestamp.description, message)

        #if DEBUG
        print("[Sync] [\(timestamp)] \(message)")
        #endif
    }

    public static func logNavigation(_ message: String, type: OSLogType = .default) {
        let timestamp = Date()
        os_log("[%{public}@] %{public}@", log: navigation, type: type, timestamp.description, message)

        #if DEBUG
        print("[Navigation] [\(timestamp)] \(message)")
        #endif
    }

    public static func logUI(_ message: String, type: OSLogType = .default) {
        let timestamp = Date()
        os_log("[%{public}@] %{public}@", log: ui, type: type, timestamp.description, message)

        #if DEBUG
        print("[UI] [\(timestamp)] \(message)")
        #endif
    }

    public static func logCalculation(_ message: String, type: OSLogType = .default) {
        let timestamp = Date()
        os_log("[%{public}@] %{public}@", log: calculation, type: type, timestamp.description, message)

        #if DEBUG
        print("[Calculation] [\(timestamp)] \(message)")
        #endif
    }

    public static func logUserAction(_ message: String, type: OSLogType = .default) {
        let timestamp = Date()
        os_log("[%{public}@] %{public}@", log: userAction, type: type, timestamp.description, message)

        #if DEBUG
        print("[UserAction] [\(timestamp)] \(message)")
        #endif
    }
}
