import SwiftUI

struct LanguageSettingsView: View {
    @EnvironmentObject private var settingsStore: SettingsStore
    @Environment(\.lookSkin) private var skin
    @State private var toastMessage: String?

    var body: some View {
        ZStack {
            LookScreenBackground()

            VStack(alignment: .leading, spacing: 0) {
                fixedHeader

                ScrollView(showsIndicators: false) {
                    VStack(spacing: LookSpacing.sm) {
                        ForEach(AppLanguage.allCases) { language in
                            languageRow(language)
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
    }

    private var fixedHeader: some View {
        NeonPageHeader(
            title: L10n.Language.title,
            subtitle: L10n.Language.subtitle
        )
        .padding(.horizontal, LookSpacing.pageHorizontal)
        .padding(.top, LookSpacing.lg)
        .padding(.bottom, LookSpacing.md)
    }

    private func languageRow(_ language: AppLanguage) -> some View {
        Button {
            select(language)
        } label: {
            NeonCard {
                HStack(spacing: LookSpacing.md) {
                    Image(systemName: language == .system ? "globe" : "character.bubble")
                        .font(.system(size: 19, weight: .bold, design: .rounded))
                        .foregroundColor(skin.primary)
                        .frame(width: 34, height: 34)
                        .background(Circle().fill(skin.card.opacity(0.96)))
                        .overlay(Circle().stroke(skin.primary.opacity(0.3), lineWidth: 1))

                    VStack(alignment: .leading, spacing: LookSpacing.xxs) {
                        Text(L10n.key(language.titleKey))
                            .font(LookTypography.body.weight(.semibold))
                            .foregroundColor(skin.textPrimary)

                        Text(detailText(for: language))
                            .font(LookTypography.caption)
                            .foregroundColor(skin.textTertiary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer()

                    if settingsStore.appLanguage == language {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(skin.primary)
                    }
                }
            }
        }
        .buttonStyle(.plain)
    }

    private func detailText(for language: AppLanguage) -> String {
        let locale = settingsStore.appLanguage.locale

        guard language == .system else {
            return L10n.string(language.detailKey, locale: locale)
        }

        let resolvedLanguageName = L10n.string(AppLanguage.systemResolvedLanguage.titleKey, locale: locale)
        let format = L10n.string(L10n.Language.currentSystemFormat, locale: locale)
        return String(format: format, resolvedLanguageName)
    }

    private func select(_ language: AppLanguage) {
        guard settingsStore.appLanguage != language else {
            return
        }

        settingsStore.appLanguage = language
        toastMessage = L10n.string(L10n.Language.changed, locale: language.locale)
    }
}

#Preview {
    NavigationStack {
        LanguageSettingsView()
            .environmentObject(SettingsStore())
    }
}
