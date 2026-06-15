import SwiftUI

struct LEDDisplayEffectContext {
    let draft: BannerDraft
    let isPlaying: Bool
    let speed: Double
    let fontScale: Double
    let viewportSize: CGSize
    let safeAreaInsets: EdgeInsets
    let layoutRefreshID: Int
}
