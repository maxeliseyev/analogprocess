//
//  AppConstants.swift
//  AnalogProcess
//
//  Created by Maxim Eliseyev on 12.07.2025.
//

import Foundation

// MARK: - App Constants
public enum AppConstants {
    
    // MARK: - Network
    public enum Network {
        static let baseURL: String = {
            guard let url = Bundle.main.object(forInfoDictionaryKey: "GitHubDataRepoURL") as? String else {
                return "https://raw.githubusercontent.com/maximeliseyev/filmdevelopmentdata/main"
            }
            return url
        }()
        
        static let filmsEndpoint = "/films.json"
        static let developersEndpoint = "/developers.json"
        static let fixersEndpoint = "/fixers.json"
        static let developmentTimesEndpoint = "/development-times.json"
        static let temperatureMultipliersEndpoint = "/temperature-multipliers.json"
        static let agitationModesEndpoint = "/agitation-modes.json"
        static let processPresetsEndpoint = "/process-presets.json"
    }
    
    // MARK: - UserDefaults Keys
    public enum UserDefaultsKeys {
        static let lastSyncDate = "lastSyncDate"
        static let lastAutoSyncDate = "LastAutoSyncDate"
        static let autoSyncEnabled = "AutoSyncEnabled"
        static let selectedStages = "selectedStages"
    }
    
    // MARK: - Time Constants
    public enum Time {
        static let quarterMinuteSeconds = 15
        static let secondsPerMinute = 60
    }
    
    // MARK: - Progress
    public enum Progress {
        static let downloadStepIncrement = 0.25
        static let maxProgress = 1.0
        static let initialProgress = 0.0
    }
    
    // MARK: - Developer Contact
    public enum Developer {
        static let email = "maxim.elis@icloud.com"
    }
    
    // MARK: - ISO Values
    public enum ISO {
        // Полный список всех ISO значений (включая промежуточные)
        static let allValues = [25, 32, 40, 50, 64, 80, 100, 125, 200, 250, 320, 400, 500, 640, 800, 1000, 1250, 1600, 2000, 2500, 3200, 4000, 5000, 6400, 8000, 12800]
        
        // Базовые ISO значения (основные ступени)
        static let baseValues = [25, 50, 100, 200, 400, 800, 1600, 3200, 6400, 12800]
        
        // ISO значения, для которых у нас есть данные пленок (100, 200, 400)
        static let availableFilmISOs = [100, 200, 400]
        
        // Значения по умолчанию
        static let defaultISO = 400
        static let defaultFilmISO = 400
        
        // Минимальные и максимальные значения
        static let minISO = 25
        static let maxISO = 12800
        
        // Промежуточные значения между основными ступенями
        static let intermediateValues = [32, 40, 64, 80, 125, 250, 320, 500, 640, 1000, 1250, 2000, 2500, 4000, 5000, 8000]
    }
}
