import SwiftUI

struct LEDDisplayEffectClock<Content: View>: View {
    let context: LEDDisplayEffectContext
    let cycleDuration: (Double) -> TimeInterval
    let content: (Double) -> Content

    @State private var referencePhase: Double = 0
    @State private var referenceDate = Date()

    init(
        context: LEDDisplayEffectContext,
        cycleDuration: @escaping (Double) -> TimeInterval,
        @ViewBuilder content: @escaping (Double) -> Content
    ) {
        self.context = context
        self.cycleDuration = cycleDuration
        self.content = content
    }

    var body: some View {
        TimelineView(.animation) { timeline in
            content(phase(at: timeline.date, playing: context.isPlaying, speed: context.speed))
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

    private func phase(at date: Date, playing: Bool, speed: Double) -> Double {
        guard playing else {
            return LEDDisplayEffectMath.normalized(referencePhase)
        }

        let elapsed = max(0, date.timeIntervalSince(referenceDate))
        let duration = max(0.2, cycleDuration(max(0.2, speed)))
        return LEDDisplayEffectMath.normalized(referencePhase + elapsed / duration)
    }

    private func resetReference() {
        referencePhase = 0
        referenceDate = Date()
    }

    private func handlePlaybackChange(wasPlaying: Bool, isPlaying: Bool) {
        let now = Date()
        if wasPlaying, !isPlaying {
            referencePhase = phase(at: now, playing: true, speed: context.speed)
            referenceDate = now
        } else if !wasPlaying, isPlaying {
            referenceDate = now
        }
    }

    private func syncReference(speed: Double? = nil) {
        let now = Date()
        referencePhase = phase(at: now, playing: context.isPlaying, speed: speed ?? context.speed)
        referenceDate = now
    }
}

enum LEDDisplayEffectMath {
    static func normalized(_ value: Double) -> Double {
        let progress = value.truncatingRemainder(dividingBy: 1)
        return progress >= 0 ? progress : progress + 1
    }

    static func smoothStep(_ value: Double) -> Double {
        let clamped = min(1, max(0, value))
        return clamped * clamped * (3 - 2 * clamped)
    }

    static func triangle(_ value: Double) -> Double {
        let phase = normalized(value)
        return 1 - abs(phase - 0.5) * 2
    }

    static func blink(isEnabled: Bool, phase: Double, lowValue: Double = 0.52) -> Double {
        guard isEnabled else {
            return 1
        }

        return normalized(phase) < 0.5 ? 1 : lowValue
    }
}
