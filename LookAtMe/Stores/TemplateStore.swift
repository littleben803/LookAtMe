import Foundation

final class TemplateStore {
    private let templates: [BannerTemplate] = [
        BannerTemplate(id: "concert-zhou-shen", title: "周深我爱你！", scene: .concert, text: "周深我爱你！", isPro: false),
        BannerTemplate(id: "concert-love-forever", title: "永远爱你❤️", scene: .concert, text: "永远爱你❤️", isPro: false),
        BannerTemplate(id: "concert-best", title: "你最棒！👍", scene: .concert, text: "你最棒！👍", isPro: false),
        BannerTemplate(id: "concert-look-here", title: "看这里！", scene: .concert, text: "看这里！", isPro: false),
        BannerTemplate(id: "concert-call", title: "加油打CALL", scene: .concert, text: "加油打CALL", isPro: false),
        BannerTemplate(id: "concert-shine", title: "全场最闪亮✨", scene: .concert, text: "全场最闪亮✨", isPro: false),

        BannerTemplate(id: "confession-wife", title: "老婆我爱你", scene: .confession, text: "老婆我爱你", isPro: false),
        BannerTemplate(id: "confession-long-time", title: "喜欢你很久了", scene: .confession, text: "喜欢你很久了", isPro: false),
        BannerTemplate(id: "confession-girlfriend", title: "做我女朋友吧", scene: .confession, text: "做我女朋友吧", isPro: false),
        BannerTemplate(id: "confession-miss", title: "今天也很想你", scene: .confession, text: "今天也很想你", isPro: false),
        BannerTemplate(id: "confession-only", title: "你是我的唯一", scene: .confession, text: "你是我的唯一", isPro: false),
        BannerTemplate(id: "confession-concert", title: "想和你看演唱会", scene: .confession, text: "想和你看演唱会", isPro: false),

        BannerTemplate(id: "birthday-happy", title: "生日快乐🎂", scene: .birthday, text: "生日快乐🎂", isPro: false),
        BannerTemplate(id: "birthday-biggest", title: "今天你最大", scene: .birthday, text: "今天你最大", isPro: false),
        BannerTemplate(id: "birthday-happy-everyday", title: "天天开心", scene: .birthday, text: "天天开心", isPro: false),
        BannerTemplate(id: "birthday-wishes", title: "愿望都会实现", scene: .birthday, text: "愿望都会实现", isPro: false),
        BannerTemplate(id: "birthday-pretty", title: "越来越漂亮", scene: .birthday, text: "越来越漂亮", isPro: false),
        BannerTemplate(id: "birthday-rich", title: "祝你暴富", scene: .birthday, text: "祝你暴富", isPro: false),

        BannerTemplate(id: "pickup-here", title: "这里这里！", scene: .pickup, text: "这里这里！", isPro: false),
        BannerTemplate(id: "pickup-home", title: "欢迎回家", scene: .pickup, text: "欢迎回家", isPro: false),
        BannerTemplate(id: "pickup-wait", title: "我在这里等你", scene: .pickup, text: "我在这里等你", isPro: false),
        BannerTemplate(id: "pickup-finally", title: "终于见到你", scene: .pickup, text: "终于见到你", isPro: false),
        BannerTemplate(id: "pickup-hard", title: "辛苦啦", scene: .pickup, text: "辛苦啦", isPro: false),
        BannerTemplate(id: "pickup-left", title: "看左边！", scene: .pickup, text: "看左边！", isPro: false)
    ]

    func templates(for scene: BannerScene) -> [BannerTemplate] {
        templates.filter { $0.scene == scene }
    }
}

