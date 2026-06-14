import SwiftUI

struct FontPickerView: View {
    @EnvironmentObject private var displayConfigStore: DisplayConfigStore

    var body: some View {
        ZStack {
            LookScreenBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: LookSpacing.lg) {
                    NeonPageHeader(
                        title: "字体选择",
                        subtitle: "不引入第三方字体，先使用系统字体组合"
                    )

                    VStack(spacing: LookSpacing.sm) {
                        ForEach(BannerFontStyle.allCases) { fontStyle in
                            fontRow(fontStyle)
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

    private func fontRow(_ fontStyle: BannerFontStyle) -> some View {
        Button {
            displayConfigStore.fontStyle = fontStyle
        } label: {
            NeonCard {
                HStack(spacing: LookSpacing.md) {
                    VStack(alignment: .leading, spacing: LookSpacing.xs) {
                        HStack {
                            Text(fontStyle.title)
                                .font(LookTypography.body.weight(.semibold))
                                .foregroundColor(LookTheme.Colors.textPrimary)
                            Spacer()
                            if displayConfigStore.fontStyle == fontStyle {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 19, weight: .bold))
                                    .foregroundColor(LookTheme.Colors.primaryPink)
                            }
                        }

                        Text(fontStyle.subtitle)
                            .font(LookTypography.caption)
                            .foregroundColor(LookTheme.Colors.textTertiary)

                        Text("周深我爱你！")
                            .font(fontStyle.font(size: 28))
                            .foregroundColor(Color(hex: displayConfigStore.textColorHex))
                            .lineLimit(1)
                            .minimumScaleFactor(0.58)
                            .shadow(color: Color(hex: displayConfigStore.textColorHex).opacity(0.78), radius: 10)
                            .padding(.top, LookSpacing.xs)
                    }
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: LookRadius.card, style: .continuous)
                    .stroke(displayConfigStore.fontStyle == fontStyle ? LookTheme.Colors.primaryPink : .clear, lineWidth: 1.8)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        FontPickerView()
            .environmentObject(DisplayConfigStore())
    }
}
