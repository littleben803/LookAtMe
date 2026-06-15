import SwiftUI

struct AuroraWaveLEDDisplayEffectView: View {
    let context: LEDDisplayEffectContext

    var body: some View {
        let width = max(1, context.viewportSize.width)
        let height = max(1, context.viewportSize.height)

        LEDDisplayEffectClock(
            context: context,
            cycleDuration: { speed in max(1.2, 3.0 / max(0.2, speed)) }
        ) { phase in
            ZStack {
                auroraBackground(width: width, height: height, phase: phase)
                auroraCurtains(width: width, height: height, phase: phase)
                auroraParticles(width: width, height: height, phase: phase)
                auroraText(width: width, phase: phase)
            }
            .frame(width: width, height: height)
            .clipped()
        }
    }

    private var fontSize: CGFloat {
        70 * CGFloat(context.fontScale)
    }

    private func auroraBackground(width: CGFloat, height: CGFloat, phase: Double) -> some View {
        ZStack {
            RadialGradient(
                colors: [
                    LookTheme.Colors.electricBlue.opacity(0.12),
                    LookTheme.Colors.neonPurple.opacity(0.12),
                    .clear
                ],
                center: UnitPoint(x: 0.45 + 0.14 * sin(phase * .pi * 2), y: 0.42),
                startRadius: 12,
                endRadius: max(width, height) * 0.62
            )

            RadialGradient(
                colors: [
                    LookTheme.Colors.hotPink.opacity(0.1),
                    .clear
                ],
                center: UnitPoint(x: 0.62 + 0.12 * cos(phase * .pi * 2), y: 0.58),
                startRadius: 18,
                endRadius: max(width, height) * 0.48
            )
        }
        .allowsHitTesting(false)
    }

    private func auroraCurtains(width: CGFloat, height: CGFloat, phase: Double) -> some View {
        ZStack {
            ForEach(0..<5, id: \.self) { index in
                let local = LEDDisplayEffectMath.normalized(phase + Double(index) * 0.18)
                let y = CGFloat(index - 2) * max(28, height * 0.06)

                Capsule()
                    .fill(
                        LinearGradient(
                            colors: auroraColors(index: index, phase: local),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: width * CGFloat(1.0 + Double(index) * 0.1), height: max(90, height * CGFloat(0.16 + Double(index) * 0.012)))
                    .offset(
                        x: CGFloat(sin((phase + Double(index) * 0.11) * .pi * 2)) * width * 0.11,
                        y: y + CGFloat(cos((phase + Double(index) * 0.17) * .pi * 2)) * height * 0.04
                    )
                    .rotationEffect(.degrees(-8 + Double(index) * 4 + sin(phase * .pi * 2) * 3))
                    .blur(radius: 22 + CGFloat(index) * 4)
                    .opacity(0.48 - Double(index) * 0.045)
                    .blendMode(.plusLighter)
            }
        }
        .allowsHitTesting(false)
    }

    private func auroraParticles(width: CGFloat, height: CGFloat, phase: Double) -> some View {
        ZStack {
            ForEach(0..<24, id: \.self) { index in
                let local = LEDDisplayEffectMath.normalized(phase * particleSpeed(index) + Double(index) * 0.041)
                let shimmer = 0.5 + 0.5 * sin((phase + Double(index) * 0.09) * .pi * 2)

                Circle()
                    .fill(particleColor(index).opacity(0.12 + shimmer * 0.38))
                    .frame(width: particleSize(index), height: particleSize(index))
                    .position(
                        x: width * particleX(index: index, local: local),
                        y: height * particleY(index: index, local: local)
                    )
                    .blur(radius: 0.6)
                    .shadow(color: particleColor(index).opacity(0.42 * shimmer), radius: 8)
            }
        }
        .allowsHitTesting(false)
    }

    private func auroraText(width: CGFloat, phase: Double) -> some View {
        let blink = LEDDisplayEffectMath.blink(isEnabled: context.draft.isBlinking, phase: phase * 0.62)
        let wave = 0.5 + 0.5 * sin(phase * .pi * 2)

        return ZStack {
            Text(context.draft.text)
                .font(context.draft.fontStyle.font(size: fontSize))
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .multilineTextAlignment(.center)
                .foregroundStyle(auroraTextGradient(phase: phase))
                .frame(width: width)
                .scaleEffect(x: context.draft.isMirrored ? -1.025 : 1.025, y: 1.025)
                .blur(radius: 22)
                .opacity((0.25 + wave * 0.08) * blink)

            Text(context.draft.text)
                .font(context.draft.fontStyle.font(size: fontSize))
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .multilineTextAlignment(.center)
                .foregroundStyle(auroraTextGradient(phase: phase + 0.12))
                .frame(width: width)
                .scaleEffect(x: context.draft.isMirrored ? -1 : 1, y: 1)
                .opacity((0.82 + wave * 0.16) * blink)
                .shadow(color: LookTheme.Colors.electricBlue.opacity(0.68), radius: 12)
                .shadow(color: LookTheme.Colors.neonPurple.opacity(0.56), radius: 34)
                .shadow(color: LookTheme.Colors.hotPink.opacity(0.34), radius: 52)
        }
    }

    private func auroraColors(index: Int, phase: Double) -> [Color] {
        let shift = LEDDisplayEffectMath.triangle(phase)
        let first = index.isMultiple(of: 2) ? LookTheme.Colors.electricBlue : LookTheme.Colors.hotPink
        let second = index.isMultiple(of: 2) ? LookTheme.Colors.neonPurple : LookTheme.Colors.electricBlue

        return [
            .clear,
            first.opacity(0.28 + shift * 0.16),
            LookTheme.Colors.softPink.opacity(0.12 + shift * 0.08),
            second.opacity(0.26 + (1 - shift) * 0.14),
            .clear
        ]
    }

    private func auroraTextGradient(phase: Double) -> LinearGradient {
        LinearGradient(
            colors: [
                LookTheme.Colors.textPrimary,
                LookTheme.Colors.electricBlue.opacity(0.85 + 0.12 * sin(phase * .pi * 2)),
                LookTheme.Colors.neonPurple.opacity(0.88),
                LookTheme.Colors.hotPink.opacity(0.82)
            ],
            startPoint: UnitPoint(x: 0.1 + 0.18 * LEDDisplayEffectMath.triangle(phase), y: 0),
            endPoint: UnitPoint(x: 0.9 - 0.18 * LEDDisplayEffectMath.triangle(phase), y: 1)
        )
    }

    private func particleX(index: Int, local: Double) -> CGFloat {
        let base = CGFloat((index * 37 + 9) % 100) / 100
        return max(0.02, min(0.98, base + CGFloat(sin(local * .pi * 2)) * 0.05))
    }

    private func particleY(index: Int, local: Double) -> CGFloat {
        let base = CGFloat((index * 43 + 21) % 100) / 100
        return max(0.08, min(0.92, base + CGFloat(cos(local * .pi * 2)) * 0.04))
    }

    private func particleSpeed(_ index: Int) -> Double {
        0.42 + Double(index % 5) * 0.06
    }

    private func particleSize(_ index: Int) -> CGFloat {
        CGFloat(2.4 + Double(index % 4) * 1.2)
    }

    private func particleColor(_ index: Int) -> Color {
        switch index % 4 {
        case 0:
            LookTheme.Colors.electricBlue
        case 1:
            LookTheme.Colors.hotPink
        case 2:
            LookTheme.Colors.neonPurple
        default:
            LookTheme.Colors.softPink
        }
    }
}
