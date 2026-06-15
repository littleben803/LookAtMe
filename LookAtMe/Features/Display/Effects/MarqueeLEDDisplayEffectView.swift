import SwiftUI

private struct MarqueeTextWidthKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

struct MarqueeLEDDisplayEffectView: View {
    let context: LEDDisplayEffectContext

    @State private var containerWidth: CGFloat = 0
    @State private var textWidth: CGFloat = 0
    @State private var referenceProgress: CGFloat = 0
    @State private var referenceDate = Date()
    @State private var blinkOpacity: Double = 1

    var body: some View {
        TimelineView(.animation) { timeline in
            LEDDisplayEffectText(context: context, fixedWidth: true, opacity: blinkOpacity)
                .background(textWidthReader)
                .offset(x: marqueeOffset(at: timeline.date))
        }
        .onPreferenceChange(MarqueeTextWidthKey.self) { width in
            updateTextWidth(width)
        }
        .frame(width: context.viewportSize.width)
        .frame(maxHeight: .infinity)
        .clipped()
        .onAppear {
            updateContainerWidth(context.viewportSize.width)
            resetReference()
            startBlinkingIfNeeded()
        }
        .onChange(of: context.viewportSize.width) { _, width in
            updateContainerWidth(width)
        }
        .onChange(of: context.layoutRefreshID) { _, _ in
            syncReference()
            textWidth = 0
            updateContainerWidth(context.viewportSize.width)
        }
        .onChange(of: context.isPlaying) { oldValue, playing in
            handlePlaybackChange(wasPlaying: oldValue, isPlaying: playing)
            if playing {
                startBlinkingIfNeeded()
            } else {
                resetBlinking()
            }
        }
        .onChange(of: context.speed) { _, _ in
            syncReference()
        }
        .onChange(of: context.fontScale) { _, _ in
            syncReference()
        }
    }

    private var textWidthReader: some View {
        GeometryReader { proxy in
            Color.clear.preference(key: MarqueeTextWidthKey.self, value: proxy.size.width)
        }
    }

    private var cycleDuration: TimeInterval {
        max(2.4, 7.0 / context.speed)
    }

    private var estimatedTextWidth: CGFloat {
        max(48, CGFloat(context.draft.text.count) * 42 * CGFloat(context.fontScale))
    }

    private var effectiveTextWidth: CGFloat {
        textWidth > 1 ? textWidth : estimatedTextWidth
    }

    private func marqueeProgress(at date: Date, playing: Bool) -> CGFloat {
        guard playing else {
            return normalizedProgress(referenceProgress)
        }

        let elapsed = max(0, date.timeIntervalSince(referenceDate))
        return normalizedProgress(referenceProgress + CGFloat(elapsed / cycleDuration))
    }

    private func marqueeOffset(at date: Date) -> CGFloat {
        marqueeOffset(
            progress: marqueeProgress(at: date, playing: context.isPlaying),
            containerWidth: max(1, containerWidth),
            textWidth: effectiveTextWidth
        )
    }

    private func marqueeOffset(progress: CGFloat, containerWidth: CGFloat, textWidth: CGFloat) -> CGFloat {
        let travelDistance = max(1, containerWidth + textWidth)
        let edgeOffset = travelDistance / 2
        let travelled = normalizedProgress(progress) * travelDistance

        switch context.draft.scrollDirection {
        case .rightToLeft:
            return edgeOffset - travelled
        case .leftToRight:
            return -edgeOffset + travelled
        }
    }

    private func marqueeProgress(forOffset offset: CGFloat, containerWidth: CGFloat, textWidth: CGFloat) -> CGFloat {
        let travelDistance = max(1, containerWidth + textWidth)
        let edgeOffset = travelDistance / 2

        switch context.draft.scrollDirection {
        case .rightToLeft:
            return normalizedProgress((edgeOffset - offset) / travelDistance)
        case .leftToRight:
            return normalizedProgress((offset + edgeOffset) / travelDistance)
        }
    }

    private func normalizedProgress(_ value: CGFloat) -> CGFloat {
        let progress = value.truncatingRemainder(dividingBy: 1)
        return progress >= 0 ? progress : progress + 1
    }

    private func resetReference() {
        referenceProgress = 0
        referenceDate = Date()
    }

    private func handlePlaybackChange(wasPlaying: Bool, isPlaying: Bool) {
        let now = Date()
        if wasPlaying, !isPlaying {
            referenceProgress = marqueeProgress(at: now, playing: true)
            referenceDate = now
        } else if !wasPlaying, isPlaying {
            referenceDate = now
        }
    }

    private func syncReference() {
        let now = Date()
        referenceProgress = marqueeProgress(at: now, playing: context.isPlaying)
        referenceDate = now
    }

    private func updateContainerWidth(_ width: CGFloat) {
        let newWidth = max(1, width)
        guard abs(newWidth - containerWidth) > 0.5 else {
            return
        }
        guard containerWidth > 0 else {
            containerWidth = newWidth
            return
        }
        preserveOffset(newContainerWidth: newWidth, newTextWidth: effectiveTextWidth)
        containerWidth = newWidth
    }

    private func updateTextWidth(_ width: CGFloat) {
        let newWidth = max(1, width)
        guard abs(newWidth - textWidth) > 0.5 else {
            return
        }
        preserveOffset(newContainerWidth: max(1, containerWidth), newTextWidth: newWidth)
        textWidth = newWidth
    }

    private func preserveOffset(newContainerWidth: CGFloat, newTextWidth: CGFloat) {
        let now = Date()
        let currentOffset = marqueeOffset(
            progress: marqueeProgress(at: now, playing: context.isPlaying),
            containerWidth: max(1, containerWidth),
            textWidth: effectiveTextWidth
        )
        referenceProgress = marqueeProgress(
            forOffset: currentOffset,
            containerWidth: newContainerWidth,
            textWidth: newTextWidth
        )
        referenceDate = now
    }

    private func startBlinkingIfNeeded() {
        guard context.draft.isBlinking, context.isPlaying else {
            blinkOpacity = 1
            return
        }

        blinkOpacity = 1
        withAnimation(.easeInOut(duration: 0.48).repeatForever(autoreverses: true)) {
            blinkOpacity = 0.42
        }
    }

    private func resetBlinking() {
        withAnimation(.linear(duration: 0.01)) {
            blinkOpacity = 1
        }
    }
}
