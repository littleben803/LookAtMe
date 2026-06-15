import SwiftUI

struct SpotlightLEDDisplayEffectView: View {
    let context: LEDDisplayEffectContext

    var body: some View {
        let width = max(1, context.viewportSize.width)
        let height = max(1, context.viewportSize.height)

        LEDDisplayEffectClock(
            context: context,
            cycleDuration: { speed in max(1.0, 2.4 / max(0.2, speed)) }
        ) { phase in
            ZStack {
                stageBackground(width: width, height: height, phase: phase)
                overheadSpotlight(width: width, height: height, phase: phase)
                lightBeams(width: width, height: height, phase: phase)
                stageFloor(width: width, height: height, phase: phase)
                spotlightText(width: width, phase: phase)
                foregroundVignette(width: width, height: height)
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

    private func stageBackground(width: CGFloat, height: CGFloat, phase: Double) -> some View {
        ZStack {
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            LookTheme.Colors.backgroundBlack.opacity(0.38),
                            LookTheme.Colors.backgroundPurple.opacity(0.62),
                            LookTheme.Colors.backgroundBlack.opacity(0.44)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            RadialGradient(
                colors: [
                    spotlightColor(phase).opacity(0.24 + 0.1 * sin(phase * .pi * 2)),
                    companionSpotlightColor(phase).opacity(0.14),
                    .clear
                ],
                center: UnitPoint(x: 0.5, y: 0.5),
                startRadius: 12,
                endRadius: max(width, height) * 0.52
            )
        }
        .allowsHitTesting(false)
    }

    private func overheadSpotlight(width: CGFloat, height: CGFloat, phase: Double) -> some View {
        let primary = spotlightColor(phase)
        let secondary = companionSpotlightColor(phase)
        let swing = sin(phase * .pi * 2)
        let pulse = 0.5 + 0.5 * cos(phase * .pi * 2)

        return ZStack {
            SpotlightConeShape(topWidthRatio: 0.08, bottomWidthRatio: 0.7)
                .fill(
                    LinearGradient(
                        colors: [
                            primary.opacity(0.54 + pulse * 0.18),
                            primary.opacity(0.22),
                            secondary.opacity(0.1),
                            .clear
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: width * 0.86, height: height * 0.78)
                .offset(x: CGFloat(swing) * width * 0.035, y: -height * 0.18)
                .blur(radius: 12)
                .blendMode(.plusLighter)

            SpotlightConeShape(topWidthRatio: 0.04, bottomWidthRatio: 0.42)
                .fill(
                    LinearGradient(
                        colors: [
                            LookTheme.Colors.textPrimary.opacity(0.34 + pulse * 0.18),
                            primary.opacity(0.32),
                            .clear
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: width * 0.52, height: height * 0.68)
                .offset(x: CGFloat(-swing) * width * 0.025, y: -height * 0.15)
                .blur(radius: 6)
                .blendMode(.plusLighter)

            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [
                            LookTheme.Colors.textPrimary.opacity(0.45),
                            primary.opacity(0.34),
                            .clear
                        ],
                        center: .center,
                        startRadius: 2,
                        endRadius: max(28, width * 0.08)
                    )
                )
                .frame(width: max(52, width * 0.12), height: max(16, width * 0.035))
                .offset(y: -height * 0.47)
                .blur(radius: 2)
                .opacity(0.82 + pulse * 0.18)
                .blendMode(.plusLighter)
        }
        .allowsHitTesting(false)
    }

    private func lightBeams(width: CGFloat, height: CGFloat, phase: Double) -> some View {
        ZStack {
            ForEach(0..<7, id: \.self) { index in
                let swing = sin((phase + Double(index) * 0.13) * .pi * 2)
                let beamColor = indexedSpotlightColor(index: index, phase: phase)

                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                beamColor.opacity(0.34),
                                beamColor.opacity(0.16),
                                .clear
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: max(84, width * 0.17), height: height * 1.34)
                    .offset(
                        x: CGFloat(index - 3) * width * 0.14 + CGFloat(swing) * width * 0.08,
                        y: -height * 0.2
                    )
                    .rotationEffect(.degrees(Double(index - 3) * 9 + swing * 10))
                    .blur(radius: 14)
                    .blendMode(.plusLighter)
                    .opacity(0.62)
            }
        }
        .allowsHitTesting(false)
    }

    private func stageFloor(width: CGFloat, height: CGFloat, phase: Double) -> some View {
        VStack {
            Spacer()

            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [
                            spotlightColor(phase).opacity(0.42),
                            companionSpotlightColor(phase).opacity(0.18),
                            .clear
                        ],
                        center: .center,
                        startRadius: 10,
                        endRadius: max(120, width * 0.34)
                    )
                )
                .frame(width: width * CGFloat(0.62 + 0.07 * sin(phase * .pi * 2)), height: height * 0.16)
                .blur(radius: 10)
                .offset(y: -height * 0.26)
        }
        .frame(width: width, height: height)
        .allowsHitTesting(false)
    }

    private func spotlightText(width: CGFloat, phase: Double) -> some View {
        let blink = LEDDisplayEffectMath.blink(isEnabled: context.draft.isBlinking, phase: phase * 0.62)
        let glow = 0.5 + 0.5 * sin(phase * .pi * 2)
        let scale = CGFloat(1 + glow * 0.035)
        let primary = spotlightColor(phase)
        let secondary = companionSpotlightColor(phase)

        return ZStack {
            RadialGradient(
                colors: [
                    primary.opacity(0.32 + glow * 0.14),
                    secondary.opacity(0.14),
                    .clear
                ],
                center: .center,
                startRadius: 16,
                endRadius: max(170, width * 0.44)
            )
            .frame(width: min(width * 0.96, max(280, width * 0.78)), height: max(140, fontSize * 1.9))
            .blur(radius: 7)

            crownLayer(phase: phase, glow: glow, blink: blink)

            Text(context.draft.text)
                .font(context.draft.fontStyle.font(size: fontSize))
                .lineLimit(1)
                .minimumScaleFactor(0.52)
                .multilineTextAlignment(.center)
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            LookTheme.Colors.textPrimary,
                            primary,
                            secondary.opacity(0.9)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: width)
                .scaleEffect(x: context.draft.isMirrored ? -scale : scale, y: scale)
                .opacity((0.84 + glow * 0.16) * blink)
                .shadow(color: primary.opacity(0.96), radius: 14 + CGFloat(glow) * 12)
                .shadow(color: secondary.opacity(0.62), radius: 38)
        }
    }

    private func crownLayer(phase: Double, glow: Double, blink: Double) -> some View {
        let crownSize = min(76, max(34, fontSize * 0.32))
        let primary = spotlightColor(phase)
        let secondary = companionSpotlightColor(phase)

        return ZStack {
            Image(systemName: "crown.fill")
                .font(.system(size: crownSize, weight: .black))
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            LookTheme.Colors.textPrimary,
                            LookTheme.Colors.warmYellow,
                            primary,
                            secondary.opacity(0.9)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: LookTheme.Colors.warmYellow.opacity(0.95), radius: 8 + CGFloat(glow) * 8)
                .shadow(color: primary.opacity(0.78), radius: 20 + CGFloat(glow) * 12)

            ForEach(0..<4, id: \.self) { index in
                Image(systemName: "sparkle")
                    .font(.system(size: max(10, crownSize * 0.23), weight: .bold))
                    .foregroundStyle(index.isMultiple(of: 2) ? primary : secondary)
                    .offset(
                        x: CGFloat(index - 1) * crownSize * 0.42,
                        y: CGFloat(index % 2 == 0 ? -1 : 1) * crownSize * 0.28
                    )
                    .opacity((0.32 + 0.68 * sparkleIntensity(index: index, phase: phase)) * blink)
                    .scaleEffect(0.72 + CGFloat(sparkleIntensity(index: index, phase: phase)) * 0.46)
                    .shadow(color: primary.opacity(0.72), radius: 10)
            }
        }
        .scaleEffect(0.96 + CGFloat(glow) * 0.08)
        .offset(y: -fontSize * 0.78)
        .opacity((0.78 + glow * 0.22) * blink)
        .allowsHitTesting(false)
    }

    private func foregroundVignette(width: CGFloat, height: CGFloat) -> some View {
        Rectangle()
            .fill(
                RadialGradient(
                    colors: [
                        .clear,
                        LookTheme.Colors.backgroundBlack.opacity(0.08),
                        LookTheme.Colors.backgroundBlack.opacity(0.34)
                    ],
                    center: .center,
                    startRadius: min(width, height) * 0.26,
                    endRadius: max(width, height) * 0.72
                )
            )
            .frame(width: width, height: height)
            .allowsHitTesting(false)
    }

    private func spotlightColor(_ phase: Double) -> Color {
        switch Int((LEDDisplayEffectMath.normalized(phase) * 4).rounded(.down)) {
        case 0:
            LookTheme.Colors.warmYellow
        case 1:
            LookTheme.Colors.electricBlue
        case 2:
            LookTheme.Colors.hotPink
        default:
            LookTheme.Colors.neonPurple
        }
    }

    private func companionSpotlightColor(_ phase: Double) -> Color {
        spotlightColor(phase + 0.34)
    }

    private func indexedSpotlightColor(index: Int, phase: Double) -> Color {
        spotlightColor(phase + Double(index) * 0.11)
    }

    private func sparkleIntensity(index: Int, phase: Double) -> Double {
        pow(0.5 + 0.5 * sin((phase * 2.2 + Double(index) * 0.18) * .pi * 2), 2.4)
    }
}

private struct SpotlightConeShape: Shape {
    let topWidthRatio: CGFloat
    let bottomWidthRatio: CGFloat

    func path(in rect: CGRect) -> Path {
        let topWidth = rect.width * topWidthRatio
        let bottomWidth = rect.width * bottomWidthRatio
        let midX = rect.midX

        var path = Path()
        path.move(to: CGPoint(x: midX - topWidth / 2, y: rect.minY))
        path.addLine(to: CGPoint(x: midX + topWidth / 2, y: rect.minY))
        path.addLine(to: CGPoint(x: midX + bottomWidth / 2, y: rect.maxY))
        path.addQuadCurve(to: CGPoint(x: midX - bottomWidth / 2, y: rect.maxY), control: CGPoint(x: midX, y: rect.maxY + rect.height * 0.08))
        path.closeSubpath()
        return path
    }
}
