import SwiftUI

struct GlitchPulseLEDDisplayEffectView: View {
    let context: LEDDisplayEffectContext

    var body: some View {
        let width = max(1, context.viewportSize.width)
        let height = max(1, context.viewportSize.height)

        LEDDisplayEffectClock(
            context: context,
            cycleDuration: { speed in max(0.68, 1.35 / max(0.2, speed)) }
        ) { phase in
            let glitch = glitchIntensity(phase)

            ZStack {
                glitchBackground(width: width, height: height, phase: phase, glitch: glitch)
                scanLines(width: width, height: height, phase: phase)
                glitchBars(width: width, height: height, phase: phase, glitch: glitch)
                glitchText(width: width, phase: phase, glitch: glitch)
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

    private func glitchBackground(width: CGFloat, height: CGFloat, phase: Double, glitch: Double) -> some View {
        ZStack {
            RadialGradient(
                colors: [
                    accentColor.opacity(0.12 + glitch * 0.12),
                    LookTheme.Colors.hotPink.opacity(0.08 + glitch * 0.1),
                    .clear
                ],
                center: UnitPoint(x: 0.48 + 0.04 * sin(phase * .pi * 8), y: 0.5),
                startRadius: 12,
                endRadius: max(width, height) * 0.54
            )

            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            .clear,
                            LookTheme.Colors.electricBlue.opacity(0.04 + glitch * 0.06),
                            LookTheme.Colors.hotPink.opacity(0.03 + glitch * 0.06),
                            .clear
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: width, height: height)
        }
        .allowsHitTesting(false)
    }

    private func scanLines(width: CGFloat, height: CGFloat, phase: Double) -> some View {
        ZStack {
            ForEach(0..<18, id: \.self) { index in
                let opacity = 0.04 + 0.08 * max(0, sin((phase * 2 + Double(index) * 0.09) * .pi * 2))
                Rectangle()
                    .fill(LookTheme.Colors.textPrimary.opacity(opacity))
                    .frame(width: width, height: 1)
                    .offset(y: -height / 2 + CGFloat(index) / 17 * height)
            }
        }
        .allowsHitTesting(false)
    }

    private func glitchBars(width: CGFloat, height: CGFloat, phase: Double, glitch: Double) -> some View {
        ZStack {
            ForEach(0..<10, id: \.self) { index in
                let local = LEDDisplayEffectMath.normalized(phase * barSpeed(index) + Double(index) * 0.127)
                let active = barIntensity(local) * glitch
                let barWidth = width * CGFloat(0.18 + Double(index % 4) * 0.1)

                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                .clear,
                                barColor(index).opacity(0.44),
                                LookTheme.Colors.textPrimary.opacity(0.28),
                                .clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: barWidth, height: CGFloat(4 + index % 4 * 4))
                    .offset(
                        x: CGFloat(local - 0.5) * width * 1.1,
                        y: CGFloat((index * 29) % 100) / 100 * height - height / 2
                    )
                    .opacity(active)
                    .blur(radius: index.isMultiple(of: 2) ? 0.2 : 1.1)
                    .blendMode(.plusLighter)
            }
        }
        .allowsHitTesting(false)
    }

    private func glitchText(width: CGFloat, phase: Double, glitch: Double) -> some View {
        let blink = LEDDisplayEffectMath.blink(isEnabled: context.draft.isBlinking, phase: phase * 0.82, lowValue: 0.48)
        let jitter = CGFloat(sin(phase * .pi * 28)) * CGFloat(1.5 + glitch * 5.0)
        let verticalJitter = CGFloat(cos(phase * .pi * 22)) * CGFloat(glitch * 2.5)
        let scale = CGFloat(1 + glitch * 0.018)

        return ZStack {
            Text(context.draft.text)
                .font(context.draft.fontStyle.font(size: fontSize))
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .multilineTextAlignment(.center)
                .foregroundStyle(LookTheme.Colors.electricBlue)
                .frame(width: width)
                .scaleEffect(x: context.draft.isMirrored ? -scale : scale, y: scale)
                .offset(x: -jitter * 1.3, y: verticalJitter)
                .opacity((0.28 + glitch * 0.24) * blink)
                .blur(radius: 0.4)
                .shadow(color: LookTheme.Colors.electricBlue.opacity(0.72), radius: 14)

            Text(context.draft.text)
                .font(context.draft.fontStyle.font(size: fontSize))
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .multilineTextAlignment(.center)
                .foregroundStyle(LookTheme.Colors.hotPink)
                .frame(width: width)
                .scaleEffect(x: context.draft.isMirrored ? -scale : scale, y: scale)
                .offset(x: jitter * 1.15, y: -verticalJitter)
                .opacity((0.26 + glitch * 0.22) * blink)
                .blur(radius: 0.4)
                .shadow(color: LookTheme.Colors.hotPink.opacity(0.64), radius: 14)

            Text(context.draft.text)
                .font(context.draft.fontStyle.font(size: fontSize))
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .multilineTextAlignment(.center)
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            LookTheme.Colors.textPrimary,
                            LookTheme.Colors.electricBlue.opacity(0.86),
                            LookTheme.Colors.hotPink.opacity(0.88)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: width)
                .scaleEffect(x: context.draft.isMirrored ? -scale : scale, y: scale)
                .offset(x: jitter * 0.2, y: 0)
                .opacity((0.8 + glitch * 0.18) * blink)
                .shadow(color: LookTheme.Colors.electricBlue.opacity(0.72), radius: 10 + CGFloat(glitch) * 8)
                .shadow(color: LookTheme.Colors.hotPink.opacity(0.54), radius: 26 + CGFloat(glitch) * 12)
        }
    }

    private func glitchIntensity(_ phase: Double) -> Double {
        let a = max(0, 1 - abs(LEDDisplayEffectMath.normalized(phase) - 0.18) * 15)
        let b = max(0, 1 - abs(LEDDisplayEffectMath.normalized(phase) - 0.56) * 19)
        let c = max(0, 1 - abs(LEDDisplayEffectMath.normalized(phase) - 0.72) * 24)
        return min(1, 0.16 + a * 0.6 + b * 0.38 + c * 0.28)
    }

    private func barIntensity(_ local: Double) -> Double {
        let attack = LEDDisplayEffectMath.smoothStep(min(1, local / 0.12))
        let release = max(0, 1 - LEDDisplayEffectMath.smoothStep(max(0, (local - 0.12) / 0.24)))
        return attack * release
    }

    private func barSpeed(_ index: Int) -> Double {
        0.8 + Double(index % 5) * 0.13
    }

    private func barColor(_ index: Int) -> Color {
        switch index % 3 {
        case 0:
            LookTheme.Colors.electricBlue
        case 1:
            LookTheme.Colors.hotPink
        default:
            LookTheme.Colors.neonPurple
        }
    }
}
