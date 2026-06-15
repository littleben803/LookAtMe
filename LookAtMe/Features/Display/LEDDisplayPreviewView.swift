import SwiftUI
import UIKit

struct LEDDisplayPreviewView: View {
    let draft: BannerDraft

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var favoriteStore: FavoriteStore
    @EnvironmentObject private var settingsStore: SettingsStore
    @EnvironmentObject private var purchaseManager: PurchaseManager
    @State private var isPlaying = true
    @State private var speed: Double
    @State private var fontScale: Double
    @State private var isOperationLayerVisible = true
    @State private var operationLayerHideTask: Task<Void, Never>?
    @State private var orientationRefreshTask: Task<Void, Never>?
    @State private var viewportSize: CGSize = .zero
    @State private var layoutRefreshID = 0
    @State private var toastMessage: String?
    @State private var paywallContext: ProPaywallContext?

    init(draft: BannerDraft) {
        self.draft = draft
        self._speed = State(initialValue: draft.speed)
        self._fontScale = State(initialValue: draft.fontScale)
    }

    var body: some View {
        GeometryReader { proxy in
            let effectContext = LEDDisplayEffectContext(
                draft: draft,
                isPlaying: isPlaying,
                speed: speed,
                fontScale: fontScale,
                viewportSize: proxy.size,
                safeAreaInsets: proxy.safeAreaInsets,
                layoutRefreshID: layoutRefreshID
            )

            ZStack {
                ZStack {
                    displayBackground

                    LEDDisplayEffectRenderer(context: effectContext)
                }

                operationLayer(size: proxy.size, safeAreaInsets: proxy.safeAreaInsets)
                    .id(layoutRefreshID)

                InterfaceOrientationSyncView(allowsLandscape: settingsStore.autoRotate) {
                    scheduleOrientationLayoutRefresh()
                }
                .frame(width: 0, height: 0)
                .allowsHitTesting(false)

                if let toastMessage {
                    VStack {
                        ToastView(message: toastMessage)
                            .padding(.top, operationLayerTopPadding(size: proxy.size, safeAreaInsets: proxy.safeAreaInsets))
                        Spacer()
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .onAppear {
                applyOrientationPreference()
                applyIdleTimerPreference()
                handleViewportSizeChange(proxy.size)
                showOperationLayer()
            }
            .onDisappear {
                operationLayerHideTask?.cancel()
                orientationRefreshTask?.cancel()
                UIApplication.shared.isIdleTimerDisabled = false
                AppOrientationDelegate.updateSupportedOrientations(.portrait)
            }
            .onChange(of: proxy.size) { _, newSize in
                handleViewportSizeChange(newSize)
            }
            .onChange(of: isPlaying) { _, _ in
                scheduleOperationLayerAutoHide()
            }
            .onChange(of: speed) { _, _ in
                scheduleOperationLayerAutoHide()
            }
            .onChange(of: fontScale) { _, _ in
                scheduleOperationLayerAutoHide()
            }
            .onChange(of: settingsStore.autoRotate) { _, _ in
                applyOrientationPreference()
                scheduleOrientationLayoutRefresh()
            }
            .onChange(of: settingsStore.keepAwake) { _, _ in
                applyIdleTimerPreference()
            }
        }
        .ignoresSafeArea()
        .statusBarHidden()
        .animation(.spring(response: 0.28, dampingFraction: 0.86), value: toastMessage)
        .onChange(of: toastMessage) { _, message in
            guard message != nil else { return }
            Task { @MainActor in
                try? await Task.sleep(for: .seconds(1.4))
                toastMessage = nil
            }
        }
        .fullScreenCover(item: $paywallContext) { context in
            ProPaywallView(context: context)
        }
    }

    private var displayBackground: some View {
        ZStack {
            LinearGradient(
                colors: [
                    draft.backgroundColor,
                    LookTheme.Colors.backgroundPurple,
                    LookTheme.Colors.backgroundBlack
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            RadialGradient(
                colors: [
                    LEDDisplayEffectText.accentColor(for: draft).opacity(0.22),
                    .clear
                ],
                center: .center,
                startRadius: 24,
                endRadius: 280
            )
            .ignoresSafeArea()
        }
    }

    private func topBar(topPadding: CGFloat) -> some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(LookTheme.Colors.textPrimary)
                    .frame(width: 42, height: 42)
                    .background(Circle().fill(LookTheme.Colors.cardPurple.opacity(0.86)))
                    .overlay(Circle().stroke(LookTheme.Colors.primaryPink.opacity(0.42), lineWidth: 1))
            }
            .buttonStyle(.plain)

            Spacer()

            Text(draft.selectedStyle.name)
                .font(LookTypography.caption)
                .foregroundColor(LookTheme.Colors.textTertiary)
                .padding(.horizontal, LookSpacing.sm)
                .padding(.vertical, LookSpacing.xs)
                .background(Capsule().fill(LookTheme.Colors.cardPurple.opacity(0.72)))

            favoriteButton
        }
        .padding(.horizontal, LookSpacing.pageHorizontal)
        .padding(.top, topPadding)
    }

    private var favoriteButton: some View {
        Button {
            toggleCurrentFavorite()
        } label: {
            Image(systemName: favoriteStore.isFavorite(draft: currentDraft) ? "heart.fill" : "heart")
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(LookTheme.Colors.primaryPink)
                .frame(width: 42, height: 42)
                .background(Circle().fill(LookTheme.Colors.cardPurple.opacity(0.86)))
                .overlay(Circle().stroke(LookTheme.Colors.primaryPink.opacity(0.42), lineWidth: 1))
                .shadow(color: LookTheme.Colors.primaryPink.opacity(0.32), radius: 12)
        }
        .buttonStyle(.plain)
    }

    private var currentDraft: BannerDraft {
        var current = draft
        current.speed = speed
        current.fontScale = fontScale
        return current
    }

    private func operationLayer(size: CGSize, safeAreaInsets: EdgeInsets) -> some View {
        let topPadding = operationLayerTopPadding(size: size, safeAreaInsets: safeAreaInsets)
        let bottomPadding = operationLayerBottomPadding(size: size, safeAreaInsets: safeAreaInsets)

        return ZStack {
            if isOperationLayerVisible {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        hideOperationLayer()
                    }

                VStack {
                    topBar(topPadding: topPadding)
                    Spacer()
                    DisplayPreviewControlPanel(
                        isPlaying: $isPlaying,
                        speed: $speed,
                        fontScale: $fontScale
                    )
                    .padding(.horizontal, LookSpacing.pageHorizontal)
                    .padding(.bottom, bottomPadding)
                }
                .transition(.opacity)
            } else {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        showOperationLayer()
                    }
            }
        }
        .ignoresSafeArea()
        .animation(.easeInOut(duration: 0.24), value: isOperationLayerVisible)
    }

    private func operationLayerTopPadding(size: CGSize, safeAreaInsets: EdgeInsets) -> CGFloat {
        guard isPortrait(size) else {
            return LookSpacing.lg
        }

        return max(safeAreaInsets.top, 44) + LookSpacing.lg
    }

    private func operationLayerBottomPadding(size: CGSize, safeAreaInsets: EdgeInsets) -> CGFloat {
        guard isPortrait(size) else {
            return LookSpacing.xl
        }

        return LookSpacing.xl + safeAreaInsets.bottom
    }

    private func isPortrait(_ size: CGSize) -> Bool {
        size.height >= size.width
    }

    private func handleViewportSizeChange(_ size: CGSize) {
        let normalizedSize = CGSize(width: size.width.rounded(), height: size.height.rounded())
        guard abs(normalizedSize.width - viewportSize.width) > 0.5
                || abs(normalizedSize.height - viewportSize.height) > 0.5 else {
            return
        }

        viewportSize = normalizedSize
        refreshLayoutState()
    }

    private func scheduleOrientationLayoutRefresh() {
        orientationRefreshTask?.cancel()
        orientationRefreshTask = Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(140))
            guard !Task.isCancelled else {
                return
            }
            refreshLayoutState()
        }
    }

    private func refreshLayoutState() {
        layoutRefreshID &+= 1
    }

    private func applyOrientationPreference() {
        AppOrientationDelegate.updateSupportedOrientations(settingsStore.autoRotate ? .allButUpsideDown : .portrait)
    }

    private func applyIdleTimerPreference() {
        UIApplication.shared.isIdleTimerDisabled = settingsStore.keepAwake
    }

    private func showOperationLayer() {
        withAnimation(.easeInOut(duration: 0.18)) {
            isOperationLayerVisible = true
        }
        scheduleOperationLayerAutoHide()
    }

    private func hideOperationLayer() {
        operationLayerHideTask?.cancel()
        withAnimation(.easeInOut(duration: 0.24)) {
            isOperationLayerVisible = false
        }
    }

    private func toggleCurrentFavorite() {
        let targetDraft = currentDraft
        if favoriteStore.favoriteID(for: targetDraft) != nil {
            favoriteStore.removeFavorite(matching: targetDraft)
            showToast("已取消收藏")
        } else {
            let result = favoriteStore.addFavorite(from: targetDraft, isProUnlocked: purchaseManager.isProUnlocked)
            handleFavoriteResult(result) {
                toggleCurrentFavorite()
            }
        }
        scheduleOperationLayerAutoHide()
    }

    private func message(for result: FavoriteAddResult) -> String {
        switch result {
        case .added:
            "已收藏当前灯牌"
        case .updatedExisting:
            "已更新收藏"
        case .ignoredEmptyText:
            "先输入一句想收藏的话"
        case .freeLimitReached(let limit):
            "免费版最多收藏 \(limit) 条，Pro 可无限收藏"
        }
    }

    private func showToast(_ message: String) {
        toastMessage = message
    }

    private func handleFavoriteResult(_ result: FavoriteAddResult, retryAfterUnlock: @escaping @MainActor () -> Void) {
        switch result {
        case .freeLimitReached:
            showPaywall(.favoriteLimit, onUnlocked: retryAfterUnlock)
        case .added, .updatedExisting, .ignoredEmptyText:
            showToast(message(for: result))
        }
    }

    private func showPaywall(_ source: ProPaywallSource, onUnlocked: @escaping @MainActor () -> Void = {}) {
        purchaseManager.clearTransientState()
        paywallContext = ProPaywallContext(source: source, onUnlocked: onUnlocked)
    }

    private func scheduleOperationLayerAutoHide() {
        operationLayerHideTask?.cancel()
        guard isOperationLayerVisible else {
            return
        }

        operationLayerHideTask = Task { @MainActor in
            try? await Task.sleep(for: .seconds(3))
            guard !Task.isCancelled else {
                return
            }
            withAnimation(.easeInOut(duration: 0.32)) {
                isOperationLayerVisible = false
            }
        }
    }
}

private struct InterfaceOrientationSyncView: UIViewControllerRepresentable {
    let allowsLandscape: Bool
    let onOrientationChange: () -> Void

    func makeUIViewController(context: Context) -> Controller {
        let controller = Controller()
        controller.allowsLandscape = allowsLandscape
        controller.onOrientationChange = onOrientationChange
        return controller
    }

    func updateUIViewController(_ uiViewController: Controller, context: Context) {
        uiViewController.allowsLandscape = allowsLandscape
        uiViewController.onOrientationChange = onOrientationChange
    }

    final class Controller: UIViewController {
        var allowsLandscape = true {
            didSet {
                guard allowsLandscape != oldValue else {
                    return
                }
                syncInterfaceOrientation()
                onOrientationChange?()
            }
        }

        var onOrientationChange: (() -> Void)?
        private var orientationObserver: NSObjectProtocol?

        override func viewDidLoad() {
            super.viewDidLoad()
            view.backgroundColor = .clear
            UIDevice.current.beginGeneratingDeviceOrientationNotifications()
            orientationObserver = NotificationCenter.default.addObserver(
                forName: UIDevice.orientationDidChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                self?.handleOrientationChange()
            }
        }

        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            syncInterfaceOrientation()
        }

        override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
            super.viewWillTransition(to: size, with: coordinator)
            coordinator.animate(alongsideTransition: nil) { [weak self] _ in
                self?.onOrientationChange?()
            }
        }

        deinit {
            if let orientationObserver {
                NotificationCenter.default.removeObserver(orientationObserver)
            }
            UIDevice.current.endGeneratingDeviceOrientationNotifications()
        }

        private func handleOrientationChange() {
            syncInterfaceOrientation()
            onOrientationChange?()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.16) { [weak self] in
                self?.onOrientationChange?()
            }
        }

        private func syncInterfaceOrientation() {
            guard let orientationMask = Self.orientationMask(for: UIDevice.current.orientation, allowsLandscape: allowsLandscape),
                  let windowScene = view.window?.windowScene else {
                return
            }

            view.window?.rootViewController?.setNeedsUpdateOfSupportedInterfaceOrientations()
            windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: orientationMask)) { _ in }
        }

        private static func orientationMask(
            for orientation: UIDeviceOrientation,
            allowsLandscape: Bool
        ) -> UIInterfaceOrientationMask? {
            guard allowsLandscape else {
                return .portrait
            }

            switch orientation {
            case .portrait, .portraitUpsideDown:
                return .portrait
            case .landscapeLeft, .landscapeRight:
                return .landscape
            default:
                return nil
            }
        }
    }
}

#Preview {
    LEDDisplayPreviewView(
        draft: BannerDraft(
            text: "周深我爱你！💗",
            selectedScene: .concert,
            selectedStyle: StyleStore().styles[0],
            textColorHex: LookTheme.Hex.primaryPink,
            backgroundColorHex: LookTheme.Hex.backgroundBlack,
            fontScale: 1,
            speed: 1,
            fontStyle: .roundedHeavy,
            scrollDirection: .rightToLeft,
            isMirrored: false,
            isBlinking: false
        )
    )
    .environmentObject(FavoriteStore())
    .environmentObject(SettingsStore())
    .environmentObject(PurchaseManager(autoStart: false))
}
