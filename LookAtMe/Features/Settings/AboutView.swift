import SwiftUI

struct AboutView: View {
    var body: some View {
        ZStack {
            LookScreenBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: LookSpacing.lg) {
                    NeonPageHeader(title: "关于想恋爱")

                    NeonCard {
                        VStack(spacing: LookSpacing.md) {
                            ZStack {
                                Circle()
                                    .fill(LookTheme.primaryButtonGradient)
                                    .frame(width: 76, height: 76)
                                    .shadow(color: LookTheme.Colors.primaryPink.opacity(0.62), radius: 18)

                                Image(systemName: "heart.text.square.fill")
                                    .font(.system(size: 32, weight: .bold, design: .rounded))
                                    .foregroundColor(LookTheme.Colors.textPrimary)
                            }

                            VStack(spacing: LookSpacing.xs) {
                                Text("想恋爱")
                                    .font(LookTypography.largeTitle)
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [
                                                LookTheme.Colors.textPrimary,
                                                LookTheme.Colors.softPink,
                                                LookTheme.Colors.primaryPink
                                            ],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .shadow(color: LookTheme.Colors.primaryPink.opacity(0.72), radius: 12)

                                Text("版本 2.0.0")
                                    .font(LookTypography.caption)
                                    .foregroundColor(LookTheme.Colors.textTertiary)
                            }

                            Text("把手机变成会发光的表白灯牌。经典 iOS 应用全新回归，为演唱会、表白、生日和接机场景提供更漂亮、更好用的灯牌体验。")
                                .font(LookTypography.body)
                                .foregroundColor(LookTheme.Colors.textSecondary)
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: .infinity)
                    }

                    VStack(spacing: LookSpacing.sm) {
                        NavigationLink(value: FeatureRoute.legal(.privacy)) {
                            legalRow("隐私政策", icon: "hand.raised.fill")
                        }
                        .buttonStyle(.plain)

                        NavigationLink(value: FeatureRoute.legal(.terms)) {
                            legalRow("用户协议", icon: "doc.text.fill")
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, LookSpacing.pageHorizontal)
                .padding(.top, LookSpacing.lg)
                .padding(.bottom, LookSpacing.tabContentBottomPadding)
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    private func legalRow(_ title: String, icon: String) -> some View {
        NeonCard {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(LookTheme.Colors.primaryPink)
                    .frame(width: 24)
                Text(title)
                    .font(LookTypography.body)
                    .foregroundColor(LookTheme.Colors.textPrimary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(LookTheme.Colors.textDisabled)
            }
        }
    }
}

#Preview {
    NavigationStack {
        AboutView()
    }
}
