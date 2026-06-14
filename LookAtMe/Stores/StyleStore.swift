import Combine
import Foundation

final class StyleStore: ObservableObject {
    let styles: [BannerStyle] = [
        BannerStyle(id: "style-marquee", name: "经典跑马灯", type: .marquee, isPro: false, previewText: "LOVE"),
        BannerStyle(id: "style-neon-blink", name: "霓虹闪烁", type: .neonBlink, isPro: false, previewText: "LOVE"),
        BannerStyle(id: "style-breathing", name: "呼吸灯", type: .breathing, isPro: false, previewText: "想你"),
        BannerStyle(id: "style-typewriter", name: "逐字出现", type: .typewriter, isPro: false, previewText: "告白"),
        BannerStyle(id: "style-meteor-shower", name: "流星告白", type: .meteorShower, isPro: true, previewText: "许愿"),
        BannerStyle(id: "style-laser-sweep", name: "激光扫场", type: .laserSweep, isPro: true, previewText: "LASER"),
        BannerStyle(id: "style-firework-burst", name: "烟花爆闪", type: .fireworkBurst, isPro: true, previewText: "WOW"),
        BannerStyle(id: "style-heart-beat", name: "心跳脉冲", type: .heartBeat, isPro: true, previewText: "心动"),
        BannerStyle(id: "style-heart-rain", name: "爱心飘落", type: .heartRain, isPro: true, previewText: "❤"),
        BannerStyle(id: "style-rainbow", name: "彩虹渐变", type: .rainbow, isPro: true, previewText: "彩虹"),
        BannerStyle(id: "style-star-flash", name: "星星闪光", type: .starFlash, isPro: true, previewText: "闪耀"),
        BannerStyle(id: "style-bullet-fly-in", name: "弹幕飞入", type: .bulletFlyIn, isPro: true, previewText: "看这里"),
        BannerStyle(id: "style-aurora-wave", name: "极光流光", type: .auroraWave, isPro: true, previewText: "极光"),
        BannerStyle(id: "style-bubble-pop", name: "气泡弹跳", type: .bubblePop, isPro: true, previewText: "喜欢"),
        BannerStyle(id: "style-spotlight", name: "聚光主角", type: .spotlight, isPro: true, previewText: "主角"),
        BannerStyle(id: "style-glitch-pulse", name: "霓虹故障", type: .glitchPulse, isPro: true, previewText: "LOVE")
    ]

    var freeStyles: [BannerStyle] {
        styles.filter { !$0.isPro }
    }

    func style(withID id: String) -> BannerStyle {
        styles.first { $0.id == id } ?? styles[0]
    }
}
