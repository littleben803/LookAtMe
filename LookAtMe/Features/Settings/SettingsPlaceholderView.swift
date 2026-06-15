import SwiftUI

struct SettingsPlaceholderView: View {
    var body: some View {
        PlaceholderScreen(
            title: L10n.Settings.title,
            subtitle: L10n.Settings.title,
            systemImage: "gearshape",
            message: L10n.Settings.placeholderMessage
        )
    }
}

#Preview {
    SettingsPlaceholderView()
}
