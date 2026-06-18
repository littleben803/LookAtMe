import SwiftUI

struct TemplateChip: View {
    let title: String
    var isPro: Bool = false
    let action: () -> Void
    @Environment(\.lookSkin) private var skin

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: skin.chrome.controlRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                isPro ? skin.pro.opacity(0.22) : skin.card.opacity(0.94),
                                isPro ? skin.primary.opacity(0.18) : skin.cardElevated.opacity(0.82)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: skin.chrome.controlRadius, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        isPro ? skin.pro.opacity(0.64) : skin.primary.opacity(0.48),
                                        isPro ? skin.primary.opacity(0.36) : skin.secondary.opacity(0.3)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 0.9
                            )
                    )

                VStack(alignment: .leading, spacing: 5) {
                    HStack(spacing: 5) {
                        Image(systemName: isPro ? "crown.fill" : skin.chrome.templateActionSymbol)
                            .font(.system(size: 8.5, weight: .black, design: .rounded))
                            .foregroundColor(isPro ? skin.pro : skin.secondary)

                        Text(isPro ? L10n.key(L10n.Common.pro) : L10n.key(L10n.Common.free))
                            .font(.system(size: 8.5, weight: .heavy, design: .rounded))
                            .foregroundColor(isPro ? skin.pro : skin.textTertiary)

                        Spacer(minLength: 0)
                    }

                    Text(title)
                        .font(.system(size: 12, weight: .heavy, design: .rounded))
                        .foregroundColor(isPro ? skin.pro.opacity(0.96) : skin.textSecondary.opacity(0.98))
                        .lineLimit(1)
                        .minimumScaleFactor(0.62)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)

                RoundedRectangle(cornerRadius: 2, style: .continuous)
                    .fill(isPro ? skin.pro : skin.primary)
                    .frame(width: 22, height: 3)
                    .padding(.top, 6)
                    .padding(.trailing, 8)
                    .shadow(color: (isPro ? skin.pro : skin.primary).opacity(0.58), radius: 6)
            }
            .frame(maxWidth: .infinity, minHeight: skin.isNeonUtilityPro ? 46 : 50)
            .shadow(color: (isPro ? skin.pro : skin.primary).opacity(isPro ? 0.26 : 0.16), radius: isPro ? 12 : 8, y: 3)
        }
        .buttonStyle(.plain)
    }
}
