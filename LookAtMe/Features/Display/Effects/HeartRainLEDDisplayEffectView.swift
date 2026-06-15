import SwiftUI

struct HeartRainLEDDisplayEffectView: View {
    let context: LEDDisplayEffectContext

    var body: some View {
        let width = max(1, context.viewportSize.width)
        let height = max(1, context.viewportSize.height)

        LEDDisplayEffectClock(
            context: context,
            cycleDuration: { speed in max(1.2, 3.1 / max(0.2, speed)) }
        ) { phase in
            ZStack {
                rainBackground(width: width, height: height, phase: phase)
                heartRain(width: width, height: height, phase: phase)
                heartText(width: width, phase: phase)
            }
            .frame(width: width, height: height)
            .clipped()
        }
    }

    private var fontSize: CGFloat {
        70 * CGFloat(context.fontScale)
    }

    private var accentColor: Color {
        LookTheme.Colors.hotPink
    }

    private func rainBackground(width: CGFloat, height: CGFloat, phase: Double) -> some View {
        ZStack {
            RadialGradient(
                colors: [
                    accentColor.opacity(0.16 + 0.04 * sin(phase * .pi * 2)),
                    LookTheme.Colors.neonPurple.opacity(0.1),
                    .clear
                ],
                center: UnitPoint(x: 0.5, y: 0.5),
                startRadius: 12,
                endRadius: max(width, height) * 0.55
            )

            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            .clear,
                            LookTheme.Colors.hotPink.opacity(0.08),
                            LookTheme.Colors.softPink.opacity(0.06),
                            .clear
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: width, height: height)
                .blur(radius: 24)
        }
        .allowsHitTesting(false)
    }

    private func heartRain(width: CGFloat, height: CGFloat, phase: Double) -> some View {
        ZStack {
            ForEach(0..<28, id: \.self) { index in
                let local = LEDDisplayEffectMath.normalized(phase * heartSpeed(index) + heartDelay(index))
                let xDrift = sin((local + Double(index) * 0.07) * .pi * 2) * CGFloat(12 + index % 5 * 5)
                let opacity = heartOpacity(local)

                Image(systemName: heartSymbol(index))
                    .font(.system(size: heartSize(index), weight: .bold))
                    .foregroundStyle(heartColor(index))
                    .scaleEffect(0.82 + CGFloat(LEDDisplayEffectMath.triangle(local)) * 0.18)
                    .rotationEffect(.degrees(heartRotation(index: index, local: local)))
                    .opacity(opacity)
                    .position(
                        x: width * heartX(index) + xDrift,
                        y: -40 + height * CGFloat(local) * 1.18
                    )
                    .shadow(color: heartColor(index).opacity(0.72 * opacity), radius: 12)
            }
        }
        .allowsHitTesting(false)
    }

    private func heartText(width: CGFloat, phase: Double) -> some View {
        let blink = LEDDisplayEffectMath.blink(isEnabled: context.draft.isBlinking, phase: phase * 0.68)
        let pulse = 0.5 + 0.5 * sin(phase * .pi * 2)
        let scale = CGFloat(0.985 + pulse * 0.025)

        return ZStack {
            RoundedRectangle(cornerRadius: max(36, fontSize * 0.44), style: .continuous)
                .fill(
                    RadialGradient(
                        colors: [
                            accentColor.opacity(0.2 + pulse * 0.08),
                            LookTheme.Colors.neonPurple.opacity(0.09),
                            .clear
                        ],
                        center: .center,
                        startRadius: 10,
                        endRadius: max(120, width * 0.34)
                    )
                )
                .frame(width: min(width * 0.9, max(220, width * 0.68)), height: max(90, fontSize * 1.35))
                .blur(radius: 10)

            Text(context.draft.text)
                .font(context.draft.fontStyle.font(size: fontSize))
                .lineLimit(1)
                .minimumScaleFactor(0.52)
                .multilineTextAlignment(.center)
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            LookTheme.Colors.textPrimary,
                            LookTheme.Colors.softPink,
                            accentColor
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: width)
                .scaleEffect(x: context.draft.isMirrored ? -scale : scale, y: scale)
                .opacity((0.82 + pulse * 0.18) * blink)
                .shadow(color: accentColor.opacity(0.88), radius: 12 + CGFloat(pulse) * 8)
                .shadow(color: LookTheme.Colors.softPink.opacity(0.52), radius: 32)
        }
    }

    private func heartX(_ index: Int) -> CGFloat {
        CGFloat((index * 31 + 7) % 100) / 100
    }

    private func heartDelay(_ index: Int) -> Double {
        Double((index * 17) % 100) / 100
    }

    private func heartSpeed(_ index: Int) -> Double {
        0.76 + Double(index % 5) * 0.07
    }

    private func heartSize(_ index: Int) -> CGFloat {
        CGFloat(14 + (index % 6) * 5)
    }

    private func heartOpacity(_ local: Double) -> Double {
        let fadeIn = LEDDisplayEffectMath.smoothStep(min(1, local / 0.12))
        let fadeOut = max(0, 1 - LEDDisplayEffectMath.smoothStep(max(0, (local - 0.78) / 0.22)))
        return min(0.88, fadeIn * fadeOut)
    }

    private func heartRotation(index: Int, local: Double) -> Double {
        sin((local + Double(index) * 0.13) * .pi * 2) * 18
    }

    private func heartSymbol(_ index: Int) -> String {
        index.isMultiple(of: 5) ? "heart" : "heart.fill"
    }

    private func heartColor(_ index: Int) -> Color {
        switch index % 4 {
        case 0:
            LookTheme.Colors.hotPink
        case 1:
            LookTheme.Colors.softPink
        case 2:
            LookTheme.Colors.primaryPink
        default:
            LookTheme.Colors.warmYellow
        }
    }
}
