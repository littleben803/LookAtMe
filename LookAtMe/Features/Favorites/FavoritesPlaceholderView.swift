import SwiftUI

struct FavoritesPlaceholderView: View {
    var body: some View {
        PlaceholderScreen(
            title: "收藏",
            subtitle: "收藏页占位",
            systemImage: "heart",
            message: "阶段 0 不实现收藏列表、编辑和删除逻辑，只保留主题化页面壳。"
        )
    }
}

#Preview {
    FavoritesPlaceholderView()
}

