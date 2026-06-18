import SwiftUI

struct MoreFeaturesPlaceholderView: View {
    @Environment(\.lookSkin) private var skin

    private let items: [(String, String)] = [
        (L10n.MoreFeatures.stylePicker, "sparkles"),
        (L10n.MoreFeatures.templateCenter, "text.rectangle.page"),
        (L10n.MoreFeatures.textColor, "paintpalette.fill"),
        (L10n.MoreFeatures.backgroundColor, "circle.lefthalf.filled"),
        (L10n.MoreFeatures.fontPicker, "textformat"),
        (L10n.MoreFeatures.displaySettings, "slider.horizontal.3")
    ]

    var body: some View {
        ZStack {
            LookScreenBackground()

            VStack(alignment: .leading, spacing: LookSpacing.lg) {
                Text(L10n.key(L10n.MoreFeatures.title))
                    .font(LookTypography.pageTitle)
                    .foregroundColor(skin.textPrimary)

                Text(L10n.key(L10n.MoreFeatures.placeholderMessage))
                    .font(LookTypography.body)
                    .foregroundColor(skin.textTertiary)

                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: LookSpacing.sm),
                        GridItem(.flexible(), spacing: LookSpacing.sm)
                    ],
                    spacing: LookSpacing.sm
                ) {
                    ForEach(items, id: \.0) { item in
                        NeonCard {
                            VStack(spacing: LookSpacing.sm) {
                                Image(systemName: item.1)
                                    .font(.system(size: 24, weight: .bold, design: .rounded))
                                    .foregroundColor(skin.primary)
                                Text(L10n.key(item.0))
                                    .font(LookTypography.body)
                                    .foregroundColor(skin.textPrimary)
                            }
                            .frame(maxWidth: .infinity, minHeight: 72)
                        }
                    }
                }

                Spacer()
            }
            .padding(LookSpacing.pageHorizontal)
            .padding(.top, LookSpacing.xl)
        }
    }
}
