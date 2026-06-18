import SwiftUI

struct SceneShortcutButton: View {
    let title: String
    let systemImage: String
    let tint: Color
    let isSelected: Bool
    let action: () -> Void
    @Environment(\.lookSkin) private var skin

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    RoundedRectangle(cornerRadius: skin.chrome.controlRadius + 4, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    skin.card.opacity(0.96),
                                    skin.cardElevated.opacity(0.9)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: skin.chrome.controlRadius + 4, style: .continuous)
                                .stroke(isSelected ? tint.opacity(0.82) : skin.secondary.opacity(0.18), lineWidth: isSelected ? 1.2 : 0.8)
                        )
                        .shadow(color: tint.opacity(isSelected ? 0.34 : 0.12), radius: isSelected ? 12 : 6)

                    Image(systemName: systemImage)
                        .font(.system(size: skin.isNeonUtilityPro ? 21 : 24, weight: .bold, design: .rounded))
                        .foregroundColor(tint)
                        .shadow(color: tint.opacity(0.82), radius: 8)
                }
                .frame(maxWidth: 56, minHeight: 52, maxHeight: 56)

                Text(L10n.key(title))
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundColor(isSelected ? skin.textPrimary : skin.textTertiary.opacity(0.9))
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}
