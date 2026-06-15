import SwiftUI

struct NeonPageHeader<Trailing: View>: View {
    let title: String
    var subtitle: String?
    var showsBackButton: Bool = true
    let trailing: Trailing

    @Environment(\.dismiss) private var dismiss

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
                        .foregroundColor(LookTheme.Colors.textPrimary)
                        .frame(width: 42, height: 42)
                        .background(Circle().fill(LookTheme.Colors.cardPurple.opacity(0.92)))
                        .overlay(Circle().stroke(LookTheme.Colors.primaryPink.opacity(0.45), lineWidth: 1))
                        .shadow(color: LookTheme.Colors.primaryPink.opacity(0.24), radius: 12)
                }
                .buttonStyle(.plain)
            }

            VStack(alignment: .leading, spacing: LookSpacing.xxs) {
                Text(title)
                    .font(LookTypography.pageTitle)
                    .foregroundColor(LookTheme.Colors.textPrimary)

                if let subtitle {
                    Text(subtitle)
                        .font(LookTypography.caption)
                        .foregroundColor(LookTheme.Colors.textTertiary)
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
