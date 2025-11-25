import Foundation

enum ProcessMode: String, CaseIterable {
    case developing = "Developing"
    case fixer = "Fixer"

    var localizedName: String {
        switch self {
        case .developing:
            return String(localized: "processModesDeveloping")
        case .fixer:
            return String(localized: "processModeFixer")
        }
    }
}