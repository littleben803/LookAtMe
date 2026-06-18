import SwiftUI

public struct SectionHeader<Trailing: View>: View {
    private let title: String
    private let subtitle: String?
    private let trailing: Trailing
    @Environment(\.lookSkin) private var skin

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
                Text(L10n.key(title))
                    .font(LookTypography.sectionTitle)
                    .foregroundColor(skin.textPrimary)

                if let subtitle {
                    Text(L10n.key(subtitle))
                        .font(LookTypography.caption)
                        .foregroundColor(skin.textTertiary)
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
