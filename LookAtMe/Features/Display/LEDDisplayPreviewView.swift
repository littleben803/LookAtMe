import SwiftUI
import UIKit

private struct DisplayTextWidthKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

struct LEDDisplayPreviewView: View {
    let draft: BannerDraft

    @Environment(\.dismiss) private var dismiss
    @State private var isPlaying = true
    @State private var speed: Double
    @State private var fontScale: Double
    @State private var marqueeContainerWidth: CGFloat = 0
    @State private var marqueeTextWidth: CGFloat = 0
    @State private var marqueeReferenceProgress: CGFloat = 0
    @State private var marqueeReferenceDate = Date()
    @State private var blinkOpacity: Double = 1
    @State private var isOperationLayerVisible = true
    @State private var operationLayerHideTask: Task<Void, Never>?
    @State private var orientationRefreshTask: Task<Void, Never>?
    @State private var viewportSize: CGSize = .zero
    @State private var layoutRefreshID = 0

    init(draft: BannerDraft) {
        self.draft = draft
        self._speed = State(initialValue: 1.0)
        self._fontScale = State(initialValue: 2.0)
    }

    var body: some View {
        GeometryReader { proxy in
            let marqueeContentWidth = max(1, proxy.size.width)

            ZStack {
                ZStack {
                    displayBackground

                    if draft.selectedStyle.type == .heartRain {
                        heartRainLayer
                    }

                    displayText(width: proxy.size.width, safeAreaInsets: proxy.safeAreaInsets)
                }
                .id(layoutRefreshID)

                operationLayer
                    .id(layoutRefreshID)

                InterfaceOrientationSyncView {
                    scheduleOrientationLayoutRefresh()
                }
                .frame(width: 0, height: 0)
                .allowsHitTesting(false)
            }
            .onAppear {
                AppOrientationDelegate.updateSupportedOrientations(.allButUpsideDown)
                handleViewportSizeChange(proxy.size)
                updateMarqueeContainerWidth(marqueeContentWidth)
                resetMarqueeReference()
                startBlinkingIfNeeded()
                showOperationLayer()
            }
            .onDisappear {
                operationLayerHideTask?.cancel()
                orientationRefreshTask?.cancel()
                AppOrientationDelegate.updateSupportedOrientations(.portrait)
            }
            .onChange(of: proxy.size) { _, newSize in
                handleViewportSizeChange(newSize)
            }
            .onChange(of: marqueeContentWidth) { _, newWidth in
                updateMarqueeContainerWidth(newWidth)
            }
            .onChange(of: isPlaying) { oldValue, playing in
                handlePlaybackChange(wasPlaying: oldValue, isPlaying: playing)
                if playing {
                    startBlinkingIfNeeded()
                } else {
                    resetBlinking()
                }
                scheduleOperationLayerAutoHide()
            }
            .onChange(of: speed) { _, _ in
                syncMarqueeReference()
                scheduleOperationLayerAutoHide()
            }
            .onChange(of: fontScale) { _, _ in
                syncMarqueeReference()
                scheduleOperationLayerAutoHide()
            }
        }
        .ignoresSafeArea()
        .statusBarHidden()
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
                    displayAccentColor.opacity(0.22),
                    .clear
                ],
                center: .center,
                startRadius: 24,
                endRadius: 280
            )
            .ignoresSafeArea()
        }
    }

    private var topBar: some View {
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
        }
        .padding(.horizontal, LookSpacing.pageHorizontal)
        .padding(.top, LookSpacing.lg)
    }

    private var operationLayer: some View {
        ZStack {
            if isOperationLayerVisible {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        hideOperationLayer()
                    }

                VStack {
                    topBar
                    Spacer()
                    DisplayPreviewControlPanel(
                        isPlaying: $isPlaying,
                        speed: $speed,
                        fontScale: $fontScale
                    )
                    .padding(.horizontal, LookSpacing.pageHorizontal)
                    .padding(.bottom, LookSpacing.xl)
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

    @ViewBuilder
    private func displayText(width: CGFloat, safeAreaInsets: EdgeInsets) -> some View {
        let contentWidth = displayContentWidth(totalWidth: width, safeAreaInsets: safeAreaInsets)
        let leadingPadding = safeAreaInsets.leading + LookSpacing.pageHorizontal
        let trailingPadding = safeAreaInsets.trailing + LookSpacing.pageHorizontal

        if draft.selectedStyle.type == .marquee {
            TimelineView(.animation) { timeline in
                styledDisplayText(fixedWidth: true)
                    .background(textWidthReader)
                    .offset(x: marqueeOffset(at: timeline.date))
            }
            .onPreferenceChange(DisplayTextWidthKey.self) { width in
                updateMarqueeTextWidth(width)
            }
            .frame(width: width)
            .frame(maxHeight: .infinity)
            .clipped()
            .frame(maxHeight: .infinity)
        } else {
            styledDisplayText(fixedWidth: false)
                .frame(width: contentWidth)
                .frame(maxHeight: .infinity)
                .padding(.leading, leadingPadding)
                .padding(.trailing, trailingPadding)
                .frame(width: width)
                .frame(maxHeight: .infinity)
        }
    }

    private func displayContentWidth(totalWidth: CGFloat, safeAreaInsets: EdgeInsets) -> CGFloat {
        max(
            1,
            totalWidth
                - safeAreaInsets.leading
                - safeAreaInsets.trailing
                - LookSpacing.pageHorizontal * 2
        )
    }

    private func styledDisplayText(fixedWidth: Bool) -> some View {
        Text(draft.text)
            .font(draft.fontStyle.font(size: 70 * fontScale))
            .lineLimit(1)
            .minimumScaleFactor(fixedWidth ? 1 : 0.55)
            .fixedSize(horizontal: fixedWidth, vertical: false)
            .foregroundStyle(textStyle)
            .shadow(color: displayAccentColor.opacity(1.0), radius: 9)
            .shadow(color: displayAccentColor.opacity(0.78), radius: 24)
            .shadow(color: displayAccentColor.opacity(0.42), radius: 44)
            .opacity(draft.isBlinking ? blinkOpacity : 1)
            .scaleEffect(x: draft.isMirrored ? -1 : 1, y: 1)
    }

    private var textWidthReader: some View {
        GeometryReader { proxy in
            Color.clear.preference(key: DisplayTextWidthKey.self, value: proxy.size.width)
        }
    }

    private var heartRainLayer: some View {
        TimelineView(.animation) { timeline in
            let seconds = timeline.date.timeIntervalSinceReferenceDate
            ZStack {
                ForEach(0..<18, id: \.self) { index in
                    let progress = (seconds * (0.08 + Double(index % 5) * 0.012) + Double(index) * 0.09).truncatingRemainder(dividingBy: 1)
                    Image(systemName: "heart.fill")
                        .font(.system(size: CGFloat(10 + (index % 4) * 6), weight: .bold))
                        .foregroundColor(index.isMultiple(of: 2) ? LookTheme.Colors.primaryPink.opacity(0.9) : LookTheme.Colors.hotPink.opacity(0.72))
                        .offset(
                            x: CGFloat((index % 6) * 56 - 150),
                            y: CGFloat(progress * 720 - 360)
                        )
                        .shadow(color: LookTheme.Colors.primaryPink.opacity(0.6), radius: 8)
                }
            }
        }
        .ignoresSafeArea()
    }

    private var displayAccentColor: Color {
        switch draft.selectedStyle.type {
        case .marquee:
            LookTheme.Colors.primaryPink
        case .neonBlink:
            LookTheme.Colors.electricBlue
        case .breathing:
            draft.textColor
        case .typewriter:
            LookTheme.Colors.softPink
        case .heartRain:
            LookTheme.Colors.hotPink
        case .rainbow:
            LookTheme.Colors.neonPurple
        case .starFlash:
            LookTheme.Colors.warmYellow
        case .bulletFlyIn:
            LookTheme.Colors.electricBlue
        case .meteorShower:
            LookTheme.Colors.warmYellow
        case .laserSweep:
            LookTheme.Colors.electricBlue
        case .fireworkBurst:
            LookTheme.Colors.hotPink
        case .heartBeat:
            LookTheme.Colors.hotPink
        case .auroraWave:
            LookTheme.Colors.neonPurple
        case .bubblePop:
            LookTheme.Colors.softPink
        case .spotlight:
            LookTheme.Colors.warmYellow
        case .glitchPulse:
            LookTheme.Colors.electricBlue
        }
    }

    private var textStyle: some ShapeStyle {
        switch draft.selectedStyle.type {
        case .rainbow, .auroraWave:
            LinearGradient(
                colors: [
                    LookTheme.Colors.primaryPink,
                    LookTheme.Colors.warmYellow,
                    LookTheme.Colors.electricBlue,
                    LookTheme.Colors.neonPurple
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        case .neonBlink, .starFlash, .bulletFlyIn, .meteorShower, .laserSweep, .fireworkBurst, .glitchPulse:
            LinearGradient(
                colors: [
                    LookTheme.Colors.textPrimary,
                    LookTheme.Colors.electricBlue,
                    LookTheme.Colors.hotPink
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .spotlight:
            LinearGradient(
                colors: [
                    LookTheme.Colors.textPrimary,
                    LookTheme.Colors.warmYellow,
                    LookTheme.Colors.hotPink
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        default:
            LinearGradient(
                colors: [
                    LookTheme.Colors.textPrimary,
                    draft.textColor,
                    LookTheme.Colors.hotPink
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }

    private var marqueeCycleDuration: TimeInterval {
        max(2.4, 7.0 / speed)
    }

    private var estimatedMarqueeTextWidth: CGFloat {
        max(48, CGFloat(draft.text.count) * 42 * fontScale)
    }

    private var effectiveMarqueeTextWidth: CGFloat {
        marqueeTextWidth > 1 ? marqueeTextWidth : estimatedMarqueeTextWidth
    }

    private func marqueeProgress(at date: Date, playing: Bool) -> CGFloat {
        guard playing else {
            return normalizedMarqueeProgress(marqueeReferenceProgress)
        }

        let elapsed = max(0, date.timeIntervalSince(marqueeReferenceDate))
        return normalizedMarqueeProgress(marqueeReferenceProgress + CGFloat(elapsed / marqueeCycleDuration))
    }

    private func marqueeOffset(at date: Date) -> CGFloat {
        marqueeOffset(
            progress: marqueeProgress(at: date, playing: isPlaying),
            containerWidth: max(1, marqueeContainerWidth),
            textWidth: effectiveMarqueeTextWidth
        )
    }

    private func marqueeOffset(progress: CGFloat, containerWidth: CGFloat, textWidth: CGFloat) -> CGFloat {
        let travelDistance = max(1, containerWidth + textWidth)
        let edgeOffset = travelDistance / 2
        let travelled = normalizedMarqueeProgress(progress) * travelDistance

        switch draft.scrollDirection {
        case .rightToLeft:
            return edgeOffset - travelled
        case .leftToRight:
            return -edgeOffset + travelled
        }
    }

    private func marqueeProgress(forOffset offset: CGFloat, containerWidth: CGFloat, textWidth: CGFloat) -> CGFloat {
        let travelDistance = max(1, containerWidth + textWidth)
        let edgeOffset = travelDistance / 2

        switch draft.scrollDirection {
        case .rightToLeft:
            return normalizedMarqueeProgress((edgeOffset - offset) / travelDistance)
        case .leftToRight:
            return normalizedMarqueeProgress((offset + edgeOffset) / travelDistance)
        }
    }

    private func normalizedMarqueeProgress(_ value: CGFloat) -> CGFloat {
        let progress = value.truncatingRemainder(dividingBy: 1)
        return progress >= 0 ? progress : progress + 1
    }

    private func resetMarqueeReference() {
        guard draft.selectedStyle.type == .marquee else {
            return
        }
        marqueeReferenceProgress = 0
        marqueeReferenceDate = Date()
    }

    private func handlePlaybackChange(wasPlaying: Bool, isPlaying: Bool) {
        guard draft.selectedStyle.type == .marquee else {
            return
        }

        let now = Date()
        if wasPlaying, !isPlaying {
            marqueeReferenceProgress = marqueeProgress(at: now, playing: true)
            marqueeReferenceDate = now
        } else if !wasPlaying, isPlaying {
            marqueeReferenceDate = now
        }
    }

    private func syncMarqueeReference() {
        guard draft.selectedStyle.type == .marquee else {
            return
        }
        let now = Date()
        marqueeReferenceProgress = marqueeProgress(at: now, playing: isPlaying)
        marqueeReferenceDate = now
    }

    private func updateMarqueeContainerWidth(_ width: CGFloat) {
        let newWidth = max(1, width)
        guard abs(newWidth - marqueeContainerWidth) > 0.5 else {
            return
        }
        guard marqueeContainerWidth > 0 else {
            marqueeContainerWidth = newWidth
            return
        }
        preserveMarqueeOffset(newContainerWidth: newWidth, newTextWidth: effectiveMarqueeTextWidth)
        marqueeContainerWidth = newWidth
    }

    private func updateMarqueeTextWidth(_ width: CGFloat) {
        let newWidth = max(1, width)
        guard abs(newWidth - marqueeTextWidth) > 0.5 else {
            return
        }
        preserveMarqueeOffset(newContainerWidth: max(1, marqueeContainerWidth), newTextWidth: newWidth)
        marqueeTextWidth = newWidth
    }

    private func preserveMarqueeOffset(newContainerWidth: CGFloat, newTextWidth: CGFloat) {
        guard draft.selectedStyle.type == .marquee else {
            return
        }

        let now = Date()
        let currentOffset = marqueeOffset(
            progress: marqueeProgress(at: now, playing: isPlaying),
            containerWidth: max(1, marqueeContainerWidth),
            textWidth: effectiveMarqueeTextWidth
        )
        marqueeReferenceProgress = marqueeProgress(
            forOffset: currentOffset,
            containerWidth: newContainerWidth,
            textWidth: newTextWidth
        )
        marqueeReferenceDate = now
    }

    private func startBlinkingIfNeeded() {
        guard draft.isBlinking, isPlaying else {
            blinkOpacity = 1
            return
        }
        blinkOpacity = 1
        withAnimation(.easeInOut(duration: 0.48).repeatForever(autoreverses: true)) {
            blinkOpacity = 0.42
        }
    }

    private func resetBlinking() {
        withAnimation(.linear(duration: 0.01)) {
            blinkOpacity = 1
        }
    }

    private func handleViewportSizeChange(_ size: CGSize) {
        let normalizedSize = CGSize(width: size.width.rounded(), height: size.height.rounded())
        guard abs(normalizedSize.width - viewportSize.width) > 0.5
                || abs(normalizedSize.height - viewportSize.height) > 0.5 else {
            return
        }

        viewportSize = normalizedSize
        refreshLayoutState(containerWidth: normalizedSize.width)
    }

    private func scheduleOrientationLayoutRefresh() {
        orientationRefreshTask?.cancel()
        orientationRefreshTask = Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(140))
            guard !Task.isCancelled else {
                return
            }
            refreshLayoutState(containerWidth: viewportSize.width)
        }
    }

    private func refreshLayoutState(containerWidth: CGFloat) {
        syncMarqueeReference()
        marqueeTextWidth = 0
        if containerWidth > 1 {
            updateMarqueeContainerWidth(containerWidth)
        }
        layoutRefreshID &+= 1
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
    let onOrientationChange: () -> Void

    func makeUIViewController(context: Context) -> Controller {
        let controller = Controller()
        controller.onOrientationChange = onOrientationChange
        return controller
    }

    func updateUIViewController(_ uiViewController: Controller, context: Context) {
        uiViewController.onOrientationChange = onOrientationChange
    }

    final class Controller: UIViewController {
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
            guard let orientationMask = Self.orientationMask(for: UIDevice.current.orientation),
                  let windowScene = view.window?.windowScene else {
                return
            }

            view.window?.rootViewController?.setNeedsUpdateOfSupportedInterfaceOrientations()
            windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: orientationMask)) { _ in }
        }

        private static func orientationMask(for orientation: UIDeviceOrientation) -> UIInterfaceOrientationMask? {
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
            text: "周深我爱你！",
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
}
