import SwiftUI

struct FireworkBurstLEDDisplayEffectView: View {
    let context: LEDDisplayEffectContext

    var body: some View {
        let width = max(1, context.viewportSize.width)
        let height = max(1, context.viewportSize.height)

        LEDDisplayEffectClock(
            context: context,
            cycleDuration: { speed in max(0.9, 2.15 / max(0.2, speed)) }
        ) { phase in
            ZStack {
                burstBackground(width: width, height: height, phase: phase)
                fireworkBursts(width: width, height: height, phase: phase)
                flashWash(width: width, height: height, phase: phase)
                burstText(width: width, phase: phase)
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

    private func burstBackground(width: CGFloat, height: CGFloat, phase: Double) -> some View {
        ZStack {
            RadialGradient(
                colors: [
                    LookTheme.Colors.hotPink.opacity(0.17 + fireworkFlash(phase) * 0.16),
                    LookTheme.Colors.neonPurple.opacity(0.1),
                    .clear
                ],
                center: UnitPoint(x: 0.5, y: 0.48),
                startRadius: 18,
                endRadius: max(width, height) * 0.58
            )

            ForEach(0..<18, id: \.self) { index in
                let twinkle = starTwinkle(index: index, phase: phase)
                Circle()
                    .fill(starColor(index).opacity(0.2 + twinkle * 0.62))
                    .frame(width: starSize(index), height: starSize(index))
                    .position(starPosition(index: index, width: width, height: height))
                    .shadow(color: starColor(index).opacity(0.5 * twinkle), radius: 7)
            }
        }
        .allowsHitTesting(false)
    }

    private func fireworkBursts(width: CGFloat, height: CGFloat, phase: Double) -> some View {
        ZStack {
            ForEach(0..<5, id: \.self) { burstIndex in
                let local = localBurstPhase(globalPhase: phase, burstIndex: burstIndex)
                let intensity = burstIntensity(local)
                let center = burstCenter(index: burstIndex, width: width, height: height)

                ZStack {
                    ForEach(0..<18, id: \.self) { particleIndex in
                        particle(
                            burstIndex: burstIndex,
                            particleIndex: particleIndex,
                            local: local,
                            intensity: intensity
                        )
                    }

                    Circle()
                        .stroke(burstColor(burstIndex).opacity(0.42 * intensity), lineWidth: 1.2)
                        .frame(
                            width: max(24, width * 0.08 + CGFloat(local) * width * 0.18),
                            height: max(24, width * 0.08 + CGFloat(local) * width * 0.18)
                        )
                        .blur(radius: 1.2)
                        .opacity(intensity)
                }
                .position(center)
            }
        }
        .allowsHitTesting(false)
    }

    private func particle(
        burstIndex: Int,
        particleIndex: Int,
        local: Double,
        intensity: Double
    ) -> some View {
        let angle = Double(particleIndex) / 18 * .pi * 2 + Double(burstIndex) * 0.31
        let distance = CGFloat(28 + Double(particleIndex % 5) * 11) * CGFloat(LEDDisplayEffectMath.smoothStep(local))
        let size = CGFloat(3.8 + Double(particleIndex % 4) * 1.6)
        let x = cos(angle) * distance
        let y = sin(angle) * distance

        return Capsule()
            .fill(
                LinearGradient(
                    colors: [
                        LookTheme.Colors.textPrimary.opacity(0.96),
                        particleColor(index: particleIndex, burstIndex: burstIndex).opacity(0.9),
                        .clear
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(width: size * 4.2, height: size)
            .rotationEffect(.radians(angle))
            .offset(x: x, y: y)
            .opacity(intensity)
            .shadow(color: particleColor(index: particleIndex, burstIndex: burstIndex).opacity(0.82 * intensity), radius: 10)
    }

    private func flashWash(width: CGFloat, height: CGFloat, phase: Double) -> some View {
        Rectangle()
            .fill(
                RadialGradient(
                    colors: [
                        LookTheme.Colors.textPrimary.opacity(0.12 * fireworkFlash(phase)),
                        LookTheme.Colors.hotPink.opacity(0.16 * fireworkFlash(phase)),
                        .clear
                    ],
                    center: .center,
                    startRadius: 8,
                    endRadius: max(width, height) * 0.62
                )
            )
            .frame(width: width, height: height)
            .blendMode(.plusLighter)
            .allowsHitTesting(false)
    }

    private func burstText(width: CGFloat, phase: Double) -> some View {
        let flash = fireworkFlash(phase)
        let blink = LEDDisplayEffectMath.blink(isEnabled: context.draft.isBlinking, phase: phase * 0.7)
        let scale = CGFloat(0.98 + flash * 0.06)

        return ZStack {
            Text(context.draft.text)
                .font(context.draft.fontStyle.font(size: fontSize))
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .multilineTextAlignment(.center)
                .foregroundStyle(LEDDisplayEffectText.textStyle(for: context.draft))
                .frame(width: width)
                .scaleEffect(x: context.draft.isMirrored ? -scale : scale, y: scale)
                .blur(radius: 22)
                .opacity((0.24 + flash * 0.24) * blink)

            Text(context.draft.text)
                .font(context.draft.fontStyle.font(size: fontSize))
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .multilineTextAlignment(.center)
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            LookTheme.Colors.textPrimary,
                            LookTheme.Colors.warmYellow.opacity(0.86),
                            accentColor,
                            LookTheme.Colors.electricBlue.opacity(0.78)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: width)
                .scaleEffect(x: context.draft.isMirrored ? -scale : scale, y: scale)
                .opacity((0.74 + flash * 0.26) * blink)
                .shadow(color: LookTheme.Colors.warmYellow.opacity(0.72 + flash * 0.2), radius: 11 + CGFloat(flash) * 10)
                .shadow(color: accentColor.opacity(0.64), radius: 30 + CGFloat(flash) * 18)
        }
    }

    private func localBurstPhase(globalPhase: Double, burstIndex: Int) -> Double {
        LEDDisplayEffectMath.normalized(globalPhase * 1.2 + Double(burstIndex) * 0.19)
    }

    private func burstIntensity(_ local: Double) -> Double {
        let grow = LEDDisplayEffectMath.smoothStep(min(1, local / 0.28))
        let fade = max(0, 1 - LEDDisplayEffectMath.smoothStep(max(0, (local - 0.22) / 0.62)))
        return grow * fade
    }

    private func fireworkFlash(_ phase: Double) -> Double {
        let first = max(0, 1 - abs(LEDDisplayEffectMath.normalized(phase * 1.2) - 0.14) * 10)
        let second = max(0, 1 - abs(LEDDisplayEffectMath.normalized(phase * 1.2 + 0.39) - 0.14) * 10)
        return min(1, first + second * 0.72)
    }

    private func burstCenter(index: Int, width: CGFloat, height: CGFloat) -> CGPoint {
        let points: [(CGFloat, CGFloat)] = [
            (0.22, 0.42),
            (0.5, 0.32),
            (0.78, 0.45),
            (0.36, 0.61),
            (0.66, 0.63)
        ]
        let point = points[index % points.count]
        return CGPoint(x: width * point.0, y: height * point.1)
    }

    private func particleColor(index: Int, burstIndex: Int) -> Color {
        switch (index + burstIndex) % 5 {
        case 0:
            LookTheme.Colors.hotPink
        case 1:
            LookTheme.Colors.warmYellow
        case 2:
            LookTheme.Colors.electricBlue
        case 3:
            LookTheme.Colors.neonPurple
        default:
            LookTheme.Colors.softPink
        }
    }

    private func burstColor(_ index: Int) -> Color {
        particleColor(index: index * 3, burstIndex: index)
    }

    private func starPosition(index: Int, width: CGFloat, height: CGFloat) -> CGPoint {
        let x = CGFloat((index * 37) % 100) / 100
        let y = CGFloat((index * 53 + 17) % 100) / 100
        return CGPoint(x: width * x, y: height * y)
    }

    private func starSize(_ index: Int) -> CGFloat {
        CGFloat(1.8 + Double(index % 4) * 0.8)
    }

    private func starColor(_ index: Int) -> Color {
        index.isMultiple(of: 3) ? LookTheme.Colors.warmYellow : LookTheme.Colors.softPink
    }

    private func starTwinkle(index: Int, phase: Double) -> Double {
        0.5 + 0.5 * sin((phase * 2.0 + Double(index) * 0.11) * .pi * 2)
    }
}
