import SwiftUI

public struct EmptyStateView: View {
    private let systemImage: String
    private let title: String
    private let message: String?
    private let actionTitle: String?
    private let action: (() -> Void)?
    @Environment(\.lookSkin) private var skin

    public init(
        systemImage: String = "heart.text.square",
        title: String,
        message: String? = nil,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.systemImage = systemImage
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }

    public var body: some View {
        VStack(spacing: LookSpacing.md) {
            ZStack {
                Circle()
                    .fill(skin.cardElevated)
                    .frame(width: 72, height: 72)
                    .overlay(
                        Circle()
                            .stroke(skin.neonBorderGradient, lineWidth: 1)
                    )
                    .lookShadow(LookShadow.neon)

                Image(systemName: systemImage)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(skin.primary)
            }

            VStack(spacing: LookSpacing.xs) {
                Text(L10n.key(title))
                    .font(LookTypography.sectionTitle)
                    .foregroundColor(skin.textPrimary)
                    .multilineTextAlignment(.center)

                if let message {
                    Text(L10n.key(message))
                        .font(LookTypography.body)
                        .foregroundColor(skin.textTertiary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            if let actionTitle, let action {
                PrimaryButton(actionTitle, action: action)
                    .frame(maxWidth: 240)
                    .padding(.top, LookSpacing.xs)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, LookSpacing.xxl)
        .padding(.horizontal, LookSpacing.lg)
    }
}
