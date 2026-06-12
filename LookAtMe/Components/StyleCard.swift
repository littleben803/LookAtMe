import SwiftUI

struct StyleCard: View {
    let style: BannerStyle
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topTrailing) {
                VStack(alignment: .leading, spacing: LookSpacing.xs) {
                    stylePreview
                        .frame(height: 64)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: LookRadius.styleCard, style: .continuous)
                                .fill(LookTheme.Colors.backgroundBlack)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: LookRadius.styleCard, style: .continuous)
                                .stroke(LookTheme.Colors.neonPurple.opacity(0.42), lineWidth: 1)
                        )

                    HStack(spacing: LookSpacing.xs) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(style.name)
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundColor(LookTheme.Colors.textPrimary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.75)

                            Text(style.isPro ? "高级样式" : "免费")
                                .font(LookTypography.caption)
                                .foregroundColor(style.isPro ? LookTheme.Colors.warmYellow : LookTheme.Colors.textTertiary)
                        }
                        Spacer(minLength: LookSpacing.xs)
                    }
                }
                .padding(LookSpacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: LookRadius.styleCard, style: .continuous)
                        .fill(LookTheme.Colors.cardPurple.opacity(0.92))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: LookRadius.styleCard, style: .continuous)
                        .stroke(isSelected ? LookTheme.Colors.primaryPink : LookTheme.Colors.primaryPink.opacity(0.24), lineWidth: isSelected ? 1.8 : 1)
                )
                .shadow(color: LookTheme.Colors.primaryPink.opacity(isSelected ? 0.34 : 0.14), radius: isSelected ? 16 : 8)

                if style.isPro {
                    ProBadge()
                        .padding(8)
                }
            }
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var stylePreview: some View {
        switch style.type {
        case .marquee:
            Text(style.previewText)
                .font(.system(size: 24, weight: .heavy, design: .rounded))
                .foregroundColor(LookTheme.Colors.primaryPink)
                .shadow(color: LookTheme.Colors.primaryPink.opacity(0.9), radius: 8)
        case .neonBlink:
            Text(style.previewText)
                .font(.system(size: 24, weight: .heavy, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [LookTheme.Colors.hotPink, LookTheme.Colors.electricBlue],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .shadow(color: LookTheme.Colors.electricBlue.opacity(0.8), radius: 8)
        case .heartRain:
            ZStack {
                ForEach(0..<8, id: \.self) { index in
                    Image(systemName: "heart.fill")
                        .font(.system(size: CGFloat(8 + index % 3 * 3), weight: .bold))
                        .foregroundColor(index.isMultiple(of: 2) ? LookTheme.Colors.primaryPink : LookTheme.Colors.hotPink)
                        .offset(x: CGFloat((index % 4) * 18 - 27), y: CGFloat((index / 4) * 18 - 14))
                        .shadow(color: LookTheme.Colors.primaryPink.opacity(0.8), radius: 6)
                }
            }
        case .rainbow:
            Text(style.previewText)
                .font(.system(size: 22, weight: .heavy, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            LookTheme.Colors.primaryPink,
                            LookTheme.Colors.warmYellow,
                            LookTheme.Colors.electricBlue,
                            LookTheme.Colors.neonPurple
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .shadow(color: LookTheme.Colors.neonPurple.opacity(0.9), radius: 8)
        }
    }
}

