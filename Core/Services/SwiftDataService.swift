//
//  SwiftDataService.swift
//  AnalogProcess
//
//  Created by Maxim Eliseyev on 11.08.2025.
//

import Foundation
import SwiftData
import SwiftUI
import Combine

@MainActor
public class SwiftDataService: ObservableObject {
    private let modelContainer: ModelContainer
    public let modelContext: ModelContext
    private let githubDataService: GitHubDataService
    private let developmentCalculator: DevelopmentCalculator
    
    @Published public var films: [SwiftDataFilm] = []
    @Published public var developers: [SwiftDataDeveloper] = []
    @Published public var fixers: [SwiftDataFixer] = []
    @Published public var temperatureMultipliers: [SwiftDataTemperatureMultiplier] = []
    
    public init(githubDataService: GitHubDataService, modelContainer: ModelContainer) {
        self.githubDataService = githubDataService
        self.modelContainer = modelContainer
        self.modelContext = ModelContext(modelContainer)
        self.developmentCalculator = DevelopmentCalculator()
        
        loadInitialData()
    }
    
    // MARK: - Initial Data Loading
    func loadInitialData() {
        refreshData()
        
        if films.isEmpty || developers.isEmpty {
            Logger.log(.debug, "loadInitialData - loading data from JSON")
            loadFilmsFromJSON()
            loadDevelopersFromJSON()
            loadFixersFromJSON()
            loadDevelopmentTimesFromJSON()
            loadTemperatureMultipliersFromJSON()
            saveContext()
            refreshData()
        }
    }

    private func loadFilmsFromJSON() {
        guard let url = Bundle.main.url(forResource: "films", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: [String: Any]] else {
            return
        }
        
        for (id, filmData) in json {
            guard let name = filmData["name"] as? String,
                  let brand = filmData["brand"] as? String,
                  let type = filmData["type"] as? String,
                  let iso = filmData["iso"] as? Int else {
                continue
            }
            
            let film = SwiftDataFilm(
                id: id,
                name: name,
                manufacturer: brand,
                type: type,
                defaultISO: Int32(iso)
            )
            insertFilm(film)
        }
    }
    
    private func loadDevelopersFromJSON() {
        guard let url = Bundle.main.url(forResource: "developers", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: [String: Any]] else {
            return
        }
        
        for (id, developerData) in json {
            guard let name = developerData["name"] as? String,
                  let brand = developerData["brand"] as? String,
                  let type = developerData["type"] as? String else {
                continue
            }
            
            let developer = SwiftDataDeveloper(
                id: id,
                name: name,
                manufacturer: brand,
                type: type,
                defaultDilution: developerData["dilution"] as? String
            )
            insertDeveloper(developer)
        }
    }
    
    private func loadFixersFromJSON() {
        guard let url = Bundle.main.url(forResource: "fixers", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: [String: Any]] else {
            return
        }
        
        for (id, fixerData) in json {
            guard let name = fixerData["name"] as? String,
                  let typeString = fixerData["type"] as? String,
                  let time = fixerData["time"] as? Int else {
                continue
            }
            
            let fixer = SwiftDataFixer(
                id: id,
                name: name,
                type: typeString,
                time: Int32(time),
                warning: fixerData["warning"] as? String
            )
            insertFixer(fixer)
        }
    }
    
    private func loadDevelopmentTimesFromJSON() {
        guard let url = Bundle.main.url(forResource: "development_times", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: [String: [String: [String: Int]]]] else {
            return
        }
        
        for (filmId, developers) in json {
            guard let film = getFilm(by: filmId) else { continue }
            
            for (developerId, dilutions) in developers {
                guard let developer = getDeveloper(by: developerId) else { continue }
                
                for (dilution, isoTimes) in dilutions {
                    for (isoString, time) in isoTimes {
                        guard let iso = Int(isoString) else { continue }
                        
                        let developmentTime = SwiftDataDevelopmentTime(
                            dilution: dilution,
                            iso: Int32(iso),
                            time: Int32(time),
                            developer: developer,
                            film: film
                        )
                        insertDevelopmentTime(developmentTime)
                    }
                }
            }
        }
    }
    
    private func loadTemperatureMultipliersFromJSON() {
        guard let url = Bundle.main.url(forResource: "temperature_multipliers", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Double] else {
            return
        }
        
        for (temperatureString, multiplier) in json {
            guard let temperature = Int(temperatureString) else { continue }
            
            let tempMultiplier = SwiftDataTemperatureMultiplier(
                temperature: temperature,
                multiplier: multiplier
            )
            insertTemperatureMultiplier(tempMultiplier)
        }
    }

    
    // MARK: - Data Refresh
    public func refreshData() {
        let filmsDescriptor = FetchDescriptor<SwiftDataFilm>(sortBy: [SortDescriptor(\.name)])
        films = (try? modelContext.fetch(filmsDescriptor)) ?? []
        
        let developersDescriptor = FetchDescriptor<SwiftDataDeveloper>(sortBy: [SortDescriptor(\.name)])
        developers = (try? modelContext.fetch(developersDescriptor)) ?? []
        
        let fixersDescriptor = FetchDescriptor<SwiftDataFixer>(sortBy: [SortDescriptor(\.name)])
        fixers = (try? modelContext.fetch(fixersDescriptor)) ?? []
        
        let tempDescriptor = FetchDescriptor<SwiftDataTemperatureMultiplier>(sortBy: [SortDescriptor(\.temperature)])
        temperatureMultipliers = (try? modelContext.fetch(tempDescriptor)) ?? []
    }
    
    // MARK: - Data Access
    public func getFilm(by id: String) -> SwiftDataFilm? {
        let descriptor = FetchDescriptor<SwiftDataFilm>(predicate: #Predicate<SwiftDataFilm> { $0.id == id })
        return try? modelContext.fetch(descriptor).first
    }
    
    public func getDeveloper(by id: String) -> SwiftDataDeveloper? {
        let descriptor = FetchDescriptor<SwiftDataDeveloper>(predicate: #Predicate<SwiftDataDeveloper> { $0.id == id })
        return try? modelContext.fetch(descriptor).first
    }
    
    public func getFixer(by id: String) -> SwiftDataFixer? {
        let descriptor = FetchDescriptor<SwiftDataFixer>(predicate: #Predicate<SwiftDataFixer> { $0.id == id })
        return try? modelContext.fetch(descriptor).first
    }
    
    // MARK: - Development Time Queries
    public func getDevelopmentTime(filmId: String, developerId: String, dilution: String, iso: Int) -> Int? {
        // Logic from SwiftDataRepository
        func fetchTime(filmId: String, developerId: String, iso: Int, dilution: String?) -> SwiftDataDevelopmentTime? {
            let iso32: Int32 = Int32(iso)
            if let dilution = dilution, !dilution.isEmpty {
                let dilutionOpt: String? = dilution
                let descriptor = FetchDescriptor<SwiftDataDevelopmentTime>(
                    predicate: #Predicate<SwiftDataDevelopmentTime> { item in
                        item.film?.id == filmId &&
                        item.developer?.id == developerId &&
                        item.iso == iso32 &&
                        item.dilution == dilutionOpt
                    }
                )
                return try? modelContext.fetch(descriptor).first
            } else {
                let descriptor = FetchDescriptor<SwiftDataDevelopmentTime>(
                    predicate: #Predicate<SwiftDataDevelopmentTime> { item in
                        item.film?.id == filmId &&
                        item.developer?.id == developerId &&
                        item.iso == iso32
                    }
                )
                return try? modelContext.fetch(descriptor).first
            }
        }

        let normalizedDilution = dilution.trimmingCharacters(in: .whitespacesAndNewlines)
        if let found = fetchTime(filmId: filmId, developerId: developerId, iso: iso, dilution: normalizedDilution) {
            return Int(found.time)
        }

        let lowercasedDilution = normalizedDilution.lowercased()
        if lowercasedDilution != normalizedDilution,
           let found = fetchTime(filmId: filmId, developerId: developerId, iso: iso, dilution: lowercasedDilution) {
            return Int(found.time)
        }

        if let found = fetchTime(filmId: filmId, developerId: developerId, iso: iso, dilution: nil) {
            return Int(found.time)
        }

        Logger.log(.debug, "getDevelopmentTime - no development time found")
        return nil
    }
    
    public func getTemperatureMultiplier(for temperature: Int) -> Double {
        for multiplier in temperatureMultipliers {
            if multiplier.temperature == temperature {
                return multiplier.multiplier
            }
        }
        return 1.0
    }
    
    public func getAvailableDilutions(filmId: String, developerId: String) -> [String] {
        let descriptor = FetchDescriptor<SwiftDataDevelopmentTime>(
            predicate: #Predicate<SwiftDataDevelopmentTime> { item in
                item.film?.id == filmId &&
                item.developer?.id == developerId
            }
        )
        let items = (try? modelContext.fetch(descriptor)) ?? []
        let dilutions = items.compactMap { ($0.dilution ?? "").trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        return Array(Set(dilutions)).sorted()
    }
    
    public func getAvailableISOs(filmId: String, developerId: String, dilution: String) -> [Int] {
        let normalizedDilution = dilution.trimmingCharacters(in: .whitespacesAndNewlines)
        let descriptor = FetchDescriptor<SwiftDataDevelopmentTime>(
            predicate: #Predicate<SwiftDataDevelopmentTime> { item in
                item.film?.id == filmId &&
                item.developer?.id == developerId &&
                (item.dilution ?? "") == normalizedDilution
            }
        )
        let items = (try? modelContext.fetch(descriptor)) ?? []
        let isos = items.map { Int($0.iso) }
        return Array(Set(isos)).sorted()
    }

    public func getAvailableDevelopers(filmId: String) -> [SwiftDataDeveloper] {
        let descriptor = FetchDescriptor<SwiftDataDevelopmentTime>(
            predicate: #Predicate<SwiftDataDevelopmentTime> { item in
                item.film?.id == filmId
            }
        )
        let items = (try? modelContext.fetch(descriptor)) ?? []
        let developerIds = items.compactMap { $0.developer?.id }
        let uniqueDeveloperIds = Array(Set(developerIds))

        return uniqueDeveloperIds.compactMap { developerId in
            getDeveloper(by: developerId)
        }.sorted { $0.name < $1.name }
    }
    
    // MARK: - Calculation Records Management
    public func saveRecord(filmName: String, developerName: String, dilution: String, temperature: Int, iso: Int, calculatedTime: Int, notes: String = "") {
        let record = SwiftDataJournalRecord(
            comment: notes,
            date: Date(),
            developerName: developerName,
            dilution: dilution,
            filmName: filmName,
            iso: Int32(iso),
            name: "\(filmName) + \(developerName)",
            temperature: temperature,
            time: Int32(calculatedTime)
        )
        modelContext.insert(record)
        saveContext()
    }
    
    public func getCalculationRecords() -> [SwiftDataJournalRecord] {
        do {
            let descriptor = FetchDescriptor<SwiftDataJournalRecord>(sortBy: [SortDescriptor(\.date, order: .reverse)])
            return try modelContext.fetch(descriptor)
        } catch {
            Logger.log(.error, "Error fetching calculation records: \(error)")
            return []
        }
    }
    
    public func deleteCalculationRecord(_ record: SwiftDataJournalRecord) {
        modelContext.delete(record)
        saveContext()
    }
    
    // MARK: - Data Management
    public func clearAllData() {
        do {
            try modelContext.delete(model: SwiftDataFilm.self)
            try modelContext.delete(model: SwiftDataDeveloper.self)
            try modelContext.delete(model: SwiftDataDevelopmentTime.self)
            try modelContext.delete(model: SwiftDataFixer.self)
            try modelContext.delete(model: SwiftDataTemperatureMultiplier.self)
            try modelContext.delete(model: SwiftDataJournalRecord.self)
            
            saveContext()
            refreshData()
        } catch {
            Logger.log(.error, "Error clearing data: \(error)")
        }
    }
    
    // MARK: - GitHub Sync
    public func syncDataFromGitHub() async throws {
        do {
            let githubData = try await githubDataService.downloadAllData()
            
            await MainActor.run {
                syncDataGeneric(githubData.films, createEntity: createSwiftDataFilm, updateEntity: updateSwiftDataFilm)
                syncDataGeneric(githubData.developers, createEntity: createSwiftDataDeveloper, updateEntity: updateSwiftDataDeveloper)
                syncDataGeneric(githubData.fixers, createEntity: createSwiftDataFixer, updateEntity: updateSwiftDataFixer)
                syncDevelopmentTimesFromGitHub(githubData.developmentTimes)
                syncTemperatureMultipliersFromGitHub(githubData.temperatureMultipliers)
                syncAgitationModesFromGitHub(githubData.agitationModes)
                syncProcessPresetsFromGitHub(githubData.processPresets)
                
                saveContext()
                refreshData()
            }
        } catch {
            Logger.log(.error, "Error syncing data from GitHub: \(error)")
            throw error
        }
    }

    // MARK: - Generic Sync Helper
    private func syncDataGeneric<DataType, EntityType: PersistentModel>(
        _ incomingData: [String: DataType],
        createEntity: (String, DataType) -> EntityType,
        updateEntity: (EntityType, DataType) -> Bool
    ) where EntityType: Identifiable & HasStringId {
        let descriptor = FetchDescriptor<EntityType>()
        guard let existingEntities = try? modelContext.fetch(descriptor) else { return }
        
        let existingEntitiesById = Dictionary(existingEntities.map { ($0.stringId, $0) }, uniquingKeysWith: { first, _ in first })
        let incomingIds = Set(incomingData.keys)
        
        let entitiesToDelete = existingEntities.filter { !incomingIds.contains($0.stringId) }
        for entity in entitiesToDelete {
            modelContext.delete(entity)
        }
        
        for (id, data) in incomingData {
            if let existingEntity = existingEntitiesById[id] {
                _ = updateEntity(existingEntity, data)
            } else {
                let newEntity = createEntity(id, data)
                modelContext.insert(newEntity)
            }
        }
    }
    
    // MARK: - Entity Creation Helpers
    private func createSwiftDataFilm(_ id: String, _ data: GitHubFilmData) -> SwiftDataFilm {
        return ModelConverter.createSwiftDataFilm(id: id, from: data)
    }

    private func createSwiftDataDeveloper(_ id: String, _ data: GitHubDeveloperData) -> SwiftDataDeveloper {
        return ModelConverter.createSwiftDataDeveloper(id: id, from: data)
    }

    private func createSwiftDataFixer(_ id: String, _ data: GitHubFixerData) -> SwiftDataFixer {
        return ModelConverter.createSwiftDataFixer(id: id, from: data)
    }
    
    // MARK: - Entity Update Helpers
    private func updateSwiftDataFilm(_ entity: SwiftDataFilm, _ data: GitHubFilmData) -> Bool {
        return ModelConverter.updateSwiftDataFilm(entity, with: data)
    }

    private func updateSwiftDataDeveloper(_ entity: SwiftDataDeveloper, _ data: GitHubDeveloperData) -> Bool {
        return ModelConverter.updateSwiftDataDeveloper(entity, with: data)
    }

    private func updateSwiftDataFixer(_ entity: SwiftDataFixer, _ data: GitHubFixerData) -> Bool {
        return ModelConverter.updateSwiftDataFixer(entity, with: data)
    }
    
    private func syncDevelopmentTimesFromGitHub(_ developmentTimes: [String: [String: [String: [String: Int]]]]) {
        func makeKey(filmId: String, developerId: String, dilution: String, iso: String) -> String {
            return "\(filmId)|\(developerId)|\(dilution)|\(iso)"
        }

        let allTimesDescriptor = FetchDescriptor<SwiftDataDevelopmentTime>()
        guard let existingTimes = try? modelContext.fetch(allTimesDescriptor) else { return }
        
        let existingTimesByKey = Dictionary(existingTimes.compactMap { time -> (String, SwiftDataDevelopmentTime)? in
            guard let filmId = time.film?.id, let devId = time.developer?.id, let dilution = time.dilution else {
                return nil
            }
            let key = makeKey(filmId: filmId, developerId: devId, dilution: dilution, iso: String(time.iso))
            return (key, time)
        }, uniquingKeysWith: { (first, _) in first })

        var incomingKeys = Set<String>()

        for (filmId, developers) in developmentTimes {
            guard let film = getFilm(by: filmId) else { continue }

            for (developerId, dilutions) in developers {
                guard let developer = getDeveloper(by: developerId) else { continue }

                for (dilution, isoTimes) in dilutions {
                    for (isoString, time) in isoTimes {
                        guard let iso = Int32(isoString) else { continue }
                        
                        let key = makeKey(filmId: filmId, developerId: developerId, dilution: dilution, iso: isoString)
                        incomingKeys.insert(key)

                        if let existingTime = existingTimesByKey[key] {
                            if existingTime.time != Int32(time) {
                                existingTime.time = Int32(time)
                            }
                        } else {
                            let newTime = SwiftDataDevelopmentTime(
                                dilution: dilution,
                                iso: iso,
                                time: Int32(time),
                                developer: developer,
                                film: film
                            )
                            insertDevelopmentTime(newTime)
                        }
                    }
                }
            }
        }
        
        let keysToDelete = Set(existingTimesByKey.keys).subtracting(incomingKeys)
        for key in keysToDelete {
            if let timeToDelete = existingTimesByKey[key] {
                modelContext.delete(timeToDelete)
            }
        }
    }
    
    private func syncTemperatureMultipliersFromGitHub(_ multipliers: [String: Double]) {
        let allMultipliersDescriptor = FetchDescriptor<SwiftDataTemperatureMultiplier>()
        guard let existingMultipliers = try? modelContext.fetch(allMultipliersDescriptor) else {
            return
        }
        
        let existingMultipliersByTemp = Dictionary(existingMultipliers.map { ($0.temperature, $0) }, uniquingKeysWith: { (first, _) in first })
        let incomingTemps = Set(multipliers.keys.compactMap { Int($0) })
        
        let multipliersToDelete = existingMultipliers.filter { !incomingTemps.contains($0.temperature) }
        for multiplier in multipliersToDelete {
            modelContext.delete(multiplier)
        }
        
        for (tempString, multiplierValue) in multipliers {
            guard let temperature = Int(tempString) else { continue }
            
            if let existingMultiplier = existingMultipliersByTemp[temperature] {
                if existingMultiplier.multiplier != multiplierValue {
                    existingMultiplier.multiplier = multiplierValue
                }
            } else {
                let newMultiplier = SwiftDataTemperatureMultiplier(
                    temperature: temperature,
                    multiplier: multiplierValue
                )
                insertTemperatureMultiplier(newMultiplier)
            }
        }
    }

    private func syncAgitationModesFromGitHub(_ agitationModes: [String: GitHubAgitationModeData]) {
        // Обновляем кеш агитации в GitHubAgitationService
        GitHubAgitationService.shared.updateModes(from: agitationModes)
        Logger.log(.debug, "Synced \(agitationModes.count) agitation modes to GitHubAgitationService")
    }

    private func syncProcessPresetsFromGitHub(_ presets: [GitHubProcessPreset]) {
        // This is a simple sync that deletes all existing presets and replaces them.
        // A more sophisticated sync would update existing presets based on their name.
        do {
            try modelContext.delete(model: SwiftDataProcessPreset.self)
        } catch {
            Logger.log(.error, "Error deleting process presets: \(error)")
        }

        for preset in presets {
            let stages = preset.stages.map { stage in
                return SwiftDataStagingStage(name: stage.name, description: stage.description, iconName: stage.iconName, color: stage.color, duration: stage.duration, temperature: stage.temperature)
            }
            let newPreset = SwiftDataProcessPreset(name: preset.name, description: preset.description, stages: stages)
            modelContext.insert(newPreset)
        }
    }

    
    // MARK: - Save Context
    public func saveContext() {
        do {
            try modelContext.save()
        } catch {
            Logger.log(.error, "Error saving SwiftData context: \(error)")
        }
    }
    
    // MARK: - Insert Methods for Data Loading
    public func insertFilm(_ film: SwiftDataFilm) {
        modelContext.insert(film)
    }
    
    public func insertDeveloper(_ developer: SwiftDataDeveloper) {
        modelContext.insert(developer)
    }
    
    public func insertFixer(_ fixer: SwiftDataFixer) {
        modelContext.insert(fixer)
    }
    
    public func insertDevelopmentTime(_ developmentTime: SwiftDataDevelopmentTime) {
        modelContext.insert(developmentTime)
    }
    
    public func insertTemperatureMultiplier(_ multiplier: SwiftDataTemperatureMultiplier) {
        modelContext.insert(multiplier)
    }
    
    // MARK: - Public Interface
    public func getFilms() -> [SwiftDataFilm] {
        return films
    }
    
    public func getDevelopers() -> [SwiftDataDeveloper] {
        return developers
    }
    
    public func getFixers() -> [SwiftDataFixer] {
        return fixers
    }
    
    // MARK: - Process Presets
    
    func getProcessPresets() -> [SwiftDataProcessPreset] {
        do {
            let descriptor = FetchDescriptor<SwiftDataProcessPreset>(sortBy: [SortDescriptor(\.name)])
            return try modelContext.fetch(descriptor)
        } catch {
            Logger.log(.error, "Error fetching process presets: \(error)")
            return []
        }
    }
    
    func saveProcessPresets(_ presets: [ProcessPreset]) {
        for preset in presets {
            let stages = preset.stages.map { stage in
                return SwiftDataStagingStage(name: stage.name, description: stage.description, iconName: stage.iconName, color: stage.color, duration: stage.duration, temperature: stage.temperature)
            }
            let newPreset = SwiftDataProcessPreset(name: preset.name, description: preset.description, stages: stages)
            modelContext.insert(newPreset)
        }
        saveContext()
    }
    
    func calculateDevelopmentTime(parameters: DevelopmentParameters) -> Int? {
        guard let baseTime = getDevelopmentTime(
            filmId: parameters.film.id,
            developerId: parameters.developer.id,
            dilution: parameters.dilution,
            iso: parameters.iso
        ) else {
            return nil
        }
        
        let temperatureMultiplier = getTemperatureMultiplier(for: parameters.temperature)
        let finalTime = Int(Double(baseTime) * temperatureMultiplier)
        return developmentCalculator.roundToQuarterMinute(finalTime)
    }
}

public protocol HasStringId {
    var stringId: String { get }
}

extension SwiftDataFilm: HasStringId {
    public var stringId: String { return id }
}

extension SwiftDataDeveloper: HasStringId {
    public var stringId: String { return id }
}

extension SwiftDataFixer: HasStringId {
    public var stringId: String { return id }
}
