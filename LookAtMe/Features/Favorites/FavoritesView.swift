import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject private var navigationState: AppNavigationState
    @EnvironmentObject private var displayConfigStore: DisplayConfigStore
    @EnvironmentObject private var favoriteStore: FavoriteStore
    @EnvironmentObject private var styleStore: StyleStore
    @EnvironmentObject private var settingsStore: SettingsStore
    @EnvironmentObject private var purchaseManager: PurchaseManager
    @Environment(\.lookSkin) private var skin

    @State private var isEditing = false
    @State private var isShowingDeleteAllConfirm = false
    @State private var toastMessage: String?
    @State private var paywallContext: ProPaywallContext?

    var body: some View {
        ZStack {
            LookScreenBackground()

            VStack(alignment: .leading, spacing: 0) {
                header
                    .padding(.horizontal, LookSpacing.pageHorizontal)
                    .padding(.top, LookSpacing.xl)
                    .padding(.bottom, LookSpacing.md)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: LookSpacing.lg) {
                        if favoriteStore.favorites.isEmpty {
                            EmptyStateView(
                                systemImage: "heart",
                                title: L10n.Favorites.emptyTitle,
                                message: L10n.Favorites.emptyMessage,
                                actionTitle: L10n.Favorites.goHome
                            ) {
                                navigationState.selectedTab = .home
                            }
                        } else {
                            VStack(spacing: LookSpacing.sm) {
                                ForEach(favoriteStore.favorites) { favorite in
                                    favoriteCard(favorite)
                                }

                                deleteAllFavoritesButton
                            }
                        }
                    }
                    .padding(.horizontal, LookSpacing.pageHorizontal)
                    .padding(.bottom, LookSpacing.tabContentBottomPadding)
                }
            }
        }
        .lookToast($toastMessage)
        .alert(localized(L10n.Favorites.Alert.deleteAllTitle), isPresented: $isShowingDeleteAllConfirm) {
            Button(localized(L10n.Common.cancel), role: .cancel) {}
            Button(localized(L10n.Favorites.deleteAll), role: .destructive) {
                clearAllFavorites()
            }
        } message: {
            Text(L10n.key(L10n.Favorites.Alert.deleteAllMessage))
        }
        .fullScreenCover(item: $paywallContext) { context in
            ProPaywallView(context: context)
        }
    }

    private var header: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(L10n.key(L10n.Favorites.title))
                .font(LookTypography.pageTitle)
                .foregroundStyle(
                    LinearGradient(
                        colors: [skin.textPrimary, skin.textSecondary, skin.primary.opacity(0.82)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Spacer()

            Button(localized(isEditing ? L10n.Favorites.done : L10n.Favorites.edit)) {
                withAnimation(.spring(response: 0.28, dampingFraction: 0.86)) {
                    isEditing.toggle()
                }
            }
            .font(LookTypography.body)
            .foregroundColor(skin.primary)
            .disabled(favoriteStore.favorites.isEmpty)
            .opacity(favoriteStore.favorites.isEmpty ? 0.45 : 1)
        }
    }

    private func favoriteCard(_ favorite: FavoriteBanner) -> some View {
        Button {
            if isEditing {
                favoriteStore.removeFavorite(id: favorite.id)
            } else {
                let style = styleStore.style(withID: favorite.styleID)
                guard purchaseManager.canUse(style) else {
                    showPaywall(.favoriteProStyle) {
                        applyFavorite(favorite)
                    }
                    return
                }
                guard purchaseManager.canUse(favorite.fontStyle) else {
                    showPaywall(.premiumFont(titleKey: favorite.fontStyle.titleKey)) {
                        applyFavorite(favorite)
                    }
                    return
                }
                applyFavorite(favorite)
            }
        } label: {
            NeonCard {
                HStack(spacing: LookSpacing.md) {
                    preview(for: favorite)

                    VStack(alignment: .leading, spacing: LookSpacing.xxs) {
                        Text(favorite.text)
                            .font(LookTypography.sectionTitle)
                            .foregroundColor(skin.textPrimary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.72)

                        Text("\(localized(favorite.scene.titleKey)) · \(localized(styleStore.style(withID: favorite.styleID).nameKey))")
                            .font(LookTypography.caption)
                            .foregroundColor(skin.textTertiary)
                            .lineLimit(1)

                        Text(L10n.format(
                            L10n.Favorites.speedSizeFormat,
                            locale: settingsStore.appLanguage.locale,
                            Int(favorite.speed * 100),
                            Int(favorite.fontScale * 100)
                        ))
                            .font(LookTypography.caption.monospacedDigit())
                            .foregroundColor(skin.textTertiary.opacity(0.82))
                            .lineLimit(1)

                        Text(Self.dateFormatter.string(from: favorite.createdAt))
                            .font(LookTypography.caption.monospacedDigit())
                            .foregroundColor(skin.textTertiary.opacity(0.62))
                    }

                    Spacer()

                    Button {
                        favoriteStore.removeFavorite(id: favorite.id)
                    } label: {
                        Image(systemName: isEditing ? "trash.fill" : "heart.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(isEditing ? LookTheme.Colors.danger : skin.primary)
                            .frame(width: 36, height: 36)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var deleteAllFavoritesButton: some View {
        Button(role: .destructive) {
            isShowingDeleteAllConfirm = true
        } label: {
            HStack(spacing: LookSpacing.xs) {
                Image(systemName: "trash")
                    .font(.system(size: 15, weight: .bold, design: .rounded))

                Text(L10n.key(L10n.Favorites.deleteAll))
                    .font(LookTypography.button)
            }
            .foregroundColor(LookTheme.Colors.danger)
            .frame(maxWidth: .infinity, minHeight: 50)
            .background(
                Capsule()
                    .fill(skin.card.opacity(0.88))
                    .overlay(Capsule().stroke(LookTheme.Colors.danger.opacity(0.42), lineWidth: 1))
            )
        }
        .buttonStyle(.plain)
        .padding(.top, LookSpacing.sm)
    }

    private func preview(for favorite: FavoriteBanner) -> some View {
        let style = styleStore.style(withID: favorite.styleID)
        return StyleCard(
            style: style,
            isSelected: false,
            previewColor: Color(hex: favorite.textColorHex),
            fontStyle: favorite.fontStyle,
            isCompact: true,
            compactPreviewHeight: 64,
            isLocked: style.isPro && !purchaseManager.isProUnlocked,
            previewLocale: settingsStore.appLanguage.locale
        ) {}
        .frame(width: 78, height: 64, alignment: .top)
        .clipped()
        .allowsHitTesting(false)
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd HH:mm"
        return formatter
    }()

    private func showToast(_ message: String) {
        toastMessage = message
    }

    private func applyFavorite(_ favorite: FavoriteBanner) {
        displayConfigStore.applyFavorite(favorite)
        navigationState.selectedTab = .home
    }

    private func clearAllFavorites() {
        favoriteStore.clearAll()
        isEditing = false
        showToast(localized(L10n.Favorites.Toast.deletedAll))
    }

    private func localized(_ key: String) -> String {
        L10n.string(key, locale: settingsStore.appLanguage.locale)
    }

    private func showPaywall(_ source: ProPaywallSource, onUnlocked: @escaping @MainActor () -> Void = {}) {
        purchaseManager.clearTransientState()
        paywallContext = ProPaywallContext(source: source, onUnlocked: onUnlocked)
    }
}

#Preview {
    FavoritesView()
        .environmentObject(AppNavigationState())
        .environmentObject(DisplayConfigStore())
        .environmentObject(FavoriteStore())
        .environmentObject(StyleStore())
        .environmentObject(SettingsStore())
        .environmentObject(PurchaseManager(autoStart: false))
}
