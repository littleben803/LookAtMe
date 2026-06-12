import SwiftUI

enum BannerScene: String, CaseIterable, Identifiable {
    case concert
    case confession
    case birthday
    case pickup

    var id: String { rawValue }

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

enum BannerStyleType: String, CaseIterable, Identifiable {
    case marquee
    case neonBlink
    case heartRain
    case rainbow

    var id: String { rawValue }
}

struct BannerStyle: Identifiable, Equatable {
    let id: String
    let name: String
    let type: BannerStyleType
    let isPro: Bool
    let previewText: String
}

struct BannerDraft {
    var text: String
    var selectedScene: BannerScene
    var selectedStyle: BannerStyle
    var textColor: Color
    var backgroundColor: Color
    var fontScale: Double
    var speed: Double
}

struct DisplayConfig {
    var textColor: Color
    var backgroundColor: Color
    var fontScale: Double
    var speed: Double
}
