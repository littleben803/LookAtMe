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

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: LookSpacing.sm) {
                Image(systemName: systemImage)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: isLocked
                                ? [LookTheme.Colors.warmYellow, LookTheme.Colors.hotPink]
                                : [LookTheme.Colors.primaryPink, LookTheme.Colors.electricBlue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 42, height: 42)
                    .background(Circle().fill(LookTheme.Colors.backgroundBlack.opacity(0.58)))

                VStack(alignment: .leading, spacing: LookSpacing.xxs) {
                    Text(L10n.key(title))
                        .font(LookTypography.body.weight(.semibold))
                        .foregroundColor(LookTheme.Colors.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)

                    if let subtitle {
                        Text(L10n.key(subtitle))
                            .font(LookTypography.caption)
                            .foregroundColor(LookTheme.Colors.textTertiary)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .frame(maxWidth: .infinity, minHeight: 112, alignment: .leading)
            .padding(LookSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: LookRadius.styleCard, style: .continuous)
                    .fill(LookTheme.Colors.cardPurple.opacity(0.9))
            )
            .overlay(
                RoundedRectangle(cornerRadius: LookRadius.styleCard, style: .continuous)
                    .stroke(isLocked ? LookTheme.Colors.warmYellow.opacity(0.38) : LookTheme.Colors.primaryPink.opacity(0.38), lineWidth: 1)
            )
            .shadow(color: LookTheme.Colors.primaryPink.opacity(0.18), radius: 12, y: 8)

            if isPro {
                ProBadge()
                    .padding(8)
            }
        }
    }
}
