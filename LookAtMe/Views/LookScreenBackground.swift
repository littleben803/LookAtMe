import SwiftUI

struct LookScreenBackground: View {
    @Environment(\.lookSkin) private var skin

    var body: some View {
        ZStack {
            Image(skin.assets.appBackground)
                .resizable()
                .scaledToFill()
                .opacity(skin.chrome.backgroundImageOpacity)
                .overlay(
                    LinearGradient(
                        colors: [
                            skin.background.opacity(1 - skin.chrome.glassOpacity * 0.45),
                            skin.background.opacity(0.78),
                            skin.background.opacity(0.94)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            RadialGradient(
                colors: [
                    skin.primary.opacity(0.18),
                    skin.secondary.opacity(0.08),
                    .clear
                ],
                center: .top,
                startRadius: 16,
                endRadius: 360
            )
            RadialGradient(
                colors: [
                    skin.secondary.opacity(0.14),
                    .clear
                ],
                center: .bottomTrailing,
                startRadius: 20,
                endRadius: 300
            )

            if skin.isNeonUtilityPro {
                UtilityGridOverlay()
                    .stroke(skin.secondary.opacity(0.08), lineWidth: 0.6)
                    .blendMode(.plusLighter)
            }
        }
        .ignoresSafeArea()
    }
}

private struct UtilityGridOverlay: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let step: CGFloat = 32
        var x = rect.minX
        while x <= rect.maxX {
            path.move(to: CGPoint(x: x, y: rect.minY))
            path.addLine(to: CGPoint(x: x, y: rect.maxY))
            x += step
        }

        var y = rect.minY
        while y <= rect.maxY {
            path.move(to: CGPoint(x: rect.minX, y: y))
            path.addLine(to: CGPoint(x: rect.maxX, y: y))
            y += step
        }
        return path
    }
}
