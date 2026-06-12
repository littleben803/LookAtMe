import Foundation

final class StyleStore {
    let styles: [BannerStyle] = [
        BannerStyle(id: "style-marquee", name: "经典跑马灯", type: .marquee, isPro: false, previewText: "LOVE"),
        BannerStyle(id: "style-neon-blink", name: "霓虹闪烁", type: .neonBlink, isPro: false, previewText: "LOVE"),
        BannerStyle(id: "style-heart-rain", name: "爱心飘落", type: .heartRain, isPro: true, previewText: "❤"),
        BannerStyle(id: "style-rainbow", name: "彩虹渐变", type: .rainbow, isPro: true, previewText: "彩虹")
    ]
}

