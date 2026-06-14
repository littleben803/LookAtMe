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

    private let userDefaults: UserDefaults
    private let settingsKey = "look.settings.v1"

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        let state = Self.loadState(from: userDefaults, key: settingsKey)
        self.autoRotate = state.autoRotate
        self.keepAwake = state.keepAwake
    }

    private func save() {
        let state = SettingsState(autoRotate: autoRotate, keepAwake: keepAwake)
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

    static let `default` = SettingsState(autoRotate: true, keepAwake: true)
}
