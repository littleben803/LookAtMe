import SwiftUI

enum BannerScene: String, CaseIterable, Identifiable, Codable {
    case concert
    case confession
    case birthday
    case pickup
    case fun

    var id: String { rawValue }

    static let homeCases: [BannerScene] = [.concert, .confession, .birthday, .pickup]

    var title: String {
        switch self {
        case .concert:
            "演唱会"
        case .confession:
            "表白"
        case .birthday:
            "生日"
        case .pickup:
            "接机"
        case .fun:
            "整活"
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
        }
    }
}

struct BannerTemplate: Identifiable, Equatable {
    let id: String
    let title: String
    let scene: BannerScene
    let text: String
    let isPro: Bool
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
    let name: String
    let type: BannerStyleType
    let isPro: Bool
    let previewText: String
}

enum BannerFontStyle: String, CaseIterable, Identifiable, Codable {
    case roundedHeavy
    case classicHeavy
    case neonTitle
    case monoBold
    case cuteRounded
    case regular

    var id: String { rawValue }

    var title: String {
        switch self {
        case .roundedHeavy:
            "圆润黑体"
        case .classicHeavy:
            "经典粗体"
        case .neonTitle:
            "霓虹标题"
        case .monoBold:
            "等宽灯牌"
        case .cuteRounded:
            "可爱圆体"
        case .regular:
            "简洁常规"
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

    var title: String {
        switch self {
        case .rightToLeft:
            "从右到左"
        case .leftToRight:
            "从左到右"
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
