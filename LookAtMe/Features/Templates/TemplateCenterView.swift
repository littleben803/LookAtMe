import SwiftUI

struct TemplateCenterView: View {
    let onUseTemplate: (BannerTemplate) -> Void

    @EnvironmentObject private var templateStore: TemplateStore
    @EnvironmentObject private var displayConfigStore: DisplayConfigStore
    @EnvironmentObject private var styleStore: StyleStore
    @EnvironmentObject private var favoriteStore: FavoriteStore
    @EnvironmentObject private var purchaseManager: PurchaseManager
    @State private var selectedScene: BannerScene = .concert
    @State private var toastMessage: String?
    @State private var paywallContext: ProPaywallContext?

    var body: some View {
        ZStack {
            LookScreenBackground()

            VStack(alignment: .leading, spacing: 0) {
                fixedHeader

                ScrollView(showsIndicators: false) {
                    VStack(spacing: LookSpacing.sm) {
                        ForEach(templateStore.templates(for: selectedScene)) { template in
                            templateRow(template)
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
                title: "模板中心",
                subtitle: "长按模板可快速使用或收藏"
            )

            sceneTabs
        }
        .padding(.horizontal, LookSpacing.pageHorizontal)
        .padding(.top, LookSpacing.lg)
        .padding(.bottom, LookSpacing.md)
    }

    private var sceneTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: LookSpacing.sm) {
                ForEach(templateStore.allScenes) { scene in
                    Button {
                        selectedScene = scene
                    } label: {
                        HStack(spacing: LookSpacing.xs) {
                            Image(systemName: scene.symbolName)
                            Text(scene.title)
                        }
                        .font(LookTypography.caption.weight(.semibold))
                        .foregroundColor(selectedScene == scene ? LookTheme.Colors.textPrimary : LookTheme.Colors.textTertiary)
                        .padding(.horizontal, LookSpacing.md)
                        .padding(.vertical, LookSpacing.xs)
                        .background(
                            Capsule()
                                .fill(selectedScene == scene ? LookTheme.Colors.primaryPink.opacity(0.28) : LookTheme.Colors.cardPurple.opacity(0.92))
                        )
                        .overlay(
                            Capsule()
                                .stroke(selectedScene == scene ? LookTheme.Colors.primaryPink : LookTheme.Colors.primaryPink.opacity(0.22), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, LookSpacing.xs)
        }
    }

    private func templateRow(_ template: BannerTemplate) -> some View {
        Button {
            useTemplate(template)
        } label: {
            NeonCard(padding: LookSpacing.md) {
                HStack(spacing: LookSpacing.md) {
                    ZStack {
                        RoundedRectangle(cornerRadius: LookRadius.chip, style: .continuous)
                            .fill(LookTheme.Colors.backgroundBlack.opacity(0.86))
                            .frame(width: 54, height: 54)
                            .overlay(
                                RoundedRectangle(cornerRadius: LookRadius.chip, style: .continuous)
                                    .stroke(template.scene.accentColor.opacity(0.58), lineWidth: 1)
                            )

                        Image(systemName: template.scene.symbolName)
                            .font(.system(size: 21, weight: .bold, design: .rounded))
                            .foregroundColor(template.scene.accentColor)
                    }

                    VStack(alignment: .leading, spacing: LookSpacing.xxs) {
                        Text(template.title)
                            .font(LookTypography.sectionTitle)
                            .foregroundColor(LookTheme.Colors.textPrimary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.78)
                        Text(template.scene.title)
                            .font(LookTypography.caption)
                            .foregroundColor(LookTheme.Colors.textTertiary)
                    }

                    Spacer()

                    if isTemplateLocked(template) {
                        ProBadge()
                    }

                    Image(systemName: isTemplateLocked(template) ? "lock.fill" : "plus.circle.fill")
                        .font(.system(size: isTemplateLocked(template) ? 18 : 22, weight: .bold))
                        .foregroundColor(isTemplateLocked(template) ? LookTheme.Colors.warmYellow : LookTheme.Colors.primaryPink)
                }
            }
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button {
                useTemplate(template)
            } label: {
                Label("使用", systemImage: "arrow.turn.down.left")
            }

            Button {
                favoriteTemplate(template)
            } label: {
                Label("收藏", systemImage: "heart.fill")
            }
        }
    }

    private func useTemplate(_ template: BannerTemplate) {
        guard purchaseManager.canUse(template) else {
            showPaywall(.template(name: template.title)) {
                useTemplate(template)
            }
            return
        }
        onUseTemplate(template)
    }

    private func favoriteTemplate(_ template: BannerTemplate) {
        guard purchaseManager.canUse(template) else {
            showPaywall(.template(name: template.title)) {
                favoriteTemplate(template)
            }
            return
        }
        let result = favoriteStore.addTemplate(
            template,
            displayConfigStore: displayConfigStore,
            styleStore: styleStore,
            isProUnlocked: purchaseManager.isProUnlocked
        )
        handleFavoriteResult(result) {
            favoriteTemplate(template)
        }
    }

    private func isTemplateLocked(_ template: BannerTemplate) -> Bool {
        template.isPro && !purchaseManager.isProUnlocked
    }

    private func message(for result: FavoriteAddResult) -> String {
        switch result {
        case .added:
            "已收藏模板"
        case .updatedExisting:
            "已更新收藏"
        case .ignoredEmptyText:
            "模板内容为空"
        case .freeLimitReached(let limit):
            "免费版最多收藏 \(limit) 条，Pro 可无限收藏"
        }
    }

    private func handleFavoriteResult(_ result: FavoriteAddResult, retryAfterUnlock: @escaping @MainActor () -> Void) {
        switch result {
        case .freeLimitReached:
            showPaywall(.favoriteLimit, onUnlocked: retryAfterUnlock)
        case .added, .updatedExisting, .ignoredEmptyText:
            toastMessage = message(for: result)
        }
    }

    private func showPaywall(_ source: ProPaywallSource, onUnlocked: @escaping @MainActor () -> Void = {}) {
        purchaseManager.clearTransientState()
        paywallContext = ProPaywallContext(source: source, onUnlocked: onUnlocked)
    }
}

#Preview {
    NavigationStack {
        TemplateCenterView(onUseTemplate: { _ in })
            .environmentObject(TemplateStore())
            .environmentObject(DisplayConfigStore())
            .environmentObject(StyleStore())
            .environmentObject(FavoriteStore())
            .environmentObject(PurchaseManager(autoStart: false))
    }
}
