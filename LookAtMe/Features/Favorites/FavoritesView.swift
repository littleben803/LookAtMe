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
                    .padding(.bottom, LookSpacing.tabContentBottomPadding)
                }
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

                        Text("速度 \(Int(favorite.speed * 100))% · 大小 \(Int(favorite.fontScale * 100))%")
                            .font(LookTypography.caption.monospacedDigit())
                            .foregroundColor(LookTheme.Colors.textTertiary.opacity(0.82))
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
        StyleCard(
            style: styleStore.style(withID: favorite.styleID),
            isSelected: false,
            previewColor: Color(hex: favorite.textColorHex),
            fontStyle: favorite.fontStyle,
            isCompact: true,
            compactPreviewHeight: 64
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
}

#Preview {
    FavoritesView()
        .environmentObject(AppNavigationState())
        .environmentObject(DisplayConfigStore())
        .environmentObject(FavoriteStore())
        .environmentObject(StyleStore())
}
