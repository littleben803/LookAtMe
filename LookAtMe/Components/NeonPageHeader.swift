import SwiftUI

struct NeonPageHeader<Trailing: View>: View {
    let title: String
    var subtitle: String?
    var showsBackButton: Bool = true
    let trailing: Trailing

    @Environment(\.dismiss) private var dismiss
    @Environment(\.lookSkin) private var skin

    init(
        title: String,
        subtitle: String? = nil,
        showsBackButton: Bool = true,
        @ViewBuilder trailing: () -> Trailing
    ) {
        self.title = title
        self.subtitle = subtitle
        self.showsBackButton = showsBackButton
        self.trailing = trailing()
    }

    var body: some View {
        HStack(alignment: .center, spacing: LookSpacing.md) {
            if showsBackButton {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(skin.textPrimary)
                        .frame(width: 42, height: 42)
                        .background(Circle().fill(skin.card.opacity(0.92)))
                        .overlay(Circle().stroke(skin.primary.opacity(0.45), lineWidth: 1))
                        .shadow(color: skin.primary.opacity(0.24), radius: 12)
                }
                .buttonStyle(.plain)
            }

            VStack(alignment: .leading, spacing: LookSpacing.xxs) {
                Text(L10n.key(title))
                    .font(LookTypography.pageTitle)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [skin.textPrimary, skin.textSecondary, skin.primary.opacity(0.82)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)

                if let subtitle {
                    Text(L10n.key(subtitle))
                        .font(LookTypography.caption)
                        .foregroundColor(skin.textTertiary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            Spacer()
            trailing
        }
        .background {
            if showsBackButton {
                InteractiveSwipeBackEnabler()
                    .frame(width: 0, height: 0)
            }
        }
    }
}

extension NeonPageHeader where Trailing == EmptyView {
    init(title: String, subtitle: String? = nil, showsBackButton: Bool = true) {
        self.init(title: title, subtitle: subtitle, showsBackButton: showsBackButton) {
            EmptyView()
        }
    }
}
