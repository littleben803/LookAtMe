import SwiftUI

struct PurchaseSuccessView: View {
    let onStart: () -> Void
    @Environment(\.lookSkin) private var skin

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
                                    skin.textPrimary,
                                    skin.textSecondary,
                                    skin.primary
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .multilineTextAlignment(.center)
                        .shadow(color: skin.primary.opacity(0.62), radius: 18)

                    Text(L10n.key(L10n.Pro.Success.subtitle))
                        .font(LookTypography.sectionTitle)
                        .foregroundColor(skin.primary)

                    Text(L10n.key(L10n.Pro.Success.message))
                        .font(LookTypography.body)
                        .foregroundColor(skin.textTertiary)
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
                            skin.primary.opacity(0.42),
                            skin.secondary.opacity(0.18),
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
                .fill(skin.card.opacity(0.88))
                .frame(width: 112, height: 112)
                .overlay(
                    Circle()
                        .stroke(skin.neonBorderGradient, lineWidth: 1.4)
                )
                .shadow(color: skin.primary.opacity(0.48), radius: 28)

            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 44, weight: .black, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            skin.pro,
                            skin.primary
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: skin.pro.opacity(0.58), radius: 16)
        }
    }
}

#Preview {
    PurchaseSuccessView {}
}
