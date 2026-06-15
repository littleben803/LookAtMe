import Combine
import Foundation

@MainActor
final class DisplayConfigStore: ObservableObject {
    static let textLimit = 20

    @Published var text: String = "" {
        didSet {
            if text.count > Self.textLimit {
                text = String(text.prefix(Self.textLimit))
            }
        }
    }

    @Published var selectedScene: BannerScene {
        didSet { saveConfig() }
    }

    @Published var selectedStyleID: String {
        didSet { saveConfig() }
    }

    @Published var textColorHex: String {
        didSet { saveConfig() }
    }

    @Published var backgroundColorHex: String {
        didSet { saveConfig() }
    }

    @Published var fontScale: Double {
        didSet { saveConfig() }
    }

    @Published var speed: Double {
        didSet { saveConfig() }
    }

    @Published var fontStyle: BannerFontStyle {
        didSet { saveConfig() }
    }

    @Published var scrollDirection: BannerScrollDirection {
        didSet { saveConfig() }
    }

    @Published var isMirrored: Bool {
        didSet { saveConfig() }
    }

    @Published var isBlinking: Bool {
        didSet { saveConfig() }
    }

    private let userDefaults: UserDefaults
    private let configKey = "look.displayConfig.v1"

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        let state = Self.loadState(from: userDefaults, key: configKey)
        self.selectedScene = state.selectedScene
        self.selectedStyleID = state.selectedStyleID
        self.textColorHex = state.textColorHex
        self.backgroundColorHex = state.backgroundColorHex
        self.fontScale = state.fontScale
        self.speed = state.speed
        self.fontStyle = state.fontStyle
        self.scrollDirection = state.scrollDirection
        self.isMirrored = state.isMirrored
        self.isBlinking = state.isBlinking
    }

    var config: DisplayConfig {
        DisplayConfig(
            textColorHex: textColorHex,
            backgroundColorHex: backgroundColorHex,
            fontScale: fontScale,
            speed: speed,
            fontStyle: fontStyle,
            scrollDirection: scrollDirection,
            isMirrored: isMirrored,
            isBlinking: isBlinking
        )
    }

    var trimmedText: String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func selectScene(_ scene: BannerScene) {
        selectedScene = scene
    }

    func applyTemplate(_ template: BannerTemplate, locale: Locale) {
        selectedScene = template.scene
        text = String(template.localizedText(locale: locale).prefix(Self.textLimit))
    }

    func selectStyle(_ style: BannerStyle) {
        selectedStyleID = style.id
    }

    func applyFavorite(_ favorite: FavoriteBanner) {
        text = String(favorite.text.prefix(Self.textLimit))
        selectedScene = favorite.scene
        selectedStyleID = favorite.styleID
        textColorHex = favorite.textColorHex
        backgroundColorHex = favorite.backgroundColorHex
        fontScale = favorite.fontScale
        speed = favorite.speed
        fontStyle = favorite.fontStyle
        scrollDirection = favorite.scrollDirection
        isMirrored = favorite.isMirrored
        isBlinking = favorite.isBlinking
    }

    func draft(styleStore: StyleStore, text overrideText: String? = nil) -> BannerDraft {
        BannerDraft(
            text: overrideText ?? trimmedText,
            selectedScene: selectedScene,
            selectedStyle: styleStore.style(withID: selectedStyleID),
            textColorHex: textColorHex,
            backgroundColorHex: backgroundColorHex,
            fontScale: fontScale,
            speed: speed,
            fontStyle: fontStyle,
            scrollDirection: scrollDirection,
            isMirrored: isMirrored,
            isBlinking: isBlinking
        )
    }

    func resetAllSettings() {
        selectedScene = .concert
        selectedStyleID = "style-marquee"
        resetDisplaySettings()
    }

    func resetDisplaySettings() {
        textColorHex = LookTheme.Hex.primaryPink
        backgroundColorHex = LookTheme.Hex.backgroundBlack
        fontScale = 2.0
        speed = 1.0
        fontStyle = .roundedHeavy
        scrollDirection = .rightToLeft
        isMirrored = false
        isBlinking = false
    }

    func clearTransientState() {
        text = ""
    }

    private func saveConfig() {
        let state = DisplayConfigState(
            selectedScene: selectedScene,
            selectedStyleID: selectedStyleID,
            textColorHex: textColorHex,
            backgroundColorHex: backgroundColorHex,
            fontScale: fontScale,
            speed: speed,
            fontStyle: fontStyle,
            scrollDirection: scrollDirection,
            isMirrored: isMirrored,
            isBlinking: isBlinking
        )
        guard let data = try? JSONEncoder().encode(state) else {
            return
        }
        userDefaults.set(data, forKey: configKey)
    }

    private static func loadState(from userDefaults: UserDefaults, key: String) -> DisplayConfigState {
        guard
            let data = userDefaults.data(forKey: key),
            let state = try? JSONDecoder().decode(DisplayConfigState.self, from: data)
        else {
            return .default
        }
        return state
    }
}

private struct DisplayConfigState: Codable {
    var selectedScene: BannerScene
    var selectedStyleID: String
    var textColorHex: String
    var backgroundColorHex: String
    var fontScale: Double
    var speed: Double
    var fontStyle: BannerFontStyle
    var scrollDirection: BannerScrollDirection
    var isMirrored: Bool
    var isBlinking: Bool

    static let `default` = DisplayConfigState(
        selectedScene: .concert,
        selectedStyleID: "style-marquee",
        textColorHex: LookTheme.Hex.primaryPink,
        backgroundColorHex: LookTheme.Hex.backgroundBlack,
        fontScale: 2.0,
        speed: 1.0,
        fontStyle: .roundedHeavy,
        scrollDirection: .rightToLeft,
        isMirrored: false,
        isBlinking: false
    )
}
