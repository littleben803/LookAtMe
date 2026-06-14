import SwiftUI

struct BackgroundColorPickerView: View {
    @EnvironmentObject private var displayConfigStore: DisplayConfigStore

    private let colors = [
        "#0D0221", "#160428", "#1F0A36", "#2A0E4D",
        "#000000", "#101014", "#130F26", "#210B2C",
        "#2B061E", "#001D3D", "#02111B", "#151515"
    ]

    private let columns = Array(repeating: GridItem(.flexible(), spacing: LookSpacing.md), count: 4)

    var body: some View {
        ZStack {
            LookScreenBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: LookSpacing.lg) {
                    NeonPageHeader(
                        title: "背景颜色",
                        subtitle: "保持深色舞台感，避免户外使用刺眼"
                    ) {
                        Button("恢复默认") {
                            displayConfigStore.backgroundColorHex = LookTheme.Hex.backgroundBlack
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
                                    isSelected: displayConfigStore.backgroundColorHex.caseInsensitiveCompare(hex) == .orderedSame
                                ) {
                                    displayConfigStore.backgroundColorHex = hex
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
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: LookRadius.card, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: displayConfigStore.backgroundColorHex),
                            LookTheme.Colors.cardPurple.opacity(0.88)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: LookRadius.card, style: .continuous)
                        .stroke(LookTheme.neonBorderGradient, lineWidth: 1)
                )
                .shadow(color: LookTheme.Colors.primaryPink.opacity(0.24), radius: 18, y: 10)

            Text("想恋爱")
                .font(displayConfigStore.fontStyle.font(size: 34 * displayConfigStore.fontScale))
                .foregroundColor(Color(hex: displayConfigStore.textColorHex))
                .lineLimit(1)
                .minimumScaleFactor(0.58)
                .shadow(color: Color(hex: displayConfigStore.textColorHex).opacity(0.9), radius: 12)
                .padding(LookSpacing.lg)
        }
        .frame(height: 128)
    }
}

#Preview {
    NavigationStack {
        BackgroundColorPickerView()
            .environmentObject(DisplayConfigStore())
    }
}
