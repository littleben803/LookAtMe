import SwiftUI

public struct SectionHeader<Trailing: View>: View {
    private let title: String
    private let subtitle: String?
    private let trailing: Trailing

    public init(
        _ title: String,
        subtitle: String? = nil,
        @ViewBuilder trailing: () -> Trailing
    ) {
        self.title = title
        self.subtitle = subtitle
        self.trailing = trailing()
    }

    public var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: LookSpacing.md) {
            VStack(alignment: .leading, spacing: LookSpacing.xxs) {
                Text(title)
                    .font(LookTypography.sectionTitle)
                    .foregroundColor(LookTheme.Colors.textPrimary)

                if let subtitle {
                    Text(subtitle)
                        .font(LookTypography.caption)
                        .foregroundColor(LookTheme.Colors.textTertiary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            Spacer(minLength: LookSpacing.md)
            trailing
        }
    }
}

public extension SectionHeader where Trailing == EmptyView {
    init(_ title: String, subtitle: String? = nil) {
        self.init(title, subtitle: subtitle) {
            EmptyView()
        }
    }
}

