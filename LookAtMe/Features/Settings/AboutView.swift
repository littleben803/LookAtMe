import SwiftUI

struct AboutView: View {
    @EnvironmentObject private var settingsStore: SettingsStore
    @Environment(\.lookSkin) private var skin

    var body: some View {
        ZStack {
            LookScreenBackground()

            VStack(alignment: .leading, spacing: 0) {
                fixedHeader

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: LookSpacing.lg) {
                        NeonCard {
                            VStack(spacing: LookSpacing.md) {
                                ZStack {
                                    Circle()
                                        .fill(skin.primaryButtonGradient)
                                        .frame(width: 76, height: 76)
                                        .shadow(color: skin.primary.opacity(0.62), radius: 18)

                                    Image(systemName: "heart.text.square.fill")
                                        .font(.system(size: 32, weight: .bold, design: .rounded))
                                        .foregroundColor(skin.textPrimary)
                                }

                                VStack(spacing: LookSpacing.xs) {
                                    Text(L10n.key(L10n.About.appName))
                                        .font(LookTypography.largeTitle)
                                        .foregroundStyle(
                                            LinearGradient(
                                                colors: [
                                                    skin.textPrimary,
                                                    skin.textSecondary,
                                                    skin.primary
                                                ],
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                        )
                                        .shadow(color: skin.primary.opacity(0.72), radius: 12)

                                    Text(L10n.format(L10n.About.versionFormat, locale: settingsStore.appLanguage.locale, "2.0.0"))
                                        .font(LookTypography.caption)
                                        .foregroundColor(skin.textTertiary)
                                }

                                Text(L10n.key(L10n.About.description))
                                    .font(LookTypography.body)
                                    .foregroundColor(skin.textSecondary)
                                    .multilineTextAlignment(.center)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .frame(maxWidth: .infinity)
                        }

                        VStack(spacing: LookSpacing.sm) {
                            NavigationLink(value: FeatureRoute.legal(.privacy)) {
                                legalRow(L10n.Legal.privacyTitle, icon: "hand.raised.fill")
                            }
                            .buttonStyle(.plain)

                            NavigationLink(value: FeatureRoute.legal(.terms)) {
                                legalRow(L10n.Legal.termsTitle, icon: "doc.text.fill")
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, LookSpacing.pageHorizontal)
                    .padding(.top, LookSpacing.lg)
                    .padding(.bottom, LookSpacing.tabContentBottomPadding)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    private var fixedHeader: some View {
        NeonPageHeader(title: L10n.About.title)
            .padding(.horizontal, LookSpacing.pageHorizontal)
            .padding(.top, LookSpacing.lg)
            .padding(.bottom, LookSpacing.md)
    }

    private func legalRow(_ title: String, icon: String) -> some View {
        NeonCard {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(skin.primary)
                    .frame(width: 24)
                Text(L10n.key(title))
                    .font(LookTypography.body)
                    .foregroundColor(skin.textPrimary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(skin.textTertiary.opacity(0.66))
            }
        }
    }
}

#Preview {
    NavigationStack {
        AboutView()
            .environmentObject(SettingsStore())
    }
}
