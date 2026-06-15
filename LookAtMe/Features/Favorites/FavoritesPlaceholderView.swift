import SwiftUI

struct FavoritesPlaceholderView: View {
    var body: some View {
        PlaceholderScreen(
            title: "收藏",
            subtitle: "收藏",
            systemImage: "heart",
            message: "保存常用灯牌，现场快速打开。"
        )
    }
}

#Preview {
    FavoritesPlaceholderView()
}
