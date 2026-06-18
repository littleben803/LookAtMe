import SwiftUI

public struct PrimaryButton: View {
    private let title: String
    private let systemImage: String?
    private let isLoading: Bool
    private let action: () -> Void

    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.lookSkin) private var skin

    public init(
        _ title: String,
        systemImage: String? = nil,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.systemImage = systemImage
        self.isLoading = isLoading
        self.action = action
    }

    public var body: some View {
        Button(action: runAction) {
            HStack(spacing: LookSpacing.sm) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                } else if let systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                }

                Text(L10n.key(title))
                    .font(LookTypography.button)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
            }
            .frame(maxWidth: .infinity, minHeight: 56)
            .padding(.horizontal, LookSpacing.md)
            .foregroundColor(skin.textPrimary)
            .background(skin.primaryButtonGradient)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(skin.textSecondary.opacity(0.5), lineWidth: 1)
            )
            .shadow(color: skin.primary.opacity(0.46), radius: 16, y: 6)
            .opacity(isEnabled && !isLoading ? 1.0 : 0.52)
        }
        .buttonStyle(.plain)
        .disabled(isLoading)
    }

    private func runAction() {
        guard !isLoading else {
            return
        }
        action()
    }
}
