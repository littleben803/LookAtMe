import SwiftUI

struct MoreFeaturesView: View {
    private let columns = [
        GridItem(.flexible(), spacing: LookSpacing.sm),
        GridItem(.flexible(), spacing: LookSpacing.sm)
    ]

    var body: some View {
        ZStack {
            LookScreenBackground()

            VStack(alignment: .leading, spacing: 0) {
                fixedHeader

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: LookSpacing.lg) {
                        SectionHeader(L10n.MoreFeatures.basicTools)
                        LazyVGrid(columns: columns, spacing: LookSpacing.sm) {
                            featureLink(L10n.MoreFeatures.stylePicker, subtitle: L10n.MoreFeatures.stylePickerSubtitle, icon: "sparkles", route: .stylePicker)
                            featureLink(L10n.MoreFeatures.templateCenter, subtitle: L10n.MoreFeatures.templateCenterSubtitle, icon: "text.quote", route: .templateCenter)
                            featureLink(L10n.MoreFeatures.textColor, subtitle: L10n.MoreFeatures.textColorSubtitle, icon: "paintpalette.fill", route: .textColor)
                            featureLink(L10n.MoreFeatures.backgroundColor, subtitle: L10n.MoreFeatures.backgroundColorSubtitle, icon: "circle.lefthalf.filled", route: .backgroundColor)
                            featureLink(L10n.MoreFeatures.fontPicker, subtitle: L10n.MoreFeatures.fontPickerSubtitle, icon: "textformat", route: .fontPicker)
                            featureLink(L10n.MoreFeatures.displaySettings, subtitle: L10n.MoreFeatures.displaySettingsSubtitle, icon: "slider.horizontal.3", route: .displaySettings)
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
        NeonPageHeader(
            title: L10n.MoreFeatures.title,
            subtitle: L10n.MoreFeatures.subtitle
        )
        .padding(.horizontal, LookSpacing.pageHorizontal)
        .padding(.top, LookSpacing.lg)
        .padding(.bottom, LookSpacing.md)
    }

    private func featureLink(_ title: String, subtitle: String, icon: String, route: FeatureRoute) -> some View {
        NavigationLink(value: route) {
            FeatureGridCardLabel(title: title, subtitle: subtitle, systemImage: icon)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        MoreFeaturesView()
    }
}
