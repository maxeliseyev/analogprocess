//
//  GitHubDataService.swift
//  AnalogProcess
//
//  Created by Maxim Eliseyev on 12.07.2025.
//

import Foundation
import SwiftUI

// MARK: - GitHub Data Service Errors
public enum GitHubDataServiceError: LocalizedError {
    case invalidURL
    case networkError(NetworkError)
    case decodingError
    case noData
    
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL for data download"
        case .networkError(let error):
            return error.errorDescription
        case .decodingError:
            return "Failed to decode data from server"
        case .noData:
            return "No data received from server"
        }
    }
}

// MARK: - GitHub Data Service
@MainActor
public class GitHubDataService: ObservableObject {
    public static let shared = GitHubDataService()
    
    private let networkSession: NetworkSession
    private let jsonDecoder: JSONDecoder
    
    @Published var isDownloading = false
    @Published var downloadProgress: Double = AppConstants.Progress.initialProgress
    @Published var lastSyncDate: Date?
    
    public init(networkSession: NetworkSession = URLSession.shared) {
        self.networkSession = networkSession
        self.jsonDecoder = JSONDecoder()
        loadLastSyncDate()
    }
    
    // MARK: - Data Download
    
    public func downloadAllData() async throws -> GitHubDataResponse {
        Logger.log(.debug, "Starting downloadAllData")
        isDownloading = true
        downloadProgress = AppConstants.Progress.initialProgress
        
        defer {
            isDownloading = false
            downloadProgress = AppConstants.Progress.initialProgress
        }
        
        do {
            async let filmsData = downloadFilms()
            async let developersData = downloadDevelopers()
            async let fixersData = downloadFixers()
            async let developmentTimesData = downloadDevelopmentTimes()
            async let temperatureMultipliersData = downloadTemperatureMultipliers()
            async let agitationModesData = downloadAgitationModes()
            async let processPresetsData = downloadProcessPresets()

            let (films, developers, fixers, developmentTimes, temperatureMultipliers, agitationModes, processPresets) = try await (filmsData, developersData, fixersData, developmentTimesData, temperatureMultipliersData, agitationModesData, processPresetsData)
            
            Logger.log(.debug, "All data downloaded successfully")
            Logger.log(.debug, "Films count: \(films.count)")
            Logger.log(.debug, "Developers count: \(developers.count)")
            Logger.log(.debug, "Fixers count: \(fixers.count)")
            Logger.log(.debug, "Development times count: \(developmentTimes.count)")
            Logger.log(.debug, "Temperature multipliers count: \(temperatureMultipliers.count)")
            Logger.log(.debug, "Agitation modes count: \(agitationModes.count)")
            Logger.log(.debug, "Process presets count: \(processPresets.count)")

            downloadProgress = AppConstants.Progress.maxProgress
            lastSyncDate = Date()
            saveLastSyncDate()

            return GitHubDataResponse(
                films: films,
                developers: developers,
                fixers: fixers,
                developmentTimes: developmentTimes,
                temperatureMultipliers: temperatureMultipliers,
                agitationModes: agitationModes,
                processPresets: processPresets
            )
        } catch {
            Logger.log(.error, "Error in downloadAllData: \(error)")
            throw error
        }
    }
    
    private func downloadFilms() async throws -> [String: GitHubFilmData] {
        guard let url = URL(string: AppConstants.Network.baseURL + AppConstants.Network.filmsEndpoint) else {
            throw GitHubDataServiceError.networkError(.invalidURL)
        }
        let (data, response) = try await networkSession.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GitHubDataServiceError.networkError(.invalidResponse)
        }
        
        guard httpResponse.statusCode == 200 else {
            throw GitHubDataServiceError.networkError(.serverError(httpResponse.statusCode))
        }
        
        do {
            let films = try jsonDecoder.decode([String: GitHubFilmData].self, from: data)
            downloadProgress += AppConstants.Progress.downloadStepIncrement
            return films
        } catch {
            Logger.log(.error, "Films decoding error: \(error)")
            throw GitHubDataServiceError.decodingError
        }
    }
    
    private func downloadDevelopers() async throws -> [String: GitHubDeveloperData] {
        guard let url = URL(string: AppConstants.Network.baseURL + AppConstants.Network.developersEndpoint) else {
            throw GitHubDataServiceError.networkError(.invalidURL)
        }
        let (data, response) = try await networkSession.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GitHubDataServiceError.networkError(.invalidResponse)
        }
        
        guard httpResponse.statusCode == 200 else {
            throw GitHubDataServiceError.networkError(.serverError(httpResponse.statusCode))
        }
        
        do {
            let developers = try jsonDecoder.decode([String: GitHubDeveloperData].self, from: data)
            downloadProgress += AppConstants.Progress.downloadStepIncrement
            return developers
        } catch {
            Logger.log(.error, "Developers decoding error: \(error)")
            throw GitHubDataServiceError.decodingError
        }
    }
    
    private func downloadFixers() async throws -> [String: GitHubFixerData] {
        guard let url = URL(string: AppConstants.Network.baseURL + AppConstants.Network.fixersEndpoint) else {
            throw GitHubDataServiceError.networkError(.invalidURL)
        }
        let (data, response) = try await networkSession.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GitHubDataServiceError.networkError(.invalidResponse)
        }
        
        guard httpResponse.statusCode == 200 else {
            throw GitHubDataServiceError.networkError(.serverError(httpResponse.statusCode))
        }
        
        do {
            let fixers = try jsonDecoder.decode([String: GitHubFixerData].self, from: data)
            downloadProgress += AppConstants.Progress.downloadStepIncrement
            return fixers
        } catch {
            Logger.log(.error, "Fixer decoding error: \(error)")
            throw GitHubDataServiceError.decodingError
        }
    }
    
    private func downloadDevelopmentTimes() async throws -> [String: [String: [String: [String: Int]]]] {
        guard let url = URL(string: AppConstants.Network.baseURL + AppConstants.Network.developmentTimesEndpoint) else {
            throw GitHubDataServiceError.networkError(.invalidURL)
        }
        let (data, response) = try await networkSession.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GitHubDataServiceError.networkError(.invalidResponse)
        }
        
        guard httpResponse.statusCode == 200 else {
            throw GitHubDataServiceError.networkError(.serverError(httpResponse.statusCode))
        }
        
        do {
            let developmentTimes = try jsonDecoder.decode([String: [String: [String: [String: Int]]]].self, from: data)
            downloadProgress += AppConstants.Progress.downloadStepIncrement
            return developmentTimes
        } catch {
            Logger.log(.error, "Development times decoding error: \(error)")
            throw GitHubDataServiceError.decodingError
        }
    }
    
    private func downloadTemperatureMultipliers() async throws -> [String: Double] {
        guard let url = URL(string: AppConstants.Network.baseURL + AppConstants.Network.temperatureMultipliersEndpoint) else {
            throw GitHubDataServiceError.networkError(.invalidURL)
        }
        let (data, response) = try await networkSession.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GitHubDataServiceError.networkError(.invalidResponse)
        }
        
        guard httpResponse.statusCode == 200 else {
            throw GitHubDataServiceError.networkError(.serverError(httpResponse.statusCode))
        }
        
        do {
            let temperatureMultipliers = try jsonDecoder.decode([String: Double].self, from: data)
            downloadProgress += AppConstants.Progress.downloadStepIncrement
            return temperatureMultipliers
        } catch {
            Logger.log(.error, "Temperature multipliers decoding error: \(error)")
            throw GitHubDataServiceError.decodingError
        }
    }

    private func downloadAgitationModes() async throws -> [String: GitHubAgitationModeData] {
        guard let url = URL(string: AppConstants.Network.baseURL + AppConstants.Network.agitationModesEndpoint) else {
            throw GitHubDataServiceError.networkError(.invalidURL)
        }
        let (data, response) = try await networkSession.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw GitHubDataServiceError.networkError(.invalidResponse)
        }

        guard httpResponse.statusCode == 200 else {
            throw GitHubDataServiceError.networkError(.serverError(httpResponse.statusCode))
        }

        do {
            let agitationResponse = try jsonDecoder.decode(GitHubAgitationResponse.self, from: data)
            downloadProgress += AppConstants.Progress.downloadStepIncrement
            return agitationResponse.modes
        } catch {
            Logger.log(.error, "Agitation modes decoding error: \(error)")
            throw GitHubDataServiceError.decodingError
        }
    }

    private func downloadProcessPresets() async throws -> [GitHubProcessPreset] {
        guard let url = URL(string: AppConstants.Network.baseURL + AppConstants.Network.processPresetsEndpoint) else {
            throw GitHubDataServiceError.networkError(.invalidURL)
        }
        let (data, response) = try await networkSession.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw GitHubDataServiceError.networkError(.invalidResponse)
        }

        do {
            let presetResponse = try jsonDecoder.decode(GitHubProcessPresetResponse.self, from: data)
            return presetResponse.presets
        } catch {
            Logger.log(.error, "Process presets decoding error: \(error)")
            throw GitHubDataServiceError.decodingError
        }
    }

    // MARK: - Sync Date Management
    
    private func loadLastSyncDate() {
        if let date = UserDefaults.standard.object(forKey: AppConstants.UserDefaultsKeys.lastSyncDate) as? Date {
            lastSyncDate = date
        }
    }
    
    private func saveLastSyncDate() {
        UserDefaults.standard.set(lastSyncDate, forKey: AppConstants.UserDefaultsKeys.lastSyncDate)
    }
}