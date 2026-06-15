import SwiftUI

struct PlaceholderScreen: View {
    let title: String
    let subtitle: String
    let systemImage: String
    let message: String

    var body: some View {
        ZStack {
            LookTheme.appBackground
                .ignoresSafeArea()

            VStack(spacing: LookSpacing.xl) {
                Image(systemName: systemImage)
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .foregroundColor(LookTheme.Colors.primaryPink)
                    .lookShadow(LookShadow.neon)

                VStack(spacing: LookSpacing.xs) {
                    Text(title)
                        .font(LookTypography.largeTitle)
                        .foregroundColor(LookTheme.Colors.textPrimary)

                    Text(subtitle)
                        .font(LookTypography.sectionTitle)
                        .foregroundColor(LookTheme.Colors.hotPink)
                }

                NeonCard {
                    Text(message)
                        .font(LookTypography.body)
                        .foregroundColor(LookTheme.Colors.textSecondary)
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
