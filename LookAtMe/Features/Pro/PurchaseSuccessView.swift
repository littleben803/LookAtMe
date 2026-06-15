import SwiftUI

struct PurchaseSuccessView: View {
    let onStart: () -> Void

    var body: some View {
        ZStack {
            LookScreenBackground()

            VStack(spacing: LookSpacing.xl) {
                Spacer(minLength: 24)

                successIcon

                VStack(spacing: LookSpacing.sm) {
                    Text(L10n.key(L10n.Pro.Success.title))
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
                        .shadow(color: LookTheme.Colors.primaryPink.opacity(0.62), radius: 18)

                    Text(L10n.key(L10n.Pro.Success.subtitle))
                        .font(LookTypography.sectionTitle)
                        .foregroundColor(LookTheme.Colors.hotPink)

                    Text(L10n.key(L10n.Pro.Success.message))
                        .font(LookTypography.body)
                        .foregroundColor(LookTheme.Colors.textTertiary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }

                PrimaryButton(L10n.Pro.Success.start, systemImage: "sparkles") {
                    onStart()
                }

                Spacer(minLength: 24)
            }
            .padding(.horizontal, LookSpacing.pageHorizontal)
        }
    }

    private var successIcon: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            LookTheme.Colors.primaryPink.opacity(0.42),
                            LookTheme.Colors.neonPurple.opacity(0.18),
                            .clear
                        ],
                        center: .center,
                        startRadius: 8,
                        endRadius: 88
                    )
                )
                .frame(width: 176, height: 176)
                .blur(radius: 2)

            Circle()
                .fill(LookTheme.Colors.cardPurple.opacity(0.88))
                .frame(width: 112, height: 112)
                .overlay(
                    Circle()
                        .stroke(LookTheme.neonBorderGradient, lineWidth: 1.4)
                )
                .shadow(color: LookTheme.Colors.primaryPink.opacity(0.48), radius: 28)

            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 44, weight: .black, design: .rounded))
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
                .shadow(color: LookTheme.Colors.warmYellow.opacity(0.58), radius: 16)
        }
    }
}

#Preview {
    PurchaseSuccessView {}
}
