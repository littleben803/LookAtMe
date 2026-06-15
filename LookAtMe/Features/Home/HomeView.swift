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

    @State private var path: [FeatureRoute] = []
    @State private var toastMessage: String?
    @State private var isShowingDisplayPreview = false
    @State private var measuredHeights: [HomeMeasuredRegion: CGFloat] = [:]
    @State private var isHeroFireworksActive = false

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
            }
            .onDisappear {
                isHeroFireworksActive = false
            }
        }
        .overlay(alignment: .top) {
            if let toastMessage {
                ToastView(message: toastMessage)
                    .padding(.top, LookSpacing.lg)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.28, dampingFraction: 0.86), value: toastMessage)
        .onChange(of: toastMessage) { _, message in
            guard message != nil else { return }
            Task { @MainActor in
                try? await Task.sleep(for: .seconds(1.7))
                toastMessage = nil
            }
        }
        .fullScreenCover(isPresented: $isShowingDisplayPreview) {
            LEDDisplayPreviewView(draft: displayConfigStore.draft(styleStore: styleStore))
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
                displayConfigStore.applyTemplate(template)
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
                    Color(hex: "#05040B").opacity(0.98),
                    Color(hex: "#05040B").opacity(0.9),
                    Color(hex: "#05040B").opacity(0.0)
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

            HeroFireworksOverlay(isActive: isHeroFireworksActive, topSafeArea: topSafeArea)
                .allowsHitTesting(false)

            VStack(spacing: 8) {
                Spacer(minLength: 0)

                HStack(spacing: 10) {
                    Text("想恋爱")
                        .font(.system(size: 42, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color(hex: "#FFE1F5"),
                                    LookTheme.Colors.primaryPink,
                                    Color(hex: "#FF89D2")
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: LookTheme.Colors.primaryPink.opacity(0.95), radius: 11)
                        .shadow(color: LookTheme.Colors.primaryPink.opacity(0.55), radius: 24)

                    Image(systemName: "heart")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(LookTheme.Colors.primaryPink)
                        .rotationEffect(.degrees(-14))
                        .shadow(color: LookTheme.Colors.primaryPink.opacity(0.9), radius: 9)
                }

                HStack(spacing: 8) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 8, weight: .bold))
                    Text("让全世界看到你的爱")
                    Image(systemName: "heart.fill")
                        .font(.system(size: 8, weight: .bold))
                }
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(LookTheme.Colors.softPink)
                .shadow(color: LookTheme.Colors.primaryPink.opacity(0.5), radius: 7)

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.top, 18)
            .padding(.bottom, 18)
            .offset(y: max(20, topSafeArea * 0.44))

            Button {
                showToast("Pro 功能将在下一阶段接入")
            } label: {
                HStack(spacing: 3) {
                    Image(systemName: "crown.fill")
                    Text("Pro")
                }
                .font(.system(size: 11, weight: .heavy, design: .rounded))
                .foregroundColor(LookTheme.Colors.warmYellow)
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(
                    Capsule()
                        .fill(Color.black.opacity(0.58))
                        .overlay(Capsule().stroke(LookTheme.Colors.warmYellow.opacity(0.45), lineWidth: 0.8))
                )
                .shadow(color: LookTheme.Colors.warmYellow.opacity(0.32), radius: 8)
            }
            .buttonStyle(.plain)
            .padding(.top, max(30, topSafeArea + 6))
            .padding(.trailing, 12)
        }
        .aspectRatio(1320.0 / 598.0, contentMode: .fit)
        .frame(maxWidth: .infinity)
        .shadow(color: LookTheme.Colors.primaryPink.opacity(0.24), radius: 18, y: 10)
    }

    private var inputSection: some View {
        ZStack(alignment: .topTrailing) {
            NeonTextInput(
                text: $displayConfigStore.text,
                limit: DisplayConfigStore.textLimit,
                placeholder: "输入你想表达的话...",
                example: "例如：周深我爱你！ 💗"
            )

            Button {
                favoriteCurrentDraft()
            } label: {
                Image(systemName: favoriteStore.isFavorite(draft: displayConfigStore.draft(styleStore: styleStore)) ? "heart.fill" : "heart")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(LookTheme.Colors.primaryPink)
                    .frame(width: 28, height: 28)
                    .background(Circle().fill(Color.black.opacity(0.36)))
                    .overlay(Circle().stroke(LookTheme.Colors.primaryPink.opacity(0.38), lineWidth: 0.8))
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
                    title: scene.title,
                    systemImage: scene.symbolName,
                    tint: scene.accentColor,
                    isSelected: displayConfigStore.selectedScene == scene
                ) {
                    displayConfigStore.selectScene(scene)
                }
            }

            SceneShortcutButton(
                title: "更多",
                systemImage: "square.grid.2x2.fill",
                tint: LookTheme.Colors.neonPurple,
                isSelected: false
            ) {
                path.append(.more)
            }
        }
        .padding(.top, 1)
    }

    private var templatesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            homeSectionHeader("热门模板 🔥") {
                path.append(.templateCenter)
            }

            LazyVGrid(columns: templateColumns, spacing: 10) {
                ForEach(homeTemplates) { template in
                    TemplateChip(title: template.title) {
                        displayConfigStore.applyTemplate(template)
                    }
                }
            }
        }
        .padding(.top, 2)
    }

    private func stylesSection(layout: HomeBodyLayout) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            homeSectionHeader("样式选择") {
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
                        showsAccessTag: true
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
        let minimumSecondRowVisibleRatio: CGFloat = 1.0 / 3.0
        let secondRowVisibilityTolerance: CGFloat = 6

        let sceneHeight = measuredHeight(.sceneShortcuts, fallback: 78)
        let templatesHeight = measuredHeight(.templatesSection, fallback: 116)
        let stylesHeaderHeight = measuredHeight(.stylesHeader, fallback: 26)
        let startButtonBarHeight = measuredHeight(.startButtonBar, fallback: 72)

        let contentWidth = max(0, availableWidth - horizontalPadding * 2)
        let styleItemWidth = max(62, (contentWidth - styleColumnSpacing * 3) / 4)
        let styleGridTop =
            topPadding +
            sectionSpacing * 2 +
            sceneHeight +
            templatesHeight +
            styleSectionTopPadding +
            stylesHeaderHeight +
            styleSectionSpacing +
            styleGridVerticalPadding / 2

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

        let twoRowTargetGridHeight = max(minimumItemHeight * 2 + styleRowSpacing, availableHeight - fixedBodyHeight)
        let twoRowItemHeight = max(minimumItemHeight, (twoRowTargetGridHeight - styleRowSpacing) / 2)
        let secondRowTop = styleGridTop + twoRowItemHeight + styleRowSpacing
        let buttonOverlayTop = max(0, availableHeight - startButtonBarHeight)
        let secondRowVisibleHeight = max(0, min(twoRowItemHeight, buttonOverlayTop - secondRowTop))
        let shouldCollapseToSingleRow = secondRowVisibleHeight < twoRowItemHeight * minimumSecondRowVisibleRatio + secondRowVisibilityTolerance

        let styleRowCount = shouldCollapseToSingleRow ? 1 : 2
        let effectiveHeight = shouldCollapseToSingleRow ? max(0, availableHeight - startButtonBarHeight) : availableHeight
        let targetGridHeight = max(
            minimumItemHeight * CGFloat(styleRowCount) + styleRowSpacing * CGFloat(max(0, styleRowCount - 1)),
            effectiveHeight - fixedBodyHeight
        )
        let styleItemHeight = styleRowCount == 1
            ? targetGridHeight
            : max(minimumItemHeight, (targetGridHeight - styleRowSpacing) / 2)
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
                Text("开始展示")
                    .font(.system(size: 22, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)

                HStack {
                    Spacer()
                    Image(systemName: "play.fill")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(LookTheme.Colors.primaryPink)
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
                        LookTheme.Colors.primaryPink,
                        Color(hex: "#FF6DBE")
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color.white.opacity(0.12), lineWidth: 1))
            .shadow(color: LookTheme.Colors.primaryPink.opacity(0.48), radius: 16, y: 6)
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
                        Color(hex: "#05040B").opacity(0.0),
                        Color(hex: "#05040B").opacity(0.88),
                        Color(hex: "#05040B").opacity(0.96)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
    }

    private var homeTemplates: [BannerTemplate] {
        guard displayConfigStore.selectedScene == .concert else {
            return templateStore.homeTemplates(for: displayConfigStore.selectedScene)
        }

        return [
            BannerTemplate(id: "home-target-zhou-shen", title: "周深我爱你!💗", scene: .concert, text: "周深我爱你!💗", isPro: false),
            BannerTemplate(id: "home-target-an-yi", title: "宝贝我爱你💋", scene: .concert, text: "宝贝我爱你💋", isPro: false),
            BannerTemplate(id: "home-target-birthday", title: "生日快乐🎂", scene: .concert, text: "生日快乐🎂", isPro: false),
            BannerTemplate(id: "home-target-here", title: "这里这里!✋", scene: .concert, text: "这里这里!✋", isPro: false),
            BannerTemplate(id: "home-target-star", title: "宝儿姐💘", scene: .concert, text: "宝儿姐💘", isPro: false),
            BannerTemplate(id: "home-target-call", title: "加油打CALL🎉", scene: .concert, text: "加油打CALL🎉", isPro: false)
        ]
    }

    private func homeSectionHeader(_ title: String, action: @escaping () -> Void) -> some View {
        HStack(alignment: .center) {
            Text(title)
                .font(.system(size: 18, weight: .heavy, design: .rounded))
                .foregroundColor(LookTheme.Colors.textPrimary)
                .shadow(color: LookTheme.Colors.primaryPink.opacity(0.28), radius: 6)

            Spacer()

            Button(action: action) {
                HStack(spacing: 2) {
                    Text("更多")
                    Image(systemName: "chevron.right")
                        .font(.system(size: 9, weight: .bold))
                }
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundColor(LookTheme.Colors.textTertiary.opacity(0.7))
            }
            .buttonStyle(.plain)
        }
    }

    private func selectStyle(_ style: BannerStyle) {
        displayConfigStore.selectStyle(style)
    }

    private func favoriteCurrentDraft() {
        guard !displayConfigStore.trimmedText.isEmpty else {
            showToast("先输入一句想收藏的话")
            return
        }
        favoriteStore.addFavorite(from: displayConfigStore.draft(styleStore: styleStore))
        showToast("已收藏")
    }

    private func startDisplay() {
        guard !displayConfigStore.trimmedText.isEmpty else {
            showToast("先输入一句想说的话")
            return
        }
        isShowingDisplayPreview = true
    }

    private func showToast(_ message: String) {
        toastMessage = message
    }
}

private struct HomeStageBackground: View {
    var body: some View {
        ZStack {
            Color(hex: "#05040B")

            RadialGradient(
                colors: [
                    LookTheme.Colors.primaryPink.opacity(0.28),
                    LookTheme.Colors.neonPurple.opacity(0.16),
                    .clear
                ],
                center: .topLeading,
                startRadius: 20,
                endRadius: 360
            )
            .offset(x: -40, y: -40)

            RadialGradient(
                colors: [
                    LookTheme.Colors.electricBlue.opacity(0.12),
                    LookTheme.Colors.neonPurple.opacity(0.1),
                    .clear
                ],
                center: .bottomTrailing,
                startRadius: 20,
                endRadius: 420
            )

            LinearGradient(
                colors: [
                    Color.black.opacity(0.18),
                    Color(hex: "#12051F").opacity(0.6),
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
        Image("HomeHeroStage")
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
}
