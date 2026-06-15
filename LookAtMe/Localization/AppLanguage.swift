import Foundation

enum AppLanguage: String, CaseIterable, Codable, Identifiable {
    case system
    case zhHans = "zh-Hans"
    case zhHant = "zh-Hant"
    case en
    case ja

    var id: String { rawValue }

    var effectiveIdentifier: String {
        switch self {
        case .system:
            Self.systemResolvedLanguage.rawValue
        case .zhHans, .zhHant, .en, .ja:
            rawValue
        }
    }

    var locale: Locale {
        Locale(identifier: effectiveIdentifier)
    }

    var titleKey: String {
        switch self {
        case .system:
            L10n.Language.system
        case .zhHans:
            L10n.Language.zhHans
        case .zhHant:
            L10n.Language.zhHant
        case .en:
            L10n.Language.english
        case .ja:
            L10n.Language.japanese
        }
    }

    var detailKey: String {
        switch self {
        case .system:
            L10n.Language.followSystemDetail
        case .zhHans, .zhHant, .en, .ja:
            L10n.Language.manualDetail
        }
    }

    static var systemResolvedLanguage: AppLanguage {
        for identifier in Locale.preferredLanguages {
            if let language = supportedLanguage(for: identifier) {
                return language
            }
        }
        return .en
    }

    private static func supportedLanguage(for identifier: String) -> AppLanguage? {
        let normalized = identifier.replacingOccurrences(of: "_", with: "-").lowercased()

        if normalized.hasPrefix("zh-hant")
            || normalized.hasPrefix("zh-tw")
            || normalized.hasPrefix("zh-hk")
            || normalized.hasPrefix("zh-mo") {
            return .zhHant
        }

        if normalized.hasPrefix("zh-hans")
            || normalized.hasPrefix("zh-cn")
            || normalized.hasPrefix("zh-sg")
            || normalized.hasPrefix("zh") {
            return .zhHans
        }

        if normalized.hasPrefix("en") {
            return .en
        }

        if normalized.hasPrefix("ja") {
            return .ja
        }

        return nil
    }
}
