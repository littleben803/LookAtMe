import Combine
import Foundation

final class StyleStore: ObservableObject {
    let styles: [BannerStyle] = [
        BannerStyle(id: "style-marquee", type: .marquee, isPro: false),
        BannerStyle(id: "style-neon-blink", type: .neonBlink, isPro: false),
        BannerStyle(id: "style-breathing", type: .breathing, isPro: false),
        BannerStyle(id: "style-typewriter", type: .typewriter, isPro: false),
        BannerStyle(id: "style-meteor-shower", type: .meteorShower, isPro: true),
        BannerStyle(id: "style-laser-sweep", type: .laserSweep, isPro: true),
        BannerStyle(id: "style-firework-burst", type: .fireworkBurst, isPro: true),
        BannerStyle(id: "style-heart-beat", type: .heartBeat, isPro: true),
        BannerStyle(id: "style-heart-rain", type: .heartRain, isPro: true),
        BannerStyle(id: "style-rainbow", type: .rainbow, isPro: true),
        BannerStyle(id: "style-star-flash", type: .starFlash, isPro: true),
        BannerStyle(id: "style-bullet-fly-in", type: .bulletFlyIn, isPro: true, previewTextKey: L10n.StylePreview.bulletLookHere),
        BannerStyle(id: "style-aurora-wave", type: .auroraWave, isPro: true),
        BannerStyle(id: "style-bubble-pop", type: .bubblePop, isPro: true),
        BannerStyle(id: "style-spotlight", type: .spotlight, isPro: true),
        BannerStyle(id: "style-glitch-pulse", type: .glitchPulse, isPro: true)
    ]

    var freeStyles: [BannerStyle] {
        styles.filter { !$0.isPro }
    }

    func style(withID id: String) -> BannerStyle {
        styles.first { $0.id == id } ?? styles[0]
    }
}
