import Foundation

enum FeatureRoute: Hashable {
    case more
    case stylePicker
    case templateCenter
    case textColor
    case backgroundColor
    case fontPicker
    case displaySettings
    case languageSettings
#if DEBUG
    case debugThemeSettings
#endif
    case help
    case about
    case legal(LegalDocument)
}

enum LegalDocument: String, Hashable, Identifiable {
    case privacy
    case terms

    var id: String { rawValue }

    var titleKey: String {
        switch self {
        case .privacy:
            L10n.Legal.privacyTitle
        case .terms:
            L10n.Legal.termsTitle
        }
    }
}
