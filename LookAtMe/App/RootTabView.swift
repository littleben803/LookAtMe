import SwiftUI
import UIKit

struct RootTabView: View {
    @StateObject private var navigationState = AppNavigationState()

    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        appearance.backgroundColor = UIColor(red: 0.05, green: 0.01, blue: 0.12, alpha: 0.88)

        let selectedColor = UIColor(red: 1.0, green: 0.30, blue: 0.65, alpha: 1.0)
        let normalColor = UIColor(red: 0.75, green: 0.69, blue: 0.82, alpha: 0.8)

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
    }

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
        .tint(LookTheme.Colors.primaryPink)
        .environmentObject(navigationState)
        .preferredColorScheme(.dark)
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

#Preview {
    RootTabView()
}
