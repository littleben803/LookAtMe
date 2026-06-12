import Combine
import Foundation

enum RootTab: Hashable {
    case home
    case favorites
    case settings
}

final class AppNavigationState: ObservableObject {
    @Published var selectedTab: RootTab = .home
}
