import Combine
import Foundation
import SwiftUI

enum LookSkinID: String, CaseIterable, Identifiable {
    case oshiPopNeon
    case liveStageConsole
    case neonUtilityPro

    var id: String { rawValue }

    static func resolve(preferredLanguages: [String] = Locale.preferredLanguages) -> LookSkinID {
        let language = normalized(preferredLanguages.first ?? Locale.current.identifier)

        if language.hasPrefix("ja") {
            return .oshiPopNeon
        }

        if language.hasPrefix("zh") {
            return .neonUtilityPro
        }

        return .liveStageConsole
    }

    private static func normalized(_ identifier: String) -> String {
        identifier
            .replacingOccurrences(of: "_", with: "-")
            .lowercased()
    }
}

struct LookSkin: Equatable {
    struct Palette: Equatable {
        let background: String
        let backgroundElevated: String
        let card: String
        let cardElevated: String
        let primary: String
        let secondary: String
        let accent: String
        let pro: String
        let textPrimary: String
        let textSecondary: String
        let textTertiary: String
    }

    struct Assets: Equatable {
        let appBackground: String
        let homeHero: String
        let paywallHero: String
    }

    struct Chrome: Equatable {
        let cardRadius: CGFloat
        let controlRadius: CGFloat
        let contentDensity: CGFloat
        let backgroundImageOpacity: Double
        let glassOpacity: Double
        let sectionSymbol: String
        let homePreviewSymbol: String
        let proHeroSymbol: String
        let templateActionSymbol: String
        let styleSelectedSymbol: String
    }

    let id: LookSkinID
    let displayName: String
    let marketName: String
    let palette: Palette
    let assets: Assets
    let chrome: Chrome

    var background: Color { Color(hex: palette.background) }
    var backgroundElevated: Color { Color(hex: palette.backgroundElevated) }
    var card: Color { Color(hex: palette.card) }
    var cardElevated: Color { Color(hex: palette.cardElevated) }
    var primary: Color { Color(hex: palette.primary) }
    var secondary: Color { Color(hex: palette.secondary) }
    var accent: Color { Color(hex: palette.accent) }
    var pro: Color { Color(hex: palette.pro) }
    var textPrimary: Color { Color(hex: palette.textPrimary) }
    var textSecondary: Color { Color(hex: palette.textSecondary) }
    var textTertiary: Color { Color(hex: palette.textTertiary) }

    var primaryButtonGradient: LinearGradient {
        LinearGradient(
            colors: [primary, secondary.opacity(0.88)],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    var neonBorderGradient: LinearGradient {
        LinearGradient(
            colors: [
                primary.opacity(0.82),
                secondary.opacity(0.58),
                accent.opacity(0.46)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var surfaceGradient: LinearGradient {
        LinearGradient(
            colors: [
                card.opacity(0.96),
                cardElevated.opacity(0.9)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var isOshiPopNeon: Bool { id == .oshiPopNeon }
    var isLiveStageConsole: Bool { id == .liveStageConsole }
    var isNeonUtilityPro: Bool { id == .neonUtilityPro }

    static func skin(for id: LookSkinID) -> LookSkin {
        switch id {
        case .oshiPopNeon:
            LookSkin(
                id: id,
                displayName: "Oshi Pop Neon",
                marketName: "Japan",
                palette: Palette(
                    background: "#07040F",
                    backgroundElevated: "#160B24",
                    card: "#1B102A",
                    cardElevated: "#311445",
                    primary: "#FF4DA6",
                    secondary: "#00F2FF",
                    accent: "#5CFFB1",
                    pro: "#FFD166",
                    textPrimary: "#FFFFFF",
                    textSecondary: "#FFE1F5",
                    textTertiary: "#CDB9DD"
                ),
                assets: Assets(
                    appBackground: "OshiPopNeonAppBackground",
                    homeHero: "OshiPopNeonHomeHero",
                    paywallHero: "OshiPopNeonPaywallHero"
                ),
                chrome: Chrome(
                    cardRadius: 22,
                    controlRadius: 16,
                    contentDensity: 0.94,
                    backgroundImageOpacity: 0.96,
                    glassOpacity: 0.88,
                    sectionSymbol: "sparkles",
                    homePreviewSymbol: "heart.fill",
                    proHeroSymbol: "crown.fill",
                    templateActionSymbol: "wand.and.stars",
                    styleSelectedSymbol: "checkmark.seal.fill"
                )
            )
        case .liveStageConsole:
            LookSkin(
                id: id,
                displayName: "Live Stage Console",
                marketName: "United States",
                palette: Palette(
                    background: "#050712",
                    backgroundElevated: "#0D1222",
                    card: "#111827",
                    cardElevated: "#202A3E",
                    primary: "#FF3E9E",
                    secondary: "#00E7FF",
                    accent: "#38F29A",
                    pro: "#FFD166",
                    textPrimary: "#FFFFFF",
                    textSecondary: "#F2F5FF",
                    textTertiary: "#AEB7C7"
                ),
                assets: Assets(
                    appBackground: "LiveStageConsoleAppBackground",
                    homeHero: "LiveStageConsoleHomeHero",
                    paywallHero: "LiveStageConsolePaywallHero"
                ),
                chrome: Chrome(
                    cardRadius: 16,
                    controlRadius: 11,
                    contentDensity: 1,
                    backgroundImageOpacity: 0.86,
                    glassOpacity: 0.82,
                    sectionSymbol: "slider.horizontal.3",
                    homePreviewSymbol: "dot.radiowaves.left.and.right",
                    proHeroSymbol: "bolt.circle.fill",
                    templateActionSymbol: "arrow.up.right.circle.fill",
                    styleSelectedSymbol: "checkmark.circle.fill"
                )
            )
        case .neonUtilityPro:
            LookSkin(
                id: id,
                displayName: "Neon Utility Pro",
                marketName: "Mainland China / Taiwan",
                palette: Palette(
                    background: "#060915",
                    backgroundElevated: "#0B1630",
                    card: "#101A2D",
                    cardElevated: "#162846",
                    primary: "#FF4DA6",
                    secondary: "#00F2FF",
                    accent: "#8DF07B",
                    pro: "#FFD166",
                    textPrimary: "#F7FAFF",
                    textSecondary: "#EAF2FF",
                    textTertiary: "#A8B6D3"
                ),
                assets: Assets(
                    appBackground: "NeonUtilityProAppBackground",
                    homeHero: "NeonUtilityProHomeHero",
                    paywallHero: "NeonUtilityProPaywallHero"
                ),
                chrome: Chrome(
                    cardRadius: 12,
                    controlRadius: 8,
                    contentDensity: 1.08,
                    backgroundImageOpacity: 0.78,
                    glassOpacity: 0.76,
                    sectionSymbol: "rectangle.grid.2x2.fill",
                    homePreviewSymbol: "waveform.path.ecg",
                    proHeroSymbol: "lock.shield.fill",
                    templateActionSymbol: "plus.square.fill",
                    styleSelectedSymbol: "checkmark.square.fill"
                )
            )
        }
    }
}

@MainActor
final class LookSkinManager: ObservableObject {
    @Published private(set) var skin: LookSkin
#if DEBUG
    @Published private(set) var debugSkinID: LookSkinID

    private static let debugSkinOverrideKey = "look.debug.skinOverride.v1"
#endif

    init(preferredLanguages: [String] = Locale.preferredLanguages) {
        let resolvedSkinID = LookSkinID.resolve(preferredLanguages: preferredLanguages)
#if DEBUG
        let initialSkinID = Self.debugSkinOverride(defaultID: resolvedSkinID)
        self.debugSkinID = initialSkinID
        self.skin = LookSkin.skin(for: initialSkinID)
#else
        self.skin = LookSkin.skin(for: resolvedSkinID)
#endif
    }

    func refreshFromSystemLanguage(preferredLanguages: [String] = Locale.preferredLanguages) {
#if DEBUG
        guard !LookDebugOptions.isThemeDebugEntryPointEnabled else {
            return
        }
#endif

        let resolvedSkin = LookSkin.skin(for: LookSkinID.resolve(preferredLanguages: preferredLanguages))
        guard resolvedSkin != skin else {
            return
        }
        skin = resolvedSkin
    }

#if DEBUG
    func selectDebugSkin(_ id: LookSkinID) {
        debugSkinID = id
        UserDefaults.standard.set(id.rawValue, forKey: Self.debugSkinOverrideKey)

        let selectedSkin = LookSkin.skin(for: id)
        guard selectedSkin != skin else {
            return
        }
        skin = selectedSkin
    }

    private static func debugSkinOverride(defaultID: LookSkinID) -> LookSkinID {
        guard LookDebugOptions.isThemeDebugEntryPointEnabled else {
            return defaultID
        }

        guard
            let storedValue = UserDefaults.standard.string(forKey: debugSkinOverrideKey),
            let storedID = LookSkinID(rawValue: storedValue)
        else {
            UserDefaults.standard.set(defaultID.rawValue, forKey: debugSkinOverrideKey)
            return defaultID
        }

        return storedID
    }
#endif
}

private struct LookSkinEnvironmentKey: EnvironmentKey {
    static let defaultValue = LookSkin.skin(for: LookSkinID.resolve())
}

extension EnvironmentValues {
    var lookSkin: LookSkin {
        get { self[LookSkinEnvironmentKey.self] }
        set { self[LookSkinEnvironmentKey.self] = newValue }
    }
}
