import SwiftUI

struct PlaceholderScreen: View {
    let title: String
    let subtitle: String
    let systemImage: String
    let message: String
    @Environment(\.lookSkin) private var skin

    var body: some View {
        ZStack {
            LookScreenBackground()

            VStack(spacing: LookSpacing.xl) {
                Image(systemName: systemImage)
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .foregroundColor(skin.primary)
                    .lookShadow(LookShadow.neon)

                VStack(spacing: LookSpacing.xs) {
                    Text(L10n.key(title))
                        .font(LookTypography.largeTitle)
                        .foregroundColor(skin.textPrimary)

                    Text(L10n.key(subtitle))
                        .font(LookTypography.sectionTitle)
                        .foregroundColor(skin.primary)
                }

                NeonCard {
                    Text(L10n.key(message))
                        .font(LookTypography.body)
                        .foregroundColor(skin.textSecondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, LookSpacing.pageHorizontal)
            }
            .padding(.vertical, LookSpacing.xxxl)
        }
    }
}

#Preview {
    PlaceholderScreen(
        title: "想恋爱",
        subtitle: "灯牌工具",
        systemImage: "sparkles",
        message: "把手机变成会发光的表白灯牌。"
    )
}
