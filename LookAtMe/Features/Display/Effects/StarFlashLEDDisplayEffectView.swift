import SwiftUI

struct StarFlashLEDDisplayEffectView: View {
    let context: LEDDisplayEffectContext

    var body: some View {
        let width = max(1, context.viewportSize.width)
        let height = max(1, context.viewportSize.height)

        LEDDisplayEffectClock(
            context: context,
            cycleDuration: { speed in max(0.75, 1.75 / max(0.2, speed)) }
        ) { phase in
            ZStack {
                starBackground(width: width, height: height, phase: phase)
                starbursts(width: width, height: height, phase: phase)
                sparkleText(width: width, phase: phase)
                textSparkles(width: width, phase: phase)
            }
            .frame(width: width, height: height)
            .clipped()
        }
    }

    private var fontSize: CGFloat {
        70 * CGFloat(context.fontScale)
    }

    private var accentColor: Color {
        LookTheme.Colors.warmYellow
    }

    private func starBackground(width: CGFloat, height: CGFloat, phase: Double) -> some View {
        ZStack {
            RadialGradient(
                colors: [
                    accentColor.opacity(0.16 + flashIntensity(phase) * 0.12),
                    LookTheme.Colors.neonPurple.opacity(0.1),
                    .clear
                ],
                center: UnitPoint(x: 0.5, y: 0.5),
                startRadius: 14,
                endRadius: max(width, height) * 0.55
            )

            ForEach(0..<42, id: \.self) { index in
                let twinkle = twinkle(index: index, phase: phase)
                Circle()
                    .fill(starColor(index).opacity(0.16 + twinkle * 0.64))
                    .frame(width: dotSize(index), height: dotSize(index))
                    .position(dotPosition(index: index, width: width, height: height))
                    .shadow(color: starColor(index).opacity(0.58 * twinkle), radius: 7)
            }
        }
        .allowsHitTesting(false)
    }

    private func starbursts(width: CGFloat, height: CGFloat, phase: Double) -> some View {
        ZStack {
            ForEach(0..<12, id: \.self) { index in
                let local = LEDDisplayEffectMath.normalized(phase * starSpeed(index) + Double(index) * 0.081)
                let intensity = starburstIntensity(local)

                starburst(color: starColor(index), intensity: intensity, size: starburstSize(index, intensity: intensity))
                    .position(starburstPosition(index: index, width: width, height: height))
                    .opacity(intensity)
                    .rotationEffect(.degrees(Double(index) * 17 + phase * 120))
            }
        }
        .allowsHitTesting(false)
    }

    private func starburst(color: Color, intensity: Double, size: CGFloat) -> some View {
        ZStack {
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [.clear, color.opacity(0.9), LookTheme.Colors.textPrimary.opacity(0.88), color.opacity(0.9), .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: size, height: max(2, size * 0.055))

            Capsule()
                .fill(
                    LinearGradient(
                        colors: [.clear, color.opacity(0.76), LookTheme.Colors.textPrimary.opacity(0.86), color.opacity(0.76), .clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: max(2, size * 0.055), height: size)

            Circle()
                .fill(LookTheme.Colors.textPrimary.opacity(0.86))
                .frame(width: max(5, size * 0.12), height: max(5, size * 0.12))
        }
        .blur(radius: 0.3)
        .shadow(color: color.opacity(0.9 * intensity), radius: 14)
    }

    private func sparkleText(width: CGFloat, phase: Double) -> some View {
        let flash = flashIntensity(phase)
        let blink = LEDDisplayEffectMath.blink(isEnabled: context.draft.isBlinking, phase: phase * 0.82)
        let scale = CGFloat(0.985 + flash * 0.035)

        return ZStack {
            Text(context.draft.text)
                .font(context.draft.fontStyle.font(size: fontSize))
                .lineLimit(1)
                .minimumScaleFactor(0.52)
                .multilineTextAlignment(.center)
                .foregroundStyle(LEDDisplayEffectText.textStyle(for: context.draft))
                .frame(width: width)
                .scaleEffect(x: context.draft.isMirrored ? -scale : scale, y: scale)
                .blur(radius: 18)
                .opacity((0.22 + flash * 0.22) * blink)

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
                            LookTheme.Colors.hotPink.opacity(0.86)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: width)
                .scaleEffect(x: context.draft.isMirrored ? -scale : scale, y: scale)
                .opacity((0.78 + flash * 0.22) * blink)
                .shadow(color: accentColor.opacity(0.9), radius: 11 + CGFloat(flash) * 12)
                .shadow(color: LookTheme.Colors.hotPink.opacity(0.45), radius: 30)
        }
    }

    private func textSparkles(width: CGFloat, phase: Double) -> some View {
        ZStack {
            ForEach(0..<9, id: \.self) { index in
                let local = LEDDisplayEffectMath.normalized(phase * 1.4 + Double(index) * 0.12)
                let intensity = starburstIntensity(local)
                let x = CGFloat((index * 23 + 12) % 100) / 100 * width - width / 2
                let y = CGFloat(index % 3 - 1) * max(20, fontSize * 0.34)

                Image(systemName: "sparkle")
                    .font(.system(size: 13 + CGFloat(index % 3) * 5, weight: .bold))
                    .foregroundStyle(starColor(index))
                    .opacity(intensity)
                    .scaleEffect(0.7 + CGFloat(intensity) * 0.5)
                    .offset(x: x, y: y)
                    .shadow(color: starColor(index).opacity(0.8 * intensity), radius: 12)
            }
        }
        .allowsHitTesting(false)
    }

    private func flashIntensity(_ phase: Double) -> Double {
        max(0.12, pow(0.5 + 0.5 * sin(phase * .pi * 6), 3))
    }

    private func starburstIntensity(_ local: Double) -> Double {
        let attack = LEDDisplayEffectMath.smoothStep(min(1, local / 0.18))
        let release = max(0, 1 - LEDDisplayEffectMath.smoothStep(max(0, (local - 0.16) / 0.5)))
        return attack * release
    }

    private func twinkle(index: Int, phase: Double) -> Double {
        pow(0.5 + 0.5 * sin((phase * starSpeed(index) + Double(index) * 0.07) * .pi * 2), 2.8)
    }

    private func dotPosition(index: Int, width: CGFloat, height: CGFloat) -> CGPoint {
        CGPoint(
            x: width * CGFloat((index * 37 + 13) % 100) / 100,
            y: height * CGFloat((index * 61 + 7) % 100) / 100
        )
    }

    private func starburstPosition(index: Int, width: CGFloat, height: CGFloat) -> CGPoint {
        CGPoint(
            x: width * CGFloat((index * 29 + 19) % 100) / 100,
            y: height * CGFloat((index * 47 + 23) % 100) / 100
        )
    }

    private func dotSize(_ index: Int) -> CGFloat {
        CGFloat(1.8 + Double(index % 4) * 0.9)
    }

    private func starburstSize(_ index: Int, intensity: Double) -> CGFloat {
        CGFloat(26 + index % 5 * 8) * CGFloat(0.82 + intensity * 0.38)
    }

    private func starSpeed(_ index: Int) -> Double {
        0.8 + Double(index % 5) * 0.16
    }

    private func starColor(_ index: Int) -> Color {
        switch index % 4 {
        case 0:
            LookTheme.Colors.warmYellow
        case 1:
            LookTheme.Colors.softPink
        case 2:
            LookTheme.Colors.electricBlue
        default:
            LookTheme.Colors.hotPink
        }
    }
}
