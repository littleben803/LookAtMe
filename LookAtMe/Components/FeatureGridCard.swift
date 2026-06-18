import SwiftUI

struct FeatureGridCard: View {
    let title: String
    let subtitle: String?
    let systemImage: String
    var isPro: Bool = false
    var isLocked: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            FeatureGridCardLabel(
                title: title,
                subtitle: subtitle,
                systemImage: systemImage,
                isPro: isPro,
                isLocked: isLocked
            )
        }
        .buttonStyle(.plain)
    }
}

struct FeatureGridCardLabel: View {
    let title: String
    let subtitle: String?
    let systemImage: String
    var isPro: Bool = false
    var isLocked: Bool = false
    @Environment(\.lookSkin) private var skin

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: LookSpacing.sm) {
                Image(systemName: systemImage)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: isLocked
                                ? [skin.pro, skin.primary]
                                : [skin.primary, skin.secondary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 42, height: 42)
                    .background(Circle().fill(skin.background.opacity(0.58)))

                VStack(alignment: .leading, spacing: LookSpacing.xxs) {
                    Text(L10n.key(title))
                        .font(LookTypography.body.weight(.semibold))
                        .foregroundColor(skin.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)

                    if let subtitle {
                        Text(L10n.key(subtitle))
                            .font(LookTypography.caption)
                            .foregroundColor(skin.textTertiary)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .frame(maxWidth: .infinity, minHeight: 112, alignment: .leading)
            .padding(LookSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: skin.chrome.cardRadius, style: .continuous)
                    .fill(skin.card.opacity(0.9))
            )
            .overlay(
                RoundedRectangle(cornerRadius: skin.chrome.cardRadius, style: .continuous)
                    .stroke(isLocked ? skin.pro.opacity(0.38) : skin.primary.opacity(0.38), lineWidth: 1)
            )
            .shadow(color: skin.primary.opacity(0.18), radius: 12, y: 8)

            if isPro {
                ProBadge()
                    .padding(8)
            }
        }
    }
}
