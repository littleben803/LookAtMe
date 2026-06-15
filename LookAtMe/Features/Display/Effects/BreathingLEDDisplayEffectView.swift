import SwiftUI

struct BreathingLEDDisplayEffectView: View {
    let context: LEDDisplayEffectContext

    @State private var referencePhase: Double = 0
    @State private var referenceDate = Date()

    var body: some View {
        let contentWidth = max(1, context.viewportSize.width)

        TimelineView(.animation) { timeline in
            let phase = breathingPhase(at: timeline.date, playing: context.isPlaying, speed: context.speed)
            let breath = breathingValue(phase)
            let userBlink = userBlinkIntensity(phase)
            let glow = 0.48 + breath * 0.52
            let textScale = CGFloat(0.965 + breath * 0.07)

            ZStack {
                ambientBreathGlow(contentWidth: contentWidth, breath: breath)

                haloRings(contentWidth: contentWidth, breath: breath)

                breathingText(
                    contentWidth: contentWidth,
                    opacity: 0.22 * glow * userBlink,
                    blurRadius: 22 + CGFloat(breath * 10),
                    scale: textScale + 0.04
                )

                breathingText(
                    contentWidth: contentWidth,
                    opacity: 0.42 * glow * userBlink,
                    blurRadius: 8 + CGFloat(breath * 6),
                    scale: textScale + 0.015
                )

                breathingText(
                    contentWidth: contentWidth,
                    opacity: max(0.62, glow) * userBlink,
                    blurRadius: 0,
                    scale: textScale
                )
            }
            .frame(width: contentWidth)
            .frame(maxHeight: .infinity)
        }
        .onAppear {
            resetReference()
        }
        .onChange(of: context.isPlaying) { oldValue, playing in
            handlePlaybackChange(wasPlaying: oldValue, isPlaying: playing)
        }
        .onChange(of: context.speed) { oldSpeed, _ in
            syncReference(speed: oldSpeed)
        }
        .onChange(of: context.fontScale) { _, _ in
            syncReference()
        }
        .onChange(of: context.layoutRefreshID) { _, _ in
            syncReference()
        }
    }

    private var fontSize: CGFloat {
        70 * CGFloat(context.fontScale)
    }

    private var accentColor: Color {
        LEDDisplayEffectText.accentColor(for: context.draft)
    }

    private func breathingText(
        contentWidth: CGFloat,
        opacity: Double,
        blurRadius: CGFloat,
        scale: CGFloat
    ) -> some View {
        Text(context.draft.text)
            .font(context.draft.fontStyle.font(size: fontSize))
            .lineLimit(1)
            .minimumScaleFactor(0.55)
            .multilineTextAlignment(.center)
            .foregroundStyle(textGradient(opacity: opacity))
            .frame(width: contentWidth)
            .scaleEffect(x: context.draft.isMirrored ? -scale : scale, y: scale)
            .blur(radius: blurRadius)
            .opacity(opacity)
            .shadow(color: accentColor.opacity(0.88 * opacity), radius: 12 + blurRadius * 0.35)
            .shadow(color: LookTheme.Colors.hotPink.opacity(0.48 * opacity), radius: 26 + blurRadius)
            .shadow(color: LookTheme.Colors.neonPurple.opacity(0.34 * opacity), radius: 48 + blurRadius)
    }

    private func textGradient(opacity: Double) -> LinearGradient {
        LinearGradient(
            colors: [
                LookTheme.Colors.textPrimary.opacity(0.96),
                accentColor.opacity(0.82 + min(0.18, opacity * 0.18)),
                LookTheme.Colors.softPink.opacity(0.86)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private func ambientBreathGlow(contentWidth: CGFloat, breath: Double) -> some View {
        let longestSide = max(context.viewportSize.width, context.viewportSize.height)
        let glowWidth = max(contentWidth * 0.72, longestSide * 0.32)
        let glowHeight = max(context.viewportSize.height * 0.2, 130)

        return ZStack {
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [
                            accentColor.opacity(0.26 + breath * 0.18),
                            LookTheme.Colors.hotPink.opacity(0.12 + breath * 0.12),
                            .clear
                        ],
                        center: .center,
                        startRadius: 12,
                        endRadius: max(180, glowWidth * 0.65)
                    )
                )
                .frame(width: glowWidth * CGFloat(0.92 + breath * 0.22), height: glowHeight * CGFloat(0.72 + breath * 0.42))
                .blur(radius: 16 + CGFloat(breath * 22))

            RadialGradient(
                colors: [
                    accentColor.opacity(0.08 + breath * 0.12),
                    LookTheme.Colors.neonPurple.opacity(0.07 + breath * 0.08),
                    .clear
                ],
                center: .center,
                startRadius: 30,
                endRadius: max(220, longestSide * 0.48)
            )
        }
        .allowsHitTesting(false)
    }

    private func haloRings(contentWidth: CGFloat, breath: Double) -> some View {
        let ringWidth = max(140, min(contentWidth * 0.78, 520))
        let ringHeight = max(70, min(context.viewportSize.height * 0.22, 180))

        return ZStack {
            ForEach(0..<3, id: \.self) { index in
                RoundedRectangle(cornerRadius: ringHeight / 2, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                accentColor.opacity(0),
                                accentColor.opacity(0.26 - Double(index) * 0.045),
                                LookTheme.Colors.hotPink.opacity(0.18 - Double(index) * 0.035),
                                accentColor.opacity(0)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: CGFloat(1.2 - Double(index) * 0.2)
                    )
                    .frame(
                        width: ringWidth * CGFloat(0.74 + breath * 0.12 + Double(index) * 0.12),
                        height: ringHeight * CGFloat(0.64 + breath * 0.18 + Double(index) * 0.16)
                    )
                    .blur(radius: CGFloat(index) * 1.4 + CGFloat(breath * 1.6))
                    .opacity(max(0, 0.56 - Double(index) * 0.12) * (0.36 + breath * 0.64))
            }
        }
        .allowsHitTesting(false)
    }

    private func breathingPhase(at date: Date, playing: Bool, speed: Double) -> Double {
        guard playing else {
            return normalized(referencePhase)
        }

        let elapsed = max(0, date.timeIntervalSince(referenceDate))
        return normalized(referencePhase + elapsed / cycleDuration(speed: speed))
    }

    private func cycleDuration(speed: Double) -> TimeInterval {
        max(1.05, 2.7 / max(0.2, speed))
    }

    private func breathingValue(_ phase: Double) -> Double {
        0.5 - 0.5 * cos(phase * .pi * 2)
    }

    private func userBlinkIntensity(_ phase: Double) -> Double {
        guard context.draft.isBlinking else {
            return 1
        }

        return normalized(phase * 0.72) < 0.5 ? 1 : 0.54
    }

    private func resetReference() {
        referencePhase = 0
        referenceDate = Date()
    }

    private func handlePlaybackChange(wasPlaying: Bool, isPlaying: Bool) {
        let now = Date()
        if wasPlaying, !isPlaying {
            referencePhase = breathingPhase(at: now, playing: true, speed: context.speed)
            referenceDate = now
        } else if !wasPlaying, isPlaying {
            referenceDate = now
        }
    }

    private func syncReference(speed: Double? = nil) {
        let now = Date()
        referencePhase = breathingPhase(at: now, playing: context.isPlaying, speed: speed ?? context.speed)
        referenceDate = now
    }

    private func normalized(_ value: Double) -> Double {
        let progress = value.truncatingRemainder(dividingBy: 1)
        return progress >= 0 ? progress : progress + 1
    }
}
