import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var displayConfigStore: DisplayConfigStore
    @EnvironmentObject private var favoriteStore: FavoriteStore
    @EnvironmentObject private var settingsStore: SettingsStore

    @State private var path: [FeatureRoute] = []
    @State private var isShowingClearConfirm = false
    @State private var toastMessage: String?

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                LookScreenBackground()

                VStack(alignment: .leading, spacing: 0) {
                    fixedHeader

                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: LookSpacing.lg) {
                            settingsGroup("显示设置") {
                                resetDisplaySettingsButton
                            } content: {
                                SettingsRow(
                                    title: "默认文字颜色",
                                    value: displayConfigStore.textColorHex,
                                    colorSwatch: Color(hex: displayConfigStore.textColorHex)
                                ) {
                                    path.append(.textColor)
                                }
                                neonDivider
                                SettingsRow(
                                    title: "默认背景颜色",
                                    value: displayConfigStore.backgroundColorHex,
                                    colorSwatch: Color(hex: displayConfigStore.backgroundColorHex)
                                ) {
                                    path.append(.backgroundColor)
                                }
                                neonDivider
                                SettingsRow(title: "默认文字大小", value: "\(Int(displayConfigStore.fontScale * 100))%") {
                                    path.append(.displaySettings)
                                }
                                neonDivider
                                SettingsRow(title: "默认滚动速度", value: speedText) {
                                    path.append(.displaySettings)
                                }
                                neonDivider
                                SettingsToggleRow(title: "自动横屏", isOn: $settingsStore.autoRotate)
                                neonDivider
                                SettingsToggleRow(title: "保持屏幕常亮", isOn: $settingsStore.keepAwake)
                            }

                            settingsGroup("其他") {
                                SettingsRow(title: "清除缓存", systemImage: "trash") {
                                    isShowingClearConfirm = true
                                }
                                neonDivider
                                SettingsRow(title: "给我们评分", systemImage: "star") {
                                    showToast("评分功能将在上架后开启")
                                }
                                neonDivider
                                ShareLink(item: "想恋爱：把手机变成会发光的表白灯牌") {
                                    shareRow
                                }
                                neonDivider
                                SettingsRow(title: "使用帮助", systemImage: "questionmark.circle") {
                                    path.append(.help)
                                }
                            }

                            settingsGroup("关于") {
                                SettingsRow(title: "关于想恋爱") {
                                    path.append(.about)
                                }
                                neonDivider
                                SettingsRow(title: "隐私政策") {
                                    path.append(.legal(.privacy))
                                }
                                neonDivider
                                SettingsRow(title: "用户协议") {
                                    path.append(.legal(.terms))
                                }
                                neonDivider
                                SettingsRow(title: "恢复购买") {
                                    showToast("Pro 购买将在下一阶段接入")
                                }
                                neonDivider
                                SettingsRow(title: "版本号", value: "2.0.0")
                            }
                        }
                        .padding(.horizontal, LookSpacing.pageHorizontal)
                        .padding(.bottom, LookSpacing.tabContentBottomPadding)
                    }
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: FeatureRoute.self) { route in
                destination(for: route)
            }
        }
        .overlay(alignment: .top) {
            if let toastMessage {
                ToastView(message: toastMessage)
                    .padding(.top, LookSpacing.lg)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.28, dampingFraction: 0.86), value: toastMessage)
        .onChange(of: toastMessage) { _, message in
            guard message != nil else { return }
            Task { @MainActor in
                try? await Task.sleep(for: .seconds(1.7))
                toastMessage = nil
            }
        }
        .confirmationDialog("清除缓存", isPresented: $isShowingClearConfirm, titleVisibility: .visible) {
            Button("仅清理临时状态") {
                displayConfigStore.clearTransientState()
                showToast("已清理临时状态")
            }
            Button("同时删除收藏", role: .destructive) {
                displayConfigStore.clearTransientState()
                favoriteStore.clearAll()
                showToast("已清理临时状态和收藏")
            }
            Button("取消", role: .cancel) {}
        } message: {
            Text("默认不会删除收藏；选择“同时删除收藏”才会清空收藏数据。")
        }
    }

    @ViewBuilder
    private func destination(for route: FeatureRoute) -> some View {
        switch route {
        case .more:
            MoreFeaturesView()
        case .stylePicker:
            StylePickerView()
        case .templateCenter:
            TemplateCenterView { _ in }
        case .textColor:
            TextColorPickerView()
        case .backgroundColor:
            BackgroundColorPickerView()
        case .fontPicker:
            FontPickerView()
        case .displaySettings:
            DisplaySettingsView()
        case .help:
            HelpView()
        case .about:
            AboutView()
        case .legal(let document):
            LegalTextView(document: document)
        }
    }

    private var speedText: String {
        switch displayConfigStore.speed {
        case ..<0.85:
            "较慢"
        case 0.85...1.25:
            "中等"
        default:
            "较快"
        }
    }

    private var fixedHeader: some View {
        Text("设置")
            .font(LookTypography.pageTitle)
            .foregroundColor(LookTheme.Colors.textPrimary)
            .padding(.horizontal, LookSpacing.pageHorizontal)
            .padding(.top, LookSpacing.xl)
            .padding(.bottom, LookSpacing.md)
    }

    private var resetDisplaySettingsButton: some View {
        Button {
            resetDisplaySettings()
        } label: {
            HStack(spacing: LookSpacing.xxs) {
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                Text("重置")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
            }
            .foregroundColor(LookTheme.Colors.hotPink)
            .padding(.horizontal, LookSpacing.sm)
            .padding(.vertical, LookSpacing.xs)
            .background(
                Capsule()
                    .fill(LookTheme.Colors.cardPurple.opacity(0.86))
                    .overlay(Capsule().stroke(LookTheme.Colors.primaryPink.opacity(0.34), lineWidth: 1))
            )
        }
        .buttonStyle(.plain)
    }

    private var neonDivider: some View {
        Divider().overlay(LookTheme.Colors.textDisabled.opacity(0.24))
    }

    private var shareRow: some View {
        HStack(spacing: LookSpacing.sm) {
            Image(systemName: "square.and.arrow.up")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(LookTheme.Colors.primaryPink)
                .frame(width: 22)

            Text("分享给朋友")
                .font(LookTypography.body)
                .foregroundColor(LookTheme.Colors.textPrimary)

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(LookTheme.Colors.textDisabled)
        }
        .padding(.vertical, LookSpacing.sm)
    }

    private func settingsGroup<Content: View>(
        _ title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        settingsGroup(title, trailing: { EmptyView() }, content: content)
    }

    private func settingsGroup<Content: View, Trailing: View>(
        _ title: String,
        @ViewBuilder trailing: () -> Trailing,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: LookSpacing.sm) {
            HStack(alignment: .center) {
                Text(title)
                    .font(LookTypography.sectionTitle)
                    .foregroundColor(LookTheme.Colors.hotPink)

                Spacer()
                trailing()
            }
            .padding(.horizontal, LookSpacing.xs)

            NeonCard {
                VStack(spacing: 0) {
                    content()
                }
            }
        }
    }

    private func resetDisplaySettings() {
        displayConfigStore.resetDisplaySettings()
        settingsStore.resetDisplaySettings()
        showToast("已恢复默认显示设置")
    }

    private func showToast(_ message: String) {
        toastMessage = message
    }
}

#Preview {
    SettingsView()
        .environmentObject(DisplayConfigStore())
        .environmentObject(FavoriteStore())
        .environmentObject(SettingsStore())
        .environmentObject(TemplateStore())
        .environmentObject(StyleStore())
}
