import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject private var navigationState: AppNavigationState

    private let sampleFavorites = [
        ("周深我爱你！", "mock/sample - 演唱会"),
        ("老婆我爱你", "mock/sample - 表白"),
        ("生日快乐🎂", "mock/sample - 生日")
    ]

    var body: some View {
        ZStack {
            LookScreenBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: LookSpacing.lg) {
                    header

                    if sampleFavorites.isEmpty {
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
                            ForEach(sampleFavorites, id: \.0) { favorite in
                                favoriteCard(title: favorite.0, subtitle: favorite.1)
                            }
                        }
                    }
                }
                .padding(.horizontal, LookSpacing.pageHorizontal)
                .padding(.top, LookSpacing.xl)
                .padding(.bottom, LookSpacing.xxxl)
            }
        }
    }

    private var header: some View {
        HStack(alignment: .firstTextBaseline) {
            Text("我的收藏")
                .font(LookTypography.pageTitle)
                .foregroundColor(LookTheme.Colors.textPrimary)

            Spacer()

            Button("编辑") {}
                .font(LookTypography.body)
                .foregroundColor(LookTheme.Colors.hotPink)
        }
    }

    private func favoriteCard(title: String, subtitle: String) -> some View {
        NeonCard {
            HStack(spacing: LookSpacing.md) {
                ZStack {
                    RoundedRectangle(cornerRadius: LookRadius.chip, style: .continuous)
                        .fill(LookTheme.Colors.backgroundBlack)
                        .frame(width: 46, height: 46)
                        .overlay(
                            RoundedRectangle(cornerRadius: LookRadius.chip, style: .continuous)
                                .stroke(LookTheme.Colors.primaryPink.opacity(0.42), lineWidth: 1)
                        )

                    Text(title.prefix(2))
                        .font(.system(size: 13, weight: .heavy, design: .rounded))
                        .foregroundColor(LookTheme.Colors.primaryPink)
                }

                VStack(alignment: .leading, spacing: LookSpacing.xxs) {
                    Text(title)
                        .font(LookTypography.sectionTitle)
                        .foregroundColor(LookTheme.Colors.textPrimary)
                    Text(subtitle)
                        .font(LookTypography.caption)
                        .foregroundColor(LookTheme.Colors.textTertiary)
                }

                Spacer()

                Image(systemName: "heart")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(LookTheme.Colors.hotPink)
            }
        }
    }
}

#Preview {
    FavoritesView()
        .environmentObject(AppNavigationState())
}

