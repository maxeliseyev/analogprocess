//
//  DevelopmentParametersView.swift
//  Film Lab
//
//  Created by Maxim Eliseyev on 12.07.2025.
//

import SwiftUI

struct DevelopmentParametersView: View {
    @ObservedObject var viewModel: DevelopmentSetupViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            if viewModel.selectedMode == ProcessMode.developing {
                // Development parameters
                ParameterRow(
                    label: String(localized: "film"),
                    value: viewModel.selectedFilm?.name ?? String(localized: "selectFilm"),
                    onTap: { viewModel.showFilmPicker = true },
                    isDisabled: false
                )
                
                ParameterRow(
                    label: String(localized: "developer"),
                    value: viewModel.selectedDeveloper?.name ?? String(localized: "selectDeveloper"),
                    onTap: { viewModel.showDeveloperPicker = true },
                    isDisabled: false
                )
                
                ParameterRow(
                    label: String(localized: "dilution"),
                    value: viewModel.selectedDilution.isEmpty ? String(localized: "selectDilution") : viewModel.selectedDilution,
                    onTap: { viewModel.showDilutionPicker = true },
                    isDisabled: viewModel.selectedFilm == nil || viewModel.selectedDeveloper == nil || viewModel.isDilutionSelectionLocked
                )
                
                ParameterRow(
                    label: String(localized: "iso"),
                    value: "\(viewModel.iso)",
                    onTap: {
                        if !viewModel.isISOSelectionLocked {
                            viewModel.showISOPicker = true
                        }
                    },
                    isDisabled: viewModel.selectedFilm == nil || viewModel.selectedDeveloper == nil || viewModel.selectedDilution.isEmpty || viewModel.isISOSelectionLocked
                )
                if viewModel.isISOSelectionLocked {
                    Text(LocalizedStringKey("noAlternativeOptions"))
                        .captionTextStyle()
                }
                
                ParameterRow(
                    label: String(localized: "temperature"),
                    value: "\(viewModel.temperature)\(String(localized: "StandardC"))",
                    onTap: { viewModel.showTemperaturePicker = true },
                    isDisabled: viewModel.isTemperatureSelectionLocked
                )
                if viewModel.isTemperatureSelectionLocked {
                    Text(LocalizedStringKey("noAlternativeOptions"))
                        .captionTextStyle()
                }
            } else {
                // Fixer parameters
                ParameterRow(
                    label: String(localized: "film"),
                    value: viewModel.selectedFilm?.name ?? String(localized: "selectFilm"),
                    onTap: { viewModel.showFilmPicker = true },
                    isDisabled: false
                )
                
                ParameterRow(
                    label: String(localized: "fixer"),
                    value: viewModel.selectedFixer?.name ?? String(localized: "selectFixer"),
                    onTap: { viewModel.showFixerPicker = true },
                    isDisabled: false
                )
                
                ParameterRow(
                    label: String(localized: "temperature"),
                    value: "\(viewModel.temperature)\(String(localized: "StandardC"))",
                    onTap: { viewModel.showTemperaturePicker = true },
                    isDisabled: false
                )
                
               
            }
        }
        .padding(.horizontal, 20)
    }
}