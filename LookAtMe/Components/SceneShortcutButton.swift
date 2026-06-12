import SwiftUI

struct SceneShortcutButton: View {
    let title: String
    let systemImage: String
    let tint: Color
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: LookSpacing.xs) {
                ZStack {
                    RoundedRectangle(cornerRadius: LookRadius.chip, style: .continuous)
                        .fill(LookTheme.Colors.cardPurple.opacity(0.94))
                        .overlay(
                            RoundedRectangle(cornerRadius: LookRadius.chip, style: .continuous)
                                .stroke(isSelected ? tint : LookTheme.Colors.primaryPink.opacity(0.28), lineWidth: isSelected ? 1.4 : 1)
                        )
                        .frame(height: 54)
                        .shadow(color: tint.opacity(isSelected ? 0.34 : 0.12), radius: isSelected ? 14 : 8)

                    Image(systemName: systemImage)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(tint)
                }

                Text(title)
                    .font(LookTypography.caption)
                    .foregroundColor(isSelected ? LookTheme.Colors.textPrimary : LookTheme.Colors.textTertiary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }
        }
        .buttonStyle(.plain)
    }
}

