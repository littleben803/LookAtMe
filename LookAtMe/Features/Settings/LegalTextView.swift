import SwiftUI

struct LegalTextView: View {
    let document: LegalDocument

    @EnvironmentObject private var purchaseManager: PurchaseManager

    var body: some View {
        ZStack {
            LookScreenBackground()

            VStack(alignment: .leading, spacing: 0) {
                fixedHeader

                ScrollView(showsIndicators: false) {
                    NeonCard {
                        VStack(alignment: .leading, spacing: LookSpacing.md) {
                            ForEach(paragraphs, id: \.self) { paragraph in
                                Text(L10n.key(paragraph))
                                    .font(LookTypography.body)
                                    .foregroundColor(LookTheme.Colors.textSecondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
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
        NeonPageHeader(
            title: document.titleKey,
            subtitle: document.subtitleKey
        )
        .padding(.horizontal, LookSpacing.pageHorizontal)
        .padding(.top, LookSpacing.lg)
        .padding(.bottom, LookSpacing.md)
    }

    private var paragraphs: [String] {
        switch document {
        case .privacy:
            privacyParagraphs
        case .terms:
            termsParagraphs
        }
    }

    private var privacyParagraphs: [String] {
        var content = [
            L10n.Legal.privacyLocalFirst,
            L10n.Legal.privacyStorage,
            L10n.Legal.privacyClearCache
        ]

        if purchaseManager.isProUnlocked {
            content.append(L10n.Legal.privacyProUnlocked)
        } else {
            content.append(L10n.Legal.privacyProLocked)
        }

        return content
    }

    private var termsParagraphs: [String] {
        var content = [
            L10n.Legal.termsEntertainment,
            L10n.Legal.termsPublicSafety
        ]

        if purchaseManager.isProUnlocked {
            content.append(L10n.Legal.termsProUnlocked)
            content.append(L10n.Legal.termsProUnlockedRestore)
        } else {
            content.append(L10n.Legal.termsProLockedPurchase)
            content.append(L10n.Legal.termsProLockedRestore)
        }

        return content
    }
}

private extension LegalDocument {
    var subtitleKey: String {
        switch self {
        case .privacy:
            L10n.Legal.privacySubtitle
        case .terms:
            L10n.Legal.termsSubtitle
        }
    }
}

#Preview {
    NavigationStack {
        LegalTextView(document: .privacy)
            .environmentObject(PurchaseManager(autoStart: false))
    }
}
