import CoreGraphics
import SwiftUI

public struct LookShadow {
    public let color: Color
    public let radius: CGFloat
    public let x: CGFloat
    public let y: CGFloat

    public init(color: Color, radius: CGFloat, x: CGFloat = 0, y: CGFloat = 0) {
        self.color = color
        self.radius = radius
        self.x = x
        self.y = y
    }

    public static let card = LookShadow(
        color: LookTheme.Colors.primaryPink.opacity(0.24),
        radius: 18,
        x: 0,
        y: 10
    )

    public static let neon = LookShadow(
        color: LookTheme.Colors.primaryPink.opacity(0.72),
        radius: 16
    )

    public static let floating = LookShadow(
        color: .black.opacity(0.35),
        radius: 22,
        x: 0,
        y: 12
    )
}

public extension View {
    func lookShadow(_ shadow: LookShadow) -> some View {
        self.shadow(
            color: shadow.color,
            radius: shadow.radius,
            x: shadow.x,
            y: shadow.y
        )
    }
}

