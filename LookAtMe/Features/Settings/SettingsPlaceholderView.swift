import SwiftUI

struct SettingsPlaceholderView: View {
    var body: some View {
        PlaceholderScreen(
            title: "设置",
            subtitle: "设置页占位",
            systemImage: "gearshape",
            message: "阶段 0 不实现设置项、恢复购买和清理逻辑，只保留主题化页面壳。"
        )
    }
}

#Preview {
    SettingsPlaceholderView()
}

