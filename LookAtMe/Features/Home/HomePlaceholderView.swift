import SwiftUI

struct HomePlaceholderView: View {
    var body: some View {
        PlaceholderScreen(
            title: L10n.Home.appName,
            subtitle: L10n.Tab.home,
            systemImage: "sparkles",
            message: L10n.Home.placeholderMessage
        )
    }
}

#Preview {
    HomePlaceholderView()
}
