import Combine
import Foundation

final class TemplateStore: ObservableObject {
    private let templates: [BannerTemplate] = [
        BannerTemplate(id: "concert-zhou-shen", scene: .concert, isPro: false),
        BannerTemplate(id: "concert-love-forever", scene: .concert, isPro: false),
        BannerTemplate(id: "concert-best", scene: .concert, isPro: false),
        BannerTemplate(id: "concert-look-here", scene: .concert, isPro: false),
        BannerTemplate(id: "concert-call", scene: .concert, isPro: false),
        BannerTemplate(id: "concert-shine", scene: .concert, isPro: false),
        BannerTemplate(id: "concert-husband-look", scene: .concert, isPro: true),
        BannerTemplate(id: "concert-tonight", scene: .concert, isPro: true),

        BannerTemplate(id: "confession-wife", scene: .confession, isPro: false),
        BannerTemplate(id: "confession-long-time", scene: .confession, isPro: false),
        BannerTemplate(id: "confession-girlfriend", scene: .confession, isPro: false),
        BannerTemplate(id: "confession-miss", scene: .confession, isPro: false),
        BannerTemplate(id: "confession-only", scene: .confession, isPro: false),
        BannerTemplate(id: "confession-concert", scene: .confession, isPro: false),
        BannerTemplate(id: "confession-meet", scene: .confession, isPro: true),
        BannerTemplate(id: "confession-hand", scene: .confession, isPro: true),

        BannerTemplate(id: "birthday-happy", scene: .birthday, isPro: false),
        BannerTemplate(id: "birthday-biggest", scene: .birthday, isPro: false),
        BannerTemplate(id: "birthday-happy-everyday", scene: .birthday, isPro: false),
        BannerTemplate(id: "birthday-wishes", scene: .birthday, isPro: false),
        BannerTemplate(id: "birthday-pretty", scene: .birthday, isPro: false),
        BannerTemplate(id: "birthday-rich", scene: .birthday, isPro: false),
        BannerTemplate(id: "birthday-forever-18", scene: .birthday, isPro: true),
        BannerTemplate(id: "birthday-dream", scene: .birthday, isPro: true),

        BannerTemplate(id: "pickup-here", scene: .pickup, isPro: false),
        BannerTemplate(id: "pickup-home", scene: .pickup, isPro: false),
        BannerTemplate(id: "pickup-wait", scene: .pickup, isPro: false),
        BannerTemplate(id: "pickup-finally", scene: .pickup, isPro: false),
        BannerTemplate(id: "pickup-hard", scene: .pickup, isPro: false),
        BannerTemplate(id: "pickup-left", scene: .pickup, isPro: false),
        BannerTemplate(id: "pickup-safe", scene: .pickup, isPro: true),
        BannerTemplate(id: "pickup-long-time", scene: .pickup, isPro: true),

        BannerTemplate(id: "fun-boss", scene: .fun, isPro: false),
        BannerTemplate(id: "fun-energy", scene: .fun, isPro: false),
        BannerTemplate(id: "fun-stop", scene: .fun, isPro: false),
        BannerTemplate(id: "fun-help", scene: .fun, isPro: false),
        BannerTemplate(id: "fun-leave", scene: .fun, isPro: false),
        BannerTemplate(id: "fun-shine", scene: .fun, isPro: false),
        BannerTemplate(id: "fun-stage", scene: .fun, isPro: true),
        BannerTemplate(id: "fun-camera", scene: .fun, isPro: true)
    ]

    var allScenes: [BannerScene] {
        BannerScene.allCases
    }

    func templates(for scene: BannerScene) -> [BannerTemplate] {
        templates.filter { $0.scene == scene }
    }

    func homeTemplates(for scene: BannerScene) -> [BannerTemplate] {
        Array(templates(for: scene).prefix(6))
    }
}
