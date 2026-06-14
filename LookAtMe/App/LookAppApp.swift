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

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(templateStore)
                .environmentObject(styleStore)
                .environmentObject(displayConfigStore)
                .environmentObject(favoriteStore)
                .environmentObject(settingsStore)
        }
    }
}
