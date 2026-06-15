import Foundation

struct ProPaywallContext: Identifiable {
    let id = UUID()
    let source: ProPaywallSource
    let onUnlocked: @MainActor () -> Void

    init(source: ProPaywallSource, onUnlocked: @escaping @MainActor () -> Void = {}) {
        self.source = source
        self.onUnlocked = onUnlocked
    }
}

enum ProPaywallSource {
    case homePro
    case style(nameKey: String)
    case template(titleKey: String)
    case premiumFont(titleKey: String)
    case favoriteLimit
    case favoriteProStyle
    case moreFeature(titleKey: String)
    case settingsRestore

    func promptTitle(locale: Locale) -> String {
        switch self {
        case .homePro:
            L10n.string(L10n.Pro.Context.homeTitle, locale: locale)
        case .style(let nameKey):
            L10n.format(L10n.Pro.Context.styleTitleFormat, locale: locale, L10n.string(nameKey, locale: locale))
        case .template(let titleKey):
            L10n.format(L10n.Pro.Context.templateTitleFormat, locale: locale, L10n.string(titleKey, locale: locale))
        case .premiumFont(let titleKey):
            L10n.format(L10n.Pro.Context.fontTitleFormat, locale: locale, L10n.string(titleKey, locale: locale))
        case .favoriteLimit:
            L10n.string(L10n.Pro.Context.favoriteLimitTitle, locale: locale)
        case .favoriteProStyle:
            L10n.string(L10n.Pro.Context.favoriteProStyleTitle, locale: locale)
        case .moreFeature(let titleKey):
            L10n.format(L10n.Pro.Context.moreFeatureTitleFormat, locale: locale, L10n.string(titleKey, locale: locale))
        case .settingsRestore:
            L10n.string(L10n.Pro.Context.settingsRestoreTitle, locale: locale)
        }
    }

    func promptSubtitle(locale: Locale) -> String {
        switch self {
        case .homePro:
            L10n.string(L10n.Pro.Context.homeSubtitle, locale: locale)
        case .style:
            L10n.string(L10n.Pro.Context.styleSubtitle, locale: locale)
        case .template:
            L10n.string(L10n.Pro.Context.templateSubtitle, locale: locale)
        case .premiumFont:
            L10n.string(L10n.Pro.Context.fontSubtitle, locale: locale)
        case .favoriteLimit:
            L10n.string(L10n.Pro.Context.favoriteLimitSubtitle, locale: locale)
        case .favoriteProStyle:
            L10n.string(L10n.Pro.Context.favoriteProStyleSubtitle, locale: locale)
        case .moreFeature:
            L10n.string(L10n.Pro.Context.moreFeatureSubtitle, locale: locale)
        case .settingsRestore:
            L10n.string(L10n.Pro.Context.settingsRestoreSubtitle, locale: locale)
        }
    }
}

extension BannerFontStyle {
    var isPro: Bool {
        switch self {
        case .neonTitle, .monoBold, .cuteRounded:
            true
        case .roundedHeavy, .classicHeavy, .regular:
            false
        }
    }
}
