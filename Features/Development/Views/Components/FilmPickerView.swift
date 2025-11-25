//
//  SwiftDataFilmPickerView.swift
//  AnalogProcess
//
//  Created by Maxim Eliseyev on 11.08.2025.
//

import SwiftUI
import SwiftData

struct FilmPickerView: View {
    // MARK: - SwiftData Properties
    let films: [SwiftDataFilm]
    @Binding var selectedFilm: SwiftDataFilm?
    @Binding var iso: Int32
    let onDismiss: () -> Void
    let onFilmSelected: ((SwiftDataFilm) -> Void)?

    // MARK: - Computed Properties

    private var filmItems: [FilmItem] {
        films.map { FilmItem(film: $0) }
    }

    private var selectedFilmItem: FilmItem? {
        selectedFilm.flatMap { film in
            filmItems.first { $0.film.id == film.id }
        }
    }

    var body: some View {
        BasePickerView(
            selectedValue: Binding(
                get: {
                    selectedFilmItem ?? (filmItems.first ?? FilmItem(film: SwiftDataFilm()))
                },
                set: { newFilmItem in
                    selectedFilm = newFilmItem.film
                    iso = newFilmItem.film.defaultISO
                    onFilmSelected?(newFilmItem.film)
                }
            ),
            items: filmItems,
            title: LocalizedStringKey("selectFilm"),
            enableSearch: true,
            onDismiss: onDismiss
        )
    }
}
