import SwiftUI

struct AboutView: View {
    @EnvironmentObject private var settingsStore: SettingsStore

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
                                        .fill(LookTheme.primaryButtonGradient)
                                        .frame(width: 76, height: 76)
                                        .shadow(color: LookTheme.Colors.primaryPink.opacity(0.62), radius: 18)

                                    Image(systemName: "heart.text.square.fill")
                                        .font(.system(size: 32, weight: .bold, design: .rounded))
                                        .foregroundColor(LookTheme.Colors.textPrimary)
                                }

                                VStack(spacing: LookSpacing.xs) {
                                    Text(L10n.key(L10n.About.appName))
                                        .font(LookTypography.largeTitle)
                                        .foregroundStyle(
                                            LinearGradient(
                                                colors: [
                                                    LookTheme.Colors.textPrimary,
                                                    LookTheme.Colors.softPink,
                                                    LookTheme.Colors.primaryPink
                                                ],
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                        )
                                        .shadow(color: LookTheme.Colors.primaryPink.opacity(0.72), radius: 12)

                                    Text(L10n.format(L10n.About.versionFormat, locale: settingsStore.appLanguage.locale, "2.0.0"))
                                        .font(LookTypography.caption)
                                        .foregroundColor(LookTheme.Colors.textTertiary)
                                }

                                Text(L10n.key(L10n.About.description))
                                    .font(LookTypography.body)
                                    .foregroundColor(LookTheme.Colors.textSecondary)
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
                    .foregroundColor(LookTheme.Colors.primaryPink)
                    .frame(width: 24)
                Text(L10n.key(title))
                    .font(LookTypography.body)
                    .foregroundColor(LookTheme.Colors.textPrimary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(LookTheme.Colors.textDisabled)
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
