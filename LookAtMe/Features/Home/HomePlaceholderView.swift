import SwiftUI

struct HomePlaceholderView: View {
    var body: some View {
        PlaceholderScreen(
            title: "想恋爱",
            subtitle: "首页",
            systemImage: "sparkles",
            message: "开始制作你的发光灯牌。"
        )
    }
}

#Preview {
    HomePlaceholderView()
}
