import Combine
import Foundation
import UIKit

@MainActor
final class AppReviewPromptStore: ObservableObject {
    static let writeReviewURL = URL(string: "https://apps.apple.com/app/id966060914?action=write-review")!

    private static let startDisplayThreshold = 10
    private static let minimumUsageInterval: TimeInterval = 2 * 24 * 60 * 60

    @Published private(set) var displayStartCount: Int
    @Published private(set) var firstDisplayStartedAt: Date?
    @Published private(set) var hasShownAutomaticPrompt: Bool

    private let userDefaults: UserDefaults
    private let stateKey = "look.reviewPrompt.v1"

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        let state = Self.loadState(from: userDefaults, key: stateKey)
        self.displayStartCount = state.displayStartCount
        self.firstDisplayStartedAt = state.firstDisplayStartedAt
        self.hasShownAutomaticPrompt = state.hasShownAutomaticPrompt
    }

    func recordSuccessfulDisplayStart(now: Date = Date()) {
        if firstDisplayStartedAt == nil {
            firstDisplayStartedAt = now
        }
        displayStartCount += 1
        save()
    }

    func consumeAutomaticPromptIfEligible(now: Date = Date()) -> Bool {
        guard
            !hasShownAutomaticPrompt,
            displayStartCount >= Self.startDisplayThreshold,
            let firstDisplayStartedAt,
            now.timeIntervalSince(firstDisplayStartedAt) >= Self.minimumUsageInterval
        else {
            return false
        }

        hasShownAutomaticPrompt = true
        save()
        return true
    }

    func suppressAutomaticPrompt() {
        guard !hasShownAutomaticPrompt else {
            return
        }

        hasShownAutomaticPrompt = true
        save()
    }

#if DEBUG
    func prepareDebugAutomaticPromptTrigger(now: Date = Date()) {
        displayStartCount = Self.startDisplayThreshold
        firstDisplayStartedAt = now.addingTimeInterval(-Self.minimumUsageInterval)
        hasShownAutomaticPrompt = false
        save()
    }

    func resetDebugAutomaticPromptState() {
        displayStartCount = AppReviewPromptState.default.displayStartCount
        firstDisplayStartedAt = AppReviewPromptState.default.firstDisplayStartedAt
        hasShownAutomaticPrompt = AppReviewPromptState.default.hasShownAutomaticPrompt
        save()
    }
#endif

    private func save() {
        let state = AppReviewPromptState(
            displayStartCount: displayStartCount,
            firstDisplayStartedAt: firstDisplayStartedAt,
            hasShownAutomaticPrompt: hasShownAutomaticPrompt
        )
        guard let data = try? JSONEncoder().encode(state) else {
            return
        }
        userDefaults.set(data, forKey: stateKey)
    }

    private static func loadState(from userDefaults: UserDefaults, key: String) -> AppReviewPromptState {
        guard
            let data = userDefaults.data(forKey: key),
            let state = try? JSONDecoder().decode(AppReviewPromptState.self, from: data)
        else {
            return .default
        }
        return state
    }
}

enum AppReviewLink {
    @MainActor
    static func openWriteReviewPage(
        onSuccess: @escaping @MainActor () -> Void = {},
        onFailure: @escaping @MainActor () -> Void = {}
    ) {
        UIApplication.shared.open(AppReviewPromptStore.writeReviewURL, options: [:]) { success in
            Task { @MainActor in
                if success {
                    onSuccess()
                } else {
                    onFailure()
                }
            }
        }
    }
}

private struct AppReviewPromptState: Codable {
    var displayStartCount: Int
    var firstDisplayStartedAt: Date?
    var hasShownAutomaticPrompt: Bool

    static let `default` = AppReviewPromptState(
        displayStartCount: 0,
        firstDisplayStartedAt: nil,
        hasShownAutomaticPrompt: false
    )
}
