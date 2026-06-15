import SwiftUI

struct LaserSweepLEDDisplayEffectView: View {
    let context: LEDDisplayEffectContext

    var body: some View {
        let width = max(1, context.viewportSize.width)
        let height = max(1, context.viewportSize.height)

        LEDDisplayEffectClock(
            context: context,
            cycleDuration: { speed in max(0.85, 1.85 / max(0.2, speed)) }
        ) { phase in
            ZStack {
                laserAtmosphere(width: width, height: height, phase: phase)
                laserGrid(width: width, height: height, phase: phase)
                laserBeams(width: width, height: height, phase: phase)
                sweepText(width: width, phase: phase)
                foregroundScan(width: width, height: height, phase: phase)
            }
            .frame(width: width, height: height)
            .clipped()
        }
    }

    private var fontSize: CGFloat {
        70 * CGFloat(context.fontScale)
    }

    private var accentColor: Color {
        LookTheme.Colors.electricBlue
    }

    private func laserAtmosphere(width: CGFloat, height: CGFloat, phase: Double) -> some View {
        ZStack {
            RadialGradient(
                colors: [
                    accentColor.opacity(0.18),
                    LookTheme.Colors.neonPurple.opacity(0.12),
                    .clear
                ],
                center: UnitPoint(x: 0.24 + 0.52 * phase, y: 0.48),
                startRadius: 8,
                endRadius: max(width, height) * 0.58
            )

            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            .clear,
                            LookTheme.Colors.electricBlue.opacity(0.08),
                            LookTheme.Colors.hotPink.opacity(0.07),
                            .clear
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: width, height: max(90, height * 0.34))
                .blur(radius: 22)
        }
        .allowsHitTesting(false)
    }

    private func laserGrid(width: CGFloat, height: CGFloat, phase: Double) -> some View {
        ZStack {
            ForEach(0..<9, id: \.self) { index in
                Capsule()
                    .fill(accentColor.opacity(0.05 + linePulse(index: index, phase: phase) * 0.14))
                    .frame(width: width * 1.2, height: 1)
                    .offset(y: CGFloat(index - 4) * max(18, height * 0.055))
                    .blur(radius: 0.6)
            }

            ForEach(0..<7, id: \.self) { index in
                Capsule()
                    .fill(LookTheme.Colors.hotPink.opacity(0.03 + linePulse(index: index + 9, phase: phase) * 0.09))
                    .frame(width: 1, height: height * 0.7)
                    .offset(x: CGFloat(index - 3) * max(36, width * 0.1))
                    .blur(radius: 0.8)
            }
        }
        .allowsHitTesting(false)
    }

    private func laserBeams(width: CGFloat, height: CGFloat, phase: Double) -> some View {
        ZStack {
            ForEach(0..<8, id: \.self) { index in
                let progress = LEDDisplayEffectMath.normalized(phase * (1.0 + Double(index % 3) * 0.08) + Double(index) * 0.13)
                let beamWidth = width * CGFloat(0.36 + Double(index % 3) * 0.08)
                let opacity = max(0, 1 - abs(progress - 0.5) * 2.5)

                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                .clear,
                                beamColor(index).opacity(0.78),
                                LookTheme.Colors.textPrimary.opacity(0.86),
                                beamColor(index).opacity(0.64),
                                .clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: beamWidth, height: index.isMultiple(of: 3) ? 7 : 4)
                    .offset(
                        x: CGFloat(progress - 0.5) * width * 1.45,
                        y: CGFloat(index - 4) * max(20, height * 0.045)
                    )
                    .rotationEffect(.degrees(index.isMultiple(of: 2) ? -9 : 9))
                    .opacity(opacity)
                    .blur(radius: index.isMultiple(of: 2) ? 0.6 : 1.5)
                    .shadow(color: beamColor(index).opacity(0.8 * opacity), radius: 20)
            }
        }
        .allowsHitTesting(false)
    }

    private func sweepText(width: CGFloat, phase: Double) -> some View {
        let blink = LEDDisplayEffectMath.blink(isEnabled: context.draft.isBlinking, phase: phase * 0.72)
        let sweep = LEDDisplayEffectMath.triangle(phase)
        let scale = CGFloat(0.985 + sweep * 0.025)

        return ZStack {
            Text(context.draft.text)
                .font(context.draft.fontStyle.font(size: fontSize))
                .lineLimit(1)
                .minimumScaleFactor(0.52)
                .multilineTextAlignment(.center)
                .foregroundStyle(LEDDisplayEffectText.textStyle(for: context.draft))
                .frame(width: width)
                .scaleEffect(x: context.draft.isMirrored ? -scale : scale, y: scale)
                .blur(radius: 16)
                .opacity(0.24 * blink)
                .shadow(color: accentColor.opacity(0.9), radius: 36)

            Text(context.draft.text)
                .font(context.draft.fontStyle.font(size: fontSize))
                .lineLimit(1)
                .minimumScaleFactor(0.52)
                .multilineTextAlignment(.center)
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            LookTheme.Colors.textPrimary,
                            accentColor,
                            LookTheme.Colors.hotPink
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: width)
                .scaleEffect(x: context.draft.isMirrored ? -scale : scale, y: scale)
                .opacity((0.78 + 0.22 * sweep) * blink)
                .shadow(color: accentColor.opacity(0.9), radius: 10)
                .shadow(color: LookTheme.Colors.hotPink.opacity(0.56), radius: 28)
        }
    }

    private func foregroundScan(width: CGFloat, height: CGFloat, phase: Double) -> some View {
        let x = CGFloat(phase - 0.5) * width * 1.36

        return Rectangle()
            .fill(
                LinearGradient(
                    colors: [
                        .clear,
                        accentColor.opacity(0.0),
                        accentColor.opacity(0.52),
                        LookTheme.Colors.textPrimary.opacity(0.82),
                        LookTheme.Colors.hotPink.opacity(0.34),
                        .clear
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(width: max(72, width * 0.18), height: height)
            .offset(x: x)
            .blur(radius: 1.2)
            .blendMode(.plusLighter)
            .allowsHitTesting(false)
    }

    private func beamColor(_ index: Int) -> Color {
        switch index % 3 {
        case 0:
            LookTheme.Colors.electricBlue
        case 1:
            LookTheme.Colors.hotPink
        default:
            LookTheme.Colors.neonPurple
        }
    }

    private func linePulse(index: Int, phase: Double) -> Double {
        0.5 + 0.5 * sin((phase * 1.5 + Double(index) * 0.17) * .pi * 2)
    }
}
