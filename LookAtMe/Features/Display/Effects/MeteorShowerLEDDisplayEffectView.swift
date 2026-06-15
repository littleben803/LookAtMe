import SwiftUI

struct MeteorShowerLEDDisplayEffectView: View {
    let context: LEDDisplayEffectContext

    @State private var referencePhase: Double = 0
    @State private var referenceDate = Date()

    var body: some View {
        let contentWidth = max(1, context.viewportSize.width)
        let contentHeight = max(1, context.viewportSize.height)

        TimelineView(.animation) { timeline in
            let phase = meteorPhase(at: timeline.date, playing: context.isPlaying, speed: context.speed)
            let userBlink = userBlinkIntensity(phase)

            ZStack {
                skyGlow(width: contentWidth, height: contentHeight, phase: phase)

                starField(width: contentWidth, height: contentHeight, phase: phase)

                meteorLayer(width: contentWidth, height: contentHeight, phase: phase)

                wishHalo(width: contentWidth, height: contentHeight, phase: phase)

                messageText(width: contentWidth, phase: phase, userBlink: userBlink)
            }
            .frame(width: contentWidth, height: contentHeight)
            .clipped()
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

    private func skyGlow(width: CGFloat, height: CGFloat, phase: Double) -> some View {
        let longSide = max(width, height)
        return ZStack {
            RadialGradient(
                colors: [
                    LookTheme.Colors.warmYellow.opacity(0.18 + 0.04 * sin(phase * .pi * 2)),
                    LookTheme.Colors.hotPink.opacity(0.12),
                    .clear
                ],
                center: UnitPoint(x: 0.52 + 0.08 * sin(phase * .pi * 2), y: 0.45),
                startRadius: 10,
                endRadius: max(180, longSide * 0.52)
            )

            RadialGradient(
                colors: [
                    LookTheme.Colors.electricBlue.opacity(0.13),
                    LookTheme.Colors.neonPurple.opacity(0.1),
                    .clear
                ],
                center: UnitPoint(x: 0.26, y: 0.24 + 0.08 * cos(phase * .pi * 2)),
                startRadius: 12,
                endRadius: max(160, longSide * 0.46)
            )
        }
        .allowsHitTesting(false)
    }

    private func starField(width: CGFloat, height: CGFloat, phase: Double) -> some View {
        ZStack {
            ForEach(0..<34, id: \.self) { index in
                let position = starPosition(index: index, width: width, height: height)
                let size = starSize(index)
                let twinkle = starTwinkle(index: index, phase: phase)

                Circle()
                    .fill(starColor(index: index).opacity(0.28 + 0.72 * twinkle))
                    .frame(width: size, height: size)
                    .position(x: position.x, y: position.y)
                    .blur(radius: index.isMultiple(of: 5) ? 0.6 : 0)
                    .shadow(color: starColor(index: index).opacity(0.5 * twinkle), radius: 6)
            }
        }
        .allowsHitTesting(false)
    }

    private func meteorLayer(width: CGFloat, height: CGFloat, phase: Double) -> some View {
        ZStack {
            ForEach(0..<12, id: \.self) { index in
                let progress = meteorProgress(index: index, phase: phase)
                let point = meteorPoint(index: index, progress: progress, width: width, height: height)
                let intensity = meteorIntensity(progress)
                let trailLength = meteorTrailLength(index: index, width: width, height: height)

                meteor(
                    index: index,
                    trailLength: trailLength,
                    thickness: meteorThickness(index),
                    intensity: intensity
                )
                .position(x: point.x, y: point.y)
            }
        }
        .allowsHitTesting(false)
    }

    private func meteor(index: Int, trailLength: CGFloat, thickness: CGFloat, intensity: Double) -> some View {
        ZStack(alignment: .trailing) {
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [
                            .clear,
                            accentColor.opacity(0.12 * intensity),
                            LookTheme.Colors.warmYellow.opacity(0.76 * intensity),
                            LookTheme.Colors.textPrimary.opacity(0.96 * intensity)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: trailLength, height: thickness)

            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            LookTheme.Colors.textPrimary.opacity(0.96 * intensity),
                            LookTheme.Colors.warmYellow.opacity(0.78 * intensity),
                            .clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: max(8, thickness * 4)
                    )
                )
                .frame(width: thickness * 7, height: thickness * 7)
                .offset(x: thickness * 1.8)
        }
        .rotationEffect(.degrees(-24 + Double(index % 4) * 2.2))
        .opacity(intensity)
        .shadow(color: LookTheme.Colors.warmYellow.opacity(0.72 * intensity), radius: 10)
        .shadow(color: LookTheme.Colors.hotPink.opacity(0.42 * intensity), radius: 26)
        .shadow(color: LookTheme.Colors.neonPurple.opacity(0.28 * intensity), radius: 44)
    }

    private func wishHalo(width: CGFloat, height: CGFloat, phase: Double) -> some View {
        let pulse = 0.5 + 0.5 * sin(phase * .pi * 2)
        let haloWidth = min(width * 0.82, max(220, width * 0.58))
        let haloHeight = min(height * 0.22, max(80, fontSize * 1.1))

        return ZStack {
            RoundedRectangle(cornerRadius: haloHeight / 2, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            .clear,
                            LookTheme.Colors.warmYellow.opacity(0.24 + pulse * 0.16),
                            LookTheme.Colors.hotPink.opacity(0.2),
                            .clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    lineWidth: 1.4
                )
                .frame(width: haloWidth, height: haloHeight)
                .blur(radius: 1.2 + CGFloat(pulse * 1.8))

            Capsule()
                .fill(
                    LinearGradient(
                        colors: [
                            .clear,
                            LookTheme.Colors.warmYellow.opacity(0.1 + pulse * 0.08),
                            LookTheme.Colors.hotPink.opacity(0.08),
                            .clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: haloWidth * 0.9, height: haloHeight * 0.62)
                .blur(radius: 22 + CGFloat(pulse * 8))
        }
        .allowsHitTesting(false)
    }

    private func messageText(width: CGFloat, phase: Double, userBlink: Double) -> some View {
        let shimmer = 0.5 + 0.5 * sin(phase * .pi * 2.4)
        let scale = 1 + CGFloat(shimmer * 0.018)

        return ZStack {
            Text(context.draft.text)
                .font(context.draft.fontStyle.font(size: fontSize))
                .lineLimit(1)
                .minimumScaleFactor(0.52)
                .multilineTextAlignment(.center)
                .foregroundStyle(textGradient(phase: phase))
                .frame(width: width)
                .scaleEffect(x: context.draft.isMirrored ? -scale : scale, y: scale)
                .blur(radius: 18)
                .opacity(0.24 * userBlink)

            Text(context.draft.text)
                .font(context.draft.fontStyle.font(size: fontSize))
                .lineLimit(1)
                .minimumScaleFactor(0.52)
                .multilineTextAlignment(.center)
                .foregroundStyle(textGradient(phase: phase))
                .frame(width: width)
                .scaleEffect(x: context.draft.isMirrored ? -scale : scale, y: scale)
                .opacity(max(0.68, 0.78 + shimmer * 0.22) * userBlink)
                .shadow(color: LookTheme.Colors.warmYellow.opacity(0.88 * userBlink), radius: 10)
                .shadow(color: LookTheme.Colors.hotPink.opacity(0.62 * userBlink), radius: 28)
                .shadow(color: LookTheme.Colors.neonPurple.opacity(0.36 * userBlink), radius: 50)
        }
    }

    private func textGradient(phase: Double) -> LinearGradient {
        let shimmer = 0.5 + 0.5 * sin(phase * .pi * 2)
        return LinearGradient(
            colors: [
                LookTheme.Colors.textPrimary.opacity(0.96),
                LookTheme.Colors.warmYellow.opacity(0.78 + shimmer * 0.18),
                LookTheme.Colors.softPink.opacity(0.88),
                LookTheme.Colors.hotPink.opacity(0.82)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private func meteorPhase(at date: Date, playing: Bool, speed: Double) -> Double {
        guard playing else {
            return normalized(referencePhase)
        }

        let elapsed = max(0, date.timeIntervalSince(referenceDate))
        return normalized(referencePhase + elapsed / cycleDuration(speed: speed))
    }

    private func cycleDuration(speed: Double) -> TimeInterval {
        max(1.45, 3.4 / max(0.2, speed))
    }

    private func meteorProgress(index: Int, phase: Double) -> Double {
        normalized(phase * (0.78 + Double(index % 5) * 0.055) + Double(index) * 0.127)
    }

    private func meteorPoint(index: Int, progress: Double, width: CGFloat, height: CGFloat) -> CGPoint {
        let rowSeed = CGFloat((index * 29) % 100) / 100
        let startX = width * (0.82 + CGFloat(index % 4) * 0.13)
        let startY = -height * 0.26 + rowSeed * height * 0.72
        let travelX = width * (1.22 + CGFloat(index % 3) * 0.16)
        let travelY = height * (0.54 + CGFloat(index % 5) * 0.07)

        return CGPoint(
            x: startX - CGFloat(progress) * travelX,
            y: startY + CGFloat(progress) * travelY
        )
    }

    private func meteorIntensity(_ progress: Double) -> Double {
        let fadeIn = min(1, progress / 0.18)
        let fadeOut = min(1, (1 - progress) / 0.22)
        let body = min(fadeIn, fadeOut)
        return max(0, min(1, body)) * 0.92
    }

    private func meteorTrailLength(index: Int, width: CGFloat, height: CGFloat) -> CGFloat {
        let base = min(max(width, height) * 0.22, 260)
        return max(110, base + CGFloat(index % 4) * 24)
    }

    private func meteorThickness(_ index: Int) -> CGFloat {
        CGFloat(2.2 + Double(index % 3) * 0.8)
    }

    private func starPosition(index: Int, width: CGFloat, height: CGFloat) -> CGPoint {
        let x = CGFloat((index * 37 + 11) % 100) / 100 * width
        let y = CGFloat((index * 53 + 19) % 100) / 100 * height
        return CGPoint(x: x, y: y)
    }

    private func starSize(_ index: Int) -> CGFloat {
        CGFloat(1.8 + Double((index * 7) % 5) * 0.8)
    }

    private func starColor(index: Int) -> Color {
        switch index % 4 {
        case 0:
            LookTheme.Colors.textPrimary
        case 1:
            LookTheme.Colors.warmYellow
        case 2:
            LookTheme.Colors.hotPink
        default:
            LookTheme.Colors.electricBlue
        }
    }

    private func starTwinkle(index: Int, phase: Double) -> Double {
        let value = 0.5 + 0.5 * sin((phase * 2 + Double(index) * 0.173) * .pi * 2)
        return max(0.22, value)
    }

    private func userBlinkIntensity(_ phase: Double) -> Double {
        guard context.draft.isBlinking else {
            return 1
        }

        return normalized(phase * 0.74) < 0.5 ? 1 : 0.52
    }

    private func resetReference() {
        referencePhase = 0
        referenceDate = Date()
    }

    private func handlePlaybackChange(wasPlaying: Bool, isPlaying: Bool) {
        let now = Date()
        if wasPlaying, !isPlaying {
            referencePhase = meteorPhase(at: now, playing: true, speed: context.speed)
            referenceDate = now
        } else if !wasPlaying, isPlaying {
            referenceDate = now
        }
    }

    private func syncReference(speed: Double? = nil) {
        let now = Date()
        referencePhase = meteorPhase(at: now, playing: context.isPlaying, speed: speed ?? context.speed)
        referenceDate = now
    }

    private func normalized(_ value: Double) -> Double {
        let progress = value.truncatingRemainder(dividingBy: 1)
        return progress >= 0 ? progress : progress + 1
    }
}
