import SwiftUI

struct HelpView: View {
    private let items = [
        ("如何制作灯牌", "在首页输入文字，选择场景、模板和样式，点击开始展示即可。"),
        ("如何在演唱会使用", "提前调好亮度和文字大小，展示时举起手机，保持画面简洁醒目。"),
        ("如何保持屏幕常亮", "在设置中打开保持屏幕常亮，正式展示前确认电量充足。"),
        ("如何横屏展示", "在设置中打开自动横屏，后续完整横屏体验会在阶段 3 完善。"),
        ("如何收藏常用文案", "首页点击爱心按钮，或在模板中心长按模板选择收藏。")
    ]

    var body: some View {
        ZStack {
            LookScreenBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: LookSpacing.lg) {
                    NeonPageHeader(title: "使用帮助", subtitle: "快速做出好看的表白灯牌")

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
                }
                .padding(.horizontal, LookSpacing.pageHorizontal)
                .padding(.top, LookSpacing.lg)
                .padding(.bottom, LookSpacing.tabContentBottomPadding)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    NavigationStack {
        HelpView()
    }
}
