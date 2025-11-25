//
//  AutoCompleteManager.swift
//  AnalogProcess
//
//  Created by Maxim Eliseyev on 25.09.2025.
//

import Foundation
import Combine

// MARK: - AutoCompleteItem Protocol

/// Протокол для элементов автодополнения
protocol AutoCompleteItem {
    /// Текст для поиска и сравнения
    var searchableText: String { get }
    /// Отображаемый текст в списке предложений
    var displayText: String { get }
}

// MARK: - String Extension

extension String: AutoCompleteItem {
    var searchableText: String { self }
    var displayText: String { self }
}

// MARK: - AutoCompleteManager

/// Универсальный менеджер автодополнения с поддержкой generic типов
@MainActor
class AutoCompleteManager<T: AutoCompleteItem>: ObservableObject {
    // MARK: - Published Properties

    @Published var suggestions: [T] = []
    @Published var isShowingSuggestions: Bool = false

    // MARK: - Private Properties

    private let dataSource: () -> [T]
    private let maxSuggestions: Int

    // MARK: - Initialization

    /// Инициализация менеджера автодополнения
    /// - Parameters:
    ///   - dataSource: Замыкание для получения источника данных
    ///   - maxSuggestions: Максимальное количество предложений (по умолчанию 5)
    init(dataSource: @escaping () -> [T], maxSuggestions: Int = 5) {
        self.dataSource = dataSource
        self.maxSuggestions = maxSuggestions
    }

    // MARK: - Public Methods

    /// Обновляет список предложений на основе поискового текста
    /// - Parameter searchText: Текст для поиска
    func updateSuggestions(for searchText: String) {
        let trimmedText = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        guard !trimmedText.isEmpty else {
            clearSuggestions()
            return
        }

        let allItems = dataSource()
        let filteredItems = allItems.filter { item in
            item.searchableText.lowercased().contains(trimmedText)
        }

        suggestions = Array(filteredItems.prefix(maxSuggestions))
        isShowingSuggestions = !suggestions.isEmpty
    }

    /// Выбирает предложение и скрывает список
    /// - Parameter item: Выбранный элемент
    /// - Returns: displayText выбранного элемента
    func selectSuggestion(_ item: T) -> String {
        hideSuggestions()
        return item.displayText
    }

    /// Скрывает список предложений
    func hideSuggestions() {
        isShowingSuggestions = false
        suggestions = []
    }

    /// Очищает предложения без изменения видимости
    func clearSuggestions() {
        suggestions = []
        isShowingSuggestions = false
    }
}

// MARK: - Convenience Extensions for SwiftData

extension AutoCompleteManager where T == String {
    /// Создает менеджер для статических строковых данных
    /// - Parameters:
    ///   - staticData: Массив строк для автодополнения
    ///   - maxSuggestions: Максимальное количество предложений
    /// - Returns: Настроенный AutoCompleteManager
    static func forStaticData(_ staticData: [String], maxSuggestions: Int = 5) -> AutoCompleteManager<String> {
        return AutoCompleteManager<String>(
            dataSource: { staticData },
            maxSuggestions: maxSuggestions
        )
    }
}

// MARK: - SwiftData Model Extensions

/// Расширение для работы со SwiftData моделями пленок
struct FilmAutoCompleteItem: AutoCompleteItem {
    let film: SwiftDataFilm

    var searchableText: String {
        "\(film.name) \(film.manufacturer)".lowercased()
    }

    var displayText: String {
        film.name
    }
}

/// Расширение для работы со SwiftData моделями проявителей
struct DeveloperAutoCompleteItem: AutoCompleteItem {
    let developer: SwiftDataDeveloper

    var searchableText: String {
        "\(developer.name) \(developer.manufacturer)".lowercased()
    }

    var displayText: String {
        developer.name
    }
}

// MARK: - Convenience Factory Methods

extension AutoCompleteManager {
    /// Создает менеджер для пленок из SwiftDataService
    /// - Parameters:
    ///   - swiftDataService: Сервис для получения данных
    ///   - maxSuggestions: Максимальное количество предложений
    /// - Returns: Настроенный AutoCompleteManager для пленок
    static func forFilms(
        swiftDataService: SwiftDataService,
        maxSuggestions: Int = 5
    ) -> AutoCompleteManager<FilmAutoCompleteItem> {
        return AutoCompleteManager<FilmAutoCompleteItem>(
            dataSource: {
                swiftDataService.films.map { FilmAutoCompleteItem(film: $0) }
            },
            maxSuggestions: maxSuggestions
        )
    }

    /// Создает менеджер для проявителей из SwiftDataService
    /// - Parameters:
    ///   - swiftDataService: Сервис для получения данных
    ///   - maxSuggestions: Максимальное количество предложений
    /// - Returns: Настроенный AutoCompleteManager для проявителей
    static func forDevelopers(
        swiftDataService: SwiftDataService,
        maxSuggestions: Int = 5
    ) -> AutoCompleteManager<DeveloperAutoCompleteItem> {
        return AutoCompleteManager<DeveloperAutoCompleteItem>(
            dataSource: {
                swiftDataService.developers.map { DeveloperAutoCompleteItem(developer: $0) }
            },
            maxSuggestions: maxSuggestions
        )
    }
}