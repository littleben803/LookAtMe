import SwiftUI

struct ProBadge: View {
    @Environment(\.lookSkin) private var skin

    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: "crown.fill")
                .font(.system(size: 8, weight: .bold))
            Text("Pro")
                .font(.system(size: 9, weight: .heavy, design: .rounded))
        }
        .foregroundColor(skin.background)
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [skin.pro, skin.primary],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
        )
    }
}
