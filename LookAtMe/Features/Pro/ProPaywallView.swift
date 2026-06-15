import SwiftUI

struct ProPaywallView: View {
    let context: ProPaywallContext

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var purchaseManager: PurchaseManager
    @State private var didFinishSuccess = false

    private let benefits = [
        "全部霓虹特效",
        "无限保存收藏",
        "高级应援模板",
        "高级字体",
        "自定义样式保存",
        "未来新样式免费更新"
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
                Text("想恋爱 Pro")
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

                Text("解锁全部高级灯牌功能")
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
                    Text(context.source.promptTitle)
                        .font(LookTypography.body.weight(.semibold))
                        .foregroundColor(LookTheme.Colors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(context.source.promptSubtitle)
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

                        Text(benefit)
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

            PaywallSecondaryButton(title: "恢复购买", systemImage: "arrow.clockwise", isDisabled: purchaseManager.isPurchasing) {
                Task {
                    await purchaseManager.restorePurchases()
                }
            }

            PaywallSecondaryButton(title: "稍后再说", systemImage: "xmark", isDisabled: purchaseManager.isPurchasing) {
                close()
            }
        }
    }

    private var finePrint: some View {
        VStack(spacing: LookSpacing.xxs) {
            Text(purchaseManager.productDisplayName)
                .font(LookTypography.caption)
                .foregroundColor(LookTheme.Colors.textTertiary)
                .lineLimit(1)
                .minimumScaleFactor(0.78)

            Text("一次购买，永久解锁；价格以 App Store 显示为准。")
                .font(LookTypography.caption)
                .foregroundColor(LookTheme.Colors.textDisabled)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var primaryButtonTitle: String {
        if purchaseManager.isPurchasing {
            return "正在购买"
        }
        if purchaseManager.isLoadingProducts {
            return "商品加载中"
        }
        guard purchaseManager.product != nil else {
            return "重新加载商品"
        }
        let price = purchaseManager.productDisplayPrice
        return price.isEmpty ? "永久解锁" : "\(price) 永久解锁"
    }

    private var primaryButtonIcon: String {
        purchaseManager.product == nil ? "arrow.clockwise" : "crown.fill"
    }

    private var statusText: String? {
        if purchaseManager.isPurchasing {
            return "正在购买"
        }
        if purchaseManager.isLoadingProducts {
            return "商品加载中"
        }
        if purchaseManager.purchaseSuccess {
            return "购买成功"
        }
        if let errorMessage = purchaseManager.errorMessage {
            return errorMessage
        }
        if purchaseManager.product == nil {
            return "商品加载失败"
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
        NeonCard(padding: LookSpacing.md) {
            VStack(alignment: .leading, spacing: LookSpacing.sm) {
                HStack(spacing: LookSpacing.xs) {
                    Image(systemName: "ladybug.fill")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                    Text("DEBUG IAP 诊断")
                        .font(LookTypography.body.weight(.semibold))
                    Spacer()
                }
                .foregroundColor(LookTheme.Colors.warmYellow)

                debugRow("Product ID", value: PurchaseManager.proProductID)
                debugRow("商品加载", value: purchaseManager.product == nil ? "未加载" : "已加载")
                debugRow("isProUnlocked", value: purchaseManager.isProUnlocked ? "true" : "false")
                debugRow("Storefront", value: purchaseManager.debugStorefrontCountryCode ?? "未知")
                debugRow("环境提示", value: "价格取自当前 StoreKit / Sandbox storefront")

                HStack(spacing: LookSpacing.sm) {
                    PaywallDebugButton("刷新诊断", systemImage: "arrow.clockwise") {
                        Task {
                            await purchaseManager.refreshDebugStorefront()
                            await purchaseManager.loadProducts()
                        }
                    }

                    PaywallDebugButton("重置本地缓存", systemImage: "trash") {
                        purchaseManager.resetLocalProCacheForDebug()
                    }
                }
            }
        }
        .task {
            await purchaseManager.refreshDebugStorefront()
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
    ProPaywallView(context: ProPaywallContext(source: .style(name: "爱心飘落")))
        .environmentObject(PurchaseManager(autoStart: false))
}
