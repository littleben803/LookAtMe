import SwiftUI

struct MoreFeaturesPlaceholderView: View {
    private let items: [(String, String)] = [
        ("样式选择", "sparkles"),
        ("模板中心", "text.rectangle.page"),
        ("文字颜色", "paintpalette.fill"),
        ("背景颜色", "circle.lefthalf.filled"),
        ("字体选择", "textformat"),
        ("展示设置", "slider.horizontal.3")
    ]

    var body: some View {
        ZStack {
            LookScreenBackground()

            VStack(alignment: .leading, spacing: LookSpacing.lg) {
                Text("更多功能")
                    .font(LookTypography.pageTitle)
                    .foregroundColor(LookTheme.Colors.textPrimary)

                Text("快速进入样式、模板、颜色、字体和展示设置。")
                    .font(LookTypography.body)
                    .foregroundColor(LookTheme.Colors.textTertiary)

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
                                    .foregroundColor(LookTheme.Colors.primaryPink)
                                Text(item.0)
                                    .font(LookTypography.body)
                                    .foregroundColor(LookTheme.Colors.textPrimary)
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
