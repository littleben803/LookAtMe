import SwiftUI

struct StaticLEDDisplayEffectView: View {
    let context: LEDDisplayEffectContext

    @State private var blinkOpacity: Double = 1

    var body: some View {
        let contentWidth = LEDDisplayEffectText.displayContentWidth(
            totalWidth: context.viewportSize.width,
            safeAreaInsets: context.safeAreaInsets
        )
        let leadingPadding = context.safeAreaInsets.leading + LookSpacing.pageHorizontal
        let trailingPadding = context.safeAreaInsets.trailing + LookSpacing.pageHorizontal

        LEDDisplayEffectText(context: context, fixedWidth: false, opacity: blinkOpacity)
            .frame(width: contentWidth)
            .frame(maxHeight: .infinity)
            .padding(.leading, leadingPadding)
            .padding(.trailing, trailingPadding)
            .frame(width: context.viewportSize.width)
            .frame(maxHeight: .infinity)
            .onAppear {
                startBlinkingIfNeeded()
            }
            .onChange(of: context.isPlaying) { _, playing in
                if playing {
                    startBlinkingIfNeeded()
                } else {
                    resetBlinking()
                }
            }
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
