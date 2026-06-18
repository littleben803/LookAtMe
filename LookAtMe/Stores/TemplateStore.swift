import Combine
import Foundation

final class TemplateStore: ObservableObject {
    private let templates: [BannerTemplate] = [
        // Concert / Live
        template(id: "concert-look-here", scene: .concert, isPro: false, en: "LOOK HERE", ja: "こっち見て!", zhHans: "看这里!", zhHant: "看這裡!"),
        template(id: "concert-encore", scene: .concert, isPro: false, en: "ENCORE!", ja: "アンコール!", zhHans: "安可!", zhHant: "安可!"),
        template(id: "concert-love-you", scene: .concert, isPro: false, en: "LOVE YOU", ja: "だいすき", zhHans: "爱你", zhHant: "愛你"),
        template(id: "concert-sing-it", scene: .concert, isPro: false, en: "SING IT BACK", ja: "一緒に歌おう", zhHans: "一起唱", zhHant: "一起唱"),
        template(id: "concert-best-night", scene: .concert, isPro: false, en: "BEST NIGHT EVER", ja: "最高の夜", zhHans: "今夜最棒", zhHant: "今夜最棒"),
        template(id: "concert-front-row", scene: .concert, isPro: false, en: "FRONT ROW ENERGY", ja: "最前列パワー", zhHans: "前排能量", zhHant: "前排能量"),
        template(id: "concert-fandom", scene: .concert, isPro: true, en: "THIS FANDOM IS LOUD", ja: "この沼、最高", zhHans: "全场一起嗨", zhHant: "全場一起嗨"),
        template(id: "concert-camera", scene: .concert, isPro: true, en: "CAMERA, OVER HERE!", ja: "カメラこっち!", zhHans: "镜头看这里!", zhHant: "鏡頭看這裡!"),

        // Love / Crush
        template(id: "confession-like-you", scene: .confession, isPro: false, en: "I LIKE YOU", ja: "好きです", zhHans: "喜欢你", zhHant: "喜歡你"),
        template(id: "confession-be-mine", scene: .confession, isPro: false, en: "BE MINE?", ja: "付き合って?", zhHans: "做我恋人?", zhHant: "做我戀人?"),
        template(id: "confession-miss-you", scene: .confession, isPro: false, en: "MISS YOU", ja: "会いたい", zhHans: "想你", zhHant: "想你"),
        template(id: "confession-you-me", scene: .confession, isPro: false, en: "YOU + ME", ja: "君と私", zhHans: "你和我", zhHant: "你和我"),
        template(id: "confession-say-yes", scene: .confession, isPro: false, en: "SAY YES?", ja: "YESって言って", zhHans: "答应我?", zhHant: "答應我?"),
        template(id: "confession-favorite", scene: .confession, isPro: false, en: "MY FAVORITE PERSON", ja: "いちばん大切", zhHans: "最喜欢你", zhHant: "最喜歡你"),
        template(id: "confession-tonight", scene: .confession, isPro: true, en: "YOU + ME TONIGHT", ja: "今夜、君と", zhHans: "今晚只想见你", zhHant: "今晚只想見你"),
        template(id: "confession-heart", scene: .confession, isPro: true, en: "HEART GOES BOOM", ja: "ドキドキ止まらない", zhHans: "心动爆表", zhHant: "心動爆表"),

        // Birthday
        template(id: "birthday-happy", scene: .birthday, isPro: false, en: "HAPPY BDAY", ja: "お誕生日おめでとう", zhHans: "生日快乐", zhHant: "生日快樂"),
        template(id: "birthday-wish", scene: .birthday, isPro: false, en: "MAKE A WISH", ja: "願いごとして", zhHans: "快许愿", zhHant: "快許願"),
        template(id: "birthday-party", scene: .birthday, isPro: false, en: "PARTY TIME", ja: "パーティータイム", zhHans: "派对时间", zhHant: "派對時間"),
        template(id: "birthday-icon", scene: .birthday, isPro: false, en: "BIRTHDAY ICON", ja: "今日の主役", zhHans: "生日主角", zhHant: "生日主角"),
        template(id: "birthday-cake", scene: .birthday, isPro: false, en: "CAKE FIRST 🎂", ja: "ケーキ食べよ🎂", zhHans: "先吃蛋糕🎂", zhHant: "先吃蛋糕🎂"),
        template(id: "birthday-shine", scene: .birthday, isPro: false, en: "GLOW UP YEAR", ja: "もっと輝く年に", zhHans: "闪耀新一年", zhHant: "閃耀新一年"),
        template(id: "birthday-21", scene: .birthday, isPro: true, en: "21 AND GLOWING", ja: "21歳、輝いてる", zhHans: "21 岁发光中", zhHant: "21 歲發光中"),
        template(id: "birthday-wish-big", scene: .birthday, isPro: true, en: "WISH BIG, SHINE BIGGER", ja: "大きく願って輝こう", zhHans: "大声许愿, 闪耀更多", zhHant: "大聲許願, 閃耀更多"),

        // Pickup / Welcome
        template(id: "pickup-welcome", scene: .pickup, isPro: false, en: "WELCOME", ja: "ようこそ", zhHans: "欢迎", zhHant: "歡迎"),
        template(id: "pickup-over-here", scene: .pickup, isPro: false, en: "OVER HERE", ja: "こっちだよ", zhHans: "我在这里", zhHant: "我在這裡"),
        template(id: "pickup-this-way", scene: .pickup, isPro: false, en: "THIS WAY", ja: "こっちへ", zhHans: "往这边", zhHant: "往這邊"),
        template(id: "pickup-safe-landing", scene: .pickup, isPro: false, en: "SAFE LANDING", ja: "無事到着!", zhHans: "平安落地", zhHant: "平安落地"),
        template(id: "pickup-finally", scene: .pickup, isPro: false, en: "FINALLY HERE", ja: "やっと会えた", zhHans: "终于到了", zhHant: "終於到了"),
        template(id: "pickup-home", scene: .pickup, isPro: false, en: "WELCOME HOME", ja: "おかえり", zhHans: "欢迎回家", zhHant: "歡迎回家"),
        template(id: "pickup-missed", scene: .pickup, isPro: true, en: "I MISSED YOU", ja: "会いたかった", zhHans: "好想你", zhHant: "好想你"),
        template(id: "pickup-name-sign", scene: .pickup, isPro: true, en: "YOUR RIDE IS HERE", ja: "迎えに来たよ", zhHans: "你的接送到了", zhHant: "你的接送到了"),

        // Party / Fun
        template(id: "fun-dance", scene: .fun, isPro: false, en: "DANCE BREAK", ja: "踊ろう", zhHans: "跳舞时间", zhHant: "跳舞時間"),
        template(id: "fun-send-help", scene: .fun, isPro: false, en: "SEND HELP", ja: "助けてw", zhHans: "救一下", zhHant: "救一下"),
        template(id: "fun-no-photos", scene: .fun, isPro: false, en: "NO PHOTOS", ja: "撮影NGです", zhHans: "别拍了", zhHant: "別拍了"),
        template(id: "fun-main-character", scene: .fun, isPro: false, en: "MAIN CHARACTER", ja: "今日は主役", zhHans: "主角登场", zhHant: "主角登場"),
        template(id: "fun-one-more", scene: .fun, isPro: false, en: "ONE MORE SONG", ja: "もう一曲!", zhHans: "再来一首", zhHant: "再來一首"),
        template(id: "fun-chaos", scene: .fun, isPro: false, en: "CHAOS MODE", ja: "カオス中", zhHans: "混乱模式", zhHant: "混亂模式"),
        template(id: "fun-afterparty", scene: .fun, isPro: true, en: "AFTER PARTY?", ja: "二次会行く?", zhHans: "续摊吗?", zhHant: "續攤嗎?"),
        template(id: "fun-camera-ready", scene: .fun, isPro: true, en: "CAMERA READY", ja: "盛れてる?", zhHans: "准备上镜", zhHant: "準備上鏡"),

        // Sports / Team
        template(id: "sports-go-team", scene: .sports, isPro: false, en: "GO TEAM", ja: "チーム最高", zhHans: "加油队伍", zhHant: "加油隊伍"),
        template(id: "sports-we-got-this", scene: .sports, isPro: false, en: "WE GOT THIS", ja: "いける!", zhHans: "我们能赢", zhHant: "我們能贏"),
        template(id: "sports-defense", scene: .sports, isPro: false, en: "DEFENSE!", ja: "守れ!", zhHans: "防守!", zhHant: "防守!"),
        template(id: "sports-mvp", scene: .sports, isPro: false, en: "MVP ENERGY", ja: "MVP級", zhHans: "MVP 能量", zhHant: "MVP 能量"),
        template(id: "sports-game-winner", scene: .sports, isPro: false, en: "GAME WINNER", ja: "勝利の一撃", zhHans: "绝杀时刻", zhHant: "絕殺時刻"),
        template(id: "sports-lets-go", scene: .sports, isPro: false, en: "LET'S GOOO", ja: "行けーー!", zhHans: "冲啊!", zhHant: "衝啊!"),
        template(id: "sports-champions", scene: .sports, isPro: true, en: "CHAMPIONS ONLY", ja: "勝者だけ", zhHans: "冠军气场", zhHant: "冠軍氣場"),
        template(id: "sports-final-boss", scene: .sports, isPro: true, en: "FINAL BOSS MODE", ja: "ラスボスモード", zhHans: "终极模式", zhHant: "終極模式"),

        // School / Event
        template(id: "school-prom", scene: .school, isPro: false, en: "PROM?", ja: "一緒に行く?", zhHans: "一起去舞会?", zhHant: "一起去舞會?"),
        template(id: "school-class-of", scene: .school, isPro: false, en: "CLASS OF 2026", ja: "2026卒", zhHans: "2026 届", zhHant: "2026 屆"),
        template(id: "school-grad", scene: .school, isPro: false, en: "GRAD SZN", ja: "卒業シーズン", zhHans: "毕业季", zhHant: "畢業季"),
        template(id: "school-save-dance", scene: .school, isPro: false, en: "SAVE ME A DANCE", ja: "一曲空けてね", zhHans: "留支舞给我", zhHant: "留支舞給我"),
        template(id: "school-club", scene: .school, isPro: false, en: "CLUB MEET HERE", ja: "集合ここ", zhHans: "社团集合", zhHant: "社團集合"),
        template(id: "school-we-made-it", scene: .school, isPro: false, en: "WE MADE IT", ja: "やりきった!", zhHans: "我们做到了", zhHant: "我們做到了"),
        template(id: "school-afterparty", scene: .school, isPro: true, en: "AFTER PARTY THIS WAY", ja: "二次会こっち", zhHans: "派对往这边", zhHant: "派對往這邊"),
        template(id: "school-final-night", scene: .school, isPro: true, en: "LAST NIGHT, BEST NIGHT", ja: "最後で最高の夜", zhHans: "最后一晚, 最闪耀", zhHant: "最後一晚, 最閃耀"),

        // Travel / Sign
        template(id: "travel-this-way", scene: .travel, isPro: false, en: "THIS WAY", ja: "こっちです", zhHans: "往这边", zhHant: "往這邊"),
        template(id: "travel-photo-here", scene: .travel, isPro: false, en: "PHOTO HERE", ja: "ここで撮ろう", zhHans: "这里拍照", zhHant: "這裡拍照"),
        template(id: "travel-wait-here", scene: .travel, isPro: false, en: "WAIT HERE", ja: "ここで待って", zhHans: "在这里等", zhHant: "在這裡等"),
        template(id: "travel-next-stop", scene: .travel, isPro: false, en: "NEXT STOP", ja: "次の目的地", zhHans: "下一站", zhHant: "下一站"),
        template(id: "travel-hotel", scene: .travel, isPro: false, en: "HOTEL SHUTTLE", ja: "ホテル送迎", zhHans: "酒店接驳", zhHant: "酒店接駁"),
        template(id: "travel-group", scene: .travel, isPro: false, en: "GROUP MEETUP", ja: "集合場所", zhHans: "集合地点", zhHant: "集合地點"),
        template(id: "travel-lost", scene: .travel, isPro: true, en: "LOST BUT CUTE", ja: "迷子だけど元気", zhHans: "迷路但可爱", zhHant: "迷路但可愛"),
        template(id: "travel-gate", scene: .travel, isPro: true, en: "GATE CHANGE", ja: "搭乗口変更", zhHans: "登机口变更", zhHant: "登機口變更"),

        // Oshi / Kawaii
        template(id: "oshi-look", scene: .oshi, isPro: false, en: "LOOK THIS WAY", ja: "見て!", zhHans: "看这里!", zhHant: "看這裡!"),
        template(id: "oshi-daisuki", scene: .oshi, isPro: false, en: "DAISUKI", ja: "だいすき", zhHans: "最喜欢", zhHant: "最喜歡"),
        template(id: "oshi-saikou", scene: .oshi, isPro: false, en: "SAIKOU!", ja: "最高!", zhHans: "最高!", zhHant: "最高!"),
        template(id: "oshi-win", scene: .oshi, isPro: false, en: "OSHIKATSU WIN", ja: "推ししか勝たん", zhHans: "推し最强", zhHant: "推し最強"),
        template(id: "oshi-kocchi", scene: .oshi, isPro: false, en: "OVER HERE (＾▽＾)", ja: "こっちだよ (＾▽＾)", zhHans: "这边哦 (＾▽＾)", zhHant: "這邊喔 (＾▽＾)"),
        template(id: "oshi-today", scene: .oshi, isPro: false, en: "TODAY IS YOURS", ja: "今日も優勝", zhHans: "今天也赢了", zhHant: "今天也贏了"),
        template(id: "oshi-fan-service", scene: .oshi, isPro: true, en: "FAN SERVICE PLEASE", ja: "ファンサください", zhHans: "求个饭撒", zhHant: "求個飯撒"),
        template(id: "oshi-heart", scene: .oshi, isPro: true, en: "HEART POSE? (ㅅ´ ˘ `)", ja: "ハートして? (ㅅ´ ˘ `)", zhHans: "比个心? (ㅅ´ ˘ `)", zhHant: "比個心? (ㅅ´ ˘ `)")
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

private func template(
    id: String,
    scene: BannerScene,
    isPro: Bool,
    en: String,
    ja: String,
    zhHans: String,
    zhHant: String? = nil
) -> BannerTemplate {
    let copy = BannerTemplateCopy(en: en, ja: ja, zhHans: zhHans, zhHant: zhHant)
    return BannerTemplate(
        id: id,
        scene: scene,
        isPro: isPro,
        localizedTitleCopy: copy,
        localizedTextCopy: copy
    )
}
