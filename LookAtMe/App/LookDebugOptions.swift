enum LookDebugOptions {
    #if DEBUG
    /// Controls Debug-only entry points that should be hidden for App Store Connect screenshots.
    static let isDebugEntryPointEnabled = false
    #else
    static let isDebugEntryPointEnabled = false
    #endif
}
