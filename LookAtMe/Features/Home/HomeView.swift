import SwiftUI

private enum HomeMeasuredRegion: Hashable {
    case sceneShortcuts
    case templatesSection
    case stylesHeader
    case startButtonBar
}

private struct HomeMeasuredHeightKey: PreferenceKey {
    static var defaultValue: [HomeMeasuredRegion: CGFloat] = [:]

    static func reduce(value: inout [HomeMeasuredRegion: CGFloat], nextValue: () -> [HomeMeasuredRegion: CGFloat]) {
        value.merge(nextValue()) { _, newValue in newValue }
    }
}

private struct HomeBodyLayout {
    let horizontalPadding: CGFloat
    let topPadding: CGFloat
    let bottomPadding: CGFloat
    let sectionSpacing: CGFloat
    let styleColumnSpacing: CGFloat
    let styleRowSpacing: CGFloat
    let styleRowCount: Int
    let styleItemWidth: CGFloat
    let styleItemHeight: CGFloat
    let stylePreviewHeight: CGFloat

    var styleGridHeight: CGFloat {
        styleItemHeight * CGFloat(styleRowCount) + styleRowSpacing * CGFloat(max(0, styleRowCount - 1))
    }

    var visibleStyleCount: Int {
        styleRowCount * 4
    }
}

struct HomeView: View {
    @EnvironmentObject private var templateStore: TemplateStore
    @EnvironmentObject private var styleStore: StyleStore
    @EnvironmentObject private var displayConfigStore: DisplayConfigStore
    @EnvironmentObject private var favoriteStore: FavoriteStore
    @EnvironmentObject private var settingsStore: SettingsStore
    @EnvironmentObject private var purchaseManager: PurchaseManager
    @EnvironmentObject private var appReviewPromptStore: AppReviewPromptStore
    @EnvironmentObject private var devicePerformanceStore: DevicePerformanceStore
    @Environment(\.lookSkin) private var skin

    @State private var path: [FeatureRoute] = []
    @State private var toastMessage: String?
    @State private var isShowingDisplayPreview = false
    @State private var isShowingReviewPrompt = false
    @State private var measuredHeights: [HomeMeasuredRegion: CGFloat] = [:]
    @State private var isHeroFireworksActive = false
    @State private var paywallContext: ProPaywallContext?

    private let templateColumns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]
    var body: some View {
        NavigationStack(path: $path) {
            GeometryReader { proxy in
                ZStack {
                    HomeStageBackground()

                    VStack(spacing: 0) {
                        headerSection(topSafeArea: proxy.safeAreaInsets.top)
                        bodyScroll(availableWidth: proxy.size.width)
                    }
                }
                .ignoresSafeArea(.container, edges: .top)
                .onPreferenceChange(HomeMeasuredHeightKey.self) { values in
                    measuredHeights.merge(values) { _, newValue in newValue }
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: FeatureRoute.self) { route in
                destination(for: route)
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                startButtonBar
                    .measureHomeHeight(.startButtonBar)
            }
            .onAppear {
                isHeroFireworksActive = true
                ensureSelectedStyleIsAvailable()
                ensureSelectedFontIsAvailable()
#if DEBUG
                if LookDebugOptions.isDebugEntryPointEnabled {
                    presentReviewPromptIfNeeded()
                }
#endif
            }
            .onDisappear {
                isHeroFireworksActive = false
            }
        }
        .lookToast($toastMessage)
        .alert(localized(L10n.Home.ReviewPrompt.title), isPresented: $isShowingReviewPrompt) {
            Button(localized(L10n.Home.ReviewPrompt.rate)) {
                AppReviewLink.openWriteReviewPage(onFailure: {
                    showToast(localized(L10n.Home.Toast.appStoreUnavailable))
                })
            }
            Button(localized(L10n.Home.ReviewPrompt.neverAgain), role: .cancel) {}
        } message: {
            Text(L10n.key(L10n.Home.ReviewPrompt.message))
        }
        .fullScreenCover(isPresented: $isShowingDisplayPreview, onDismiss: presentReviewPromptIfNeeded) {
            LEDDisplayPreviewView(draft: displayConfigStore.draft(styleStore: styleStore))
        }
        .fullScreenCover(item: $paywallContext) { context in
            ProPaywallView(context: context)
        }
    }

    @ViewBuilder
    private func destination(for route: FeatureRoute) -> some View {
        switch route {
        case .more:
            MoreFeaturesView()
        case .stylePicker:
            StylePickerView()
        case .templateCenter:
            TemplateCenterView { template in
                displayConfigStore.applyTemplate(template, locale: settingsStore.appLanguage.locale)
                path.removeAll()
            }
        case .textColor:
            TextColorPickerView()
        case .backgroundColor:
            BackgroundColorPickerView()
        case .fontPicker:
            FontPickerView()
        case .displaySettings:
            DisplaySettingsView()
        case .languageSettings:
            LanguageSettingsView()
#if DEBUG
        case .debugThemeSettings:
            DebugThemeSettingsView()
#endif
        case .help:
            HelpView()
        case .about:
            AboutView()
        case .legal(let document):
            LegalTextView(document: document)
        }
    }

    private func headerSection(topSafeArea: CGFloat) -> some View {
        VStack(spacing: 10) {
            heroBanner(topSafeArea: topSafeArea)

            inputSection
                .padding(.horizontal, 20)
                .padding(.top, -12)
        }
        .padding(.bottom, 12)
        .background(
            LinearGradient(
                colors: [
                    skin.background.opacity(0.98),
                    skin.background.opacity(0.9),
                    skin.background.opacity(0.0)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }

    private func bodyScroll(availableWidth: CGFloat) -> some View {
        GeometryReader { proxy in
            let bodyHeight = max(0, proxy.size.height)
            let layout = bodyLayout(availableHeight: bodyHeight, availableWidth: availableWidth)

            ScrollView(showsIndicators: false) {
                VStack(spacing: layout.sectionSpacing) {
                    sceneShortcuts
                        .measureHomeHeight(.sceneShortcuts)
                    templatesSection
                        .measureHomeHeight(.templatesSection)
                    stylesSection(layout: layout)
                }
                .padding(.horizontal, layout.horizontalPadding)
                .padding(.top, layout.topPadding)
                .padding(.bottom, layout.bottomPadding)
                .frame(minHeight: bodyHeight, alignment: .top)
            }
        }
    }

    private func heroBanner(topSafeArea: CGFloat) -> some View {
        ZStack(alignment: .topTrailing) {
            HeroStageBackdrop()

            if devicePerformanceStore.profile.enablesHomeFireworks {
                HeroFireworksOverlay(isActive: isHeroFireworksActive, topSafeArea: topSafeArea)
                    .allowsHitTesting(false)
            }

            VStack(spacing: skin.isNeonUtilityPro ? 7 : 8) {
                Spacer(minLength: max(12, topSafeArea * 0.22))

                HStack(spacing: 8) {
                    Image(systemName: skin.chrome.sectionSymbol)
                        .font(.system(size: 13, weight: .black, design: .rounded))
                        .foregroundColor(skin.secondary)
                        .frame(width: 26, height: 26)
                        .background(Circle().fill(Color.black.opacity(0.42)))
                        .overlay(Circle().stroke(skin.secondary.opacity(0.42), lineWidth: 0.8))

                    Text(L10n.key(L10n.Home.appName))
                        .font(.system(size: skin.isNeonUtilityPro ? 26 : 29, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    skin.textPrimary,
                                    skin.primary,
                                    skin.secondary.opacity(0.88)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: skin.primary.opacity(0.95), radius: 11)
                        .shadow(color: skin.secondary.opacity(0.36), radius: 24)
                        .lineLimit(1)

                    Spacer(minLength: 0)

                    Text(L10n.key(L10n.Home.tagline))
                        .font(.system(size: 11, weight: .heavy, design: .rounded))
                        .foregroundColor(skin.textSecondary.opacity(0.86))
                        .lineLimit(1)
                        .minimumScaleFactor(0.68)
                }
                .padding(.horizontal, 18)

                HomeHeroDisplayPanel(text: heroPreviewText)
                    .padding(.horizontal, 18)

                HStack(spacing: 6) {
                    HomeHeroPill(title: L10n.Home.heroLedReady, systemImage: "textformat.size")
                    HomeHeroPill(title: L10n.Home.heroLiveMode, systemImage: "dot.radiowaves.left.and.right")
                    HomeHeroPill(title: L10n.Home.heroTemplates, systemImage: "square.grid.2x2.fill")
                }
                .padding(.top, 2)

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.top, max(12, topSafeArea * 0.28))
            .padding(.bottom, 14)

            if !purchaseManager.isProUnlocked {
                Button {
                    showPaywall(.homePro)
                } label: {
                    HStack(spacing: 3) {
                        Image(systemName: "crown.fill")
                        Text(L10n.key(L10n.Common.pro))
                    }
                    .font(.system(size: 11, weight: .heavy, design: .rounded))
                    .foregroundColor(skin.pro)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(
                        Capsule()
                            .fill(Color.black.opacity(0.58))
                            .overlay(Capsule().stroke(skin.pro.opacity(0.45), lineWidth: 0.8))
                    )
                    .shadow(color: skin.pro.opacity(0.32), radius: 8)
                }
                .buttonStyle(.plain)
                .padding(.top, max(30, topSafeArea + 6))
                .padding(.trailing, 12)
            }
        }
        .aspectRatio(1320.0 / 598.0, contentMode: .fit)
        .frame(maxWidth: .infinity)
        .shadow(color: skin.primary.opacity(0.24), radius: 18, y: 10)
    }

    private var inputSection: some View {
        ZStack(alignment: .topTrailing) {
            NeonTextInput(
                text: $displayConfigStore.text,
                limit: DisplayConfigStore.textLimit,
                placeholder: L10n.Home.inputPlaceholder,
                example: L10n.Home.inputExample
            )

            Button {
                favoriteCurrentDraft()
            } label: {
                Image(systemName: favoriteStore.isFavorite(draft: displayConfigStore.draft(styleStore: styleStore)) ? "heart.fill" : "heart")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(skin.primary)
                    .frame(width: 28, height: 28)
                    .background(Circle().fill(Color.black.opacity(0.36)))
                    .overlay(Circle().stroke(skin.primary.opacity(0.38), lineWidth: 0.8))
            }
            .buttonStyle(.plain)
            .padding(.top, 9)
            .padding(.trailing, 10)
        }
    }

    private var sceneShortcuts: some View {
        HStack(spacing: 8) {
            ForEach(BannerScene.homeCases) { scene in
                SceneShortcutButton(
                    title: scene.titleKey,
                    systemImage: scene.symbolName,
                    tint: scene.accentColor,
                    isSelected: displayConfigStore.selectedScene == scene
                ) {
                    displayConfigStore.selectScene(scene)
                }
            }

            SceneShortcutButton(
                title: L10n.Common.more,
                systemImage: "square.grid.2x2.fill",
                tint: skin.secondary,
                isSelected: false
            ) {
                path.append(.more)
            }
        }
        .padding(.top, 1)
    }

    private var templatesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            homeSectionHeader(L10n.Home.hotTemplates) {
                path.append(.templateCenter)
            }

            LazyVGrid(columns: templateColumns, spacing: 10) {
                ForEach(homeTemplates) { template in
                    TemplateChip(
                        title: template.localizedTitle(locale: settingsStore.appLanguage.locale),
                        isPro: template.isPro && !purchaseManager.isProUnlocked
                    ) {
                        applyTemplate(template)
                    }
                }
            }
        }
        .padding(.top, 2)
    }

    private func stylesSection(layout: HomeBodyLayout) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            homeSectionHeader(L10n.Home.styleSelection) {
                path.append(.stylePicker)
            }
            .measureHomeHeight(.stylesHeader)

            LazyVGrid(
                columns: styleGridColumns(itemWidth: layout.styleItemWidth, spacing: layout.styleColumnSpacing),
                spacing: layout.styleRowSpacing
            ) {
                ForEach(Array(styleStore.styles.prefix(layout.visibleStyleCount))) { style in
                    StyleCard(
                        style: style,
                        isSelected: displayConfigStore.selectedStyleID == style.id,
                        previewColor: Color(hex: displayConfigStore.textColorHex),
                        fontStyle: displayConfigStore.fontStyle,
                        isCompact: true,
                        compactPreviewHeight: layout.stylePreviewHeight,
                        showsAccessTag: !purchaseManager.isProUnlocked,
                        isLocked: isStyleLocked(style),
                        previewLocale: settingsStore.appLanguage.locale
                    ) {
                        selectStyle(style)
                    }
                    .frame(width: layout.styleItemWidth, height: layout.styleItemHeight)
                }
            }
            .frame(height: layout.styleGridHeight)
            .padding(.vertical, 2)
        }
        .padding(.top, 2)
    }

    private func bodyLayout(availableHeight: CGFloat, availableWidth: CGFloat) -> HomeBodyLayout {
        let horizontalPadding: CGFloat = 20
        let topPadding: CGFloat = 4
        let bottomPadding: CGFloat = 6
        let sectionSpacing: CGFloat = 14
        let styleColumnSpacing: CGFloat = 10
        let styleRowSpacing: CGFloat = 12
        let styleSectionTopPadding: CGFloat = 2
        let styleSectionSpacing: CGFloat = 10
        let styleGridVerticalPadding: CGFloat = 4
        let styleTitleAndSpacing: CGFloat = 24
        let minimumItemHeight: CGFloat = 88
        let singleRowMaximumWidth: CGFloat = 375

        let sceneHeight = measuredHeight(.sceneShortcuts, fallback: 78)
        let templatesHeight = measuredHeight(.templatesSection, fallback: 116)
        let stylesHeaderHeight = measuredHeight(.stylesHeader, fallback: 26)

        let contentWidth = max(0, availableWidth - horizontalPadding * 2)
        let styleItemWidth = max(62, (contentWidth - styleColumnSpacing * 3) / 4)
        let fixedBodyHeight =
            topPadding +
            bottomPadding +
            sectionSpacing * 2 +
            sceneHeight +
            templatesHeight +
            styleSectionTopPadding +
            styleSectionSpacing +
            stylesHeaderHeight +
            styleGridVerticalPadding

        let shouldCollapseToSingleRow = availableWidth <= singleRowMaximumWidth
        let styleRowCount = shouldCollapseToSingleRow ? 1 : 2
        let targetGridHeight = max(
            minimumItemHeight * CGFloat(styleRowCount) + styleRowSpacing * CGFloat(max(0, styleRowCount - 1)),
            availableHeight - fixedBodyHeight
        )
        let styleItemHeight = max(
            minimumItemHeight,
            (targetGridHeight - styleRowSpacing * CGFloat(max(0, styleRowCount - 1))) / CGFloat(styleRowCount)
        )
        let stylePreviewHeight = max(62, styleItemHeight - styleTitleAndSpacing)

        return HomeBodyLayout(
            horizontalPadding: horizontalPadding,
            topPadding: topPadding,
            bottomPadding: bottomPadding,
            sectionSpacing: sectionSpacing,
            styleColumnSpacing: styleColumnSpacing,
            styleRowSpacing: styleRowSpacing,
            styleRowCount: styleRowCount,
            styleItemWidth: styleItemWidth,
            styleItemHeight: styleItemHeight,
            stylePreviewHeight: stylePreviewHeight
        )
    }

    private func styleGridColumns(itemWidth: CGFloat, spacing: CGFloat) -> [GridItem] {
        [
            GridItem(.fixed(itemWidth), spacing: spacing),
            GridItem(.fixed(itemWidth), spacing: spacing),
            GridItem(.fixed(itemWidth), spacing: spacing),
            GridItem(.fixed(itemWidth), spacing: spacing)
        ]
    }

    private func measuredHeight(_ region: HomeMeasuredRegion, fallback: CGFloat) -> CGFloat {
        measuredHeights[region].flatMap { $0 > 0 ? $0 : nil } ?? fallback
    }

    private var startButton: some View {
        Button {
            startDisplay()
        } label: {
            ZStack {
                Text(L10n.key(L10n.Home.startDisplay))
                    .font(.system(size: 22, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)

                HStack {
                    Spacer()
                    Image(systemName: "play.fill")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(skin.primary)
                        .frame(width: 42, height: 42)
                        .background(Circle().fill(Color.white))
                        .shadow(color: Color.white.opacity(0.42), radius: 8)
                }
                .padding(.trailing, 8)
            }
            .frame(maxWidth: .infinity, minHeight: 58)
            .background(
                LinearGradient(
                    colors: [
                        Color(hex: "#FF2E8F"),
                        skin.primary,
                        skin.secondary.opacity(0.78)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color.white.opacity(0.12), lineWidth: 1))
            .shadow(color: skin.primary.opacity(0.48), radius: 16, y: 6)
        }
        .buttonStyle(.plain)
    }

    private var startButtonBar: some View {
        startButton
            .padding(.horizontal, 22)
            .padding(.top, 4)
            .padding(.bottom, 10)
            .background(
                LinearGradient(
                    colors: [
                        skin.background.opacity(0.0),
                        skin.background.opacity(0.88),
                        skin.background.opacity(0.96)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
    }

    private var homeTemplates: [BannerTemplate] {
        templateStore.homeTemplates(for: displayConfigStore.selectedScene)
    }

    private var heroPreviewText: String {
        let trimmedText = displayConfigStore.trimmedText
        return trimmedText.isEmpty ? localized(L10n.Home.inputExample) : trimmedText
    }

    private func homeSectionHeader(_ title: String, action: @escaping () -> Void) -> some View {
        HStack(alignment: .center) {
            HStack(spacing: 7) {
                Image(systemName: skin.chrome.sectionSymbol)
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .foregroundColor(skin.secondary)

                Text(L10n.key(title))
                    .font(.system(size: 18, weight: .heavy, design: .rounded))
                    .foregroundColor(skin.textPrimary)
                    .shadow(color: skin.primary.opacity(0.28), radius: 6)
            }

            Spacer()

            Button(action: action) {
                HStack(spacing: 2) {
                    Text(L10n.key(L10n.Common.more))
                    Image(systemName: "chevron.right")
                        .font(.system(size: 9, weight: .bold))
                }
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundColor(skin.textTertiary.opacity(0.76))
            }
            .buttonStyle(.plain)
        }
    }

    private func selectStyle(_ style: BannerStyle) {
        guard purchaseManager.canUse(style) else {
            showPaywall(.style(nameKey: style.nameKey)) {
                selectStyle(style)
            }
            return
        }
        displayConfigStore.selectStyle(style)
    }

    private func favoriteCurrentDraft() {
        guard !displayConfigStore.trimmedText.isEmpty else {
            showToast(localized(L10n.Home.Toast.inputFavoriteFirst))
            return
        }
        let result = favoriteStore.addFavorite(
            from: displayConfigStore.draft(styleStore: styleStore),
            isProUnlocked: purchaseManager.isProUnlocked
        )
        handleFavoriteResult(result) {
            favoriteCurrentDraft()
        }
    }

    private func startDisplay() {
        guard !displayConfigStore.trimmedText.isEmpty else {
            showToast(localized(L10n.Home.Toast.inputDisplayFirst))
            return
        }
        let selectedStyle = styleStore.style(withID: displayConfigStore.selectedStyleID)
        guard purchaseManager.canUse(selectedStyle) else {
            showPaywall(.style(nameKey: selectedStyle.nameKey)) {
                startDisplay()
            }
            return
        }
        guard purchaseManager.canUse(displayConfigStore.fontStyle) else {
            showPaywall(.premiumFont(titleKey: displayConfigStore.fontStyle.titleKey)) {
                startDisplay()
            }
            return
        }
        appReviewPromptStore.recordSuccessfulDisplayStart()
        isShowingDisplayPreview = true
    }

    private func presentReviewPromptIfNeeded() {
        guard appReviewPromptStore.consumeAutomaticPromptIfEligible() else {
            return
        }

        isShowingReviewPrompt = true
    }

    private func applyTemplate(_ template: BannerTemplate) {
        guard purchaseManager.canUse(template) else {
            showPaywall(.template(title: template.localizedTitle(locale: settingsStore.appLanguage.locale))) {
                applyTemplate(template)
            }
            return
        }
        displayConfigStore.applyTemplate(template, locale: settingsStore.appLanguage.locale)
    }

    private func ensureSelectedStyleIsAvailable() {
        let selectedStyle = styleStore.style(withID: displayConfigStore.selectedStyleID)
        guard isStyleLocked(selectedStyle), let freeStyle = styleStore.freeStyles.first else {
            return
        }
        displayConfigStore.selectStyle(freeStyle)
    }

    private func ensureSelectedFontIsAvailable() {
        guard !purchaseManager.canUse(displayConfigStore.fontStyle) else {
            return
        }
        displayConfigStore.fontStyle = .roundedHeavy
    }

    private func isStyleLocked(_ style: BannerStyle) -> Bool {
        style.isPro && !purchaseManager.isProUnlocked
    }

    private func handleFavoriteResult(_ result: FavoriteAddResult, retryAfterUnlock: @escaping @MainActor () -> Void) {
        switch result {
        case .freeLimitReached:
            showPaywall(.favoriteLimit, onUnlocked: retryAfterUnlock)
        case .added, .updatedExisting, .ignoredEmptyText:
            showToast(message(for: result))
        }
    }

    private func message(for result: FavoriteAddResult) -> String {
        switch result {
        case .added:
            localized(L10n.Home.Toast.favoriteAdded)
        case .updatedExisting:
            localized(L10n.Home.Toast.favoriteUpdated)
        case .ignoredEmptyText:
            localized(L10n.Home.Toast.inputFavoriteFirst)
        case .freeLimitReached(let limit):
            L10n.format(L10n.Home.Toast.favoriteLimitFormat, locale: settingsStore.appLanguage.locale, limit)
        }
    }

    private func localized(_ key: String) -> String {
        L10n.string(key, locale: settingsStore.appLanguage.locale)
    }

    private func showToast(_ message: String) {
        toastMessage = message
    }

    private func showPaywall(_ source: ProPaywallSource, onUnlocked: @escaping @MainActor () -> Void = {}) {
        purchaseManager.clearTransientState()
        paywallContext = ProPaywallContext(source: source, onUnlocked: onUnlocked)
    }
}

private struct HomeHeroDisplayPanel: View {
    let text: String
    @Environment(\.lookSkin) private var skin

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: skin.chrome.controlRadius + 8, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.black.opacity(0.82),
                            skin.backgroundElevated.opacity(0.88)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: skin.chrome.controlRadius + 8, style: .continuous)
                        .stroke(skin.neonBorderGradient, lineWidth: 1.1)
                )

            heroAccentLayer
                .clipShape(RoundedRectangle(cornerRadius: skin.chrome.controlRadius + 8, style: .continuous))

            HStack(spacing: 10) {
                Image(systemName: skin.chrome.homePreviewSymbol)
                    .font(.system(size: skin.isLiveStageConsole ? 16 : 15, weight: .black, design: .rounded))
                    .foregroundColor(skin.secondary)
                    .frame(width: 30, height: 30)
                    .background(Circle().fill(skin.secondary.opacity(0.13)))
                    .overlay(Circle().stroke(skin.secondary.opacity(0.34), lineWidth: 0.8))

                Text(text)
                    .font(.system(size: skin.isNeonUtilityPro ? 25 : 28, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [skin.textPrimary, skin.primary, skin.pro.opacity(0.92)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .lineLimit(1)
                    .minimumScaleFactor(0.48)
                    .shadow(color: skin.primary.opacity(0.95), radius: 8)
                    .shadow(color: skin.secondary.opacity(0.42), radius: 18)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 12)
        }
        .frame(height: skin.isNeonUtilityPro ? 56 : 62)
        .shadow(color: skin.primary.opacity(0.32), radius: 16, y: 7)
    }

    @ViewBuilder
    private var heroAccentLayer: some View {
        if skin.isOshiPopNeon {
            HStack {
                Spacer()
                ForEach(0..<4, id: \.self) { index in
                    Image(systemName: index.isMultiple(of: 2) ? "heart.fill" : "sparkle")
                        .font(.system(size: CGFloat(9 + index * 2), weight: .black, design: .rounded))
                        .foregroundColor(index.isMultiple(of: 2) ? skin.primary.opacity(0.32) : skin.pro.opacity(0.3))
                        .rotationEffect(.degrees(Double(index * 13 - 18)))
                }
            }
            .padding(.trailing, 14)
        } else if skin.isLiveStageConsole {
            HStack(alignment: .bottom, spacing: 5) {
                Spacer()
                ForEach(0..<9, id: \.self) { index in
                    Capsule()
                        .fill(index.isMultiple(of: 2) ? skin.secondary.opacity(0.28) : skin.primary.opacity(0.24))
                        .frame(width: 4, height: CGFloat(14 + (index % 4) * 7))
                        .shadow(color: skin.secondary.opacity(0.22), radius: 6)
                }
            }
            .padding(.trailing, 18)
            .padding(.bottom, 10)
        } else {
            ZStack(alignment: .trailing) {
                UtilityHeroGrid()
                    .stroke(skin.secondary.opacity(0.16), lineWidth: 0.7)

                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [.clear, skin.accent.opacity(0.22), .clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 88)
                    .blendMode(.plusLighter)
            }
        }
    }
}

private struct UtilityHeroGrid: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let step: CGFloat = 18
        var x = rect.minX
        while x <= rect.maxX {
            path.move(to: CGPoint(x: x, y: rect.minY))
            path.addLine(to: CGPoint(x: x, y: rect.maxY))
            x += step
        }

        var y = rect.minY
        while y <= rect.maxY {
            path.move(to: CGPoint(x: rect.minX, y: y))
            path.addLine(to: CGPoint(x: rect.maxX, y: y))
            y += step
        }
        return path
    }
}

private struct HomeHeroPill: View {
    let title: String
    let systemImage: String
    @Environment(\.lookSkin) private var skin

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: systemImage)
                .font(.system(size: 8.5, weight: .black, design: .rounded))

            Text(L10n.key(title))
                .font(.system(size: 9.5, weight: .black, design: .rounded))
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
        .foregroundColor(skin.textPrimary.opacity(0.92))
        .padding(.horizontal, 7)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(Color.black.opacity(0.36))
                .overlay(
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [
                                    skin.primary.opacity(0.18),
                                    skin.secondary.opacity(0.08)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
        )
        .overlay(
            Capsule()
                .stroke(
                    LinearGradient(
                        colors: [
                            skin.textSecondary.opacity(0.5),
                            skin.secondary.opacity(0.25)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.8
                )
        )
        .shadow(color: skin.primary.opacity(0.22), radius: 8)
    }
}

private struct HomeStageBackground: View {
    @Environment(\.lookSkin) private var skin

    var body: some View {
        ZStack {
            Image(skin.assets.appBackground)
                .resizable()
                .scaledToFill()
                .opacity(skin.chrome.backgroundImageOpacity)
                .overlay(skin.background.opacity(skin.isLiveStageConsole ? 0.56 : 0.62))

            RadialGradient(
                colors: [
                    skin.primary.opacity(0.18),
                    skin.secondary.opacity(0.1),
                    .clear
                ],
                center: .topLeading,
                startRadius: 20,
                endRadius: 360
            )
            .offset(x: -40, y: -40)

            RadialGradient(
                colors: [
                    skin.secondary.opacity(0.12),
                    skin.accent.opacity(0.08),
                    .clear
                ],
                center: .bottomTrailing,
                startRadius: 20,
                endRadius: 420
            )

            LinearGradient(
                colors: [
                    Color.black.opacity(0.18),
                    skin.backgroundElevated.opacity(0.58),
                    Color.black.opacity(0.72)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .ignoresSafeArea()
    }
}

private struct HeroStageBackdrop: View {
    @Environment(\.lookSkin) private var skin

    var body: some View {
        GeometryReader { proxy in
            heroImage(width: proxy.size.width, height: proxy.size.height)
                .clipped()
                .mask(
                    LinearGradient(
                        stops: [
                            .init(color: .black, location: 0.0),
                            .init(color: .black, location: 0.68),
                            .init(color: .black.opacity(0.72), location: 0.82),
                            .init(color: .black.opacity(0.0), location: 1.0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        }
    }

    private func heroImage(width: CGFloat, height: CGFloat) -> some View {
        Image(skin.assets.homeHero)
            .resizable()
            .scaledToFill()
            .frame(width: width, height: height)
    }
}

private struct HeroFireworksOverlay: View {
    let isActive: Bool
    let topSafeArea: CGFloat

    var body: some View {
        GeometryReader { proxy in
            if isActive {
                TimelineView(.animation) { timeline in
                    let seconds = timeline.date.timeIntervalSinceReferenceDate
                    let animationTopOffset = min(max(topSafeArea * 0.35, 18), 28)
                    let animationHeight = max(1, proxy.size.height - animationTopOffset)

                    ZStack {
                        ZStack {
                            ForEach(0..<5, id: \.self) { index in
                                firework(
                                    index: index,
                                    seconds: seconds,
                                    width: proxy.size.width,
                                    height: animationHeight
                                )
                            }

                            driftingSparkles(seconds: seconds, width: proxy.size.width, height: animationHeight)
                        }
                        .frame(width: proxy.size.width, height: animationHeight)
                        .clipped()
                        .offset(y: animationTopOffset)
                    }
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .clipped()
                }
            }
        }
    }

    private func firework(index: Int, seconds: TimeInterval, width: CGFloat, height: CGFloat) -> some View {
        let interval = 1.25 + Double(index % 3) * 0.18
        let raw = seconds / interval + Double(index) * 0.31
        let cycle = floor(raw)
        let local = raw - cycle
        let seed = Int(cycle) * 67 + index * 29
        let center = CGPoint(
            x: width * (0.18 + randomUnit(seed) * 0.66),
            y: height * (0.14 + randomUnit(seed + 11) * 0.38)
        )
        let intensity = burstIntensity(local)

        return ZStack {
            burstHalo(local: local, intensity: intensity, color: fireworkColor(index: index, seed: seed))

            ForEach(0..<22, id: \.self) { particleIndex in
                particle(
                    burstIndex: index,
                    particleIndex: particleIndex,
                    local: local,
                    intensity: intensity,
                    maxDistance: min(width, height) * (0.13 + randomUnit(seed + particleIndex) * 0.05),
                    seed: seed
                )
            }

            Circle()
                .fill(LookTheme.Colors.textPrimary.opacity(0.42 * intensity))
                .frame(width: 9 + CGFloat(intensity) * 10, height: 9 + CGFloat(intensity) * 10)
                .blur(radius: 1.2)
                .shadow(color: fireworkColor(index: index, seed: seed).opacity(0.85 * intensity), radius: 16)
        }
        .position(center)
        .opacity(local < 0.84 ? 1 : 0)
        .blendMode(.plusLighter)
    }

    private func particle(
        burstIndex: Int,
        particleIndex: Int,
        local: Double,
        intensity: Double,
        maxDistance: CGFloat,
        seed: Int
    ) -> some View {
        let angle = Double(particleIndex) / 22 * .pi * 2 + randomDouble(seed + particleIndex * 7) * 0.35
        let eased = smoothStep(min(1, local / 0.72))
        let distance = maxDistance * CGFloat(eased)
        let x = cos(angle) * distance
        let y = sin(angle) * distance + CGFloat(local * local) * 18
        let color = particleColor(index: particleIndex + burstIndex, seed: seed)

        return Capsule()
            .fill(
                LinearGradient(
                    colors: [
                        LookTheme.Colors.textPrimary.opacity(0.92),
                        color.opacity(0.96),
                        .clear
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(width: 16 + CGFloat(particleIndex % 4) * 4, height: 3.2)
            .rotationEffect(.radians(angle))
            .offset(x: x, y: y)
            .opacity(intensity)
            .shadow(color: color.opacity(0.82 * intensity), radius: 10)
    }

    private func burstHalo(local: Double, intensity: Double, color: Color) -> some View {
        let size = CGFloat(32 + smoothStep(local) * 132)
        return ZStack {
            Circle()
                .stroke(color.opacity(0.48 * intensity), lineWidth: 1.2)
                .frame(width: size, height: size)
                .blur(radius: 0.8)

            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            color.opacity(0.26 * intensity),
                            LookTheme.Colors.textPrimary.opacity(0.1 * intensity),
                            .clear
                        ],
                        center: .center,
                        startRadius: 2,
                        endRadius: max(42, size * 0.56)
                    )
                )
                .frame(width: size * 0.8, height: size * 0.8)
                .blur(radius: 7)
        }
    }

    private func driftingSparkles(seconds: TimeInterval, width: CGFloat, height: CGFloat) -> some View {
        ZStack {
            ForEach(0..<18, id: \.self) { index in
                let phase = normalized(seconds * (0.05 + Double(index % 4) * 0.012) + Double(index) * 0.09)
                let twinkle = 0.5 + 0.5 * sin((seconds * 0.9 + Double(index) * 0.37) * .pi * 2)

                Image(systemName: "sparkle")
                    .font(.system(size: 5 + CGFloat(index % 3) * 2, weight: .bold))
                    .foregroundStyle(particleColor(index: index, seed: index * 17))
                    .position(
                        x: width * CGFloat((index * 37 + 13) % 100) / 100,
                        y: height * (0.1 + CGFloat(phase) * 0.56)
                    )
                    .opacity(0.12 + twinkle * 0.34)
                    .shadow(color: particleColor(index: index, seed: index * 17).opacity(0.48), radius: 7)
            }
        }
    }

    private func burstIntensity(_ local: Double) -> Double {
        let attack = smoothStep(min(1, local / 0.18))
        let release = max(0, 1 - smoothStep(max(0, (local - 0.16) / 0.62)))
        return attack * release
    }

    private func fireworkColor(index: Int, seed: Int) -> Color {
        particleColor(index: index, seed: seed)
    }

    private func particleColor(index: Int, seed: Int) -> Color {
        switch (index + seed) % 5 {
        case 0:
            LookTheme.Colors.primaryPink
        case 1:
            LookTheme.Colors.warmYellow
        case 2:
            LookTheme.Colors.electricBlue
        case 3:
            LookTheme.Colors.softPink
        default:
            LookTheme.Colors.neonPurple
        }
    }

    private func smoothStep(_ value: Double) -> Double {
        let clamped = min(1, max(0, value))
        return clamped * clamped * (3 - 2 * clamped)
    }

    private func normalized(_ value: Double) -> Double {
        let progress = value.truncatingRemainder(dividingBy: 1)
        return progress >= 0 ? progress : progress + 1
    }

    private func randomUnit(_ seed: Int) -> CGFloat {
        CGFloat(randomDouble(seed))
    }

    private func randomDouble(_ seed: Int) -> Double {
        let value = sin(Double(seed) * 12.9898) * 43758.5453
        return value - floor(value)
    }
}

private extension View {
    func measureHomeHeight(_ region: HomeMeasuredRegion) -> some View {
        background(
            GeometryReader { proxy in
                Color.clear.preference(
                    key: HomeMeasuredHeightKey.self,
                    value: [region: proxy.size.height]
                )
            }
        )
    }
}

#Preview {
    HomeView()
        .environmentObject(TemplateStore())
        .environmentObject(StyleStore())
        .environmentObject(DisplayConfigStore())
        .environmentObject(FavoriteStore())
        .environmentObject(SettingsStore())
        .environmentObject(PurchaseManager(autoStart: false))
        .environmentObject(AppReviewPromptStore())
        .environmentObject(DevicePerformanceStore())
}
