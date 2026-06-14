import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject private var navigationState: AppNavigationState
    @EnvironmentObject private var displayConfigStore: DisplayConfigStore
    @EnvironmentObject private var favoriteStore: FavoriteStore
    @EnvironmentObject private var styleStore: StyleStore

    @State private var isEditing = false

    var body: some View {
        ZStack {
            LookScreenBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: LookSpacing.lg) {
                    header

                    if favoriteStore.favorites.isEmpty {
                        EmptyStateView(
                            systemImage: "heart",
                            title: "还没有收藏哦~",
                            message: "快去首页做一条属于你的灯牌吧",
                            actionTitle: "去首页"
                        ) {
                            navigationState.selectedTab = .home
                        }
                    } else {
                        VStack(spacing: LookSpacing.sm) {
                            ForEach(favoriteStore.favorites) { favorite in
                                favoriteCard(favorite)
                            }
                        }
                    }
                }
                .padding(.horizontal, LookSpacing.pageHorizontal)
                .padding(.top, LookSpacing.xl)
                .padding(.bottom, LookSpacing.tabContentBottomPadding)
            }
        }
    }

    private var header: some View {
        HStack(alignment: .firstTextBaseline) {
            Text("我的收藏")
                .font(LookTypography.pageTitle)
                .foregroundColor(LookTheme.Colors.textPrimary)

            Spacer()

            Button(isEditing ? "完成" : "编辑") {
                withAnimation(.spring(response: 0.28, dampingFraction: 0.86)) {
                    isEditing.toggle()
                }
            }
            .font(LookTypography.body)
            .foregroundColor(LookTheme.Colors.hotPink)
            .disabled(favoriteStore.favorites.isEmpty)
            .opacity(favoriteStore.favorites.isEmpty ? 0.45 : 1)
        }
    }

    private func favoriteCard(_ favorite: FavoriteBanner) -> some View {
        Button {
            if isEditing {
                favoriteStore.removeFavorite(id: favorite.id)
            } else {
                displayConfigStore.applyFavorite(favorite)
                navigationState.selectedTab = .home
            }
        } label: {
            NeonCard {
                HStack(spacing: LookSpacing.md) {
                    preview(for: favorite)

                    VStack(alignment: .leading, spacing: LookSpacing.xxs) {
                        Text(favorite.text)
                            .font(LookTypography.sectionTitle)
                            .foregroundColor(LookTheme.Colors.textPrimary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.72)

                        Text("\(favorite.scene.title) · \(styleStore.style(withID: favorite.styleID).name)")
                            .font(LookTypography.caption)
                            .foregroundColor(LookTheme.Colors.textTertiary)
                            .lineLimit(1)

                        Text(Self.dateFormatter.string(from: favorite.createdAt))
                            .font(LookTypography.caption.monospacedDigit())
                            .foregroundColor(LookTheme.Colors.textDisabled)
                    }

                    Spacer()

                    Button {
                        favoriteStore.removeFavorite(id: favorite.id)
                    } label: {
                        Image(systemName: isEditing ? "trash.fill" : "heart.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(isEditing ? LookTheme.Colors.danger : LookTheme.Colors.hotPink)
                            .frame(width: 36, height: 36)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private func preview(for favorite: FavoriteBanner) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: LookRadius.chip, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: favorite.backgroundColorHex),
                            LookTheme.Colors.cardPurple.opacity(0.86)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 62, height: 54)
                .overlay(
                    RoundedRectangle(cornerRadius: LookRadius.chip, style: .continuous)
                        .stroke(Color(hex: favorite.textColorHex).opacity(0.62), lineWidth: 1)
                )

            Text(String(favorite.text.prefix(2)))
                .font(favorite.fontStyle.font(size: 14))
                .foregroundColor(Color(hex: favorite.textColorHex))
                .lineLimit(1)
                .shadow(color: Color(hex: favorite.textColorHex).opacity(0.84), radius: 7)
        }
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd HH:mm"
        return formatter
    }()
}

#Preview {
    FavoritesView()
        .environmentObject(AppNavigationState())
        .environmentObject(DisplayConfigStore())
        .environmentObject(FavoriteStore())
        .environmentObject(StyleStore())
}
