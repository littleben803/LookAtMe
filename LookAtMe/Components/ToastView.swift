import SwiftUI

struct ToastView: View {
    let message: String

    var body: some View {
        Text(message)
            .font(LookTypography.body)
            .foregroundColor(LookTheme.Colors.textPrimary)
            .padding(.horizontal, LookSpacing.lg)
            .padding(.vertical, LookSpacing.sm)
            .background(
                Capsule()
                    .fill(LookTheme.Colors.elevatedPurple.opacity(0.96))
                    .overlay(
                        Capsule()
                            .stroke(LookTheme.Colors.primaryPink.opacity(0.5), lineWidth: 1)
                    )
            )
            .shadow(color: LookTheme.Colors.primaryPink.opacity(0.35), radius: 14)
    }
}

