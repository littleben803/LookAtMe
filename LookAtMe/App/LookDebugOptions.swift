enum LookDebugOptions {
    #if DEBUG
    /// Controls Debug-only entry points that should be hidden for App Store Connect screenshots.
    static let isDebugEntryPointEnabled = false
    static let isThemeDebugEntryPointEnabled = true
    #else
    static let isDebugEntryPointEnabled = false
    static let isThemeDebugEntryPointEnabled = false
    #endif

    static var isSettingsDebugGroupEnabled: Bool {
        isDebugEntryPointEnabled || isThemeDebugEntryPointEnabled
    }
}
