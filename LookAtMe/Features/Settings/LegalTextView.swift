import SwiftUI

struct LegalTextView: View {
    let document: LegalDocument

    @EnvironmentObject private var purchaseManager: PurchaseManager

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
            subtitle: document.subtitle
        )
        .padding(.horizontal, LookSpacing.pageHorizontal)
        .padding(.top, LookSpacing.lg)
        .padding(.bottom, LookSpacing.md)
    }

    private var paragraphs: [String] {
        switch document {
        case .privacy:
            privacyParagraphs
        case .terms:
            termsParagraphs
        }
    }

    private var privacyParagraphs: [String] {
        var content = [
            "想恋爱 2.0 是一款本地优先工具，不接入账号、服务端、广告追踪或在线 AI。",
            "收藏内容和展示设置会保存在本机 UserDefaults 中，用于恢复你的常用灯牌和展示偏好。",
            "清除缓存不会默认删除收藏；只有在你明确确认时，才会清空收藏数据。"
        ]

        if purchaseManager.isProUnlocked {
            content.append("尊敬的 Pro 用户，你已解锁全部高级样式、高级模板、高级字体、无限收藏和自定义样式保存等能力。你的权益校验以 Apple App Store 的购买记录为准，我们不会获取或保存你的付款账号、银行卡信息或 Apple ID 密码。")
        } else {
            content.append("如你使用高级权益，交易由 Apple App Store 处理。我们不会获取或保存你的付款账号、银行卡信息或 Apple ID 密码。")
        }

        return content
    }

    private var termsParagraphs: [String] {
        var content = [
            "想恋爱用于娱乐、自我表达和现场氛围展示，不应被理解为确定性承诺或专业建议。",
            "请在演唱会、机场等公共场景中遵守现场秩序，避免遮挡他人视线或影响安全。"
        ]

        if purchaseManager.isProUnlocked {
            content.append("尊敬的 Pro 用户，你可以使用所有高级样式、高级模板、高级字体、无限收藏、自定义样式保存以及未来新增的高级样式更新。")
            content.append("高级权益为一次性购买后的永久解锁项目。你可以在设置页使用恢复购买，以重新校验当前 Apple ID 下的已购权益。")
        } else {
            content.append("高级权益为一次性购买后的永久解锁项目，购买、恢复购买和退款流程均由 Apple App Store 提供。")
            content.append("你可以在设置页使用恢复购买，以重新校验当前 Apple ID 下的已购权益。")
        }

        return content
    }
}

private extension LegalDocument {
    var subtitle: String {
        switch self {
        case .privacy:
            "了解本地数据保存和权益隐私说明"
        case .terms:
            "使用灯牌功能和高级权益前请阅读"
        }
    }
}

#Preview {
    NavigationStack {
        LegalTextView(document: .privacy)
            .environmentObject(PurchaseManager(autoStart: false))
    }
}
