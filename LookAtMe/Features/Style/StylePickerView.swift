import SwiftUI

struct StylePickerView: View {
    @EnvironmentObject private var styleStore: StyleStore
    @EnvironmentObject private var displayConfigStore: DisplayConfigStore
    @EnvironmentObject private var purchaseManager: PurchaseManager
    @State private var filter: StyleFilter = .all
    @State private var toastMessage: String?
    @State private var paywallContext: ProPaywallContext?

    private let columns = [
        GridItem(.flexible(), spacing: LookSpacing.sm),
        GridItem(.flexible(), spacing: LookSpacing.sm)
    ]

    private var filteredStyles: [BannerStyle] {
        switch filter {
        case .all:
            styleStore.styles
        case .free:
            styleStore.styles.filter { !$0.isPro }
        case .pro:
            styleStore.styles.filter(\.isPro)
        }
    }

    var body: some View {
        ZStack {
            LookScreenBackground()

            VStack(alignment: .leading, spacing: 0) {
                fixedHeader

                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: columns, spacing: LookSpacing.sm) {
                        ForEach(filteredStyles) { style in
                            StyleCard(
                                style: style,
                                isSelected: displayConfigStore.selectedStyleID == style.id,
                                previewColor: Color(hex: displayConfigStore.textColorHex),
                                fontStyle: displayConfigStore.fontStyle,
                                isLocked: isStyleLocked(style)
                            ) {
                                select(style)
                            }
                        }
                    }
                    .padding(.horizontal, LookSpacing.pageHorizontal)
                    .padding(.top, LookSpacing.lg)
                    .padding(.bottom, LookSpacing.tabContentBottomPadding)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .lookToast($toastMessage)
        .fullScreenCover(item: $paywallContext) { context in
            ProPaywallView(context: context)
        }
    }

    private var fixedHeader: some View {
        VStack(alignment: .leading, spacing: LookSpacing.lg) {
            NeonPageHeader(
                title: "样式选择",
                subtitle: purchaseManager.isProUnlocked ? "全部样式均可直接使用" : "免费样式可直接使用，Pro 样式解锁后使用"
            )

            Picker("筛选", selection: $filter) {
                ForEach(StyleFilter.allCases) { item in
                    Text(item.title(isProUnlocked: purchaseManager.isProUnlocked)).tag(item)
                }
            }
            .pickerStyle(.segmented)
            .tint(LookTheme.Colors.primaryPink)
        }
        .padding(.horizontal, LookSpacing.pageHorizontal)
        .padding(.top, LookSpacing.lg)
        .padding(.bottom, LookSpacing.md)
    }

    private func select(_ style: BannerStyle) {
        guard purchaseManager.canUse(style) else {
            showPaywall(.style(name: style.name)) {
                select(style)
            }
            return
        }
        displayConfigStore.selectStyle(style)
    }

    private func isStyleLocked(_ style: BannerStyle) -> Bool {
        style.isPro && !purchaseManager.isProUnlocked
    }

    private func showPaywall(_ source: ProPaywallSource, onUnlocked: @escaping @MainActor () -> Void = {}) {
        purchaseManager.clearTransientState()
        paywallContext = ProPaywallContext(source: source, onUnlocked: onUnlocked)
    }
}

private enum StyleFilter: String, CaseIterable, Identifiable {
    case all
    case free
    case pro

    var id: String { rawValue }

    func title(isProUnlocked: Bool) -> String {
        switch self {
        case .all:
            "全部"
        case .free:
            "免费"
        case .pro:
            isProUnlocked ? "高级" : "Pro"
        }
    }
}

#Preview {
    NavigationStack {
            StylePickerView()
                .environmentObject(StyleStore())
                .environmentObject(DisplayConfigStore())
                .environmentObject(PurchaseManager(autoStart: false))
    }
}
