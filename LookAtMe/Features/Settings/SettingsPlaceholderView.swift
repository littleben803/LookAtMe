import SwiftUI

struct SettingsPlaceholderView: View {
    var body: some View {
        PlaceholderScreen(
            title: "设置",
            subtitle: "设置",
            systemImage: "gearshape",
            message: "调整显示偏好和查看应用信息。"
        )
    }
}

#Preview {
    SettingsPlaceholderView()
}
