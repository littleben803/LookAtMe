import SwiftUI

struct StylePickerView: View {
    @EnvironmentObject private var styleStore: StyleStore
    @EnvironmentObject private var displayConfigStore: DisplayConfigStore
    @EnvironmentObject private var settingsStore: SettingsStore
    @EnvironmentObject private var purchaseManager: PurchaseManager
    @Environment(\.lookSkin) private var skin
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
                                showsAccessTag: true,
                                isLocked: isStyleLocked(style),
                                previewLocale: settingsStore.appLanguage.locale
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
                title: L10n.StylePicker.title,
                subtitle: purchaseManager.isProUnlocked ? L10n.StylePicker.subtitleUnlocked : L10n.StylePicker.subtitleLocked
            )

            proEffectsTeaser

            Picker(L10n.key(L10n.StylePicker.filter), selection: $filter) {
                ForEach(StyleFilter.allCases) { item in
                    Text(L10n.key(item.titleKey(isProUnlocked: purchaseManager.isProUnlocked))).tag(item)
                }
            }
            .pickerStyle(.segmented)
            .tint(skin.primary)
        }
        .padding(.horizontal, LookSpacing.pageHorizontal)
        .padding(.top, LookSpacing.lg)
        .padding(.bottom, LookSpacing.md)
    }

    private var proEffectsTeaser: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                filter = .pro
            }
        } label: {
            HStack(alignment: .center, spacing: LookSpacing.md) {
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    skin.pro.opacity(0.72),
                                    skin.primary.opacity(0.18),
                                    .clear
                                ],
                                center: .center,
                                startRadius: 4,
                                endRadius: 34
                            )
                        )
                        .frame(width: 58, height: 58)

                    Image(systemName: skin.chrome.proHeroSymbol)
                        .font(.system(size: 22, weight: .black, design: .rounded))
                        .foregroundColor(skin.pro)
                        .shadow(color: skin.pro.opacity(0.72), radius: 10)
                }

                VStack(alignment: .leading, spacing: LookSpacing.xxs) {
                    Text(L10n.key(L10n.StylePicker.proTeaserTitle))
                        .font(LookTypography.sectionTitle)
                        .foregroundColor(skin.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.76)

                    Text(L10n.key(L10n.StylePicker.proTeaserSubtitle))
                        .font(LookTypography.caption)
                        .foregroundColor(skin.textTertiary)
                        .fixedSize(horizontal: false, vertical: true)

                    HStack(spacing: 5) {
                        ForEach(["bolt.fill", skin.chrome.sectionSymbol, skin.chrome.templateActionSymbol], id: \.self) { iconName in
                            Image(systemName: iconName)
                                .font(.system(size: 9, weight: .black, design: .rounded))
                                .foregroundColor(skin.pro)
                                .frame(width: 24, height: 18)
                                .background(
                                    Capsule()
                                        .fill(Color.black.opacity(0.32))
                                        .overlay(Capsule().stroke(skin.pro.opacity(0.28), lineWidth: 0.7))
                                )
                        }
                    }
                    .padding(.top, 3)
                }

                Spacer(minLength: 0)

                Text(L10n.key(L10n.StylePicker.proTeaserAction))
                    .font(.system(size: 11, weight: .heavy, design: .rounded))
                    .foregroundColor(skin.background)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(skin.pro))
            }
            .padding(LookSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: skin.chrome.cardRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                skin.pro.opacity(0.18),
                                skin.card.opacity(0.94),
                                skin.backgroundElevated.opacity(0.9)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
        .overlay(
                RoundedRectangle(cornerRadius: skin.chrome.cardRadius, style: .continuous)
                    .stroke(skin.pro.opacity(0.38), lineWidth: 1)
            )
            .shadow(color: skin.pro.opacity(0.18), radius: 18, y: 8)
        }
        .buttonStyle(.plain)
    }

    private func select(_ style: BannerStyle) {
        guard purchaseManager.canUse(style) else {
            showPaywall(.style(nameKey: style.nameKey)) {
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

    func titleKey(isProUnlocked: Bool) -> String {
        switch self {
        case .all:
            L10n.StylePicker.filterAll
        case .free:
            L10n.StylePicker.filterFree
        case .pro:
            isProUnlocked ? L10n.StylePicker.filterPremium : L10n.Common.pro
        }
    }
}

#Preview {
    NavigationStack {
            StylePickerView()
                .environmentObject(StyleStore())
                .environmentObject(DisplayConfigStore())
                .environmentObject(SettingsStore())
                .environmentObject(PurchaseManager(autoStart: false))
    }
}
