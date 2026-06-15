import Foundation

struct ProPaywallContext: Identifiable {
    let id = UUID()
    let source: ProPaywallSource
    let onUnlocked: @MainActor () -> Void

    init(source: ProPaywallSource, onUnlocked: @escaping @MainActor () -> Void = {}) {
        self.source = source
        self.onUnlocked = onUnlocked
    }
}

enum ProPaywallSource {
    case homePro
    case style(name: String)
    case template(name: String)
    case premiumFont(name: String)
    case favoriteLimit
    case favoriteProStyle
    case moreFeature(name: String)
    case settingsRestore

    var promptTitle: String {
        switch self {
        case .homePro:
            "解锁全部高级灯牌"
        case .style(let name):
            "解锁「\(name)」"
        case .template(let name):
            "解锁「\(name)」模板"
        case .premiumFont(let name):
            "解锁「\(name)」字体"
        case .favoriteLimit:
            "解锁无限收藏"
        case .favoriteProStyle:
            "解锁收藏里的 Pro 样式"
        case .moreFeature(let name):
            "解锁「\(name)」"
        case .settingsRestore:
            "恢复想恋爱 Pro"
        }
    }

    var promptSubtitle: String {
        switch self {
        case .homePro:
            "高级样式、模板、字体和无限收藏一次解锁。"
        case .style:
            "购买后会自动回到刚才选择的高级样式。"
        case .template:
            "购买后会自动使用刚才选择的高级模板。"
        case .premiumFont:
            "购买后会自动应用刚才选择的高级字体。"
        case .favoriteLimit:
            "免费版最多保存 5 条收藏，Pro 可无限保存。"
        case .favoriteProStyle:
            "购买后会自动应用这条收藏。"
        case .moreFeature:
            "购买后即可使用全部 Pro 增强能力。"
        case .settingsRestore:
            "如果你已经购买过，可以直接恢复购买。"
        }
    }
}

extension BannerFontStyle {
    var isPro: Bool {
        switch self {
        case .neonTitle, .monoBold, .cuteRounded:
            true
        case .roundedHeavy, .classicHeavy, .regular:
            false
        }
    }
}
