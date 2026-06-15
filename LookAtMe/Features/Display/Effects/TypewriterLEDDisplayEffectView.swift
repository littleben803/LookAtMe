import SwiftUI

struct TypewriterLEDDisplayEffectView: View {
    let context: LEDDisplayEffectContext

    @State private var referenceProgress: Double = 0
    @State private var referenceDate = Date()

    var body: some View {
        let contentWidth = max(1, context.viewportSize.width)
        let characters = Array(context.draft.text)

        TimelineView(.animation) { timeline in
            let progress = typewriterProgress(at: timeline.date, playing: context.isPlaying, speed: context.speed)
            let revealUnits = revealUnits(progress: progress, characterCount: characters.count)
            let userBlink = userBlinkIntensity(progress)

            ZStack {
                ambientGlow(contentWidth: contentWidth, progress: progress, revealUnits: revealUnits, characterCount: characters.count)

                scanTrails(contentWidth: contentWidth, progress: progress)

                characterRow(
                    characters: characters,
                    contentWidth: contentWidth,
                    revealUnits: revealUnits,
                    progress: progress,
                    userBlink: userBlink
                )

                cursor(
                    contentWidth: contentWidth,
                    characterCount: characters.count,
                    revealUnits: revealUnits,
                    progress: progress,
                    userBlink: userBlink
                )
            }
            .frame(width: contentWidth)
            .frame(maxHeight: .infinity)
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

    private var characterAdvance: CGFloat {
        max(24, fontSize * 0.84)
    }

    private var characterSpacing: CGFloat {
        max(1, fontSize * 0.018)
    }

    private func rowMetrics(contentWidth: CGFloat, characterCount: Int) -> (unscaledWidth: CGFloat, scale: CGFloat) {
        guard characterCount > 0 else {
            return (1, 1)
        }

        let spacingWidth = CGFloat(max(0, characterCount - 1)) * characterSpacing
        let unscaledWidth = CGFloat(characterCount) * characterAdvance + spacingWidth
        let scale = min(1, contentWidth * 0.94 / max(1, unscaledWidth))
        return (unscaledWidth, scale)
    }

    private func characterRow(
        characters: [Character],
        contentWidth: CGFloat,
        revealUnits: Double,
        progress: Double,
        userBlink: Double
    ) -> some View {
        let metrics = rowMetrics(contentWidth: contentWidth, characterCount: characters.count)

        return HStack(spacing: characterSpacing) {
            ForEach(Array(characters.enumerated()), id: \.offset) { index, character in
                let reveal = characterReveal(index: index, revealUnits: revealUnits)
                let flash = characterFlash(index: index, revealUnits: revealUnits)

                Text(String(character))
                    .font(context.draft.fontStyle.font(size: fontSize))
                    .lineLimit(1)
                    .foregroundStyle(characterGradient(index: index, progress: progress))
                    .frame(width: characterAdvance)
                    .opacity(reveal * userBlink)
                    .scaleEffect(0.88 + CGFloat(reveal) * 0.12 + CGFloat(flash) * 0.1)
                    .shadow(color: accentColor.opacity(0.82 * reveal), radius: 8 + CGFloat(flash) * 10)
                    .shadow(color: LookTheme.Colors.hotPink.opacity(0.58 * reveal), radius: 22 + CGFloat(flash) * 18)
                    .shadow(color: LookTheme.Colors.neonPurple.opacity(0.36 * reveal), radius: 42)
            }
        }
        .frame(width: metrics.unscaledWidth)
        .scaleEffect(x: context.draft.isMirrored ? -metrics.scale : metrics.scale, y: metrics.scale)
        .frame(width: contentWidth)
    }

    private func cursor(
        contentWidth: CGFloat,
        characterCount: Int,
        revealUnits: Double,
        progress: Double,
        userBlink: Double
    ) -> some View {
        let metrics = rowMetrics(contentWidth: contentWidth, characterCount: characterCount)
        let cursorStep = characterAdvance + characterSpacing
        let typedUnits = min(Double(characterCount), max(0, revealUnits))
        let rawCursorX = -metrics.unscaledWidth * metrics.scale / 2
            + CGFloat(typedUnits) * cursorStep * metrics.scale
            - characterSpacing * metrics.scale / 2
        let cursorX = context.draft.isMirrored ? -rawCursorX : rawCursorX
        let completed = revealUnits >= Double(characterCount)
        let blink = completed ? 0.45 + 0.55 * max(0, sin(progress * .pi * 18)) : 1

        return RoundedRectangle(cornerRadius: 3, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        LookTheme.Colors.textPrimary.opacity(0.9),
                        accentColor,
                        LookTheme.Colors.hotPink.opacity(0.88)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: max(5, fontSize * 0.055), height: fontSize * 0.88)
            .scaleEffect(metrics.scale)
            .offset(x: cursorX)
            .opacity(characterCount > 0 ? blink * userBlink : 0)
            .shadow(color: accentColor.opacity(0.86), radius: 10)
            .shadow(color: LookTheme.Colors.hotPink.opacity(0.58), radius: 24)
            .allowsHitTesting(false)
    }

    private func ambientGlow(
        contentWidth: CGFloat,
        progress: Double,
        revealUnits: Double,
        characterCount: Int
    ) -> some View {
        let longestSide = max(context.viewportSize.width, context.viewportSize.height)
        let revealRatio = characterCount > 0 ? min(1, revealUnits / Double(characterCount)) : 0
        let centerX = 0.16 + revealRatio * 0.68

        return ZStack {
            RadialGradient(
                colors: [
                    accentColor.opacity(0.12 + revealRatio * 0.18),
                    LookTheme.Colors.hotPink.opacity(0.08 + revealRatio * 0.12),
                    .clear
                ],
                center: UnitPoint(x: centerX, y: 0.5),
                startRadius: 12,
                endRadius: max(180, longestSide * 0.48)
            )

            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            .clear,
                            LookTheme.Colors.neonPurple.opacity(0.08),
                            accentColor.opacity(0.07 + revealRatio * 0.08),
                            .clear
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: contentWidth, height: max(80, context.viewportSize.height * 0.28))
                .blur(radius: 24)
                .opacity(0.7 + 0.3 * sin(progress * .pi * 2))
        }
        .allowsHitTesting(false)
    }

    private func scanTrails(contentWidth: CGFloat, progress: Double) -> some View {
        ZStack {
            ForEach(0..<8, id: \.self) { index in
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                .clear,
                                accentColor.opacity(0.2),
                                LookTheme.Colors.hotPink.opacity(0.16),
                                .clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: contentWidth * CGFloat(0.1 + Double(index % 3) * 0.045), height: index.isMultiple(of: 2) ? 3 : 2)
                    .offset(
                        x: scanTrailOffset(contentWidth: contentWidth, progress: progress, index: index),
                        y: CGFloat(index - 4) * max(10, fontSize * 0.13)
                    )
                    .opacity(scanTrailOpacity(progress: progress, index: index))
                    .blur(radius: 0.8)
            }
        }
        .allowsHitTesting(false)
    }

    private func characterGradient(index: Int, progress: Double) -> LinearGradient {
        let phase = normalized(progress + Double(index) * 0.11)
        return LinearGradient(
            colors: [
                LookTheme.Colors.textPrimary.opacity(0.94),
                accentColor.opacity(0.78 + 0.18 * sin(phase * .pi * 2)),
                index.isMultiple(of: 2) ? LookTheme.Colors.hotPink.opacity(0.9) : LookTheme.Colors.softPink.opacity(0.88)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private func typewriterProgress(at date: Date, playing: Bool, speed: Double) -> Double {
        guard playing else {
            return normalized(referenceProgress)
        }

        let elapsed = max(0, date.timeIntervalSince(referenceDate))
        return normalized(referenceProgress + elapsed / cycleDuration(speed: speed))
    }

    private func cycleDuration(speed: Double) -> TimeInterval {
        let count = max(1, context.draft.text.count)
        let baseDuration = 0.24 * Double(count) + 0.95
        return max(0.9, baseDuration / max(0.2, speed))
    }

    private func revealUnits(progress: Double, characterCount: Int) -> Double {
        guard characterCount > 0 else {
            return 0
        }

        let typingWindow = 0.76
        let holdWindow = 0.18

        if progress <= typingWindow {
            let raw = progress / typingWindow
            return smoothStep(raw) * Double(characterCount)
        }

        if progress <= typingWindow + holdWindow {
            return Double(characterCount)
        }

        let fadeProgress = (progress - typingWindow - holdWindow) / max(0.001, 1 - typingWindow - holdWindow)
        return Double(characterCount) * max(0, 1 - smoothStep(fadeProgress))
    }

    private func characterReveal(index: Int, revealUnits: Double) -> Double {
        let local = revealUnits - Double(index)
        if local <= 0 {
            return 0
        }
        if local >= 1 {
            return 1
        }
        return smoothStep(local)
    }

    private func characterFlash(index: Int, revealUnits: Double) -> Double {
        let local = revealUnits - Double(index)
        guard local > 0, local < 1 else {
            return 0
        }
        return max(0, sin(local * .pi))
    }

    private func userBlinkIntensity(_ progress: Double) -> Double {
        guard context.draft.isBlinking else {
            return 1
        }

        return normalized(progress * 0.8) < 0.5 ? 1 : 0.54
    }

    private func scanTrailOffset(contentWidth: CGFloat, progress: Double, index: Int) -> CGFloat {
        let trailProgress = normalized(progress * 1.35 + Double(index) * 0.17)
        return CGFloat(trailProgress - 0.5) * contentWidth * 1.08
    }

    private func scanTrailOpacity(progress: Double, index: Int) -> Double {
        let trailProgress = normalized(progress * 1.55 + Double(index) * 0.13)
        let pulse = max(0, 1 - abs(trailProgress - 0.5) * 3.2)
        return min(0.42, pulse * 0.58)
    }

    private func resetReference() {
        referenceProgress = 0
        referenceDate = Date()
    }

    private func handlePlaybackChange(wasPlaying: Bool, isPlaying: Bool) {
        let now = Date()
        if wasPlaying, !isPlaying {
            referenceProgress = typewriterProgress(at: now, playing: true, speed: context.speed)
            referenceDate = now
        } else if !wasPlaying, isPlaying {
            referenceDate = now
        }
    }

    private func syncReference(speed: Double? = nil) {
        let now = Date()
        referenceProgress = typewriterProgress(at: now, playing: context.isPlaying, speed: speed ?? context.speed)
        referenceDate = now
    }

    private func smoothStep(_ value: Double) -> Double {
        let clamped = min(1, max(0, value))
        return clamped * clamped * (3 - 2 * clamped)
    }

    private func normalized(_ value: Double) -> Double {
        let progress = value.truncatingRemainder(dividingBy: 1)
        return progress >= 0 ? progress : progress + 1
    }
}
