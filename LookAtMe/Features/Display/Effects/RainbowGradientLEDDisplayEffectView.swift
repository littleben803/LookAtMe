import SwiftUI

struct RainbowGradientLEDDisplayEffectView: View {
    let context: LEDDisplayEffectContext

    var body: some View {
        let width = max(1, context.viewportSize.width)
        let height = max(1, context.viewportSize.height)

        LEDDisplayEffectClock(
            context: context,
            cycleDuration: { speed in max(1.0, 2.6 / max(0.2, speed)) }
        ) { phase in
            ZStack {
                rainbowBackground(width: width, height: height, phase: phase)
                flowingBands(width: width, height: height, phase: phase)
                rainbowText(width: width, phase: phase)
            }
            .frame(width: width, height: height)
            .clipped()
        }
    }

    private var fontSize: CGFloat {
        70 * CGFloat(context.fontScale)
    }

    private var rainbowColors: [Color] {
        [
            LookTheme.Colors.hotPink,
            LookTheme.Colors.warmYellow,
            LookTheme.Colors.electricBlue,
            LookTheme.Colors.neonPurple,
            LookTheme.Colors.softPink
        ]
    }

    private func rainbowBackground(width: CGFloat, height: CGFloat, phase: Double) -> some View {
        ZStack {
            RadialGradient(
                colors: [
                    LookTheme.Colors.hotPink.opacity(0.12),
                    LookTheme.Colors.electricBlue.opacity(0.08),
                    .clear
                ],
                center: UnitPoint(x: 0.4 + 0.2 * sin(phase * .pi * 2), y: 0.52),
                startRadius: 12,
                endRadius: max(width, height) * 0.62
            )

            RadialGradient(
                colors: [
                    LookTheme.Colors.warmYellow.opacity(0.09),
                    LookTheme.Colors.neonPurple.opacity(0.08),
                    .clear
                ],
                center: UnitPoint(x: 0.62 + 0.16 * cos(phase * .pi * 2), y: 0.44),
                startRadius: 12,
                endRadius: max(width, height) * 0.52
            )
        }
        .allowsHitTesting(false)
    }

    private func flowingBands(width: CGFloat, height: CGFloat, phase: Double) -> some View {
        ZStack {
            ForEach(0..<7, id: \.self) { index in
                let progress = LEDDisplayEffectMath.normalized(phase + Double(index) * 0.135)
                let bandWidth = width * CGFloat(0.38 + Double(index % 3) * 0.08)

                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                .clear,
                                rainbowColors[index % rainbowColors.count].opacity(0.18),
                                rainbowColors[(index + 2) % rainbowColors.count].opacity(0.22),
                                .clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: bandWidth, height: max(36, height * 0.09))
                    .offset(
                        x: CGFloat(progress - 0.5) * width * 1.3,
                        y: CGFloat(index - 3) * max(22, height * 0.05)
                    )
                    .rotationEffect(.degrees(index.isMultiple(of: 2) ? -12 : 12))
                    .blur(radius: 13)
                    .blendMode(.plusLighter)
            }
        }
        .allowsHitTesting(false)
    }

    private func rainbowText(width: CGFloat, phase: Double) -> some View {
        let blink = LEDDisplayEffectMath.blink(isEnabled: context.draft.isBlinking, phase: phase * 0.66)
        let pulse = 0.5 + 0.5 * sin(phase * .pi * 2)

        return ZStack {
            Text(context.draft.text)
                .font(context.draft.fontStyle.font(size: fontSize))
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .multilineTextAlignment(.center)
                .foregroundStyle(rainbowGradient(phase: phase + 0.12))
                .frame(width: width)
                .scaleEffect(x: context.draft.isMirrored ? -1.03 : 1.03, y: 1.03)
                .blur(radius: 20)
                .opacity((0.26 + pulse * 0.08) * blink)
                .shadow(color: LookTheme.Colors.hotPink.opacity(0.52), radius: 28)

            Text(context.draft.text)
                .font(context.draft.fontStyle.font(size: fontSize))
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .multilineTextAlignment(.center)
                .foregroundStyle(rainbowGradient(phase: phase))
                .frame(width: width)
                .scaleEffect(x: context.draft.isMirrored ? -1 : 1, y: 1)
                .opacity((0.84 + pulse * 0.16) * blink)
                .shadow(color: LookTheme.Colors.hotPink.opacity(0.58), radius: 10)
                .shadow(color: LookTheme.Colors.electricBlue.opacity(0.46), radius: 26)
                .shadow(color: LookTheme.Colors.neonPurple.opacity(0.42), radius: 40)
        }
    }

    private func rainbowGradient(phase: Double) -> LinearGradient {
        let offset = Int((phase * Double(rainbowColors.count)).rounded(.down))
        let rotated = (0..<rainbowColors.count).map { index in
            rainbowColors[(index + offset) % rainbowColors.count]
        }

        return LinearGradient(
            colors: rotated + [rotated[0]],
            startPoint: UnitPoint(x: -0.2 + 0.4 * LEDDisplayEffectMath.triangle(phase), y: 0.5),
            endPoint: UnitPoint(x: 1.2 - 0.4 * LEDDisplayEffectMath.triangle(phase), y: 0.5)
        )
    }
}
