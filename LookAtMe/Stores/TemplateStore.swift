import Combine
import Foundation

final class TemplateStore: ObservableObject {
    private let templates: [BannerTemplate] = [
        BannerTemplate(id: "concert-zhou-shen", title: "周深我爱你！", scene: .concert, text: "周深我爱你！", isPro: false),
        BannerTemplate(id: "concert-love-forever", title: "永远爱你❤️", scene: .concert, text: "永远爱你❤️", isPro: false),
        BannerTemplate(id: "concert-best", title: "你最棒！👍", scene: .concert, text: "你最棒！👍", isPro: false),
        BannerTemplate(id: "concert-look-here", title: "看这里！", scene: .concert, text: "看这里！", isPro: false),
        BannerTemplate(id: "concert-call", title: "加油打CALL", scene: .concert, text: "加油打CALL", isPro: false),
        BannerTemplate(id: "concert-shine", title: "全场最闪亮✨", scene: .concert, text: "全场最闪亮✨", isPro: false),
        BannerTemplate(id: "concert-husband-look", title: "老公看这里！", scene: .concert, text: "老公看这里！", isPro: false),
        BannerTemplate(id: "concert-tonight", title: "今晚为你而来", scene: .concert, text: "今晚为你而来", isPro: false),

        BannerTemplate(id: "confession-wife", title: "老婆我爱你", scene: .confession, text: "老婆我爱你", isPro: false),
        BannerTemplate(id: "confession-long-time", title: "喜欢你很久了", scene: .confession, text: "喜欢你很久了", isPro: false),
        BannerTemplate(id: "confession-girlfriend", title: "做我女朋友吧", scene: .confession, text: "做我女朋友吧", isPro: false),
        BannerTemplate(id: "confession-miss", title: "今天也很想你", scene: .confession, text: "今天也很想你", isPro: false),
        BannerTemplate(id: "confession-only", title: "你是我的唯一", scene: .confession, text: "你是我的唯一", isPro: false),
        BannerTemplate(id: "confession-concert", title: "想和你看演唱会", scene: .confession, text: "想和你看演唱会", isPro: false),
        BannerTemplate(id: "confession-meet", title: "遇见你真好", scene: .confession, text: "遇见你真好", isPro: false),
        BannerTemplate(id: "confession-hand", title: "可以牵手吗", scene: .confession, text: "可以牵手吗", isPro: false),

        BannerTemplate(id: "birthday-happy", title: "生日快乐🎂", scene: .birthday, text: "生日快乐🎂", isPro: false),
        BannerTemplate(id: "birthday-biggest", title: "今天你最大", scene: .birthday, text: "今天你最大", isPro: false),
        BannerTemplate(id: "birthday-happy-everyday", title: "天天开心", scene: .birthday, text: "天天开心", isPro: false),
        BannerTemplate(id: "birthday-wishes", title: "愿望都会实现", scene: .birthday, text: "愿望都会实现", isPro: false),
        BannerTemplate(id: "birthday-pretty", title: "越来越漂亮", scene: .birthday, text: "越来越漂亮", isPro: false),
        BannerTemplate(id: "birthday-rich", title: "祝你暴富", scene: .birthday, text: "祝你暴富", isPro: false),
        BannerTemplate(id: "birthday-forever-18", title: "永远十八岁", scene: .birthday, text: "永远十八岁", isPro: false),
        BannerTemplate(id: "birthday-dream", title: "心想事成", scene: .birthday, text: "心想事成", isPro: false),

        BannerTemplate(id: "pickup-here", title: "这里这里！", scene: .pickup, text: "这里这里！", isPro: false),
        BannerTemplate(id: "pickup-home", title: "欢迎回家", scene: .pickup, text: "欢迎回家", isPro: false),
        BannerTemplate(id: "pickup-wait", title: "我在这里等你", scene: .pickup, text: "我在这里等你", isPro: false),
        BannerTemplate(id: "pickup-finally", title: "终于见到你", scene: .pickup, text: "终于见到你", isPro: false),
        BannerTemplate(id: "pickup-hard", title: "辛苦啦", scene: .pickup, text: "辛苦啦", isPro: false),
        BannerTemplate(id: "pickup-left", title: "看左边！", scene: .pickup, text: "看左边！", isPro: false),
        BannerTemplate(id: "pickup-safe", title: "一路平安", scene: .pickup, text: "一路平安", isPro: false),
        BannerTemplate(id: "pickup-long-time", title: "好久不见", scene: .pickup, text: "好久不见", isPro: false),

        BannerTemplate(id: "fun-boss", title: "老板加鸡腿", scene: .fun, text: "老板加鸡腿", isPro: false),
        BannerTemplate(id: "fun-energy", title: "前方高能", scene: .fun, text: "前方高能", isPro: false),
        BannerTemplate(id: "fun-stop", title: "别卷了", scene: .fun, text: "别卷了", isPro: false),
        BannerTemplate(id: "fun-help", title: "救救孩子", scene: .fun, text: "救救孩子", isPro: false),
        BannerTemplate(id: "fun-leave", title: "我先撤了", scene: .fun, text: "我先撤了", isPro: false),
        BannerTemplate(id: "fun-shine", title: "全场最闪亮✨", scene: .fun, text: "全场最闪亮✨", isPro: false),
        BannerTemplate(id: "fun-stage", title: "让我上台", scene: .fun, text: "让我上台", isPro: false),
        BannerTemplate(id: "fun-camera", title: "摄像老师看这里", scene: .fun, text: "摄像老师看这里", isPro: false)
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
