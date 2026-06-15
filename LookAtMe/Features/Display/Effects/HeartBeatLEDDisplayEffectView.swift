import SwiftUI

struct HeartBeatLEDDisplayEffectView: View {
    let context: LEDDisplayEffectContext

    var body: some View {
        let width = max(1, context.viewportSize.width)
        let height = max(1, context.viewportSize.height)

        LEDDisplayEffectClock(
            context: context,
            cycleDuration: { speed in max(0.82, 1.55 / max(0.2, speed)) }
        ) { phase in
            let beat = heartbeatValue(phase)

            ZStack {
                heartBackground(width: width, height: height, phase: phase, beat: beat)
                pulseRings(width: width, height: height, phase: phase, beat: beat)
                ecgLine(width: width, phase: phase, beat: beat)
                heartText(width: width, phase: phase, beat: beat)
                floatingHearts(width: width, height: height, phase: phase, beat: beat)
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

    private func heartBackground(width: CGFloat, height: CGFloat, phase: Double, beat: Double) -> some View {
        ZStack {
            RadialGradient(
                colors: [
                    accentColor.opacity(0.22 + beat * 0.2),
                    LookTheme.Colors.neonPurple.opacity(0.1 + beat * 0.08),
                    .clear
                ],
                center: UnitPoint(x: 0.5, y: 0.5),
                startRadius: 20,
                endRadius: max(width, height) * (0.42 + CGFloat(beat) * 0.16)
            )

            RadialGradient(
                colors: [
                    LookTheme.Colors.softPink.opacity(0.13 * beat),
                    .clear
                ],
                center: UnitPoint(x: 0.5 + 0.03 * sin(phase * .pi * 2), y: 0.48),
                startRadius: 12,
                endRadius: max(width, height) * 0.36
            )
        }
        .allowsHitTesting(false)
    }

    private func pulseRings(width: CGFloat, height: CGFloat, phase: Double, beat: Double) -> some View {
        ZStack {
            ForEach(0..<4, id: \.self) { index in
                let local = LEDDisplayEffectMath.normalized(phase + Double(index) * 0.18)
                let pulse = max(0, 1 - local)
                let ringWidth = min(width * 0.86, max(160, width * (0.24 + CGFloat(local) * 0.62)))
                let ringHeight = min(height * 0.36, max(88, height * (0.1 + CGFloat(local) * 0.2)))

                RoundedRectangle(cornerRadius: ringHeight / 2, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                .clear,
                                accentColor.opacity(0.34 * pulse),
                                LookTheme.Colors.softPink.opacity(0.24 * pulse),
                                .clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: 1.2 + CGFloat(beat) * 1.1
                    )
                    .frame(width: ringWidth, height: ringHeight)
                    .blur(radius: CGFloat(index) * 0.8)
                    .opacity(pulse)
            }
        }
        .allowsHitTesting(false)
    }

    private func ecgLine(width: CGFloat, phase: Double, beat: Double) -> some View {
        ZStack {
            ForEach(0..<18, id: \.self) { index in
                let x = CGFloat(index) / 17 * width - width / 2
                let local = LEDDisplayEffectMath.normalized(phase * 1.2 + Double(index) * 0.055)
                let spike = max(0, 1 - abs(local - 0.18) * 14)
                let y = CGFloat(spike) * -max(22, fontSize * 0.22) + CGFloat(index % 2 == 0 ? 3 : -3)

                Capsule()
                    .fill(accentColor.opacity(0.16 + spike * 0.54 + beat * 0.16))
                    .frame(width: max(18, width / 22), height: 2)
                    .offset(x: x, y: y + fontSize * 0.78)
                    .shadow(color: accentColor.opacity(0.42 + spike * 0.3), radius: 7)
            }
        }
        .allowsHitTesting(false)
    }

    private func heartText(width: CGFloat, phase: Double, beat: Double) -> some View {
        let blink = LEDDisplayEffectMath.blink(isEnabled: context.draft.isBlinking, phase: phase * 0.82)
        let scale = CGFloat(0.98 + beat * 0.09)

        return ZStack {
            Text(context.draft.text)
                .font(context.draft.fontStyle.font(size: fontSize))
                .lineLimit(1)
                .minimumScaleFactor(0.52)
                .multilineTextAlignment(.center)
                .foregroundStyle(LEDDisplayEffectText.textStyle(for: context.draft))
                .frame(width: width)
                .scaleEffect(x: context.draft.isMirrored ? -scale : scale, y: scale)
                .blur(radius: 20)
                .opacity((0.25 + beat * 0.16) * blink)

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
                .opacity((0.78 + beat * 0.22) * blink)
                .shadow(color: accentColor.opacity(0.86), radius: 11 + CGFloat(beat) * 14)
                .shadow(color: LookTheme.Colors.neonPurple.opacity(0.46), radius: 30 + CGFloat(beat) * 22)
        }
    }

    private func floatingHearts(width: CGFloat, height: CGFloat, phase: Double, beat: Double) -> some View {
        ZStack {
            ForEach(0..<10, id: \.self) { index in
                let local = LEDDisplayEffectMath.normalized(phase * 0.72 + Double(index) * 0.1)
                let opacity = max(0, 1 - abs(local - 0.55) * 1.7)

                Image(systemName: "heart.fill")
                    .font(.system(size: CGFloat(12 + index % 4 * 4), weight: .bold))
                    .foregroundStyle(index.isMultiple(of: 2) ? LookTheme.Colors.hotPink : LookTheme.Colors.softPink)
                    .opacity((0.08 + opacity * 0.48) * (0.72 + beat * 0.28))
                    .scaleEffect(0.8 + CGFloat(beat) * 0.28)
                    .position(
                        x: width * heartX(index: index),
                        y: height * heartY(index: index, local: local)
                    )
                    .shadow(color: accentColor.opacity(0.56 * opacity), radius: 12)
            }
        }
        .allowsHitTesting(false)
    }

    private func heartbeatValue(_ phase: Double) -> Double {
        let first = max(0, 1 - abs(LEDDisplayEffectMath.normalized(phase) - 0.16) * 13)
        let second = max(0, 1 - abs(LEDDisplayEffectMath.normalized(phase) - 0.32) * 17) * 0.62
        return min(1, first + second)
    }

    private func heartX(index: Int) -> CGFloat {
        CGFloat((index * 29 + 11) % 100) / 100
    }

    private func heartY(index: Int, local: Double) -> CGFloat {
        let base = CGFloat((index * 41 + 23) % 100) / 100
        return max(0.08, min(0.9, base - CGFloat(local - 0.5) * 0.18))
    }
}
