import SwiftUI

struct BulletFlyInLEDDisplayEffectView: View {
    let context: LEDDisplayEffectContext

    var body: some View {
        let width = max(1, context.viewportSize.width)
        let height = max(1, context.viewportSize.height)

        LEDDisplayEffectClock(
            context: context,
            cycleDuration: { speed in max(1.0, 2.45 / max(0.2, speed)) }
        ) { phase in
            ZStack {
                barrageBackground(width: width, height: height, phase: phase)
                bulletRows(width: width, height: height, phase: phase)
                heroText(width: width, phase: phase)
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

    private func barrageBackground(width: CGFloat, height: CGFloat, phase: Double) -> some View {
        ZStack {
            RadialGradient(
                colors: [
                    accentColor.opacity(0.14),
                    LookTheme.Colors.hotPink.opacity(0.08),
                    .clear
                ],
                center: UnitPoint(x: 0.48 + 0.08 * sin(phase * .pi * 2), y: 0.48),
                startRadius: 12,
                endRadius: max(width, height) * 0.55
            )

            ForEach(0..<7, id: \.self) { index in
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                .clear,
                                LookTheme.Colors.electricBlue.opacity(0.12),
                                LookTheme.Colors.hotPink.opacity(0.09),
                                .clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: width * 1.2, height: 2)
                    .offset(y: CGFloat(index - 3) * max(26, height * 0.06))
                    .opacity(0.34 + 0.18 * sin((phase + Double(index) * 0.11) * .pi * 2))
            }
        }
        .allowsHitTesting(false)
    }

    private func bulletRows(width: CGFloat, height: CGFloat, phase: Double) -> some View {
        ZStack {
            ForEach(0..<12, id: \.self) { index in
                let local = LEDDisplayEffectMath.normalized(phase * bulletSpeed(index) + bulletDelay(index))
                let x = width * 0.72 - CGFloat(local) * width * 1.55
                let y = bulletY(index: index, height: height)
                let opacity = bulletOpacity(local)

                bulletText(index: index, opacity: opacity)
                    .offset(x: x, y: y)
                    .opacity(opacity)
            }
        }
        .allowsHitTesting(false)
    }

    private func bulletText(index: Int, opacity: Double) -> some View {
        Text(bulletString(index))
            .font(context.draft.fontStyle.font(size: max(18, fontSize * bulletFontScale(index))))
            .lineLimit(1)
            .fixedSize(horizontal: true, vertical: false)
            .foregroundStyle(bulletGradient(index))
            .padding(.horizontal, max(10, fontSize * 0.13))
            .padding(.vertical, max(4, fontSize * 0.045))
            .background(
                Capsule()
                    .fill(LookTheme.Colors.cardPurple.opacity(0.34 + opacity * 0.16))
                    .overlay(
                        Capsule()
                            .stroke(bulletColor(index).opacity(0.28 + opacity * 0.28), lineWidth: 1)
                    )
            )
            .shadow(color: bulletColor(index).opacity(0.72 * opacity), radius: 12)
    }

    private func heroText(width: CGFloat, phase: Double) -> some View {
        let blink = LEDDisplayEffectMath.blink(isEnabled: context.draft.isBlinking, phase: phase * 0.74)
        let pulse = 0.5 + 0.5 * sin(phase * .pi * 2)
        let scale = CGFloat(0.985 + pulse * 0.025)

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
                .opacity(0.22 * blink)

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
                .opacity((0.8 + pulse * 0.18) * blink)
                .shadow(color: accentColor.opacity(0.82), radius: 10)
                .shadow(color: LookTheme.Colors.hotPink.opacity(0.5), radius: 28)
        }
    }

    private func bulletString(_ index: Int) -> String {
        switch index % 4 {
        case 0:
            context.draft.text
        case 1:
            "看这里 \(context.draft.text)"
        case 2:
            "\(context.draft.text) !!!"
        default:
            "为你打 CALL"
        }
    }

    private func bulletGradient(_ index: Int) -> LinearGradient {
        LinearGradient(
            colors: [
                LookTheme.Colors.textPrimary.opacity(0.92),
                bulletColor(index),
                index.isMultiple(of: 2) ? LookTheme.Colors.hotPink : LookTheme.Colors.softPink
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    private func bulletColor(_ index: Int) -> Color {
        switch index % 4 {
        case 0:
            LookTheme.Colors.electricBlue
        case 1:
            LookTheme.Colors.hotPink
        case 2:
            LookTheme.Colors.warmYellow
        default:
            LookTheme.Colors.neonPurple
        }
    }

    private func bulletFontScale(_ index: Int) -> CGFloat {
        CGFloat(0.34 + Double(index % 4) * 0.04)
    }

    private func bulletY(index: Int, height: CGFloat) -> CGFloat {
        let lanes: [CGFloat] = [-0.36, -0.27, -0.18, -0.09, 0.09, 0.18, 0.27, 0.36]
        return lanes[index % lanes.count] * height
    }

    private func bulletDelay(_ index: Int) -> Double {
        Double((index * 13) % 100) / 100
    }

    private func bulletSpeed(_ index: Int) -> Double {
        0.76 + Double(index % 5) * 0.07
    }

    private func bulletOpacity(_ local: Double) -> Double {
        let inValue = LEDDisplayEffectMath.smoothStep(min(1, local / 0.12))
        let outValue = max(0, 1 - LEDDisplayEffectMath.smoothStep(max(0, (local - 0.78) / 0.22)))
        return min(0.82, inValue * outValue)
    }
}
