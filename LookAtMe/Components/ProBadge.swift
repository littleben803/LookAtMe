import SwiftUI

struct ProBadge: View {
    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: "crown.fill")
                .font(.system(size: 8, weight: .bold))
            Text("Pro")
                .font(.system(size: 9, weight: .heavy, design: .rounded))
        }
        .foregroundColor(LookTheme.Colors.backgroundBlack)
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [LookTheme.Colors.warmYellow, LookTheme.Colors.hotPink],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
        )
    }
}

