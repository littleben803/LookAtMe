import SwiftUI
import UIKit

final class AppOrientationDelegate: NSObject, UIApplicationDelegate {
    private static var supportedOrientations: UIInterfaceOrientationMask = .portrait

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        Self.supportedOrientations
    }

    @MainActor
    static func updateSupportedOrientations(_ orientations: UIInterfaceOrientationMask) {
        supportedOrientations = orientations

        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .forEach { windowScene in
                windowScene.windows.forEach {
                    $0.rootViewController?.setNeedsUpdateOfSupportedInterfaceOrientations()
                }
                windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: orientations)) { _ in }
            }
    }
}

@main
struct LookAppApp: App {
    @UIApplicationDelegateAdaptor(AppOrientationDelegate.self) private var appOrientationDelegate

    @StateObject private var templateStore = TemplateStore()
    @StateObject private var styleStore = StyleStore()
    @StateObject private var displayConfigStore = DisplayConfigStore()
    @StateObject private var favoriteStore = FavoriteStore()
    @StateObject private var settingsStore = SettingsStore()
    @StateObject private var purchaseManager = PurchaseManager()
    @StateObject private var appReviewPromptStore = AppReviewPromptStore()
    @StateObject private var devicePerformanceStore = DevicePerformanceStore()
    @StateObject private var skinManager = LookSkinManager()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(templateStore)
                .environmentObject(styleStore)
                .environmentObject(displayConfigStore)
                .environmentObject(favoriteStore)
                .environmentObject(settingsStore)
                .environmentObject(purchaseManager)
                .environmentObject(appReviewPromptStore)
                .environmentObject(devicePerformanceStore)
                .environmentObject(skinManager)
                .environment(\.lookSkin, skinManager.skin)
                .environment(\.locale, settingsStore.appLanguage.locale)
                .onReceive(NotificationCenter.default.publisher(for: NSLocale.currentLocaleDidChangeNotification)) { _ in
                    skinManager.refreshFromSystemLanguage()
                }
#if DEBUG
                .debugLaunchPaywallIfNeeded(purchaseManager: purchaseManager)
#endif
        }
    }
}

#if DEBUG
private struct DebugLaunchPaywallModifier: ViewModifier {
    let purchaseManager: PurchaseManager

    @State private var paywallContext: ProPaywallContext?

    private var shouldShowPaywall: Bool {
        LookDebugOptions.isDebugEntryPointEnabled &&
            (ProcessInfo.processInfo.environment["LOOKATME_DEBUG_PAYWALL"] == "1"
            || ProcessInfo.processInfo.arguments.contains("-LookAtMeDebugPaywall")
            )
    }

    func body(content: Content) -> some View {
        content
            .fullScreenCover(item: $paywallContext) { context in
                ProPaywallView(context: context)
                    .environmentObject(purchaseManager)
            }
            .task {
                guard shouldShowPaywall, paywallContext == nil else { return }
                try? await Task.sleep(for: .milliseconds(600))
                paywallContext = ProPaywallContext(source: .homePro)
            }
    }
}

private extension View {
    func debugLaunchPaywallIfNeeded(purchaseManager: PurchaseManager) -> some View {
        modifier(DebugLaunchPaywallModifier(purchaseManager: purchaseManager))
    }
}
#endif
