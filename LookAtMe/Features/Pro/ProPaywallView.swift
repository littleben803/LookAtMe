import SwiftUI

struct ProPaywallView: View {
    let context: ProPaywallContext

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var settingsStore: SettingsStore
    @EnvironmentObject private var purchaseManager: PurchaseManager
    @State private var didFinishSuccess = false

    private let benefits = [
        L10n.Pro.Benefit.allEffects,
        L10n.Pro.Benefit.unlimitedFavorites,
        L10n.Pro.Benefit.premiumTemplates,
        L10n.Pro.Benefit.premiumFonts,
        L10n.Pro.Benefit.customStyleSave,
        L10n.Pro.Benefit.futureUpdates
    ]

    var body: some View {
        Group {
            if purchaseManager.purchaseSuccess || purchaseManager.isProUnlocked && context.source.isSettingsRestore {
                PurchaseSuccessView {
                    finishSuccess()
                }
            } else {
                paywallContent
            }
        }
        .task {
            guard purchaseManager.product == nil, !purchaseManager.isLoadingProducts else {
                return
            }
            await purchaseManager.loadProducts()
        }
        .onDisappear {
            guard !didFinishSuccess else {
                return
            }
            purchaseManager.clearTransientState()
        }
    }

    private var paywallContent: some View {
        ZStack {
            LookScreenBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: LookSpacing.xl) {
                    topBar
                    hero
                    triggerCard
                    debugDiagnostics
                    benefitsCard
                    statusView
                    actions
                    finePrint
                }
                .padding(.horizontal, LookSpacing.pageHorizontal)
                .padding(.top, LookSpacing.lg)
                .padding(.bottom, LookSpacing.xxxl)
            }
        }
    }

    private var topBar: some View {
        HStack {
            Spacer()

            Button {
                close()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(LookTheme.Colors.textPrimary)
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(LookTheme.Colors.cardPurple.opacity(0.86)))
                    .overlay(Circle().stroke(LookTheme.Colors.primaryPink.opacity(0.36), lineWidth: 1))
            }
            .buttonStyle(.plain)
        }
    }

    private var hero: some View {
        VStack(spacing: LookSpacing.md) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                LookTheme.Colors.primaryPink.opacity(0.42),
                                LookTheme.Colors.electricBlue.opacity(0.14),
                                .clear
                            ],
                            center: .center,
                            startRadius: 8,
                            endRadius: 104
                        )
                    )
                    .frame(width: 196, height: 196)

                Image(systemName: "crown.fill")
                    .font(.system(size: 52, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                LookTheme.Colors.warmYellow,
                                LookTheme.Colors.hotPink
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: LookTheme.Colors.warmYellow.opacity(0.62), radius: 18)
            }
            .frame(height: 138)

            VStack(spacing: LookSpacing.xs) {
                Text(L10n.key(L10n.Pro.title))
                    .font(.system(size: 34, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                LookTheme.Colors.textPrimary,
                                LookTheme.Colors.softPink,
                                LookTheme.Colors.primaryPink
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .multilineTextAlignment(.center)
                    .shadow(color: LookTheme.Colors.primaryPink.opacity(0.58), radius: 18)

                Text(L10n.key(L10n.Pro.subtitle))
                    .font(LookTypography.sectionTitle)
                    .foregroundColor(LookTheme.Colors.hotPink)
                    .multilineTextAlignment(.center)
            }
        }
    }

    private var triggerCard: some View {
        NeonCard(padding: LookSpacing.md) {
            HStack(alignment: .top, spacing: LookSpacing.md) {
                Image(systemName: "sparkles")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(LookTheme.Colors.warmYellow)
                    .frame(width: 34, height: 34)
                    .background(Circle().fill(LookTheme.Colors.backgroundBlack.opacity(0.72)))

                VStack(alignment: .leading, spacing: LookSpacing.xxs) {
                    Text(context.source.promptTitle(locale: settingsStore.appLanguage.locale))
                        .font(LookTypography.body.weight(.semibold))
                        .foregroundColor(LookTheme.Colors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(context.source.promptSubtitle(locale: settingsStore.appLanguage.locale))
                        .font(LookTypography.caption)
                        .foregroundColor(LookTheme.Colors.textTertiary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)
            }
        }
    }

    private var benefitsCard: some View {
        NeonCard {
            VStack(alignment: .leading, spacing: LookSpacing.md) {
                ForEach(benefits, id: \.self) { benefit in
                    HStack(spacing: LookSpacing.sm) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(LookTheme.Colors.primaryPink)
                            .frame(width: 22)

                        Text(L10n.key(benefit))
                            .font(LookTypography.body)
                            .foregroundColor(LookTheme.Colors.textPrimary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.82)

                        Spacer(minLength: 0)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var statusView: some View {
        if let statusText {
            HStack(spacing: LookSpacing.sm) {
                if purchaseManager.isLoadingProducts || purchaseManager.isPurchasing {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(LookTheme.Colors.primaryPink)
                } else {
                    Image(systemName: statusIconName)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(statusColor)
                }

                Text(statusText)
                    .font(LookTypography.caption.weight(.semibold))
                    .foregroundColor(statusColor)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, LookSpacing.md)
            .padding(.vertical, LookSpacing.sm)
            .background(
                RoundedRectangle(cornerRadius: LookRadius.chip, style: .continuous)
                    .fill(LookTheme.Colors.cardPurple.opacity(0.72))
                    .overlay(
                        RoundedRectangle(cornerRadius: LookRadius.chip, style: .continuous)
                            .stroke(statusColor.opacity(0.34), lineWidth: 1)
                    )
            )
        }
    }

    private var actions: some View {
        VStack(spacing: LookSpacing.md) {
            PrimaryButton(primaryButtonTitle, systemImage: primaryButtonIcon, isLoading: purchaseManager.isPurchasing || purchaseManager.isLoadingProducts) {
                runPrimaryAction()
            }
            .disabled(purchaseManager.isPurchasing || purchaseManager.isLoadingProducts)

            PaywallSecondaryButton(title: localized(L10n.Pro.restorePurchase), systemImage: "arrow.clockwise", isDisabled: purchaseManager.isPurchasing) {
                Task {
                    await purchaseManager.restorePurchases()
                }
            }

            PaywallSecondaryButton(title: localized(L10n.Pro.later), systemImage: "xmark", isDisabled: purchaseManager.isPurchasing) {
                close()
            }
        }
    }

    private var finePrint: some View {
        VStack(spacing: LookSpacing.xxs) {
            Text(purchaseManager.productDisplayName(locale: settingsStore.appLanguage.locale))
                .font(LookTypography.caption)
                .foregroundColor(LookTheme.Colors.textTertiary)
                .lineLimit(1)
                .minimumScaleFactor(0.78)

            Text(L10n.key(L10n.Pro.finePrint))
                .font(LookTypography.caption)
                .foregroundColor(LookTheme.Colors.textDisabled)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var primaryButtonTitle: String {
        if purchaseManager.isPurchasing {
            return localized(L10n.Pro.purchasing)
        }
        if purchaseManager.isLoadingProducts {
            return localized(L10n.Pro.loadingProduct)
        }
        guard purchaseManager.product != nil else {
            return localized(L10n.Pro.reloadProduct)
        }
        let price = purchaseManager.productDisplayPrice
        return price.isEmpty
            ? localized(L10n.Pro.unlockForever)
            : L10n.format(L10n.Pro.unlockForeverPriceFormat, locale: settingsStore.appLanguage.locale, price)
    }

    private var primaryButtonIcon: String {
        purchaseManager.product == nil ? "arrow.clockwise" : "crown.fill"
    }

    private var statusText: String? {
        if purchaseManager.isPurchasing {
            return localized(L10n.Pro.purchasing)
        }
        if purchaseManager.isLoadingProducts {
            return localized(L10n.Pro.loadingProduct)
        }
        if purchaseManager.purchaseSuccess {
            return localized(L10n.Pro.purchaseSuccess)
        }
        if let errorMessage = purchaseManager.errorMessage {
            return localized(errorMessage)
        }
        if purchaseManager.product == nil {
            return localized(L10n.Pro.productLoadFailed)
        }
        return nil
    }

    private var statusIconName: String {
        if purchaseManager.purchaseSuccess {
            return "checkmark.circle.fill"
        }
        if purchaseManager.errorMessage != nil || purchaseManager.product == nil {
            return "exclamationmark.triangle.fill"
        }
        return "info.circle.fill"
    }

    private var statusColor: Color {
        if purchaseManager.purchaseSuccess {
            return LookTheme.Colors.success
        }
        if purchaseManager.errorMessage != nil || purchaseManager.product == nil {
            return LookTheme.Colors.warmYellow
        }
        return LookTheme.Colors.textTertiary
    }

    private func runPrimaryAction() {
        guard !purchaseManager.isLoadingProducts, !purchaseManager.isPurchasing else {
            return
        }

        Task {
            if purchaseManager.product == nil {
                await purchaseManager.loadProducts()
            } else {
                await purchaseManager.purchase()
            }
        }
    }

    @ViewBuilder
    private var debugDiagnostics: some View {
        #if DEBUG
        if LookDebugOptions.isDebugEntryPointEnabled {
            NeonCard(padding: LookSpacing.md) {
                VStack(alignment: .leading, spacing: LookSpacing.sm) {
                    HStack(spacing: LookSpacing.xs) {
                        Image(systemName: "ladybug.fill")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                        Text(L10n.key(L10n.Pro.Debug.title))
                            .font(LookTypography.body.weight(.semibold))
                        Spacer()
                    }
                    .foregroundColor(LookTheme.Colors.warmYellow)

                    debugRow("Product ID", value: PurchaseManager.proProductID)
                    debugRow(localized(L10n.Pro.loadingProduct), value: localized(purchaseManager.product == nil ? L10n.Pro.Debug.productNotLoaded : L10n.Pro.Debug.productLoaded))
                    debugRow("isProUnlocked", value: purchaseManager.isProUnlocked ? "true" : "false")
                    debugRow("Storefront", value: purchaseManager.debugStorefrontCountryCode ?? localized(L10n.Pro.Debug.unknown))
                    debugRow(localized(L10n.Pro.Debug.environmentHintTitle), value: localized(L10n.Pro.Debug.environmentHintValue))

                    HStack(spacing: LookSpacing.sm) {
                        PaywallDebugButton(localized(L10n.Pro.Debug.refresh), systemImage: "arrow.clockwise") {
                            Task {
                                await purchaseManager.refreshDebugStorefront()
                                await purchaseManager.loadProducts()
                            }
                        }

                        PaywallDebugButton(localized(L10n.Pro.Debug.resetCache), systemImage: "trash") {
                            purchaseManager.resetLocalProCacheForDebug()
                        }
                    }
                }
            }
            .task {
                await purchaseManager.refreshDebugStorefront()
            }
        }
        #endif
    }

    #if DEBUG
    private func debugRow(_ title: String, value: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: LookSpacing.sm) {
            Text(title)
                .font(LookTypography.caption.weight(.semibold))
                .foregroundColor(LookTheme.Colors.textTertiary)
                .frame(width: 94, alignment: .leading)

            Text(value)
                .font(LookTypography.caption.monospacedDigit())
                .foregroundColor(LookTheme.Colors.textPrimary)
                .lineLimit(2)
                .minimumScaleFactor(0.78)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    #endif

    private func close() {
        purchaseManager.clearTransientState()
        dismiss()
    }

    private func finishSuccess() {
        didFinishSuccess = true
        context.onUnlocked()
        purchaseManager.clearTransientState()
        dismiss()
    }

    private func localized(_ key: String) -> String {
        L10n.string(key, locale: settingsStore.appLanguage.locale)
    }
}

private struct PaywallSecondaryButton: View {
    let title: String
    let systemImage: String
    var isDisabled = false
    let action: () -> Void

    var body: some View {
        Button {
            guard !isDisabled else {
                return
            }
            action()
        } label: {
            HStack(spacing: LookSpacing.sm) {
                Image(systemName: systemImage)
                    .font(.system(size: 14, weight: .bold, design: .rounded))

                Text(title)
                    .font(LookTypography.body.weight(.semibold))
            }
            .foregroundColor(LookTheme.Colors.textPrimary)
            .frame(maxWidth: .infinity, minHeight: 48)
            .background(
                Capsule()
                    .fill(LookTheme.Colors.cardPurple.opacity(0.86))
                    .overlay(Capsule().stroke(LookTheme.Colors.primaryPink.opacity(0.28), lineWidth: 1))
            )
            .opacity(isDisabled ? 0.5 : 1)
        }
        .buttonStyle(.plain)
    }
}

#if DEBUG
private struct PaywallDebugButton: View {
    let title: String
    let systemImage: String
    let action: () -> Void

    init(_ title: String, systemImage: String, action: @escaping () -> Void) {
        self.title = title
        self.systemImage = systemImage
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: LookSpacing.xxs) {
                Image(systemName: systemImage)
                    .font(.system(size: 11, weight: .bold, design: .rounded))

                Text(title)
                    .font(LookTypography.caption.weight(.semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)
            }
            .foregroundColor(LookTheme.Colors.textPrimary)
            .frame(maxWidth: .infinity, minHeight: 34)
            .background(
                Capsule()
                    .fill(LookTheme.Colors.backgroundBlack.opacity(0.62))
                    .overlay(Capsule().stroke(LookTheme.Colors.warmYellow.opacity(0.3), lineWidth: 1))
            )
        }
        .buttonStyle(.plain)
    }
}
#endif

private extension ProPaywallSource {
    var isSettingsRestore: Bool {
        if case .settingsRestore = self {
            return true
        }
        return false
    }
}

#Preview {
    ProPaywallView(context: ProPaywallContext(source: .style(nameKey: L10n.Style.name("style-heart-rain"))))
        .environmentObject(SettingsStore())
        .environmentObject(PurchaseManager(autoStart: false))
}
