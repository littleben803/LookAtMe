import SwiftUI

struct TemplateChip: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(LookTypography.caption)
                .foregroundColor(LookTheme.Colors.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.78)
                .frame(maxWidth: .infinity, minHeight: 36)
                .padding(.horizontal, LookSpacing.sm)
                .background(
                    Capsule()
                        .fill(LookTheme.Colors.cardPurple.opacity(0.9))
                )
                .overlay(
                    Capsule()
                        .stroke(LookTheme.Colors.primaryPink.opacity(0.38), lineWidth: 1)
                )
                .shadow(color: LookTheme.Colors.primaryPink.opacity(0.18), radius: 9)
        }
        .buttonStyle(.plain)
    }
}

