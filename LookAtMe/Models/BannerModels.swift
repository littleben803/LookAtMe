import SwiftUI

enum BannerScene: String, CaseIterable, Identifiable, Codable {
    case concert
    case confession
    case birthday
    case pickup
    case fun
    case sports
    case school
    case travel
    case oshi

    var id: String { rawValue }

    static let homeCases: [BannerScene] = [.concert, .confession, .birthday, .pickup]

    var titleKey: String {
        switch self {
        case .concert:
            L10n.BannerScene.concert
        case .confession:
            L10n.BannerScene.confession
        case .birthday:
            L10n.BannerScene.birthday
        case .pickup:
            L10n.BannerScene.pickup
        case .fun:
            L10n.BannerScene.fun
        case .sports:
            L10n.BannerScene.sports
        case .school:
            L10n.BannerScene.school
        case .travel:
            L10n.BannerScene.travel
        case .oshi:
            L10n.BannerScene.oshi
        }
    }

    var symbolName: String {
        switch self {
        case .concert:
            "wand.and.stars"
        case .confession:
            "heart.fill"
        case .birthday:
            "birthday.cake.fill"
        case .pickup:
            "airplane"
        case .fun:
            "sparkles"
        case .sports:
            "trophy.fill"
        case .school:
            "graduationcap.fill"
        case .travel:
            "signpost.right.fill"
        case .oshi:
            "star.circle.fill"
        }
    }

    var accentColor: Color {
        switch self {
        case .concert:
            LookTheme.Colors.primaryPink
        case .confession:
            LookTheme.Colors.hotPink
        case .birthday:
            LookTheme.Colors.warmYellow
        case .pickup:
            LookTheme.Colors.electricBlue
        case .fun:
            LookTheme.Colors.neonPurple
        case .sports:
            LookTheme.Colors.electricBlue
        case .school:
            LookTheme.Colors.hotPink
        case .travel:
            LookTheme.Colors.softPink
        case .oshi:
            LookTheme.Colors.warmYellow
        }
    }
}

struct BannerTemplateCopy: Equatable {
    let en: String
    let ja: String
    let zhHans: String
    let zhHant: String

    init(en: String, ja: String, zhHans: String, zhHant: String? = nil) {
        self.en = en
        self.ja = ja
        self.zhHans = zhHans
        self.zhHant = zhHant ?? zhHans
    }

    func localized(locale: Locale) -> String {
        let identifier = locale.identifier.replacingOccurrences(of: "_", with: "-").lowercased()

        if identifier.hasPrefix("ja") {
            return ja
        }

        if identifier.hasPrefix("zh-hant")
            || identifier.hasPrefix("zh-tw")
            || identifier.hasPrefix("zh-hk")
            || identifier.hasPrefix("zh-mo") {
            return zhHant
        }

        if identifier.hasPrefix("zh") {
            return zhHans
        }

        return en
    }
}

struct BannerTemplate: Identifiable, Equatable {
    let id: String
    let scene: BannerScene
    let isPro: Bool
    let titleKey: String
    let textKey: String
    let localizedTitleCopy: BannerTemplateCopy?
    let localizedTextCopy: BannerTemplateCopy?

    init(
        id: String,
        scene: BannerScene,
        isPro: Bool,
        titleKey: String? = nil,
        textKey: String? = nil,
        localizedTitleCopy: BannerTemplateCopy? = nil,
        localizedTextCopy: BannerTemplateCopy? = nil
    ) {
        self.id = id
        self.scene = scene
        self.isPro = isPro
        self.titleKey = titleKey ?? L10n.Template.title(id)
        self.textKey = textKey ?? L10n.Template.text(id)
        self.localizedTitleCopy = localizedTitleCopy
        self.localizedTextCopy = localizedTextCopy
    }

    func localizedTitle(locale: Locale) -> String {
        if let localizedTitleCopy {
            return localizedTitleCopy.localized(locale: locale)
        }

        return L10n.string(titleKey, locale: locale)
    }

    func localizedText(locale: Locale) -> String {
        if let localizedTextCopy {
            return localizedTextCopy.localized(locale: locale)
        }

        return L10n.string(textKey, locale: locale)
    }
}

enum BannerStyleType: String, CaseIterable, Identifiable, Codable {
    case marquee
    case neonBlink
    case breathing
    case typewriter
    case heartRain
    case rainbow
    case starFlash
    case bulletFlyIn
    case meteorShower
    case laserSweep
    case fireworkBurst
    case heartBeat
    case auroraWave
    case bubblePop
    case spotlight
    case glitchPulse

    var id: String { rawValue }
}

struct BannerStyle: Identifiable, Equatable {
    let id: String
    let type: BannerStyleType
    let isPro: Bool
    let nameKey: String
    let previewTextKey: String

    init(id: String, type: BannerStyleType, isPro: Bool, nameKey: String? = nil, previewTextKey: String? = nil) {
        self.id = id
        self.type = type
        self.isPro = isPro
        self.nameKey = nameKey ?? L10n.Style.name(id)
        self.previewTextKey = previewTextKey ?? L10n.Style.preview(id)
    }

    func localizedName(locale: Locale) -> String {
        L10n.string(nameKey, locale: locale)
    }

    func localizedPreviewText(locale: Locale) -> String {
        L10n.string(previewTextKey, locale: locale)
    }
}

enum BannerFontStyle: String, CaseIterable, Identifiable, Codable {
    case roundedHeavy
    case classicHeavy
    case neonTitle
    case monoBold
    case cuteRounded
    case regular

    var id: String { rawValue }

    var titleKey: String {
        switch self {
        case .roundedHeavy:
            L10n.BannerFontStyle.roundedHeavy
        case .classicHeavy:
            L10n.BannerFontStyle.classicHeavy
        case .neonTitle:
            L10n.BannerFontStyle.neonTitle
        case .monoBold:
            L10n.BannerFontStyle.monoBold
        case .cuteRounded:
            L10n.BannerFontStyle.cuteRounded
        case .regular:
            L10n.BannerFontStyle.regular
        }
    }

    var subtitle: String {
        switch self {
        case .roundedHeavy:
            "system rounded heavy"
        case .classicHeavy:
            "system heavy"
        case .neonTitle:
            "system black rounded"
        case .monoBold:
            "monospaced bold"
        case .cuteRounded:
            "system rounded bold"
        case .regular:
            "system regular"
        }
    }

    func font(size: CGFloat) -> Font {
        switch self {
        case .roundedHeavy:
            .system(size: size, weight: .heavy, design: .rounded)
        case .classicHeavy:
            .system(size: size, weight: .heavy, design: .default)
        case .neonTitle:
            .system(size: size, weight: .black, design: .rounded)
        case .monoBold:
            .system(size: size, weight: .bold, design: .monospaced)
        case .cuteRounded:
            .system(size: size, weight: .bold, design: .rounded)
        case .regular:
            .system(size: size, weight: .regular, design: .default)
        }
    }
}

enum BannerScrollDirection: String, CaseIterable, Identifiable, Codable {
    case rightToLeft
    case leftToRight

    var id: String { rawValue }

    var titleKey: String {
        switch self {
        case .rightToLeft:
            L10n.DisplaySettings.Direction.rightToLeft
        case .leftToRight:
            L10n.DisplaySettings.Direction.leftToRight
        }
    }

}

struct BannerDraft {
    var text: String
    var selectedScene: BannerScene
    var selectedStyle: BannerStyle
    var textColorHex: String
    var backgroundColorHex: String
    var fontScale: Double
    var speed: Double
    var fontStyle: BannerFontStyle
    var scrollDirection: BannerScrollDirection
    var isMirrored: Bool
    var isBlinking: Bool

    var textColor: Color { Color(hex: textColorHex) }
    var backgroundColor: Color { Color(hex: backgroundColorHex) }
}

struct DisplayConfig {
    var textColorHex: String
    var backgroundColorHex: String
    var fontScale: Double
    var speed: Double
    var fontStyle: BannerFontStyle
    var scrollDirection: BannerScrollDirection
    var isMirrored: Bool
    var isBlinking: Bool

    var textColor: Color { Color(hex: textColorHex) }
    var backgroundColor: Color { Color(hex: backgroundColorHex) }
}

struct FavoriteBanner: Identifiable, Codable, Equatable {
    let id: String
    var text: String
    var scene: BannerScene
    var styleID: String
    var textColorHex: String
    var backgroundColorHex: String
    var fontScale: Double
    var speed: Double
    var fontStyle: BannerFontStyle
    var scrollDirection: BannerScrollDirection
    var isMirrored: Bool
    var isBlinking: Bool
    var createdAt: Date
    var updatedAt: Date
}
