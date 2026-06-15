import SwiftUI

struct HelpView: View {
    private let items = [
        ("如何制作灯牌", "在首页输入文字，选择场景、模板和样式，点击开始展示即可。"),
        ("如何在演唱会使用", "提前调好亮度和文字大小，展示时举起手机，保持画面简洁醒目。"),
        ("如何保持屏幕常亮", "在设置中打开保持屏幕常亮，正式展示前确认电量充足。"),
        ("如何使用横屏", "在设置中打开自动横屏，进入播放页后旋转手机即可横屏展示；关闭后播放页会保持竖屏。"),
        ("如何收藏常用文案", "可以在首页输入框右侧点爱心收藏，也可以在播放页右上角点爱心保存当前文字、样式、速度和大小。")
    ]

    var body: some View {
        ZStack {
            LookScreenBackground()

            VStack(alignment: .leading, spacing: 0) {
                fixedHeader

                ScrollView(showsIndicators: false) {
                    VStack(spacing: LookSpacing.sm) {
                        ForEach(items, id: \.0) { item in
                            NeonCard {
                                VStack(alignment: .leading, spacing: LookSpacing.xs) {
                                    Text(item.0)
                                        .font(LookTypography.sectionTitle)
                                        .foregroundColor(LookTheme.Colors.textPrimary)
                                    Text(item.1)
                                        .font(LookTypography.body)
                                        .foregroundColor(LookTheme.Colors.textTertiary)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
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
    }

    private var fixedHeader: some View {
        NeonPageHeader(title: "使用帮助", subtitle: "快速做出好看的表白灯牌")
            .padding(.horizontal, LookSpacing.pageHorizontal)
            .padding(.top, LookSpacing.lg)
            .padding(.bottom, LookSpacing.md)
    }
}

#Preview {
    NavigationStack {
        HelpView()
    }
}
