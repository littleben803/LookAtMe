import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var displayConfigStore: DisplayConfigStore
    @EnvironmentObject private var favoriteStore: FavoriteStore
    @EnvironmentObject private var settingsStore: SettingsStore
    @EnvironmentObject private var purchaseManager: PurchaseManager
    @EnvironmentObject private var appReviewPromptStore: AppReviewPromptStore

    @State private var path: [FeatureRoute] = []
    @State private var isShowingClearConfirm = false
    @State private var toastMessage: String?
    @State private var paywallContext: ProPaywallContext?
#if DEBUG
    @State private var isDebugReviewPromptArmed = false
#endif

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                LookScreenBackground()

                VStack(alignment: .leading, spacing: 0) {
                    fixedHeader

                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: LookSpacing.lg) {
                            settingsGroup(L10n.Settings.displayGroup) {
                                resetDisplaySettingsButton
                            } content: {
                                SettingsRow(
                                    title: L10n.Settings.defaultTextColor,
                                    value: displayConfigStore.textColorHex,
                                    colorSwatch: Color(hex: displayConfigStore.textColorHex)
                                ) {
                                    path.append(.textColor)
                                }
                                neonDivider
                                SettingsRow(
                                    title: L10n.Settings.defaultBackgroundColor,
                                    value: displayConfigStore.backgroundColorHex,
                                    colorSwatch: Color(hex: displayConfigStore.backgroundColorHex)
                                ) {
                                    path.append(.backgroundColor)
                                }
                                neonDivider
                                SettingsRow(title: L10n.Settings.defaultTextSize, value: "\(Int(displayConfigStore.fontScale * 100))%") {
                                    path.append(.displaySettings)
                                }
                                neonDivider
                                SettingsRow(title: L10n.Settings.defaultScrollSpeed, value: speedText) {
                                    path.append(.displaySettings)
                                }
                                neonDivider
                                SettingsToggleRow(title: L10n.Settings.autoRotate, isOn: $settingsStore.autoRotate)
                                neonDivider
                                SettingsToggleRow(title: L10n.Settings.keepAwake, isOn: $settingsStore.keepAwake)
                            }

                            settingsGroup(L10n.Settings.otherGroup) {
                                SettingsRow(
                                    title: L10n.Settings.language,
                                    value: localized(settingsStore.appLanguage.titleKey),
                                    systemImage: "globe"
                                ) {
                                    path.append(.languageSettings)
                                }
                                neonDivider
                                SettingsRow(title: L10n.Settings.clearCache, systemImage: "trash") {
                                    isShowingClearConfirm = true
                                }
                                neonDivider
                                SettingsRow(title: L10n.Settings.rateUs, systemImage: "star") {
                                    openReviewPage()
                                }
                                neonDivider
                                ShareLink(item: localized(L10n.Settings.shareMessage)) {
                                    shareRow
                                }
                                neonDivider
                                SettingsRow(title: L10n.Settings.help, systemImage: "questionmark.circle") {
                                    path.append(.help)
                                }
                            }

#if DEBUG
                            if LookDebugOptions.isDebugEntryPointEnabled {
                                settingsGroup(L10n.Settings.Debug.group) {
                                    SettingsToggleRow(title: L10n.Settings.Debug.triggerReviewPrompt, isOn: debugReviewPromptBinding)
                                }
                            }
#endif

                            settingsGroup(L10n.Settings.aboutGroup) {
                                SettingsRow(title: L10n.Settings.aboutApp) {
                                    path.append(.about)
                                }
                                neonDivider
                                SettingsRow(title: L10n.Settings.privacyPolicy) {
                                    path.append(.legal(.privacy))
                                }
                                neonDivider
                                SettingsRow(title: L10n.Settings.terms) {
                                    path.append(.legal(.terms))
                                }
                                neonDivider
                                SettingsRow(title: L10n.Settings.restorePurchase) {
                                    showPaywall(.settingsRestore) {
                                        showToast(localized(L10n.Settings.Toast.proUnlocked))
                                    }
                                }
                                neonDivider
                                SettingsRow(title: L10n.Settings.version, value: "2.0.0")
                            }
                        }
                        .padding(.horizontal, LookSpacing.pageHorizontal)
                        .padding(.bottom, LookSpacing.tabContentBottomPadding)
                    }
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: FeatureRoute.self) { route in
                destination(for: route)
            }
        }
        .lookToast($toastMessage)
        .alert(localized(L10n.Settings.Alert.clearCacheTitle), isPresented: $isShowingClearConfirm) {
            Button(localized(L10n.Settings.Alert.clearTemporary)) {
                displayConfigStore.clearTransientState()
                showToast(localized(L10n.Settings.Toast.transientCleared))
            }
            Button(localized(L10n.Settings.Alert.clearWithFavorites), role: .destructive) {
                displayConfigStore.clearTransientState()
                favoriteStore.clearAll()
                showToast(localized(L10n.Settings.Toast.transientAndFavoritesCleared))
            }
            Button(localized(L10n.Common.cancel), role: .cancel) {}
        } message: {
            Text(L10n.key(L10n.Settings.Alert.clearCacheMessage))
        }
        .fullScreenCover(item: $paywallContext) { context in
            ProPaywallView(context: context)
        }
    }

    @ViewBuilder
    private func destination(for route: FeatureRoute) -> some View {
        switch route {
        case .more:
            MoreFeaturesView()
        case .stylePicker:
            StylePickerView()
        case .templateCenter:
            TemplateCenterView { _ in }
        case .textColor:
            TextColorPickerView()
        case .backgroundColor:
            BackgroundColorPickerView()
        case .fontPicker:
            FontPickerView()
        case .displaySettings:
            DisplaySettingsView()
        case .languageSettings:
            LanguageSettingsView()
        case .help:
            HelpView()
        case .about:
            AboutView()
        case .legal(let document):
            LegalTextView(document: document)
        }
    }

    private var speedText: String {
        switch displayConfigStore.speed {
        case ..<0.85:
            localized(L10n.Settings.speedSlow)
        case 0.85...1.25:
            localized(L10n.Settings.speedMedium)
        default:
            localized(L10n.Settings.speedFast)
        }
    }

    private var fixedHeader: some View {
        Text(L10n.key(L10n.Settings.title))
            .font(LookTypography.pageTitle)
            .foregroundColor(LookTheme.Colors.textPrimary)
            .padding(.horizontal, LookSpacing.pageHorizontal)
            .padding(.top, LookSpacing.xl)
            .padding(.bottom, LookSpacing.md)
    }

    private var resetDisplaySettingsButton: some View {
        Button {
            resetDisplaySettings()
        } label: {
            HStack(spacing: LookSpacing.xxs) {
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                Text(L10n.key(L10n.Settings.reset))
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
            }
            .foregroundColor(LookTheme.Colors.hotPink)
            .padding(.horizontal, LookSpacing.sm)
            .padding(.vertical, LookSpacing.xs)
            .background(
                Capsule()
                    .fill(LookTheme.Colors.cardPurple.opacity(0.86))
                    .overlay(Capsule().stroke(LookTheme.Colors.primaryPink.opacity(0.34), lineWidth: 1))
            )
        }
        .buttonStyle(.plain)
    }

    private var neonDivider: some View {
        Divider().overlay(LookTheme.Colors.textDisabled.opacity(0.24))
    }

    private var shareRow: some View {
        HStack(spacing: LookSpacing.sm) {
            Image(systemName: "square.and.arrow.up")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(LookTheme.Colors.primaryPink)
                .frame(width: 22)

            Text(L10n.key(L10n.Settings.shareToFriends))
                .font(LookTypography.body)
                .foregroundColor(LookTheme.Colors.textPrimary)

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(LookTheme.Colors.textDisabled)
        }
        .padding(.vertical, LookSpacing.sm)
    }

    private func settingsGroup<Content: View>(
        _ title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        settingsGroup(title, trailing: { EmptyView() }, content: content)
    }

    private func settingsGroup<Content: View, Trailing: View>(
        _ title: String,
        @ViewBuilder trailing: () -> Trailing,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: LookSpacing.sm) {
            HStack(alignment: .center) {
                Text(L10n.key(title))
                    .font(LookTypography.sectionTitle)
                    .foregroundColor(LookTheme.Colors.hotPink)

                Spacer()
                trailing()
            }
            .padding(.horizontal, LookSpacing.xs)

            NeonCard {
                VStack(spacing: 0) {
                    content()
                }
            }
        }
    }

    private func resetDisplaySettings() {
        displayConfigStore.resetDisplaySettings()
        settingsStore.resetDisplaySettings()
        showToast(localized(L10n.Settings.Toast.displaySettingsReset))
    }

    private func openReviewPage() {
        AppReviewLink.openWriteReviewPage(
            onSuccess: {
                appReviewPromptStore.suppressAutomaticPrompt()
            },
            onFailure: {
                showToast(localized(L10n.Settings.Toast.appStoreUnavailable))
            }
        )
    }

#if DEBUG
    private var debugReviewPromptBinding: Binding<Bool> {
        Binding(
            get: { isDebugReviewPromptArmed },
            set: { isOn in
                isDebugReviewPromptArmed = isOn
                if isOn {
                    appReviewPromptStore.prepareDebugAutomaticPromptTrigger()
                    showToast(localized(L10n.Settings.Toast.debugReviewPromptEnabled))
                } else {
                    appReviewPromptStore.resetDebugAutomaticPromptState()
                    showToast(localized(L10n.Settings.Toast.debugReviewPromptReset))
                }
            }
        )
    }
#endif

    private func localized(_ key: String) -> String {
        L10n.string(key, locale: settingsStore.appLanguage.locale)
    }

    private func showToast(_ message: String) {
        toastMessage = message
    }

    private func showPaywall(_ source: ProPaywallSource, onUnlocked: @escaping @MainActor () -> Void = {}) {
        purchaseManager.clearTransientState()
        paywallContext = ProPaywallContext(source: source, onUnlocked: onUnlocked)
    }
}

#Preview {
    SettingsView()
        .environmentObject(DisplayConfigStore())
        .environmentObject(FavoriteStore())
        .environmentObject(SettingsStore())
        .environmentObject(TemplateStore())
        .environmentObject(StyleStore())
        .environmentObject(PurchaseManager(autoStart: false))
        .environmentObject(AppReviewPromptStore())
}
