import Combine
import Foundation

@MainActor
final class SettingsStore: ObservableObject {
    @Published var autoRotate: Bool {
        didSet { save() }
    }

    @Published var keepAwake: Bool {
        didSet { save() }
    }

    @Published var appLanguage: AppLanguage {
        didSet { save() }
    }

    private let userDefaults: UserDefaults
    private let settingsKey = "look.settings.v1"

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        let state = Self.loadState(from: userDefaults, key: settingsKey)
        self.autoRotate = state.autoRotate
        self.keepAwake = state.keepAwake
        self.appLanguage = state.appLanguage
    }

    func resetDisplaySettings() {
        autoRotate = SettingsState.default.autoRotate
        keepAwake = SettingsState.default.keepAwake
    }

    private func save() {
        let state = SettingsState(autoRotate: autoRotate, keepAwake: keepAwake, appLanguage: appLanguage)
        guard let data = try? JSONEncoder().encode(state) else {
            return
        }
        userDefaults.set(data, forKey: settingsKey)
    }

    private static func loadState(from userDefaults: UserDefaults, key: String) -> SettingsState {
        guard
            let data = userDefaults.data(forKey: key),
            let state = try? JSONDecoder().decode(SettingsState.self, from: data)
        else {
            return .default
        }
        return state
    }
}

private struct SettingsState: Codable {
    var autoRotate: Bool
    var keepAwake: Bool
    var appLanguage: AppLanguage

    static let `default` = SettingsState(autoRotate: true, keepAwake: true, appLanguage: .system)

    init(autoRotate: Bool, keepAwake: Bool, appLanguage: AppLanguage) {
        self.autoRotate = autoRotate
        self.keepAwake = keepAwake
        self.appLanguage = appLanguage
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.autoRotate = try container.decodeIfPresent(Bool.self, forKey: .autoRotate) ?? Self.default.autoRotate
        self.keepAwake = try container.decodeIfPresent(Bool.self, forKey: .keepAwake) ?? Self.default.keepAwake
        self.appLanguage = try container.decodeIfPresent(AppLanguage.self, forKey: .appLanguage) ?? Self.default.appLanguage
    }
}
