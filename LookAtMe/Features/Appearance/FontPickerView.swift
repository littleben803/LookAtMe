import SwiftUI

struct FontPickerView: View {
    @EnvironmentObject private var displayConfigStore: DisplayConfigStore
    @EnvironmentObject private var purchaseManager: PurchaseManager
    @State private var paywallContext: ProPaywallContext?

    var body: some View {
        ZStack {
            LookScreenBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: LookSpacing.lg) {
                    NeonPageHeader(
                        title: L10n.Appearance.fontTitle,
                        subtitle: L10n.Appearance.fontSubtitle
                    )

                    VStack(spacing: LookSpacing.sm) {
                        ForEach(BannerFontStyle.allCases) { fontStyle in
                            fontRow(fontStyle)
                        }
                    }
                }
                .padding(.horizontal, LookSpacing.pageHorizontal)
                .padding(.top, LookSpacing.lg)
                .padding(.bottom, LookSpacing.tabContentBottomPadding)
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            ensureSelectedFontIsAvailable()
        }
        .fullScreenCover(item: $paywallContext) { context in
            ProPaywallView(context: context)
        }
    }

    private func fontRow(_ fontStyle: BannerFontStyle) -> some View {
        Button {
            select(fontStyle)
        } label: {
            NeonCard {
                HStack(spacing: LookSpacing.md) {
                    VStack(alignment: .leading, spacing: LookSpacing.xs) {
                        HStack {
                            Text(L10n.key(fontStyle.titleKey))
                                .font(LookTypography.body.weight(.semibold))
                                .foregroundColor(LookTheme.Colors.textPrimary)
                            Spacer()
                            if displayConfigStore.fontStyle == fontStyle {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 19, weight: .bold))
                                    .foregroundColor(LookTheme.Colors.primaryPink)
                            }
                            if isFontLocked(fontStyle) {
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(LookTheme.Colors.warmYellow)
                            }
                            if isFontLocked(fontStyle) {
                                ProBadge()
                            }
                        }

                        Text(fontStyle.subtitle)
                            .font(LookTypography.caption)
                            .foregroundColor(LookTheme.Colors.textTertiary)

                        Text(L10n.key(L10n.Appearance.previewMessage))
                            .font(fontStyle.font(size: 28))
                            .foregroundColor(Color(hex: displayConfigStore.textColorHex))
                            .lineLimit(1)
                            .minimumScaleFactor(0.58)
                            .shadow(color: Color(hex: displayConfigStore.textColorHex).opacity(0.78), radius: 10)
                            .padding(.top, LookSpacing.xs)
                    }
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: LookRadius.card, style: .continuous)
                    .stroke(displayConfigStore.fontStyle == fontStyle ? LookTheme.Colors.primaryPink : .clear, lineWidth: 1.8)
            )
        }
        .buttonStyle(.plain)
    }

    private func select(_ fontStyle: BannerFontStyle) {
        guard purchaseManager.canUse(fontStyle) else {
            showPaywall(.premiumFont(titleKey: fontStyle.titleKey)) {
                select(fontStyle)
            }
            return
        }
        displayConfigStore.fontStyle = fontStyle
    }

    private func isFontLocked(_ fontStyle: BannerFontStyle) -> Bool {
        fontStyle.isPro && !purchaseManager.isProUnlocked
    }

    private func ensureSelectedFontIsAvailable() {
        guard !purchaseManager.canUse(displayConfigStore.fontStyle) else {
            return
        }
        displayConfigStore.fontStyle = .roundedHeavy
    }

    private func showPaywall(_ source: ProPaywallSource, onUnlocked: @escaping @MainActor () -> Void = {}) {
        purchaseManager.clearTransientState()
        paywallContext = ProPaywallContext(source: source, onUnlocked: onUnlocked)
    }
}

#Preview {
    NavigationStack {
        FontPickerView()
            .environmentObject(DisplayConfigStore())
            .environmentObject(PurchaseManager(autoStart: false))
    }
}
