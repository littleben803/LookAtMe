#if DEBUG
import SwiftUI

struct DebugThemeSettingsView: View {
    @EnvironmentObject private var settingsStore: SettingsStore
    @EnvironmentObject private var skinManager: LookSkinManager
    @Environment(\.lookSkin) private var skin

    @State private var toastMessage: String?

    private let debugLanguages: [AppLanguage] = [.zhHans, .zhHant, .en, .ja]

    var body: some View {
        ZStack {
            LookScreenBackground()

            VStack(alignment: .leading, spacing: 0) {
                fixedHeader

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: LookSpacing.lg) {
                        debugGroup("Theme") {
                            ForEach(Array(LookSkinID.allCases.enumerated()), id: \.element.id) { index, skinID in
                                let option = LookSkin.skin(for: skinID)

                                themeRow(option)

                                if index < LookSkinID.allCases.count - 1 {
                                    debugDivider
                                }
                            }
                        }

                        debugGroup("App Language") {
                            ForEach(Array(debugLanguages.enumerated()), id: \.element.id) { index, language in
                                languageRow(language)

                                if index < debugLanguages.count - 1 {
                                    debugDivider
                                }
                            }
                        }
                    }
                    .padding(.horizontal, LookSpacing.pageHorizontal)
                    .padding(.top, LookSpacing.lg)
                    .padding(.bottom, LookSpacing.tabContentBottomPadding)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .lookToast($toastMessage)
        .onAppear(perform: lockLanguageToManualIfNeeded)
    }

    private var fixedHeader: some View {
        NeonPageHeader(
            title: "Theme",
            subtitle: "Debug only: switch skin and app language without following the system."
        )
        .padding(.horizontal, LookSpacing.pageHorizontal)
        .padding(.top, LookSpacing.lg)
        .padding(.bottom, LookSpacing.md)
    }

    private func debugGroup<Content: View>(
        _ title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: LookSpacing.sm) {
            Text(verbatim: title)
                .font(LookTypography.sectionTitle)
                .foregroundColor(skin.primary)
                .padding(.horizontal, LookSpacing.xs)

            NeonCard {
                VStack(spacing: 0) {
                    content()
                }
            }
        }
    }

    private func themeRow(_ option: LookSkin) -> some View {
        Button {
            skinManager.selectDebugSkin(option.id)
            toastMessage = "Theme: \(option.displayName)"
        } label: {
            HStack(spacing: LookSpacing.md) {
                themePreview(for: option)

                VStack(alignment: .leading, spacing: LookSpacing.xxs) {
                    Text(verbatim: option.displayName)
                        .font(LookTypography.body.weight(.semibold))
                        .foregroundColor(skin.textPrimary)

                    Text(verbatim: option.marketName)
                        .font(LookTypography.caption)
                        .foregroundColor(skin.textTertiary)
                }

                Spacer()

                selectionMark(isSelected: skinManager.skin.id == option.id)
            }
            .padding(.vertical, LookSpacing.sm)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func themePreview(for option: LookSkin) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [option.cardElevated, option.backgroundElevated],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            HStack(spacing: 3) {
                Circle().fill(option.primary)
                Circle().fill(option.secondary)
                Circle().fill(option.accent)
            }
            .frame(width: 34)
        }
        .frame(width: 44, height: 34)
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(option.primary.opacity(0.48), lineWidth: 1)
        )
        .shadow(color: option.primary.opacity(0.24), radius: 10, y: 4)
    }

    private func languageRow(_ language: AppLanguage) -> some View {
        Button {
            settingsStore.appLanguage = language
            toastMessage = "Language: \(languageTitle(language, locale: language.locale))"
        } label: {
            HStack(spacing: LookSpacing.md) {
                Image(systemName: "character.bubble")
                    .font(.system(size: 19, weight: .bold, design: .rounded))
                    .foregroundColor(skin.primary)
                    .frame(width: 34, height: 34)
                    .background(Circle().fill(skin.card.opacity(0.96)))
                    .overlay(Circle().stroke(skin.primary.opacity(0.3), lineWidth: 1))

                VStack(alignment: .leading, spacing: LookSpacing.xxs) {
                    Text(verbatim: languageTitle(language, locale: settingsStore.appLanguage.locale))
                        .font(LookTypography.body.weight(.semibold))
                        .foregroundColor(skin.textPrimary)

                    Text(verbatim: language.effectiveIdentifier)
                        .font(LookTypography.caption)
                        .foregroundColor(skin.textTertiary)
                }

                Spacer()

                selectionMark(isSelected: selectedDebugLanguage == language)
            }
            .padding(.vertical, LookSpacing.sm)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func selectionMark(isSelected: Bool) -> some View {
        Image(systemName: isSelected ? skin.chrome.styleSelectedSymbol : "circle")
            .font(.system(size: 20, weight: .bold))
            .foregroundColor(isSelected ? skin.primary : skin.textTertiary.opacity(0.48))
    }

    private var debugDivider: some View {
        Divider().overlay(skin.textTertiary.opacity(0.2))
    }

    private var selectedDebugLanguage: AppLanguage {
        if settingsStore.appLanguage == .system {
            return AppLanguage.systemResolvedLanguage
        }
        return settingsStore.appLanguage
    }

    private func lockLanguageToManualIfNeeded() {
        guard settingsStore.appLanguage == .system else {
            return
        }
        settingsStore.appLanguage = AppLanguage.systemResolvedLanguage
    }

    private func languageTitle(_ language: AppLanguage, locale: Locale) -> String {
        L10n.string(language.titleKey, locale: locale)
    }
}

#Preview {
    NavigationStack {
        DebugThemeSettingsView()
            .environmentObject(SettingsStore())
            .environmentObject(LookSkinManager())
            .environment(\.lookSkin, LookSkin.skin(for: .liveStageConsole))
    }
}
#endif
