import SwiftUI

struct SceneShortcutButton: View {
    let title: String
    let systemImage: String
    let tint: Color
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    RoundedRectangle(cornerRadius: 13, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hex: "#141020").opacity(0.96),
                                    Color(hex: "#211033").opacity(0.9)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 13, style: .continuous)
                                .stroke(isSelected ? tint.opacity(0.82) : LookTheme.Colors.neonPurple.opacity(0.18), lineWidth: isSelected ? 1.2 : 0.8)
                        )
                        .shadow(color: tint.opacity(isSelected ? 0.34 : 0.12), radius: isSelected ? 12 : 6)

                    Image(systemName: systemImage)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(tint)
                        .shadow(color: tint.opacity(0.82), radius: 8)
                }
                .frame(maxWidth: 56, minHeight: 52, maxHeight: 56)

                Text(title)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundColor(isSelected ? LookTheme.Colors.textPrimary : LookTheme.Colors.textTertiary.opacity(0.9))
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}
