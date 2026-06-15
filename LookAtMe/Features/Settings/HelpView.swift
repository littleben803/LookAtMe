import SwiftUI

struct HelpView: View {
    private let items = [
        (L10n.Help.makeBannerTitle, L10n.Help.makeBannerMessage),
        (L10n.Help.concertTitle, L10n.Help.concertMessage),
        (L10n.Help.keepAwakeTitle, L10n.Help.keepAwakeMessage),
        (L10n.Help.landscapeTitle, L10n.Help.landscapeMessage),
        (L10n.Help.favoriteTitle, L10n.Help.favoriteMessage)
    ]

    var body: some View {
        ZStack {
            LookScreenBackground()

            VStack(alignment: .leading, spacing: 0) {
                fixedHeader

                ScrollView(showsIndicators: false) {
                    VStack(spacing: LookSpacing.sm) {
                        ForEach(items, id: \.0) { item in
                            NeonCard {
                                VStack(alignment: .leading, spacing: LookSpacing.xs) {
                                    Text(L10n.key(item.0))
                                        .font(LookTypography.sectionTitle)
                                        .foregroundColor(LookTheme.Colors.textPrimary)
                                    Text(L10n.key(item.1))
                                        .font(LookTypography.body)
                                        .foregroundColor(LookTheme.Colors.textTertiary)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                    .padding(.horizontal, LookSpacing.pageHorizontal)
                    .padding(.top, LookSpacing.lg)
                    .padding(.bottom, LookSpacing.tabContentBottomPadding)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    private var fixedHeader: some View {
        NeonPageHeader(title: L10n.Help.title, subtitle: L10n.Help.subtitle)
            .padding(.horizontal, LookSpacing.pageHorizontal)
            .padding(.top, LookSpacing.lg)
            .padding(.bottom, LookSpacing.md)
    }
}

#Preview {
    NavigationStack {
        HelpView()
    }
}
