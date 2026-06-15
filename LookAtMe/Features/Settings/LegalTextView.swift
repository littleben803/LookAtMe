import SwiftUI

struct LegalTextView: View {
    let document: LegalDocument

    var body: some View {
        ZStack {
            LookScreenBackground()

            VStack(alignment: .leading, spacing: 0) {
                fixedHeader

                ScrollView(showsIndicators: false) {
                    NeonCard {
                        VStack(alignment: .leading, spacing: LookSpacing.md) {
                            ForEach(paragraphs, id: \.self) { paragraph in
                                Text(paragraph)
                                    .font(LookTypography.body)
                                    .foregroundColor(LookTheme.Colors.textSecondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
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
            title: document.title,
            subtitle: "本阶段为本地占位内容，提审前替换为正式文本或 URL"
        )
        .padding(.horizontal, LookSpacing.pageHorizontal)
        .padding(.top, LookSpacing.lg)
        .padding(.bottom, LookSpacing.md)
    }

    private var paragraphs: [String] {
        switch document {
        case .privacy:
            [
                "想恋爱 2.0 当前阶段为本地优先工具，不接入账号、服务端、广告追踪或在线 AI。",
                "收藏内容和展示设置会保存在本机 UserDefaults 中，用于恢复你的常用灯牌和展示偏好。",
                "清除缓存不会默认删除收藏；只有在你明确确认时，才会清空收藏数据。",
                "正式上架前，本页面会替换为完整隐私政策。"
            ]
        case .terms:
            [
                "想恋爱用于娱乐、自我表达和现场氛围展示，不应被理解为确定性承诺或专业建议。",
                "请在演唱会、机场等公共场景中遵守现场秩序，避免遮挡他人视线或影响安全。",
                "Pro 相关购买能力将在后续阶段接入，本阶段所有 Pro 项仅为锁定态展示。",
                "正式上架前，本页面会替换为完整用户协议。"
            ]
        }
    }
}

#Preview {
    NavigationStack {
        LegalTextView(document: .privacy)
    }
}
