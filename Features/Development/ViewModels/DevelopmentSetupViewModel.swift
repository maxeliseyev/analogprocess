import SwiftUI
import Combine


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
        selectedFilm = film
        iso = Int(film.defaultISO)

        // Проверяем, доступен ли текущий проявитель для новой пленки
        if let currentDeveloper = selectedDeveloper {
            let availableDevelopers = dataService.getAvailableDevelopers(filmId: film.id)
            if !availableDevelopers.contains(where: { $0.id == currentDeveloper.id }) {
                selectedDeveloper = nil
                selectedDilution = ""
            }
        }

        calculateTimeAutomatically()
    }
    
    func selectDeveloper(_ developer: SwiftDataDeveloper) {
        selectedDeveloper = developer
        selectedDilution = developer.defaultDilution ?? ""
        calculateTimeAutomatically()
    }
    
    func selectDilution(_ dilution: String) {
        selectedDilution = dilution
        calculateTimeAutomatically()
    }
    
    func selectFixer(_ fixer: SwiftDataFixer) {
        selectedFixer = fixer
        calculateTimeAutomatically()
    }
    
    func updateISO(_ newISO: Int) {
        iso = newISO
        calculateTimeAutomatically()
    }
    
    func updateTemperature(_ newTemperature: Int) {
        temperature = newTemperature
        calculateTimeAutomatically()
    }
    
    func updateMode(_ newMode: ProcessMode) {
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
            
            let parameters = DevelopmentParameters(film: film, developer: developer, dilution: selectedDilution, temperature: temperature, iso: iso, time: 0)
            calculatedTime = dataService.calculateDevelopmentTime(parameters: parameters)
            
        case .fixer:
            guard let fixer = selectedFixer else {
                calculatedTime = nil
                return
            }
            calculatedTime = Int(fixer.time)
        }
    }
}