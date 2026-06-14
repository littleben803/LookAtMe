import Combine
import SwiftUI

@MainActor
final class HomeViewModel: ObservableObject {
    static let textLimit = 20

    @Published var text: String = ""
    @Published var selectedScene: BannerScene = .concert
    @Published var selectedStyle: BannerStyle
    @Published var toastMessage: String?
    @Published var isShowingDisplayPreview = false
    @Published var isShowingMore = false

    private let templateStore: TemplateStore
    private let styleStore: StyleStore

    init() {
        let templateStore = TemplateStore()
        let styleStore = StyleStore()
        self.templateStore = templateStore
        self.styleStore = styleStore
        self.selectedStyle = styleStore.styles[0]
    }

    var templates: [BannerTemplate] {
        templateStore.templates(for: selectedScene)
    }

    var styles: [BannerStyle] {
        styleStore.styles
    }

    var currentDraft: BannerDraft {
        BannerDraft(
            text: trimmedText,
            selectedScene: selectedScene,
            selectedStyle: selectedStyle,
            textColorHex: LookTheme.Hex.primaryPink,
            backgroundColorHex: LookTheme.Hex.backgroundBlack,
            fontScale: 1.0,
            speed: 1.0,
            fontStyle: .roundedHeavy,
            scrollDirection: .rightToLeft,
            isMirrored: false,
            isBlinking: false
        )
    }

    func selectScene(_ scene: BannerScene) {
        selectedScene = scene
    }

    func applyTemplate(_ template: BannerTemplate) {
        text = String(template.text.prefix(Self.textLimit))
    }

    func selectStyle(_ style: BannerStyle) {
        if style.isPro {
            showToast("Pro 功能暂未接入")
            return
        }
        selectedStyle = style
    }

    func startDisplay() {
        guard !trimmedText.isEmpty else {
            showToast("先输入一句想说的话")
            return
        }
        isShowingDisplayPreview = true
    }

    func showProEntryPlaceholder() {
        showToast("Pro 功能暂未接入")
    }

    func showMorePlaceholder() {
        isShowingMore = true
    }

    func showToast(_ message: String) {
        toastMessage = message
    }

    private var trimmedText: String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
