import Foundation
import SwiftUI

enum L10n {
    static func key(_ value: String) -> LocalizedStringKey {
        LocalizedStringKey(value)
    }

    static func string(_ key: String, locale: Locale) -> String {
        localizedBundle(for: locale).localizedString(forKey: key, value: nil, table: nil)
    }

    static func format(_ key: String, locale: Locale, _ arguments: CVarArg...) -> String {
        String(format: string(key, locale: locale), locale: locale, arguments: arguments)
    }

    private static func localizedBundle(for locale: Locale) -> Bundle {
        let identifier = supportedLocalizationIdentifier(for: locale.identifier)
        guard
            let path = Bundle.main.path(forResource: identifier, ofType: "lproj"),
            let bundle = Bundle(path: path)
        else {
            return .main
        }
        return bundle
    }

    private static func supportedLocalizationIdentifier(for identifier: String) -> String {
        let normalized = identifier.replacingOccurrences(of: "_", with: "-").lowercased()

        if normalized.hasPrefix("zh-hant")
            || normalized.hasPrefix("zh-tw")
            || normalized.hasPrefix("zh-hk")
            || normalized.hasPrefix("zh-mo") {
            return "zh-Hant"
        }

        if normalized.hasPrefix("zh-hans")
            || normalized.hasPrefix("zh-cn")
            || normalized.hasPrefix("zh-sg")
            || normalized.hasPrefix("zh") {
            return "zh-Hans"
        }

        if normalized.hasPrefix("en") {
            return "en"
        }

        if normalized.hasPrefix("ja") {
            return "ja"
        }

        return "en"
    }

    enum Tab {
        static let home = "tab.home"
        static let favorites = "tab.favorites"
        static let settings = "tab.settings"
    }

    enum Common {
        static let cancel = "common.cancel"
        static let more = "common.more"
        static let reset = "common.reset"
        static let resetDefault = "common.reset_default"
        static let use = "common.use"
        static let favorite = "common.favorite"
        static let free = "common.free"
        static let pro = "common.pro"
        static let premiumStyle = "common.premium_style"
        static let speed = "common.speed"
        static let size = "common.size"
    }

    enum Language {
        static let title = "settings.language.title"
        static let subtitle = "settings.language.subtitle"
        static let system = "settings.language.system"
        static let zhHans = "settings.language.zh_hans"
        static let zhHant = "settings.language.zh_hant"
        static let english = "settings.language.english"
        static let japanese = "settings.language.japanese"
        static let followSystemDetail = "settings.language.follow_system_detail"
        static let manualDetail = "settings.language.manual_detail"
        static let currentSystemFormat = "settings.language.current_system_format"
        static let changed = "settings.language.changed"
    }

    enum Settings {
        static let title = "settings.title"
        static let placeholderMessage = "settings.placeholder.message"
        static let displayGroup = "settings.group.display"
        static let otherGroup = "settings.group.other"
        static let aboutGroup = "settings.group.about"
        static let defaultTextColor = "settings.default_text_color"
        static let defaultBackgroundColor = "settings.default_background_color"
        static let defaultTextSize = "settings.default_text_size"
        static let defaultScrollSpeed = "settings.default_scroll_speed"
        static let autoRotate = "settings.auto_rotate"
        static let keepAwake = "settings.keep_awake"
        static let language = "settings.language"
        static let clearCache = "settings.clear_cache"
        static let rateUs = "settings.rate_us"
        static let shareMessage = "settings.share_message"
        static let shareToFriends = "settings.share_to_friends"
        static let help = "settings.help"
        static let aboutApp = "settings.about_app"
        static let privacyPolicy = "settings.privacy_policy"
        static let terms = "settings.terms"
        static let restorePurchase = "settings.restore_purchase"
        static let version = "settings.version"
        static let reset = "settings.reset"
        static let speedSlow = "settings.speed.slow"
        static let speedMedium = "settings.speed.medium"
        static let speedFast = "settings.speed.fast"

        enum Alert {
            static let clearCacheTitle = "settings.alert.clear_cache.title"
            static let clearTemporary = "settings.alert.clear_cache.clear_temporary"
            static let clearWithFavorites = "settings.alert.clear_cache.clear_with_favorites"
            static let clearCacheMessage = "settings.alert.clear_cache.message"
        }

        enum Toast {
            static let displaySettingsReset = "settings.toast.display_settings_reset"
            static let transientCleared = "settings.toast.transient_cleared"
            static let transientAndFavoritesCleared = "settings.toast.transient_and_favorites_cleared"
            static let proUnlocked = "settings.toast.pro_unlocked"
            static let appStoreUnavailable = "settings.toast.app_store_unavailable"
            static let debugReviewPromptEnabled = "settings.toast.debug_review_prompt_enabled"
            static let debugReviewPromptReset = "settings.toast.debug_review_prompt_reset"
        }

        enum Debug {
            static let group = "settings.debug.group"
            static let triggerReviewPrompt = "settings.debug.trigger_review_prompt"
        }
    }

    enum Home {
        static let appName = "home.app_name"
        static let tagline = "home.tagline"
        static let heroLedReady = "home.hero_pill.led_ready"
        static let heroLiveMode = "home.hero_pill.live_mode"
        static let heroTemplates = "home.hero_pill.templates"
        static let placeholderMessage = "home.placeholder.message"
        static let inputPlaceholder = "home.input.placeholder"
        static let inputExample = "home.input.example"
        static let hotTemplates = "home.section.hot_templates"
        static let styleSelection = "home.section.style_selection"
        static let startDisplay = "home.start_display"

        enum ReviewPrompt {
            static let title = "home.review_prompt.title"
            static let rate = "home.review_prompt.rate"
            static let neverAgain = "home.review_prompt.never_again"
            static let message = "home.review_prompt.message"
        }

        enum Toast {
            static let inputFavoriteFirst = "home.toast.input_favorite_first"
            static let inputDisplayFirst = "home.toast.input_display_first"
            static let favoriteAdded = "home.toast.favorite_added"
            static let favoriteUpdated = "home.toast.favorite_updated"
            static let favoriteLimitFormat = "home.toast.favorite_limit_format"
            static let appStoreUnavailable = "home.toast.app_store_unavailable"
        }
    }

    enum Favorites {
        static let title = "favorites.title"
        static let placeholderMessage = "favorites.placeholder.message"
        static let edit = "favorites.edit"
        static let done = "favorites.done"
        static let emptyTitle = "favorites.empty.title"
        static let emptyMessage = "favorites.empty.message"
        static let goHome = "favorites.empty.go_home"
        static let speedSizeFormat = "favorites.item.speed_size_format"
        static let deleteAll = "favorites.delete_all"

        enum Alert {
            static let deleteAllTitle = "favorites.alert.delete_all.title"
            static let deleteAllMessage = "favorites.alert.delete_all.message"
        }

        enum Toast {
            static let deletedAll = "favorites.toast.deleted_all"
        }
    }

    enum MoreFeatures {
        static let title = "more.title"
        static let subtitle = "more.subtitle"
        static let basicTools = "more.section.basic_tools"
        static let stylePicker = "more.feature.style_picker"
        static let stylePickerSubtitle = "more.feature.style_picker.subtitle"
        static let templateCenter = "more.feature.template_center"
        static let templateCenterSubtitle = "more.feature.template_center.subtitle"
        static let textColor = "more.feature.text_color"
        static let textColorSubtitle = "more.feature.text_color.subtitle"
        static let backgroundColor = "more.feature.background_color"
        static let backgroundColorSubtitle = "more.feature.background_color.subtitle"
        static let fontPicker = "more.feature.font_picker"
        static let fontPickerSubtitle = "more.feature.font_picker.subtitle"
        static let displaySettings = "more.feature.display_settings"
        static let displaySettingsSubtitle = "more.feature.display_settings.subtitle"
        static let placeholderMessage = "more.placeholder.message"
    }

    enum TemplateCenter {
        static let title = "template_center.title"
        static let subtitle = "template_center.subtitle"

        enum Toast {
            static let favoriteAdded = "template_center.toast.favorite_added"
            static let favoriteUpdated = "template_center.toast.favorite_updated"
            static let templateEmpty = "template_center.toast.template_empty"
            static let favoriteLimitFormat = "template_center.toast.favorite_limit_format"
        }
    }

    enum StylePicker {
        static let title = "style_picker.title"
        static let subtitleUnlocked = "style_picker.subtitle.unlocked"
        static let subtitleLocked = "style_picker.subtitle.locked"
        static let filter = "style_picker.filter"
        static let filterAll = "style_picker.filter.all"
        static let filterFree = "style_picker.filter.free"
        static let filterPremium = "style_picker.filter.premium"
        static let proTeaserTitle = "style_picker.pro_teaser.title"
        static let proTeaserSubtitle = "style_picker.pro_teaser.subtitle"
        static let proTeaserAction = "style_picker.pro_teaser.action"
    }

    enum Appearance {
        static let textColorTitle = "appearance.text_color.title"
        static let textColorSubtitle = "appearance.text_color.subtitle"
        static let backgroundColorTitle = "appearance.background_color.title"
        static let backgroundColorSubtitle = "appearance.background_color.subtitle"
        static let fontTitle = "appearance.font.title"
        static let fontSubtitle = "appearance.font.subtitle"
        static let preview = "appearance.preview"
        static let previewMessage = "appearance.preview.message"
    }

    enum DisplaySettings {
        static let title = "display_settings.title"
        static let subtitle = "display_settings.subtitle"
        static let basicParameters = "display_settings.group.basic_parameters"
        static let playback = "display_settings.group.playback"
        static let textSize = "display_settings.text_size"
        static let scrollSpeed = "display_settings.scroll_speed"
        static let scrollDirection = "display_settings.scroll_direction"
        static let mirror = "display_settings.mirror"
        static let blink = "display_settings.blink"
        static let resetAll = "display_settings.reset_all"

        enum Direction {
            static let rightToLeft = "display_settings.direction.right_to_left"
            static let leftToRight = "display_settings.direction.left_to_right"
        }

        enum Alert {
            static let resetTitle = "display_settings.alert.reset.title"
            static let resetMessage = "display_settings.alert.reset.message"
        }
    }

    enum DisplayPreview {
        enum Toast {
            static let favoriteRemoved = "display_preview.toast.favorite_removed"
            static let favoriteAdded = "display_preview.toast.favorite_added"
            static let favoriteUpdated = "display_preview.toast.favorite_updated"
            static let inputFavoriteFirst = "display_preview.toast.input_favorite_first"
            static let favoriteLimitFormat = "display_preview.toast.favorite_limit_format"
        }
    }

    enum DisplayEffect {
        enum BulletFlyIn {
            static let lookHereFormat = "display_effect.bullet_fly_in.look_here_format"
            static let call = "display_effect.bullet_fly_in.call"
        }
    }

    enum BannerScene {
        static let concert = "banner_scene.concert"
        static let confession = "banner_scene.confession"
        static let birthday = "banner_scene.birthday"
        static let pickup = "banner_scene.pickup"
        static let fun = "banner_scene.fun"
        static let sports = "banner_scene.sports"
        static let school = "banner_scene.school"
        static let travel = "banner_scene.travel"
        static let oshi = "banner_scene.oshi"
    }

    enum BannerFontStyle {
        static let roundedHeavy = "banner_font.rounded_heavy"
        static let classicHeavy = "banner_font.classic_heavy"
        static let neonTitle = "banner_font.neon_title"
        static let monoBold = "banner_font.mono_bold"
        static let cuteRounded = "banner_font.cute_rounded"
        static let regular = "banner_font.regular"
    }

    enum Template {
        static func title(_ id: String) -> String {
            "template.\(id).title"
        }

        static func text(_ id: String) -> String {
            "template.\(id).text"
        }
    }

    enum Style {
        static func name(_ id: String) -> String {
            "style.\(id).name"
        }

        static func preview(_ id: String) -> String {
            "style.\(id).preview"
        }
    }

    enum StylePreview {
        static let bulletLookHere = "style_preview.bullet.look_here"
        static let bulletLove = "style_preview.bullet.love"
        static let bulletCall = "style_preview.bullet.call"
    }

    enum Purchase {
        static let productFallbackName = "purchase.product_fallback_name"

        enum Error {
            static let productLoadFailed = "purchase.error.product_load_failed"
            static let productLoadFailedNetwork = "purchase.error.product_load_failed_network"
            static let productMismatch = "purchase.error.product_mismatch"
            static let purchaseRevoked = "purchase.error.purchase_revoked"
            static let userCancelled = "purchase.error.user_cancelled"
            static let purchasePending = "purchase.error.purchase_pending"
            static let purchaseFailed = "purchase.error.purchase_failed"
            static let restoreNotFound = "purchase.error.restore_not_found"
            static let restoreFailedNetwork = "purchase.error.restore_failed_network"
            static let verificationFailed = "purchase.error.verification_failed"
            static let networkFailed = "purchase.error.network_failed"
            static let unverifiedTransaction = "purchase.error.unverified_transaction"
        }
    }

    enum Pro {
        static let title = "pro.title"
        static let subtitle = "pro.subtitle"
        static let heroBadgeEffects = "pro.hero_badge.effects"
        static let heroBadgeTemplates = "pro.hero_badge.templates"
        static let heroBadgeSavedLooks = "pro.hero_badge.saved_looks"
        static let finePrint = "pro.fine_print"
        static let restorePurchase = "pro.restore_purchase"
        static let later = "pro.later"
        static let purchasing = "pro.purchasing"
        static let loadingProduct = "pro.loading_product"
        static let reloadProduct = "pro.reload_product"
        static let unlockForever = "pro.unlock_forever"
        static let unlockForeverPriceFormat = "pro.unlock_forever_price_format"
        static let purchaseSuccess = "pro.purchase_success"
        static let productLoadFailed = "pro.product_load_failed"

        enum Benefit {
            static let allEffects = "pro.benefit.all_effects"
            static let unlimitedFavorites = "pro.benefit.unlimited_favorites"
            static let premiumTemplates = "pro.benefit.premium_templates"
            static let premiumFonts = "pro.benefit.premium_fonts"
            static let customStyleSave = "pro.benefit.custom_style_save"
            static let futureUpdates = "pro.benefit.future_updates"
        }

        enum Context {
            static let homeTitle = "pro.context.home.title"
            static let styleTitleFormat = "pro.context.style.title_format"
            static let templateTitleFormat = "pro.context.template.title_format"
            static let fontTitleFormat = "pro.context.font.title_format"
            static let favoriteLimitTitle = "pro.context.favorite_limit.title"
            static let favoriteProStyleTitle = "pro.context.favorite_pro_style.title"
            static let moreFeatureTitleFormat = "pro.context.more_feature.title_format"
            static let settingsRestoreTitle = "pro.context.settings_restore.title"
            static let homeSubtitle = "pro.context.home.subtitle"
            static let styleSubtitle = "pro.context.style.subtitle"
            static let templateSubtitle = "pro.context.template.subtitle"
            static let fontSubtitle = "pro.context.font.subtitle"
            static let favoriteLimitSubtitle = "pro.context.favorite_limit.subtitle"
            static let favoriteProStyleSubtitle = "pro.context.favorite_pro_style.subtitle"
            static let moreFeatureSubtitle = "pro.context.more_feature.subtitle"
            static let settingsRestoreSubtitle = "pro.context.settings_restore.subtitle"
        }

        enum Success {
            static let title = "pro.success.title"
            static let subtitle = "pro.success.subtitle"
            static let message = "pro.success.message"
            static let start = "pro.success.start"
        }

        enum Debug {
            static let title = "pro.debug.title"
            static let productLoaded = "pro.debug.product_loaded"
            static let productNotLoaded = "pro.debug.product_not_loaded"
            static let unknown = "pro.debug.unknown"
            static let environmentHintTitle = "pro.debug.environment_hint.title"
            static let environmentHintValue = "pro.debug.environment_hint.value"
            static let refresh = "pro.debug.refresh"
            static let resetCache = "pro.debug.reset_cache"
        }
    }

    enum Help {
        static let title = "help.title"
        static let subtitle = "help.subtitle"
        static let makeBannerTitle = "help.item.make_banner.title"
        static let makeBannerMessage = "help.item.make_banner.message"
        static let concertTitle = "help.item.concert.title"
        static let concertMessage = "help.item.concert.message"
        static let keepAwakeTitle = "help.item.keep_awake.title"
        static let keepAwakeMessage = "help.item.keep_awake.message"
        static let landscapeTitle = "help.item.landscape.title"
        static let landscapeMessage = "help.item.landscape.message"
        static let favoriteTitle = "help.item.favorite.title"
        static let favoriteMessage = "help.item.favorite.message"
    }

    enum About {
        static let title = "about.title"
        static let appName = "about.app_name"
        static let versionFormat = "about.version_format"
        static let description = "about.description"
    }

    enum Legal {
        static let privacyTitle = "legal.privacy.title"
        static let termsTitle = "legal.terms.title"
        static let privacySubtitle = "legal.privacy.subtitle"
        static let termsSubtitle = "legal.terms.subtitle"
        static let privacyLocalFirst = "legal.privacy.local_first"
        static let privacyStorage = "legal.privacy.storage"
        static let privacyClearCache = "legal.privacy.clear_cache"
        static let privacyProUnlocked = "legal.privacy.pro_unlocked"
        static let privacyProLocked = "legal.privacy.pro_locked"
        static let termsEntertainment = "legal.terms.entertainment"
        static let termsPublicSafety = "legal.terms.public_safety"
        static let termsProUnlocked = "legal.terms.pro_unlocked"
        static let termsProUnlockedRestore = "legal.terms.pro_unlocked_restore"
        static let termsProLockedPurchase = "legal.terms.pro_locked_purchase"
        static let termsProLockedRestore = "legal.terms.pro_locked_restore"
    }
}
