import SwiftUI

struct LEDDisplayEffectText: View {
    let context: LEDDisplayEffectContext
    let fixedWidth: Bool
    let opacity: Double

    var body: some View {
        Text(context.draft.text)
            .font(context.draft.fontStyle.font(size: 70 * CGFloat(context.fontScale)))
            .lineLimit(1)
            .minimumScaleFactor(fixedWidth ? 1 : 0.55)
            .fixedSize(horizontal: fixedWidth, vertical: false)
            .foregroundStyle(Self.textStyle(for: context.draft))
            .shadow(color: Self.accentColor(for: context.draft).opacity(1.0), radius: 9)
            .shadow(color: Self.accentColor(for: context.draft).opacity(0.78), radius: 24)
            .shadow(color: Self.accentColor(for: context.draft).opacity(0.42), radius: 44)
            .opacity(context.draft.isBlinking ? opacity : 1)
            .scaleEffect(x: context.draft.isMirrored ? -1 : 1, y: 1)
    }

    static func displayContentWidth(totalWidth: CGFloat, safeAreaInsets: EdgeInsets) -> CGFloat {
        max(
            1,
            totalWidth
                - safeAreaInsets.leading
                - safeAreaInsets.trailing
                - LookSpacing.pageHorizontal * 2
        )
    }

    static func accentColor(for draft: BannerDraft) -> Color {
        switch draft.selectedStyle.type {
        case .marquee:
            LookTheme.Colors.primaryPink
        case .neonBlink:
            LookTheme.Colors.electricBlue
        case .breathing:
            draft.textColor
        case .typewriter:
            LookTheme.Colors.softPink
        case .heartRain:
            LookTheme.Colors.hotPink
        case .rainbow:
            LookTheme.Colors.neonPurple
        case .starFlash:
            LookTheme.Colors.warmYellow
        case .bulletFlyIn:
            LookTheme.Colors.electricBlue
        case .meteorShower:
            LookTheme.Colors.warmYellow
        case .laserSweep:
            LookTheme.Colors.electricBlue
        case .fireworkBurst:
            LookTheme.Colors.hotPink
        case .heartBeat:
            LookTheme.Colors.hotPink
        case .auroraWave:
            LookTheme.Colors.neonPurple
        case .bubblePop:
            LookTheme.Colors.softPink
        case .spotlight:
            LookTheme.Colors.warmYellow
        case .glitchPulse:
            LookTheme.Colors.electricBlue
        }
    }

    static func textStyle(for draft: BannerDraft) -> LinearGradient {
        switch draft.selectedStyle.type {
        case .rainbow, .auroraWave:
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
        case .neonBlink, .starFlash, .bulletFlyIn, .meteorShower, .laserSweep, .fireworkBurst, .glitchPulse:
            LinearGradient(
                colors: [
                    LookTheme.Colors.textPrimary,
                    LookTheme.Colors.electricBlue,
                    LookTheme.Colors.hotPink
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .spotlight:
            LinearGradient(
                colors: [
                    LookTheme.Colors.textPrimary,
                    LookTheme.Colors.warmYellow,
                    LookTheme.Colors.hotPink
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        default:
            LinearGradient(
                colors: [
                    LookTheme.Colors.textPrimary,
                    draft.textColor,
                    LookTheme.Colors.hotPink
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
}
