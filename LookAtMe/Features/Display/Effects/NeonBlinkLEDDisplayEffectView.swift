import SwiftUI

struct NeonBlinkLEDDisplayEffectView: View {
    let context: LEDDisplayEffectContext

    @State private var referencePhase: Double = 0
    @State private var referenceDate = Date()

    var body: some View {
        let contentWidth = max(1, context.viewportSize.width)

        TimelineView(.animation) { timeline in
            let phase = neonPhase(at: timeline.date, playing: context.isPlaying, speed: context.speed)
            let intensity = neonIntensity(phase)
            let userBlink = userBlinkIntensity(phase)
            let chromaticOffset = CGFloat(sin(phase * .pi * 10)) * CGFloat(1.4 + intensity * 1.6)

            ZStack {
                ambientGlow(phase: phase, intensity: intensity)

                electricBars(contentWidth: contentWidth, phase: phase, intensity: intensity)

                neonText(
                    contentWidth: contentWidth,
                    gradient: auraGradient(phase: phase),
                    opacity: 0.28 * intensity * userBlink,
                    blurRadius: 18,
                    scale: 1.02
                )

                neonText(
                    contentWidth: contentWidth,
                    gradient: cyanGhostGradient,
                    opacity: 0.32 * intensity * userBlink,
                    blurRadius: 0.5,
                    xOffset: -chromaticOffset
                )

                neonText(
                    contentWidth: contentWidth,
                    gradient: pinkGhostGradient,
                    opacity: 0.28 * intensity * userBlink,
                    blurRadius: 0.5,
                    xOffset: chromaticOffset
                )

                neonText(
                    contentWidth: contentWidth,
                    gradient: mainGradient(phase: phase),
                    opacity: max(0.58, intensity) * userBlink,
                    blurRadius: 0,
                    scale: 1 + CGFloat((intensity - 0.72) * 0.018)
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

    private var cyanGhostGradient: LinearGradient {
        LinearGradient(
            colors: [
                LookTheme.Colors.electricBlue.opacity(0.2),
                LookTheme.Colors.electricBlue,
                LookTheme.Colors.textPrimary.opacity(0.8)
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    private var pinkGhostGradient: LinearGradient {
        LinearGradient(
            colors: [
                LookTheme.Colors.textPrimary.opacity(0.8),
                LookTheme.Colors.hotPink,
                LookTheme.Colors.primaryPink.opacity(0.2)
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    private func mainGradient(phase: Double) -> LinearGradient {
        let colorSwap = 0.5 + 0.5 * sin(phase * .pi * 2)
        return LinearGradient(
            colors: [
                LookTheme.Colors.textPrimary,
                LookTheme.Colors.electricBlue.opacity(0.78 + colorSwap * 0.2),
                LookTheme.Colors.hotPink.opacity(0.86),
                LookTheme.Colors.textPrimary.opacity(0.92)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private func auraGradient(phase: Double) -> LinearGradient {
        let pulse = 0.5 + 0.5 * sin(phase * .pi * 4)
        return LinearGradient(
            colors: [
                LookTheme.Colors.electricBlue.opacity(0.76 + pulse * 0.18),
                LookTheme.Colors.neonPurple.opacity(0.66),
                LookTheme.Colors.hotPink.opacity(0.72 + pulse * 0.22)
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    private func neonText(
        contentWidth: CGFloat,
        gradient: LinearGradient,
        opacity: Double,
        blurRadius: CGFloat,
        xOffset: CGFloat = 0,
        scale: CGFloat = 1
    ) -> some View {
        Text(context.draft.text)
            .font(context.draft.fontStyle.font(size: fontSize))
            .lineLimit(1)
            .minimumScaleFactor(0.55)
            .multilineTextAlignment(.center)
            .foregroundStyle(gradient)
            .frame(width: contentWidth)
            .scaleEffect(x: context.draft.isMirrored ? -scale : scale, y: scale)
            .offset(x: xOffset)
            .blur(radius: blurRadius)
            .opacity(opacity)
            .shadow(color: LookTheme.Colors.electricBlue.opacity(0.68 * opacity), radius: 12)
            .shadow(color: LookTheme.Colors.hotPink.opacity(0.54 * opacity), radius: 26)
            .shadow(color: LookTheme.Colors.neonPurple.opacity(0.42 * opacity), radius: 44)
    }

    private func ambientGlow(phase: Double, intensity: Double) -> some View {
        let radius = min(context.viewportSize.width, context.viewportSize.height) * 0.72
        return ZStack {
            RadialGradient(
                colors: [
                    LookTheme.Colors.electricBlue.opacity(0.18 * intensity),
                    LookTheme.Colors.neonPurple.opacity(0.12 * intensity),
                    .clear
                ],
                center: UnitPoint(x: 0.44 + 0.04 * sin(phase * .pi * 2), y: 0.5),
                startRadius: 20,
                endRadius: max(160, radius)
            )

            RadialGradient(
                colors: [
                    LookTheme.Colors.hotPink.opacity(0.16 * intensity),
                    .clear
                ],
                center: UnitPoint(x: 0.58, y: 0.48 + 0.04 * cos(phase * .pi * 2)),
                startRadius: 18,
                endRadius: max(120, radius * 0.72)
            )
        }
        .allowsHitTesting(false)
    }

    private func electricBars(contentWidth: CGFloat, phase: Double, intensity: Double) -> some View {
        ZStack {
            ForEach(0..<9, id: \.self) { index in
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                LookTheme.Colors.electricBlue.opacity(0),
                                LookTheme.Colors.electricBlue.opacity(0.42),
                                LookTheme.Colors.hotPink.opacity(0.36),
                                LookTheme.Colors.hotPink.opacity(0)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(
                        width: electricBarWidth(contentWidth: contentWidth, index: index),
                        height: index.isMultiple(of: 3) ? 3 : 2
                    )
                    .offset(
                        x: electricBarOffset(contentWidth: contentWidth, phase: phase, index: index),
                        y: CGFloat(index - 4) * 18
                    )
                    .opacity(electricBarOpacity(phase: phase, index: index) * intensity)
                    .blur(radius: index.isMultiple(of: 2) ? 0.4 : 1.2)
            }
        }
        .allowsHitTesting(false)
    }

    private func electricBarWidth(contentWidth: CGFloat, index: Int) -> CGFloat {
        contentWidth * CGFloat(0.16 + Double(index % 4) * 0.045)
    }

    private func electricBarOffset(contentWidth: CGFloat, phase: Double, index: Int) -> CGFloat {
        let progress = normalized(phase + Double(index) * 0.137)
        return CGFloat(progress - 0.5) * contentWidth * 1.08
    }

    private func electricBarOpacity(phase: Double, index: Int) -> Double {
        let progress = normalized(phase * 1.7 + Double(index) * 0.21)
        let pulse = max(0, 1 - abs(progress - 0.5) * 3.4)
        return min(0.58, pulse * 0.72)
    }

    private func neonPhase(at date: Date, playing: Bool, speed: Double) -> Double {
        guard playing else {
            return normalized(referencePhase)
        }

        let elapsed = max(0, date.timeIntervalSince(referenceDate))
        return normalized(referencePhase + elapsed / cycleDuration(speed: speed))
    }

    private func cycleDuration(speed: Double) -> TimeInterval {
        max(0.72, 1.35 / max(0.2, speed))
    }

    private func neonIntensity(_ phase: Double) -> Double {
        let slowPulse = 0.5 + 0.5 * sin(phase * .pi * 2)
        let fastPulse = 0.5 + 0.5 * sin(phase * .pi * 15 + 0.7)
        let dip = flickerDip(phase)
        return min(1, max(0.46, 0.64 + slowPulse * 0.24 + fastPulse * 0.16 - dip))
    }

    private func userBlinkIntensity(_ phase: Double) -> Double {
        guard context.draft.isBlinking else {
            return 1
        }

        return normalized(phase * 0.62) < 0.5 ? 1 : 0.52
    }

    private func flickerDip(_ phase: Double) -> Double {
        let shortDip = normalized(phase + 0.07) < 0.055 ? 0.22 : 0
        let secondDip = normalized(phase + 0.19) < 0.035 ? 0.16 : 0
        let lateDip = normalized(phase + 0.61) < 0.045 ? 0.18 : 0
        return shortDip + secondDip + lateDip
    }

    private func resetReference() {
        referencePhase = 0
        referenceDate = Date()
    }

    private func handlePlaybackChange(wasPlaying: Bool, isPlaying: Bool) {
        let now = Date()
        if wasPlaying, !isPlaying {
            referencePhase = neonPhase(at: now, playing: true, speed: context.speed)
            referenceDate = now
        } else if !wasPlaying, isPlaying {
            referenceDate = now
        }
    }

    private func syncReference(speed: Double? = nil) {
        let now = Date()
        referencePhase = neonPhase(at: now, playing: context.isPlaying, speed: speed ?? context.speed)
        referenceDate = now
    }

    private func normalized(_ value: Double) -> Double {
        let progress = value.truncatingRemainder(dividingBy: 1)
        return progress >= 0 ? progress : progress + 1
    }
}
