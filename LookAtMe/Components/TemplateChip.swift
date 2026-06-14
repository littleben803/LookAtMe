import SwiftUI

struct TemplateChip: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundColor(LookTheme.Colors.textSecondary.opacity(0.96))
                .lineLimit(1)
                .minimumScaleFactor(0.68)
                .frame(maxWidth: .infinity, minHeight: 38)
                .padding(.horizontal, 8)
                .background(
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hex: "#201027").opacity(0.92),
                                    Color(hex: "#35102D").opacity(0.78)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .overlay(
                    Capsule()
                        .stroke(LookTheme.Colors.primaryPink.opacity(0.34), lineWidth: 0.8)
                )
                .shadow(color: LookTheme.Colors.primaryPink.opacity(0.22), radius: 9)
        }
        .buttonStyle(.plain)
    }
}
