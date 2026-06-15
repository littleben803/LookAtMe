import SwiftUI

struct TextColorPickerView: View {
    @EnvironmentObject private var displayConfigStore: DisplayConfigStore

    private let colors = [
        "#FF4DA6", "#FF73C5", "#FFB3DE", "#FF2D55",
        "#FF950A", "#FFD166", "#FFFF66", "#17C964",
        "#32D74B", "#00F2FF", "#5AC8FA", "#0A84FF",
        "#8B5CF6", "#BF5AF2", "#FFFFFF", "#EDEDED",
        "#BFB0D1", "#FF3B30", "#FF6B6B", "#F472B6",
        "#A78BFA", "#22D3EE", "#FDE68A", "#C084FC"
    ]

    private let columns = Array(repeating: GridItem(.flexible(), spacing: LookSpacing.md), count: 4)

    var body: some View {
        ZStack {
            LookScreenBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: LookSpacing.lg) {
                    NeonPageHeader(
                        title: L10n.Appearance.textColorTitle,
                        subtitle: L10n.Appearance.textColorSubtitle
                    ) {
                        Button(L10n.key(L10n.Common.resetDefault)) {
                            displayConfigStore.textColorHex = LookTheme.Hex.primaryPink
                        }
                        .font(LookTypography.caption.weight(.semibold))
                        .foregroundColor(LookTheme.Colors.hotPink)
                    }

                    previewCard

                    NeonCard {
                        LazyVGrid(columns: columns, spacing: LookSpacing.md) {
                            ForEach(colors, id: \.self) { hex in
                                ColorSwatchButton(
                                    hex: hex,
                                    isSelected: displayConfigStore.textColorHex.caseInsensitiveCompare(hex) == .orderedSame
                                ) {
                                    displayConfigStore.textColorHex = hex
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, LookSpacing.pageHorizontal)
                .padding(.top, LookSpacing.lg)
                .padding(.bottom, LookSpacing.tabContentBottomPadding)
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    private var previewCard: some View {
        NeonCard {
            VStack(alignment: .leading, spacing: LookSpacing.sm) {
                Text(L10n.key(L10n.Appearance.preview))
                    .font(LookTypography.caption)
                    .foregroundColor(LookTheme.Colors.textTertiary)

                Text(L10n.key(L10n.Appearance.previewMessage))
                    .font(displayConfigStore.fontStyle.font(size: 34 * displayConfigStore.fontScale))
                    .foregroundColor(Color(hex: displayConfigStore.textColorHex))
                    .lineLimit(1)
                    .minimumScaleFactor(0.58)
                    .shadow(color: Color(hex: displayConfigStore.textColorHex).opacity(0.9), radius: 12)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    NavigationStack {
        TextColorPickerView()
            .environmentObject(DisplayConfigStore())
    }
}
