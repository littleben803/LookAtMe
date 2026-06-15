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
                        SectionHeader("基础工具")
                        LazyVGrid(columns: columns, spacing: LookSpacing.sm) {
                            featureLink("样式选择", subtitle: "切换展示效果", icon: "sparkles", route: .stylePicker)
                            featureLink("模板中心", subtitle: "更多现成文案", icon: "text.quote", route: .templateCenter)
                            featureLink("文字颜色", subtitle: "24 个常用色", icon: "paintpalette.fill", route: .textColor)
                            featureLink("背景颜色", subtitle: "深色舞台背景", icon: "circle.lefthalf.filled", route: .backgroundColor)
                            featureLink("字体选择", subtitle: "不同灯牌气质", icon: "textformat", route: .fontPicker)
                            featureLink("展示设置", subtitle: "速度、大小、方向", icon: "slider.horizontal.3", route: .displaySettings)
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
            title: "更多功能",
            subtitle: "把灯牌调成你想要的样子"
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
