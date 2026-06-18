import SwiftUI

struct ColorSwatchButton: View {
    let hex: String
    let isSelected: Bool
    let action: () -> Void
    @Environment(\.lookSkin) private var skin

    var body: some View {
        Button(action: action) {
            Circle()
                .fill(Color(hex: hex))
                .frame(width: 42, height: 42)
                .overlay(
                    Circle()
                        .stroke(
                            isSelected ? skin.primary : skin.textPrimary.opacity(0.22),
                            lineWidth: isSelected ? 3 : 1
                        )
                )
                .overlay(
                    Circle()
                        .stroke(skin.background.opacity(0.42), lineWidth: 1)
                        .padding(5)
                )
                .shadow(color: Color(hex: hex).opacity(isSelected ? 0.72 : 0.28), radius: isSelected ? 14 : 7)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(hex)
    }
}
