import SwiftUI

struct MoreFeaturesView: View {
    @EnvironmentObject private var purchaseManager: PurchaseManager
    @State private var toastMessage: String?
    @State private var paywallContext: ProPaywallContext?

    private let columns = [
        GridItem(.flexible(), spacing: LookSpacing.sm),
        GridItem(.flexible(), spacing: LookSpacing.sm)
    ]

    var body: some View {
        ZStack {
            LookScreenBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: LookSpacing.lg) {
                    NeonPageHeader(
                        title: "更多功能",
                        subtitle: "把灯牌调成你想要的样子"
                    )

                    SectionHeader("基础工具")
                    LazyVGrid(columns: columns, spacing: LookSpacing.sm) {
                        featureLink("样式选择", subtitle: "切换展示效果", icon: "sparkles", route: .stylePicker)
                        featureLink("模板中心", subtitle: "更多现成文案", icon: "text.quote", route: .templateCenter)
                        featureLink("文字颜色", subtitle: "24 个常用色", icon: "paintpalette.fill", route: .textColor)
                        featureLink("背景颜色", subtitle: "深色舞台背景", icon: "circle.lefthalf.filled", route: .backgroundColor)
                        featureLink("字体选择", subtitle: "不同灯牌气质", icon: "textformat", route: .fontPicker)
                        featureLink("展示设置", subtitle: "速度、大小、方向", icon: "slider.horizontal.3", route: .displaySettings)
                    }

                    SectionHeader(
                        purchaseManager.isProUnlocked ? "高级功能区" : "Pro 功能区",
                        subtitle: purchaseManager.isProUnlocked ? "全部高级灯牌能力已可使用" : "解锁后使用高级灯牌能力"
                    )
                    LazyVGrid(columns: columns, spacing: LookSpacing.sm) {
                        proFeature("随机灯牌", subtitle: "一键生成惊喜", icon: "shuffle")
                        proFeature("快速截图", subtitle: "保存灯牌画面", icon: "camera.fill")
                        proFeature("品牌水印", subtitle: "自定义署名", icon: "seal.fill")
                        proFeature("高级动效", subtitle: "更丰富 LED 效果", icon: "wand.and.stars.inverse")
                    }
                }
                .padding(.horizontal, LookSpacing.pageHorizontal)
                .padding(.top, LookSpacing.lg)
                .padding(.bottom, LookSpacing.tabContentBottomPadding)
            }
        }
        .navigationBarBackButtonHidden(true)
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
        .fullScreenCover(item: $paywallContext) { context in
            ProPaywallView(context: context)
        }
    }

    private func featureLink(_ title: String, subtitle: String, icon: String, route: FeatureRoute) -> some View {
        NavigationLink(value: route) {
            FeatureGridCardLabel(title: title, subtitle: subtitle, systemImage: icon)
        }
        .buttonStyle(.plain)
    }

    private func proFeature(_ title: String, subtitle: String, icon: String) -> some View {
        FeatureGridCard(
            title: title,
            subtitle: subtitle,
            systemImage: icon,
            isPro: !purchaseManager.isProUnlocked,
            isLocked: !purchaseManager.isProUnlocked
        ) {
            guard purchaseManager.isProUnlocked else {
                showPaywall(.moreFeature(name: title)) {
                    showToast("高级功能已解锁")
                }
                return
            }
            showToast("高级功能已解锁")
        }
    }

    private func showToast(_ message: String) {
        toastMessage = message
    }

    private func showPaywall(_ source: ProPaywallSource, onUnlocked: @escaping @MainActor () -> Void = {}) {
        purchaseManager.clearTransientState()
        paywallContext = ProPaywallContext(source: source, onUnlocked: onUnlocked)
    }
}

#Preview {
    NavigationStack {
        MoreFeaturesView()
            .environmentObject(PurchaseManager(autoStart: false))
    }
}
