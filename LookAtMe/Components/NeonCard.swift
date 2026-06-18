import SwiftUI

public struct NeonCard<Content: View>: View {
    private let padding: CGFloat
    private let content: Content
    @Environment(\.lookSkin) private var skin

    public init(
        padding: CGFloat = LookSpacing.cardPadding,
        @ViewBuilder content: () -> Content
    ) {
        self.padding = padding
        self.content = content()
    }

    public var body: some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: skin.chrome.cardRadius, style: .continuous)
                    .fill(skin.surfaceGradient)
            )
            .overlay(
                RoundedRectangle(cornerRadius: skin.chrome.cardRadius, style: .continuous)
                    .stroke(skin.neonBorderGradient, lineWidth: 1)
            )
            .shadow(color: skin.primary.opacity(0.16), radius: 16, y: 8)
    }
}
