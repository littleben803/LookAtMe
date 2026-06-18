import SwiftUI

struct DisplaySettingsView: View {
    @EnvironmentObject private var displayConfigStore: DisplayConfigStore
    @Environment(\.lookSkin) private var skin
    @State private var isShowingResetConfirm = false

    var body: some View {
        ZStack {
            LookScreenBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: LookSpacing.lg) {
                    NeonPageHeader(
                        title: L10n.DisplaySettings.title,
                        subtitle: L10n.DisplaySettings.subtitle
                    )

                    settingsGroup(L10n.DisplaySettings.basicParameters) {
                        sliderRow(
                            title: L10n.DisplaySettings.textSize,
                            value: $displayConfigStore.fontScale,
                            range: 0.7...3.0,
                            valueText: "\(Int(displayConfigStore.fontScale * 100))%"
                        )
                        neonDivider
                        sliderRow(
                            title: L10n.DisplaySettings.scrollSpeed,
                            value: $displayConfigStore.speed,
                            range: 0.5...2.0,
                            valueText: "\(Int(displayConfigStore.speed * 100))%"
                        )
                    }

                    settingsGroup(L10n.DisplaySettings.playback) {
                        VStack(alignment: .leading, spacing: LookSpacing.sm) {
                            Text(L10n.key(L10n.DisplaySettings.scrollDirection))
                                .font(LookTypography.body)
                                .foregroundColor(skin.textPrimary)

                            Picker(L10n.key(L10n.DisplaySettings.scrollDirection), selection: $displayConfigStore.scrollDirection) {
                                ForEach(BannerScrollDirection.allCases) { direction in
                                    Text(L10n.key(direction.titleKey)).tag(direction)
                                }
                            }
                            .pickerStyle(.segmented)
                            .tint(skin.primary)
                        }
                        .padding(.vertical, LookSpacing.xs)

                        neonDivider
                        SettingsToggleRow(title: L10n.DisplaySettings.mirror, isOn: $displayConfigStore.isMirrored)
                        neonDivider
                        SettingsToggleRow(title: L10n.DisplaySettings.blink, isOn: $displayConfigStore.isBlinking)
                    }

                    Button(role: .destructive) {
                        isShowingResetConfirm = true
                    } label: {
                        Text(L10n.key(L10n.DisplaySettings.resetAll))
                            .font(LookTypography.button)
                            .foregroundColor(LookTheme.Colors.danger)
                            .frame(maxWidth: .infinity, minHeight: 52)
                            .background(
                                Capsule()
                                    .fill(skin.card.opacity(0.88))
                                    .overlay(Capsule().stroke(LookTheme.Colors.danger.opacity(0.42), lineWidth: 1))
                            )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, LookSpacing.pageHorizontal)
                .padding(.top, LookSpacing.lg)
                .padding(.bottom, LookSpacing.tabContentBottomPadding)
            }
        }
        .navigationBarBackButtonHidden(true)
        .alert(L10n.key(L10n.DisplaySettings.Alert.resetTitle), isPresented: $isShowingResetConfirm) {
            Button(L10n.key(L10n.Common.cancel), role: .cancel) {}
            Button(L10n.key(L10n.Common.reset), role: .destructive) {
                displayConfigStore.resetAllSettings()
            }
        } message: {
            Text(L10n.key(L10n.DisplaySettings.Alert.resetMessage))
        }
    }

    private var neonDivider: some View {
        Divider().overlay(skin.textTertiary.opacity(0.2))
    }

    private func settingsGroup<Content: View>(
        _ title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: LookSpacing.sm) {
            Text(L10n.key(title))
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

    private func sliderRow(
        title: String,
        value: Binding<Double>,
        range: ClosedRange<Double>,
        valueText: String
    ) -> some View {
        VStack(spacing: LookSpacing.xs) {
            HStack {
                Text(L10n.key(title))
                    .font(LookTypography.body)
                    .foregroundColor(skin.textPrimary)
                Spacer()
                Text(valueText)
                    .font(LookTypography.caption.monospacedDigit())
                    .foregroundColor(skin.textTertiary)
            }
            Slider(value: value, in: range)
                .tint(skin.primary)
        }
        .padding(.vertical, LookSpacing.sm)
    }
}

#Preview {
    NavigationStack {
        DisplaySettingsView()
            .environmentObject(DisplayConfigStore())
    }
}
