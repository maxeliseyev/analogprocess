//
//  BasePickerView.swift
//  Film Lab
//
//  Created by Maxim Eliseyev on 12.07.2025.
//

import SwiftUI
import UIKit
import SwiftData

protocol BasePickerItem: Hashable {
    var displayTitle: String { get }
    var isAvailable: Bool { get }
}

protocol Searchable {
    var searchableText: String { get }
}

struct BasePickerView<T: BasePickerItem>: View {
    @Binding var selectedValue: T
    let items: [T]
    let title: LocalizedStringKey
    let onDismiss: () -> Void
    let enableSearch: Bool

    @State private var searchText = ""

    init(selectedValue: Binding<T>, items: [T], title: LocalizedStringKey, enableSearch: Bool = false, onDismiss: @escaping () -> Void) {
        self._selectedValue = selectedValue
        self.items = items
        self.title = title
        self.enableSearch = enableSearch
        self.onDismiss = onDismiss
    }

    private var filteredItems: [T] {
        guard enableSearch, !searchText.isEmpty else { return items }

        return items.filter { item in
            if let searchableItem = item as? Searchable {
                return searchableItem.searchableText.localizedCaseInsensitiveContains(searchText)
            } else {
                return item.displayTitle.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground).ignoresSafeArea()
                
                VStack(spacing: 0) {
                    if enableSearch {
                        SearchBar(text: $searchText)
                            .padding(.horizontal)
                            .padding(.top, 8)
                    }

                    Group {
                        if filteredItems.isEmpty {
                            VStack(spacing: 20) {
                                Image(systemName: enableSearch && !searchText.isEmpty ? "magnifyingglass" : "info.circle")
                                    .infoIconStyle()

                                Text(LocalizedStringKey(enableSearch && !searchText.isEmpty ? "noResultsFound" : "noOptionsAvailable"))
                                    .font(.headline)
                                    .foregroundColor(.primary)

                                Text(LocalizedStringKey(enableSearch && !searchText.isEmpty ? "trySearchingDifferentKeywords" : "noOptionsDescription"))
                                    .disabledTextStyle()
                                    .multilineTextAlignment(.center)
                            }
                            .padding()
                        } else {
                            List(filteredItems, id: \.self) { item in
                                Button(action: {
                                    if item.isAvailable {
                                        selectedValue = item
                                        onDismiss()
                                    }
                                }) {
                                    HStack {
                                        Text(item.displayTitle)
                                            .primaryTextStyle()
                                            .foregroundColor(item.isAvailable ? .primary : .secondary)

                                        Spacer()

                                        if selectedValue == item {
                                            Image(systemName: "checkmark")
                                                .checkmarkStyle()
                                        }
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                                .disabled(!item.isAvailable)
                            }
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(title)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(LocalizedStringKey("cancel")) {
                        onDismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Specific Implementations

struct ISOItem: BasePickerItem {
    let value: Int
    let isAvailable: Bool

    var displayTitle: String {
        String(format: String(localized: "isoLabel"), "\(value)")
    }

    static func == (lhs: ISOItem, rhs: ISOItem) -> Bool {
        lhs.value == rhs.value
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(value)
    }
}

struct FilmItem: BasePickerItem, Searchable {
    let film: SwiftDataFilm

    var displayTitle: String {
        "\(film.manufacturer) \(film.name)"
    }

    var isAvailable: Bool {
        true // Films are always available for selection
    }

    var searchableText: String {
        "\(film.name) \(film.manufacturer)".lowercased()
    }

    static func == (lhs: FilmItem, rhs: FilmItem) -> Bool {
        lhs.film.id == rhs.film.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(film.id)
    }
}

struct DeveloperItem: BasePickerItem, Searchable {
    let developer: SwiftDataDeveloper

    var displayTitle: String {
        "\(developer.manufacturer) \(developer.name)"
    }

    var isAvailable: Bool {
        true // Developers are always available for selection
    }

    var searchableText: String {
        "\(developer.name) \(developer.manufacturer)".lowercased()
    }

    static func == (lhs: DeveloperItem, rhs: DeveloperItem) -> Bool {
        lhs.developer.id == rhs.developer.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(developer.id)
    }
}

struct FixerItem: BasePickerItem, Searchable {
    let fixer: SwiftDataFixer

    var displayTitle: String {
        let typeDisplay = getFixerTypeDisplayName(fixer.type)
        let timeDisplay = "\(fixer.time / 60) мин"
        return "\(fixer.name) • \(typeDisplay) • \(timeDisplay)"
    }

    var isAvailable: Bool {
        true // Fixers are always available for selection
    }

    var searchableText: String {
        "\(fixer.name) \(getFixerTypeDisplayName(fixer.type))".lowercased()
    }

    static func == (lhs: FixerItem, rhs: FixerItem) -> Bool {
        lhs.fixer.id == rhs.fixer.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(fixer.id)
    }

    private func getFixerTypeDisplayName(_ type: String) -> String {
        switch type {
        case "rapid":
            return "Быстрый фиксаж"
        case "acid":
            return "Кислый фиксаж"
        case "neutral":
            return "Нейтральный фиксаж"
        default:
            return type
        }
    }
}

struct DilutionItem: BasePickerItem {
    let dilution: String
    let isDisabled: Bool

    var displayTitle: String {
        dilution
    }

    var isAvailable: Bool {
        !isDisabled
    }

    static func == (lhs: DilutionItem, rhs: DilutionItem) -> Bool {
        lhs.dilution == rhs.dilution
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(dilution)
    }
}

struct TemperatureItem: BasePickerItem {
    let temperature: Int

    var displayTitle: String {
        "\(temperature)\(String(localized: "degreesCelsius"))"
    }

    var isAvailable: Bool {
        true // All temperatures are available for selection
    }

    static func == (lhs: TemperatureItem, rhs: TemperatureItem) -> Bool {
        lhs.temperature == rhs.temperature
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(temperature)
    }
}

// MARK: - SearchBar Component

struct SearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)

            TextField("Search...", text: $text)
                .textFieldStyle(PlainTextFieldStyle())

            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

// MARK: - Preview

struct BasePickerView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            BasePickerView(
                selectedValue: .constant(ISOItem(value: 400, isAvailable: true)),
                items: [
                    ISOItem(value: 100, isAvailable: true),
                    ISOItem(value: 200, isAvailable: true),
                    ISOItem(value: 400, isAvailable: true),
                    ISOItem(value: 800, isAvailable: true)
                ],
                title: LocalizedStringKey("selectISO"),
                enableSearch: true,
                onDismiss: {}
            )

            BasePickerView(
                selectedValue: .constant(ISOItem(value: 400, isAvailable: true)),
                items: [],
                title: LocalizedStringKey("selectISO"),
                enableSearch: false,
                onDismiss: {}
            )
        }
    }
} 