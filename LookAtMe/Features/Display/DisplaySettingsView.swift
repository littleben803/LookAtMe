import SwiftUI

struct DisplaySettingsView: View {
    @EnvironmentObject private var displayConfigStore: DisplayConfigStore
    @State private var isShowingResetConfirm = false

    var body: some View {
        ZStack {
            LookScreenBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: LookSpacing.lg) {
                    NeonPageHeader(
                        title: "展示设置",
                        subtitle: "调整 LED 灯牌的播放方式"
                    )

                    settingsGroup("基础参数") {
                        sliderRow(
                            title: "文字大小",
                            value: $displayConfigStore.fontScale,
                            range: 0.7...3.0,
                            valueText: "\(Int(displayConfigStore.fontScale * 100))%"
                        )
                        neonDivider
                        sliderRow(
                            title: "滚动速度",
                            value: $displayConfigStore.speed,
                            range: 0.5...2.0,
                            valueText: "\(Int(displayConfigStore.speed * 100))%"
                        )
                    }

                    settingsGroup("播放方式") {
                        VStack(alignment: .leading, spacing: LookSpacing.sm) {
                            Text("滚动方向")
                                .font(LookTypography.body)
                                .foregroundColor(LookTheme.Colors.textPrimary)

                            Picker("滚动方向", selection: $displayConfigStore.scrollDirection) {
                                ForEach(BannerScrollDirection.allCases) { direction in
                                    Text(direction.title).tag(direction)
                                }
                            }
                            .pickerStyle(.segmented)
                            .tint(LookTheme.Colors.primaryPink)
                        }
                        .padding(.vertical, LookSpacing.xs)

                        neonDivider
                        SettingsToggleRow(title: "镜像反转", isOn: $displayConfigStore.isMirrored)
                        neonDivider
                        SettingsToggleRow(title: "闪烁效果", isOn: $displayConfigStore.isBlinking)
                    }

                    Button(role: .destructive) {
                        isShowingResetConfirm = true
                    } label: {
                        Text("重置所有设置")
                            .font(LookTypography.button)
                            .foregroundColor(LookTheme.Colors.danger)
                            .frame(maxWidth: .infinity, minHeight: 52)
                            .background(
                                Capsule()
                                    .fill(LookTheme.Colors.cardPurple.opacity(0.88))
                                    .overlay(Capsule().stroke(LookTheme.Colors.danger.opacity(0.42), lineWidth: 1))
                            )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, LookSpacing.pageHorizontal)
                .padding(.top, LookSpacing.lg)
                .padding(.bottom, LookSpacing.tabContentBottomPadding)
            }
        }
        .navigationBarBackButtonHidden(true)
        .alert("重置所有展示设置？", isPresented: $isShowingResetConfirm) {
            Button("取消", role: .cancel) {}
            Button("重置", role: .destructive) {
                displayConfigStore.resetAllSettings()
            }
        } message: {
            Text("会恢复文字颜色、背景颜色、字体、大小、速度、方向等展示配置。")
        }
    }

    private var neonDivider: some View {
        Divider().overlay(LookTheme.Colors.textDisabled.opacity(0.24))
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

    private func sliderRow(
        title: String,
        value: Binding<Double>,
        range: ClosedRange<Double>,
        valueText: String
    ) -> some View {
        VStack(spacing: LookSpacing.xs) {
            HStack {
                Text(title)
                    .font(LookTypography.body)
                    .foregroundColor(LookTheme.Colors.textPrimary)
                Spacer()
                Text(valueText)
                    .font(LookTypography.caption.monospacedDigit())
                    .foregroundColor(LookTheme.Colors.textTertiary)
            }
            Slider(value: value, in: range)
                .tint(LookTheme.Colors.primaryPink)
        }
        .padding(.vertical, LookSpacing.sm)
    }
}

#Preview {
    NavigationStack {
        DisplaySettingsView()
            .environmentObject(DisplayConfigStore())
    }
}
