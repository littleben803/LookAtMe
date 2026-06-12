import SwiftUI

struct SettingsView: View {
    @State private var autoRotate = true
    @State private var keepAwake = true

    var body: some View {
        ZStack {
            LookScreenBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: LookSpacing.lg) {
                    Text("设置")
                        .font(LookTypography.pageTitle)
                        .foregroundColor(LookTheme.Colors.textPrimary)
                        .padding(.top, LookSpacing.xl)

                    settingsGroup("显示设置") {
                        SettingsRow(title: "默认文字颜色", value: "#FF4DA6", colorSwatch: LookTheme.Colors.primaryPink)
                        Divider().overlay(LookTheme.Colors.textDisabled.opacity(0.24))
                        SettingsRow(title: "默认背景颜色", value: "#0D0221", colorSwatch: LookTheme.Colors.backgroundBlack)
                        Divider().overlay(LookTheme.Colors.textDisabled.opacity(0.24))
                        SettingsRow(title: "默认文字大小", value: "100%")
                        Divider().overlay(LookTheme.Colors.textDisabled.opacity(0.24))
                        SettingsRow(title: "默认滚动速度", value: "中等")
                        Divider().overlay(LookTheme.Colors.textDisabled.opacity(0.24))
                        SettingsToggleRow(title: "自动横屏", isOn: $autoRotate)
                        Divider().overlay(LookTheme.Colors.textDisabled.opacity(0.24))
                        SettingsToggleRow(title: "保持屏幕常亮", isOn: $keepAwake)
                    }

                    settingsGroup("其他") {
                        SettingsRow(title: "清除缓存", systemImage: "trash", action: {})
                        Divider().overlay(LookTheme.Colors.textDisabled.opacity(0.24))
                        SettingsRow(title: "给我们评分", systemImage: "star", action: {})
                        Divider().overlay(LookTheme.Colors.textDisabled.opacity(0.24))
                        SettingsRow(title: "分享给朋友", systemImage: "square.and.arrow.up", action: {})
                        Divider().overlay(LookTheme.Colors.textDisabled.opacity(0.24))
                        SettingsRow(title: "使用帮助", systemImage: "questionmark.circle", action: {})
                    }

                    settingsGroup("关于") {
                        SettingsRow(title: "关于想恋爱", action: {})
                        Divider().overlay(LookTheme.Colors.textDisabled.opacity(0.24))
                        SettingsRow(title: "隐私政策", action: {})
                        Divider().overlay(LookTheme.Colors.textDisabled.opacity(0.24))
                        SettingsRow(title: "用户协议", action: {})
                        Divider().overlay(LookTheme.Colors.textDisabled.opacity(0.24))
                        SettingsRow(title: "恢复购买", action: {})
                        Divider().overlay(LookTheme.Colors.textDisabled.opacity(0.24))
                        SettingsRow(title: "版本号", value: "2.0.0")
                    }
                }
                .padding(.horizontal, LookSpacing.pageHorizontal)
                .padding(.bottom, LookSpacing.xxxl)
            }
        }
    }

    private func settingsGroup<Content: View>(
        _ title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: LookSpacing.sm) {
            Text(title)
                .font(LookTypography.sectionTitle)
                .foregroundColor(LookTheme.Colors.hotPink)
                .padding(.horizontal, LookSpacing.xs)

            NeonCard {
                VStack(spacing: 0) {
                    content()
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}

