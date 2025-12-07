import SwiftUI
import Combine
import os.log


@MainActor
class DevelopmentSetupViewModel: ObservableObject {
    
    // MARK: - Properties
    @Published var selectedFilm: SwiftDataFilm?
    @Published var selectedDeveloper: SwiftDataDeveloper?
    @Published var selectedFixer: SwiftDataFixer?
    @Published var selectedDilution: String = ""
    @Published var temperature: Int = 20
    @Published var iso: Int = AppConstants.ISO.defaultISO
    @Published var calculatedTime: Int?
    
    // MARK: - Mode Selection
    @Published var selectedMode: ProcessMode = .developing
    
    // MARK: - UI States
    @Published var showFilmPicker = false
    @Published var showDeveloperPicker = false
    @Published var showDilutionPicker = false
    @Published var showFixerPicker = false
    @Published var showISOPicker = false
    @Published var showTemperaturePicker = false
    
    // MARK: - Navigation
    @Published var navigateToCalculator = false
    @Published var navigateToTimer = false
    
    // MARK: - Services
    let dataService: SwiftDataService
    
    init(dataService: SwiftDataService) {
        self.dataService = dataService
    }
    
    // MARK: - Computed Properties
    var films: [SwiftDataFilm] {
        dataService.films
    }
    
    var developers: [SwiftDataDeveloper] {
        guard let selectedFilm = selectedFilm else {
            return dataService.developers
        }
        return dataService.getAvailableDevelopers(filmId: selectedFilm.id)
    }
    
    var fixers: [SwiftDataFixer] {
        dataService.fixers
    }
    
    var selectedFilmName: String {
        selectedFilm?.name ?? ""
    }
    
    var selectedDeveloperName: String {
        selectedDeveloper?.name ?? ""
    }
    
    var dilutionOptions: [String] {
        guard let film = selectedFilm, let developer = selectedDeveloper else { return [] }
        return dataService.getAvailableDilutions(filmId: film.id, developerId: developer.id)
    }
    
    var isoOptions: [Int] {
        guard let film = selectedFilm, let developer = selectedDeveloper, !selectedDilution.isEmpty else { return [] }
        return dataService.getAvailableISOs(filmId: film.id, developerId: developer.id, dilution: selectedDilution)
    }
    
    var isDilutionSelectionLocked: Bool {
        dilutionOptions.count <= 1
    }
    
    var isISOSelectionLocked: Bool {
        isoOptions.count <= 1
    }
    
    var isTemperatureSelectionLocked: Bool {
        false  // Temperature selection is always available
    }
    
    // MARK: - Public Methods
    func selectFilm(_ film: SwiftDataFilm) {
        Logger.logUserAction("Film selected: \(film.name)", type: .info)

        selectedFilm = film
        iso = Int(film.defaultISO)

        // Проверяем, доступен ли текущий проявитель для новой пленки
        if let currentDeveloper = selectedDeveloper {
            let availableDevelopers = dataService.getAvailableDevelopers(filmId: film.id)
            if !availableDevelopers.contains(where: { $0.id == currentDeveloper.id }) {
                Logger.logUserAction("Developer reset due to film change", type: .debug)
                selectedDeveloper = nil
                selectedDilution = ""
            }
        }

        calculateTimeAutomatically()
    }
    
    func selectDeveloper(_ developer: SwiftDataDeveloper) {
        Logger.logUserAction("Developer selected: \(developer.name)", type: .info)

        selectedDeveloper = developer
        selectedDilution = developer.defaultDilution ?? ""
        calculateTimeAutomatically()
    }

    func selectDilution(_ dilution: String) {
        Logger.logUserAction("Dilution selected: \(dilution)", type: .info)

        selectedDilution = dilution
        calculateTimeAutomatically()
    }

    func selectFixer(_ fixer: SwiftDataFixer) {
        Logger.logUserAction("Fixer selected: \(fixer.name)", type: .info)

        selectedFixer = fixer
        calculateTimeAutomatically()
    }

    func updateISO(_ newISO: Int) {
        Logger.logUserAction("ISO changed: \(newISO)", type: .debug)

        iso = newISO
        calculateTimeAutomatically()
    }

    func updateTemperature(_ newTemperature: Int) {
        Logger.logUserAction("Temperature changed: \(newTemperature)°C", type: .debug)

        temperature = newTemperature
        calculateTimeAutomatically()
    }

    func updateMode(_ newMode: ProcessMode) {
        Logger.logUserAction("Mode changed: \(newMode)", type: .info)

        selectedMode = newMode
        calculateTimeAutomatically()
    }
    
    func reloadData() {
        dataService.refreshData()
        objectWillChange.send()
    }
    
    // MARK: - Private Methods
    private func calculateTimeAutomatically() {
        switch selectedMode {
        case .developing:
            guard let film = selectedFilm, let developer = selectedDeveloper else {
                calculatedTime = nil
                return
            }

            Logger.logCalculation("Auto-calculating time - film: \(film.name), developer: \(developer.name), dilution: \(selectedDilution), temp: \(temperature)°C, ISO: \(iso)", type: .info)

            let parameters = DevelopmentParameters(film: film, developer: developer, dilution: selectedDilution, temperature: temperature, iso: iso, time: 0)
            calculatedTime = dataService.calculateDevelopmentTime(parameters: parameters)

            if let time = calculatedTime {
                Logger.logCalculation("Time calculated: \(time)s (\(time / 60)m \(time % 60)s)", type: .info)
            } else {
                Logger.logCalculation("No development time found for combination", type: .error)
            }

        case .fixer:
            guard let fixer = selectedFixer else {
                calculatedTime = nil
                return
            }

            Logger.logCalculation("Fixer time set: \(fixer.name) - \(Int(fixer.time))s", type: .info)
            calculatedTime = Int(fixer.time)
        }
    }
}