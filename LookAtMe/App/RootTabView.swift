import SwiftUI
import UIKit

struct RootTabView: View {
    @StateObject private var navigationState = AppNavigationState()
    @Environment(\.lookSkin) private var skin

    var body: some View {
        TabView(selection: $navigationState.selectedTab) {
            HomeView()
                .tabItem {
                    Label(L10n.key(L10n.Tab.home), systemImage: "house.fill")
                }
                .tag(RootTab.home)

            FavoritesView()
                .tabItem {
                    Label(L10n.key(L10n.Tab.favorites), systemImage: navigationState.selectedTab == .favorites ? "heart.fill" : "heart")
                }
                .tag(RootTab.favorites)

            SettingsView()
                .tabItem {
                    Label(L10n.key(L10n.Tab.settings), systemImage: "gearshape.fill")
                }
                .tag(RootTab.settings)
        }
        .tint(skin.primary)
        .background(TabBarSkinApplier(skin: skin).frame(width: 0, height: 0))
        .onAppear {
            UITabBar.applyLookSkin(skin)
        }
        .onChange(of: skin) { _, newSkin in
            UITabBar.applyLookSkin(newSkin)
        }
        .environmentObject(navigationState)
        .preferredColorScheme(.dark)
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

private struct TabBarSkinApplier: UIViewControllerRepresentable {
    let skin: LookSkin

    func makeUIViewController(context: Context) -> Controller {
        Controller()
    }

    func updateUIViewController(_ uiViewController: Controller, context: Context) {
        uiViewController.apply(skin)
    }

    final class Controller: UIViewController {
        private var lastSkinID: LookSkinID?

        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            if let lastSkinID {
                UITabBar.applyLookSkin(LookSkin.skin(for: lastSkinID), tabBar: tabBarController?.tabBar)
            }
        }

        func apply(_ skin: LookSkin) {
            lastSkinID = skin.id
            UITabBar.applyLookSkin(skin, tabBar: tabBarController?.tabBar)
        }
    }
}

private extension UITabBar {
    static func applyLookSkin(_ skin: LookSkin, tabBar: UITabBar? = nil) {
        let selectedColor = UIColor(skin.primary)
        let normalColor = UIColor(skin.textTertiary.opacity(0.82))
        let backgroundColor = UIColor(skin.background.opacity(0.9))

        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        appearance.backgroundColor = backgroundColor

        let itemAppearance = UITabBarItemAppearance()
        itemAppearance.normal.iconColor = normalColor
        itemAppearance.normal.titleTextAttributes = [.foregroundColor: normalColor]
        itemAppearance.selected.iconColor = selectedColor
        itemAppearance.selected.titleTextAttributes = [.foregroundColor: selectedColor]

        appearance.stackedLayoutAppearance = itemAppearance
        appearance.inlineLayoutAppearance = itemAppearance
        appearance.compactInlineLayoutAppearance = itemAppearance

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        UITabBar.appearance().tintColor = selectedColor
        UITabBar.appearance().unselectedItemTintColor = normalColor

        tabBar?.standardAppearance = appearance
        tabBar?.scrollEdgeAppearance = appearance
        tabBar?.tintColor = selectedColor
        tabBar?.unselectedItemTintColor = normalColor
    }
}

#Preview {
    RootTabView()
}
