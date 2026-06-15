import SwiftUI

public struct PrimaryButton: View {
    private let title: String
    private let systemImage: String?
    private let isLoading: Bool
    private let action: () -> Void

    @Environment(\.isEnabled) private var isEnabled

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
            .foregroundColor(LookTheme.Colors.textPrimary)
            .background(LookTheme.primaryButtonGradient)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(LookTheme.Colors.softPink.opacity(0.55), lineWidth: 1)
            )
            .lookShadow(LookShadow.neon)
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
