import SwiftUI

struct BubblePopLEDDisplayEffectView: View {
    let context: LEDDisplayEffectContext

    var body: some View {
        let width = max(1, context.viewportSize.width)
        let height = max(1, context.viewportSize.height)

        LEDDisplayEffectClock(
            context: context,
            cycleDuration: { speed in max(1.0, 2.35 / max(0.2, speed)) }
        ) { phase in
            ZStack {
                bubbleBackground(width: width, height: height, phase: phase)
                bubbles(width: width, height: height, phase: phase)
                bubbleText(width: width, phase: phase)
                popHighlights(width: width, height: height, phase: phase)
            }
            .frame(width: width, height: height)
            .clipped()
        }
    }

    private var fontSize: CGFloat {
        70 * CGFloat(context.fontScale)
    }

    private var accentColor: Color {
        LookTheme.Colors.softPink
    }

    private func bubbleBackground(width: CGFloat, height: CGFloat, phase: Double) -> some View {
        ZStack {
            RadialGradient(
                colors: [
                    LookTheme.Colors.softPink.opacity(0.14),
                    LookTheme.Colors.electricBlue.opacity(0.09),
                    .clear
                ],
                center: UnitPoint(x: 0.46 + 0.08 * sin(phase * .pi * 2), y: 0.5),
                startRadius: 14,
                endRadius: max(width, height) * 0.56
            )

            RadialGradient(
                colors: [
                    LookTheme.Colors.hotPink.opacity(0.08),
                    .clear
                ],
                center: UnitPoint(x: 0.62, y: 0.42 + 0.08 * cos(phase * .pi * 2)),
                startRadius: 12,
                endRadius: max(width, height) * 0.42
            )
        }
        .allowsHitTesting(false)
    }

    private func bubbles(width: CGFloat, height: CGFloat, phase: Double) -> some View {
        ZStack {
            ForEach(0..<22, id: \.self) { index in
                let local = LEDDisplayEffectMath.normalized(phase * bubbleSpeed(index) + bubbleDelay(index))
                let bounce = abs(sin((local + Double(index) * 0.04) * .pi * 2))
                let opacity = bubbleOpacity(local)
                let size = bubbleSize(index) * CGFloat(0.88 + bounce * 0.16)

                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [
                                bubbleColor(index).opacity(0.24),
                                LookTheme.Colors.textPrimary.opacity(0.5),
                                bubbleColor(index).opacity(0.56)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: max(1.2, size * 0.055)
                    )
                    .background(
                        Circle()
                            .fill(bubbleColor(index).opacity(0.04 + opacity * 0.1))
                    )
                    .frame(width: size, height: size)
                    .position(
                        x: width * bubbleX(index: index, local: local),
                        y: height + 50 - height * CGFloat(local) * 1.24
                    )
                    .opacity(opacity)
                    .shadow(color: bubbleColor(index).opacity(0.5 * opacity), radius: 12)
            }
        }
        .allowsHitTesting(false)
    }

    private func bubbleText(width: CGFloat, phase: Double) -> some View {
        let blink = LEDDisplayEffectMath.blink(isEnabled: context.draft.isBlinking, phase: phase * 0.7)
        let bounce = abs(sin(phase * .pi * 2))
        let scale = CGFloat(0.975 + bounce * 0.045)

        return ZStack {
            RoundedRectangle(cornerRadius: max(36, fontSize * 0.45), style: .continuous)
                .fill(
                    RadialGradient(
                        colors: [
                            LookTheme.Colors.softPink.opacity(0.18 + bounce * 0.06),
                            LookTheme.Colors.electricBlue.opacity(0.08),
                            .clear
                        ],
                        center: .center,
                        startRadius: 12,
                        endRadius: max(120, width * 0.34)
                    )
                )
                .frame(width: min(width * 0.88, max(220, width * 0.68)), height: max(90, fontSize * 1.35))
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
                            accentColor,
                            LookTheme.Colors.electricBlue.opacity(0.86)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: width)
                .scaleEffect(x: context.draft.isMirrored ? -scale : scale, y: scale)
                .opacity((0.82 + bounce * 0.16) * blink)
                .shadow(color: accentColor.opacity(0.78), radius: 12)
                .shadow(color: LookTheme.Colors.electricBlue.opacity(0.42), radius: 32)
        }
    }

    private func popHighlights(width: CGFloat, height: CGFloat, phase: Double) -> some View {
        ZStack {
            ForEach(0..<7, id: \.self) { index in
                let local = LEDDisplayEffectMath.normalized(phase * 1.3 + Double(index) * 0.15)
                let pop = popIntensity(local)

                Image(systemName: "sparkle")
                    .font(.system(size: 12 + CGFloat(index % 4) * 4, weight: .bold))
                    .foregroundStyle(bubbleColor(index))
                    .position(
                        x: width * CGFloat((index * 31 + 14) % 100) / 100,
                        y: height * CGFloat((index * 43 + 27) % 100) / 100
                    )
                    .scaleEffect(0.6 + CGFloat(pop) * 0.7)
                    .opacity(pop)
                    .shadow(color: bubbleColor(index).opacity(0.8 * pop), radius: 10)
            }
        }
        .allowsHitTesting(false)
    }

    private func bubbleX(index: Int, local: Double) -> CGFloat {
        let base = CGFloat((index * 37 + 11) % 100) / 100
        return max(0.04, min(0.96, base + CGFloat(sin((local + Double(index) * 0.07) * .pi * 2)) * 0.06))
    }

    private func bubbleDelay(_ index: Int) -> Double {
        Double((index * 19) % 100) / 100
    }

    private func bubbleSpeed(_ index: Int) -> Double {
        0.6 + Double(index % 5) * 0.07
    }

    private func bubbleSize(_ index: Int) -> CGFloat {
        CGFloat(20 + (index % 7) * 9)
    }

    private func bubbleOpacity(_ local: Double) -> Double {
        let inValue = LEDDisplayEffectMath.smoothStep(min(1, local / 0.12))
        let outValue = max(0, 1 - LEDDisplayEffectMath.smoothStep(max(0, (local - 0.78) / 0.22)))
        return min(0.74, inValue * outValue)
    }

    private func popIntensity(_ local: Double) -> Double {
        let attack = LEDDisplayEffectMath.smoothStep(min(1, local / 0.12))
        let release = max(0, 1 - LEDDisplayEffectMath.smoothStep(max(0, (local - 0.12) / 0.28)))
        return attack * release
    }

    private func bubbleColor(_ index: Int) -> Color {
        switch index % 4 {
        case 0:
            LookTheme.Colors.softPink
        case 1:
            LookTheme.Colors.electricBlue
        case 2:
            LookTheme.Colors.hotPink
        default:
            LookTheme.Colors.neonPurple
        }
    }
}
