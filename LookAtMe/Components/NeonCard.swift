import SwiftUI

public struct NeonCard<Content: View>: View {
    private let padding: CGFloat
    private let content: Content

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
                RoundedRectangle(cornerRadius: LookRadius.card, style: .continuous)
                    .fill(LookTheme.Colors.cardPurple)
            )
            .overlay(
                RoundedRectangle(cornerRadius: LookRadius.card, style: .continuous)
                    .stroke(LookTheme.neonBorderGradient, lineWidth: 1)
            )
            .lookShadow(LookShadow.card)
    }
}

