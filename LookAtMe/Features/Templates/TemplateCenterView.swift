import SwiftUI

struct TemplateCenterView: View {
    let onUseTemplate: (BannerTemplate) -> Void

    @EnvironmentObject private var templateStore: TemplateStore
    @EnvironmentObject private var displayConfigStore: DisplayConfigStore
    @EnvironmentObject private var styleStore: StyleStore
    @EnvironmentObject private var favoriteStore: FavoriteStore
    @EnvironmentObject private var settingsStore: SettingsStore
    @EnvironmentObject private var purchaseManager: PurchaseManager
    @Environment(\.lookSkin) private var skin
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
        VStack(alignment: .leading, spacing: skin.isNeonUtilityPro ? LookSpacing.md : LookSpacing.lg) {
            NeonPageHeader(
                title: L10n.TemplateCenter.title,
                subtitle: L10n.TemplateCenter.subtitle
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
                            Text(L10n.key(scene.titleKey))
                        }
                        .font(LookTypography.caption.weight(.semibold))
                        .foregroundColor(selectedScene == scene ? skin.textPrimary : skin.textTertiary)
                        .padding(.horizontal, LookSpacing.md)
                        .padding(.vertical, skin.isNeonUtilityPro ? 7 : LookSpacing.xs)
                        .background(
                            RoundedRectangle(cornerRadius: skin.chrome.controlRadius, style: .continuous)
                                .fill(selectedScene == scene ? skin.primary.opacity(0.28) : skin.card.opacity(0.92))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: skin.chrome.controlRadius, style: .continuous)
                                .stroke(selectedScene == scene ? skin.primary : skin.primary.opacity(0.22), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, LookSpacing.xs)
        }
    }

    private func templateRow(_ template: BannerTemplate) -> some View {
        let templateTitle = template.localizedTitle(locale: settingsStore.appLanguage.locale)
        let templateText = template.localizedText(locale: settingsStore.appLanguage.locale)
        let sceneTitle = L10n.string(template.scene.titleKey, locale: settingsStore.appLanguage.locale)
        let previewText = templateText == templateTitle ? sceneTitle : templateText
        let isLocked = isTemplateLocked(template)

        return Button {
            useTemplate(template)
        } label: {
            VStack(alignment: .leading, spacing: skin.isNeonUtilityPro ? 9 : 11) {
                HStack(spacing: 10) {
                    Image(systemName: template.scene.symbolName)
                        .font(.system(size: 17, weight: .black, design: .rounded))
                        .foregroundColor(template.scene.accentColor)
                        .frame(width: 38, height: 38)
                        .background(
                            RoundedRectangle(cornerRadius: skin.chrome.controlRadius, style: .continuous)
                                .fill(template.scene.accentColor.opacity(0.14))
                                .overlay(
                                    RoundedRectangle(cornerRadius: skin.chrome.controlRadius, style: .continuous)
                                        .stroke(template.scene.accentColor.opacity(0.46), lineWidth: 0.8)
                                )
                        )
                        .shadow(color: template.scene.accentColor.opacity(0.36), radius: 8)

                    VStack(alignment: .leading, spacing: 3) {
                        Text(templateTitle)
                            .font(.system(size: skin.isNeonUtilityPro ? 16 : 17, weight: .heavy, design: .rounded))
                            .foregroundColor(skin.textPrimary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.78)

                        Text(sceneTitle)
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .foregroundColor(skin.textTertiary)
                            .lineLimit(1)
                    }

                    Spacer(minLength: 0)

                    TemplateAccessPill(isPro: template.isPro, isLocked: isLocked)

                    Image(systemName: isLocked ? "lock.fill" : skin.chrome.templateActionSymbol)
                        .font(.system(size: isLocked ? 15 : 18, weight: .bold, design: .rounded))
                        .foregroundColor(isLocked ? skin.pro : skin.primary)
                        .frame(width: 28, height: 28)
                        .background(Circle().fill(Color.black.opacity(0.32)))
                }

                Text(previewText)
                    .font(.system(size: skin.isNeonUtilityPro ? 18 : 20, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                template.isPro ? skin.pro : template.scene.accentColor,
                                skin.textPrimary.opacity(0.94)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .frame(maxWidth: .infinity, minHeight: skin.isNeonUtilityPro ? 38 : 44, alignment: .leading)
                    .padding(.horizontal, 12)
                    .background(
                        RoundedRectangle(cornerRadius: skin.chrome.controlRadius, style: .continuous)
                            .fill(Color(hex: "#050611").opacity(0.88))
                            .overlay(
                                RoundedRectangle(cornerRadius: skin.chrome.controlRadius, style: .continuous)
                                    .stroke(template.scene.accentColor.opacity(template.isPro ? 0.42 : 0.3), lineWidth: 0.8)
                            )
                    )
                    .shadow(color: template.scene.accentColor.opacity(template.isPro ? 0.22 : 0.14), radius: 8)
            }
            .padding(skin.isNeonUtilityPro ? 13 : LookSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: skin.chrome.cardRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                skin.card.opacity(0.96),
                                template.scene.accentColor.opacity(0.1),
                                skin.cardElevated.opacity(0.88)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: skin.chrome.cardRadius, style: .continuous)
                    .stroke(isLocked ? skin.pro.opacity(0.42) : template.scene.accentColor.opacity(0.34), lineWidth: 1)
            )
            .overlay(alignment: .leading) {
                RoundedRectangle(cornerRadius: 2, style: .continuous)
                    .fill(template.isPro ? skin.pro : template.scene.accentColor)
                    .frame(width: 4)
                    .padding(.vertical, 12)
                    .shadow(color: (template.isPro ? skin.pro : template.scene.accentColor).opacity(0.48), radius: 8)
            }
            .shadow(color: template.scene.accentColor.opacity(isLocked ? 0.12 : 0.16), radius: 14, y: 6)
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button {
                useTemplate(template)
            } label: {
                Label(L10n.key(L10n.Common.use), systemImage: "arrow.turn.down.left")
            }

            Button {
                favoriteTemplate(template)
            } label: {
                Label(L10n.key(L10n.Common.favorite), systemImage: "heart.fill")
            }
        }
    }

    private func useTemplate(_ template: BannerTemplate) {
        guard purchaseManager.canUse(template) else {
            showPaywall(.template(title: template.localizedTitle(locale: settingsStore.appLanguage.locale))) {
                useTemplate(template)
            }
            return
        }
        onUseTemplate(template)
    }

    private func favoriteTemplate(_ template: BannerTemplate) {
        guard purchaseManager.canUse(template) else {
            showPaywall(.template(title: template.localizedTitle(locale: settingsStore.appLanguage.locale))) {
                favoriteTemplate(template)
            }
            return
        }
        let result = favoriteStore.addTemplate(
            template,
            displayConfigStore: displayConfigStore,
            styleStore: styleStore,
            locale: settingsStore.appLanguage.locale,
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
            localized(L10n.TemplateCenter.Toast.favoriteAdded)
        case .updatedExisting:
            localized(L10n.TemplateCenter.Toast.favoriteUpdated)
        case .ignoredEmptyText:
            localized(L10n.TemplateCenter.Toast.templateEmpty)
        case .freeLimitReached(let limit):
            L10n.format(L10n.TemplateCenter.Toast.favoriteLimitFormat, locale: settingsStore.appLanguage.locale, limit)
        }
    }

    private func localized(_ key: String) -> String {
        L10n.string(key, locale: settingsStore.appLanguage.locale)
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

private struct TemplateAccessPill: View {
    let isPro: Bool
    let isLocked: Bool
    @Environment(\.lookSkin) private var skin

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: isPro ? "crown.fill" : "checkmark")
                .font(.system(size: 8, weight: .black, design: .rounded))

            Text(L10n.key(isPro ? L10n.Common.pro : L10n.Common.free))
                .font(.system(size: 8.5, weight: .heavy, design: .rounded))
        }
        .foregroundColor(isPro ? skin.background : skin.textPrimary)
        .padding(.horizontal, 7)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(isPro ? skin.pro.opacity(isLocked ? 1 : 0.88) : skin.primary.opacity(0.22))
        )
        .overlay(
            Capsule()
                .stroke(isPro ? skin.pro.opacity(0.5) : skin.primary.opacity(0.42), lineWidth: 0.8)
        )
    }
}

#Preview {
    NavigationStack {
        TemplateCenterView(onUseTemplate: { _ in })
            .environmentObject(TemplateStore())
            .environmentObject(DisplayConfigStore())
            .environmentObject(StyleStore())
            .environmentObject(FavoriteStore())
            .environmentObject(SettingsStore())
            .environmentObject(PurchaseManager(autoStart: false))
    }
}
