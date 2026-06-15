import SwiftUI

struct FavoritesPlaceholderView: View {
    var body: some View {
        PlaceholderScreen(
            title: L10n.Tab.favorites,
            subtitle: L10n.Tab.favorites,
            systemImage: "heart",
            message: L10n.Favorites.placeholderMessage
        )
    }
}

#Preview {
    FavoritesPlaceholderView()
}
