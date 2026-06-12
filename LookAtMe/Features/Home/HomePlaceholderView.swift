import SwiftUI

struct HomePlaceholderView: View {
    var body: some View {
        PlaceholderScreen(
            title: "想恋爱",
            subtitle: "首页占位",
            systemImage: "sparkles",
            message: "阶段 0 仅验证 App 入口、Tab 结构和主题接入。正式首页将在后续阶段实现。"
        )
    }
}

#Preview {
    HomePlaceholderView()
}

