import Combine
import Foundation

@MainActor
final class FavoriteStore: ObservableObject {
    @Published private(set) var favorites: [FavoriteBanner] = []

    private let userDefaults: UserDefaults
    private let favoritesKey = "look.favoriteBanners.v1"

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        self.favorites = Self.loadFavorites(from: userDefaults, key: favoritesKey)
    }

    func addFavorite(from draft: BannerDraft) {
        let trimmedText = draft.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else {
            return
        }

        if let existingIndex = favorites.firstIndex(where: { matches($0, draft: draft) }) {
            favorites[existingIndex].updatedAt = Date()
            save()
            return
        }

        let now = Date()
        let favorite = FavoriteBanner(
            id: UUID().uuidString,
            text: String(trimmedText.prefix(DisplayConfigStore.textLimit)),
            scene: draft.selectedScene,
            styleID: draft.selectedStyle.id,
            textColorHex: draft.textColorHex,
            backgroundColorHex: draft.backgroundColorHex,
            fontScale: draft.fontScale,
            speed: draft.speed,
            fontStyle: draft.fontStyle,
            scrollDirection: draft.scrollDirection,
            isMirrored: draft.isMirrored,
            isBlinking: draft.isBlinking,
            createdAt: now,
            updatedAt: now
        )
        favorites.insert(favorite, at: 0)
        save()
    }

    func addTemplate(_ template: BannerTemplate, displayConfigStore: DisplayConfigStore, styleStore: StyleStore) {
        let draft = displayConfigStore.draft(styleStore: styleStore, text: template.text)
        addFavorite(from: draft)
    }

    func removeFavorite(id: String) {
        favorites.removeAll { $0.id == id }
        save()
    }

    func removeFavorite(matching draft: BannerDraft) {
        guard let id = favoriteID(for: draft) else {
            return
        }
        removeFavorite(id: id)
    }

    func updateFavorite(_ favorite: FavoriteBanner) {
        guard let index = favorites.firstIndex(where: { $0.id == favorite.id }) else {
            return
        }
        var updated = favorite
        updated.updatedAt = Date()
        favorites[index] = updated
        save()
    }

    func isFavorite(draft: BannerDraft) -> Bool {
        favoriteID(for: draft) != nil
    }

    func favoriteID(for draft: BannerDraft) -> String? {
        favorites.first { matches($0, draft: draft) }?.id
    }

    func clearAll() {
        favorites.removeAll()
        save()
    }

    private func matches(_ favorite: FavoriteBanner, draft: BannerDraft) -> Bool {
        favorite.text == draft.text.trimmingCharacters(in: .whitespacesAndNewlines)
            && favorite.scene == draft.selectedScene
            && favorite.styleID == draft.selectedStyle.id
            && favorite.textColorHex == draft.textColorHex
            && favorite.backgroundColorHex == draft.backgroundColorHex
            && abs(favorite.fontScale - draft.fontScale) < 0.001
            && abs(favorite.speed - draft.speed) < 0.001
            && favorite.fontStyle == draft.fontStyle
            && favorite.scrollDirection == draft.scrollDirection
            && favorite.isMirrored == draft.isMirrored
            && favorite.isBlinking == draft.isBlinking
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(favorites) else {
            return
        }
        userDefaults.set(data, forKey: favoritesKey)
    }

    private static func loadFavorites(from userDefaults: UserDefaults, key: String) -> [FavoriteBanner] {
        guard
            let data = userDefaults.data(forKey: key),
            let favorites = try? JSONDecoder().decode([FavoriteBanner].self, from: data)
        else {
            return []
        }
        return favorites.sorted { $0.updatedAt > $1.updatedAt }
    }
}
