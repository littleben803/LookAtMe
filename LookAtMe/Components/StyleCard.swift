import SwiftUI

struct StyleCard: View {
    let style: BannerStyle
    let isSelected: Bool
    var previewColor: Color = LookTheme.Colors.primaryPink
    var fontStyle: BannerFontStyle = .roundedHeavy
    var isCompact: Bool = false
    var compactPreviewHeight: CGFloat = 62
    let action: () -> Void

    var body: some View {
        if isCompact {
            compactBody
        } else {
            regularBody
        }
    }

    private var compactBody: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack(alignment: .topTrailing) {
                    stylePreview
                        .frame(height: compactPreviewHeight)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(Color(hex: "#090614"))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .stroke(isSelected ? LookTheme.Colors.primaryPink : LookTheme.Colors.neonPurple.opacity(0.42), lineWidth: isSelected ? 1.6 : 0.9)
                        )
                        .shadow(color: LookTheme.Colors.primaryPink.opacity(isSelected ? 0.34 : 0.12), radius: isSelected ? 12 : 7)

                    StyleAccessTag(isPro: style.isPro)
                        .padding(.top, -5)
                        .padding(.trailing, -5)
                }

                Text(style.name)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(LookTheme.Colors.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
                    .frame(maxWidth: .infinity)
                    .frame(height: 18)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var regularBody: some View {
        Button(action: action) {
            ZStack(alignment: .topTrailing) {
                VStack(alignment: isCompact ? .center : .leading, spacing: isCompact ? 5 : LookSpacing.xs) {
                    stylePreview
                        .frame(height: isCompact ? 50 : 64)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: isCompact ? 10 : LookRadius.styleCard, style: .continuous)
                                .fill(Color(hex: "#090614"))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: isCompact ? 10 : LookRadius.styleCard, style: .continuous)
                                .stroke(LookTheme.Colors.neonPurple.opacity(isCompact ? 0.35 : 0.42), lineWidth: isCompact ? 0.8 : 1)
                        )

                    HStack(spacing: isCompact ? 2 : LookSpacing.xs) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(style.name)
                                .font(.system(size: isCompact ? 10.5 : 13, weight: .bold, design: .rounded))
                                .foregroundColor(LookTheme.Colors.textPrimary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.62)

                            Text(style.isPro ? "高级样式" : "免费")
                                .font(.system(size: isCompact ? 9 : 12, weight: .semibold, design: .rounded))
                                .foregroundColor(style.isPro ? LookTheme.Colors.warmYellow : LookTheme.Colors.textTertiary)
                        }
                        Spacer(minLength: isCompact ? 0 : LookSpacing.xs)
                    }
                }
                .padding(isCompact ? 6 : LookSpacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: isCompact ? 12 : LookRadius.styleCard, style: .continuous)
                        .fill(Color(hex: "#120A1E").opacity(0.94))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: isCompact ? 12 : LookRadius.styleCard, style: .continuous)
                        .stroke(isSelected ? LookTheme.Colors.primaryPink : LookTheme.Colors.primaryPink.opacity(0.24), lineWidth: isSelected ? (isCompact ? 1.2 : 1.8) : 0.8)
                )
                .shadow(color: LookTheme.Colors.primaryPink.opacity(isSelected ? 0.34 : 0.14), radius: isSelected ? (isCompact ? 12 : 16) : 7)

                if style.isPro {
                    ProBadge()
                        .scaleEffect(isCompact ? 0.72 : 1)
                        .padding(isCompact ? 2 : 8)
                }
            }
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var stylePreview: some View {
        switch style.type {
        case .marquee:
            Text(style.previewText)
                .font(fontStyle.font(size: isCompact ? 18 : 24))
                .foregroundColor(previewColor)
                .shadow(color: previewColor.opacity(0.9), radius: 8)
        case .neonBlink:
            Text(style.previewText)
                .font(fontStyle.font(size: isCompact ? 18 : 24))
                .foregroundStyle(
                    LinearGradient(
                        colors: [LookTheme.Colors.hotPink, LookTheme.Colors.electricBlue],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .shadow(color: LookTheme.Colors.electricBlue.opacity(0.8), radius: 8)
        case .breathing:
            ZStack {
                Circle()
                    .fill(previewColor.opacity(0.22))
                    .frame(width: isCompact ? 34 : 50, height: isCompact ? 34 : 50)
                    .blur(radius: 8)
                Text(style.previewText)
                    .font(fontStyle.font(size: isCompact ? 16 : 21))
                    .foregroundColor(previewColor)
                    .shadow(color: previewColor.opacity(0.95), radius: 10)
            }
        case .typewriter:
            HStack(spacing: 2) {
                ForEach(Array(style.previewText.enumerated()), id: \.offset) { index, character in
                    Text(String(character))
                        .font(fontStyle.font(size: isCompact ? 15 : 20))
                        .foregroundColor(index.isMultiple(of: 2) ? previewColor : LookTheme.Colors.softPink)
                        .shadow(color: previewColor.opacity(0.72), radius: 6)
                }
            }
        case .heartRain:
            ZStack {
                ForEach(0..<8, id: \.self) { index in
                    Image(systemName: "heart.fill")
                        .font(.system(size: CGFloat((isCompact ? 6 : 8) + index % 3 * 3), weight: .bold))
                        .foregroundColor(index.isMultiple(of: 2) ? LookTheme.Colors.primaryPink : LookTheme.Colors.hotPink)
                        .offset(x: CGFloat((index % 4) * (isCompact ? 12 : 18) - (isCompact ? 18 : 27)), y: CGFloat((index / 4) * (isCompact ? 13 : 18) - (isCompact ? 10 : 14)))
                        .shadow(color: LookTheme.Colors.primaryPink.opacity(0.8), radius: 6)
                }
            }
        case .rainbow:
            Text(style.previewText)
                .font(.system(size: isCompact ? 15 : 22, weight: .heavy, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            LookTheme.Colors.primaryPink,
                            LookTheme.Colors.warmYellow,
                            LookTheme.Colors.electricBlue,
                            LookTheme.Colors.neonPurple
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .shadow(color: LookTheme.Colors.neonPurple.opacity(0.9), radius: 8)
        case .starFlash:
            ZStack {
                Text(style.previewText)
                    .font(fontStyle.font(size: isCompact ? 15 : 20))
                    .foregroundColor(LookTheme.Colors.warmYellow)
                    .shadow(color: LookTheme.Colors.warmYellow.opacity(0.9), radius: 8)
                ForEach(0..<5, id: \.self) { index in
                    Image(systemName: "sparkle")
                        .font(.system(size: CGFloat(8 + index * 2), weight: .bold))
                        .foregroundColor(index.isMultiple(of: 2) ? LookTheme.Colors.primaryPink : LookTheme.Colors.electricBlue)
                        .offset(x: CGFloat(index * 16 - 32), y: CGFloat((index % 2) * 22 - 12))
                }
            }
        case .bulletFlyIn:
            VStack(alignment: .leading, spacing: isCompact ? 2 : 4) {
                ForEach(["看这里", "LOVE", "打CALL"], id: \.self) { text in
                    Text(text)
                        .font(fontStyle.font(size: isCompact ? 10 : 13))
                        .foregroundColor(text == style.previewText ? previewColor : LookTheme.Colors.textTertiary)
                        .shadow(color: previewColor.opacity(0.45), radius: 5)
                }
            }
        case .meteorShower:
            ZStack {
                ForEach(0..<5, id: \.self) { index in
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [
                                    LookTheme.Colors.warmYellow.opacity(0.95),
                                    LookTheme.Colors.hotPink.opacity(0.18)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: CGFloat((isCompact ? 22 : 32) + (index % 2) * 7), height: isCompact ? 3 : 4)
                        .rotationEffect(.degrees(-24))
                        .offset(
                            x: CGFloat(index * (isCompact ? 15 : 20) - (isCompact ? 30 : 40)),
                            y: CGFloat((index % 3) * (isCompact ? 11 : 14) - (isCompact ? 13 : 18))
                        )
                        .shadow(color: LookTheme.Colors.warmYellow.opacity(0.7), radius: 7)
                }

                Text(style.previewText)
                    .font(fontStyle.font(size: isCompact ? 14 : 19))
                    .foregroundColor(LookTheme.Colors.softPink)
                    .shadow(color: LookTheme.Colors.primaryPink.opacity(0.9), radius: 9)
            }
        case .laserSweep:
            ZStack {
                ForEach(0..<3, id: \.self) { index in
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [
                                    .clear,
                                    LookTheme.Colors.electricBlue.opacity(0.95),
                                    LookTheme.Colors.primaryPink.opacity(0.72),
                                    .clear
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: isCompact ? 72 : 104, height: CGFloat(3 + index))
                        .rotationEffect(.degrees(Double(index - 1) * 8))
                        .offset(y: CGFloat((index - 1) * (isCompact ? 9 : 12)))
                        .shadow(color: LookTheme.Colors.electricBlue.opacity(0.88), radius: 8)
                }

                Text(style.previewText)
                    .font(.system(size: isCompact ? 12 : 17, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: LookTheme.Colors.electricBlue.opacity(0.95), radius: 7)
            }
        case .fireworkBurst:
            ZStack {
                ForEach(0..<10, id: \.self) { index in
                    Capsule()
                        .fill(index.isMultiple(of: 2) ? LookTheme.Colors.primaryPink : LookTheme.Colors.warmYellow)
                        .frame(width: isCompact ? 2.4 : 3.4, height: isCompact ? 13 : 18)
                        .offset(y: -CGFloat(isCompact ? 17 : 23))
                        .rotationEffect(.degrees(Double(index) * 36))
                        .shadow(color: LookTheme.Colors.hotPink.opacity(0.8), radius: 7)
                }

                Circle()
                    .fill(LookTheme.Colors.hotPink.opacity(0.55))
                    .frame(width: isCompact ? 28 : 38, height: isCompact ? 28 : 38)
                    .blur(radius: 10)

                Text(style.previewText)
                    .font(.system(size: isCompact ? 13 : 18, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: LookTheme.Colors.primaryPink.opacity(0.95), radius: 8)
            }
        case .heartBeat:
            HStack(spacing: isCompact ? 5 : 8) {
                Image(systemName: "heart.fill")
                    .font(.system(size: isCompact ? 18 : 25, weight: .bold))
                    .foregroundColor(LookTheme.Colors.hotPink)
                    .shadow(color: LookTheme.Colors.hotPink.opacity(0.9), radius: 9)

                VStack(alignment: .leading, spacing: isCompact ? 2 : 3) {
                    Capsule()
                        .fill(LookTheme.Colors.hotPink)
                        .frame(width: isCompact ? 22 : 30, height: 3)
                    HStack(spacing: 2) {
                        ForEach(0..<5, id: \.self) { index in
                            Capsule()
                                .fill(index.isMultiple(of: 2) ? LookTheme.Colors.hotPink : LookTheme.Colors.softPink)
                                .frame(width: 3, height: CGFloat((isCompact ? 7 : 10) + (index % 3) * 5))
                        }
                    }
                    Text(style.previewText)
                        .font(fontStyle.font(size: isCompact ? 10 : 13))
                        .foregroundColor(LookTheme.Colors.textPrimary)
                }
            }
        case .auroraWave:
            ZStack {
                ForEach(0..<3, id: \.self) { index in
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [
                                    index.isMultiple(of: 2) ? LookTheme.Colors.electricBlue.opacity(0.82) : LookTheme.Colors.primaryPink.opacity(0.75),
                                    LookTheme.Colors.neonPurple.opacity(0.82)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: CGFloat((isCompact ? 74 : 108) - index * 12), height: CGFloat((isCompact ? 14 : 19) - index * 2))
                        .rotationEffect(.degrees(Double(index - 1) * 10))
                        .offset(y: CGFloat((index - 1) * (isCompact ? 9 : 12)))
                        .blur(radius: CGFloat(index + 1))
                        .shadow(color: LookTheme.Colors.neonPurple.opacity(0.7), radius: 10)
                }

                Text(style.previewText)
                    .font(fontStyle.font(size: isCompact ? 14 : 19))
                    .foregroundColor(.white)
                    .shadow(color: LookTheme.Colors.electricBlue.opacity(0.9), radius: 8)
            }
        case .bubblePop:
            ZStack {
                ForEach(0..<7, id: \.self) { index in
                    Circle()
                        .stroke(index.isMultiple(of: 2) ? LookTheme.Colors.softPink : LookTheme.Colors.electricBlue, lineWidth: isCompact ? 1.2 : 1.6)
                        .frame(
                            width: CGFloat((isCompact ? 9 : 12) + (index % 3) * 5),
                            height: CGFloat((isCompact ? 9 : 12) + (index % 3) * 5)
                        )
                        .offset(
                            x: CGFloat((index % 4) * (isCompact ? 15 : 19) - (isCompact ? 24 : 30)),
                            y: CGFloat((index / 4) * (isCompact ? 17 : 21) - (isCompact ? 8 : 11))
                        )
                        .shadow(color: LookTheme.Colors.electricBlue.opacity(0.58), radius: 5)
                }

                Text(style.previewText)
                    .font(fontStyle.font(size: isCompact ? 13 : 18))
                    .foregroundColor(LookTheme.Colors.softPink)
                    .shadow(color: LookTheme.Colors.hotPink.opacity(0.9), radius: 8)
            }
        case .spotlight:
            ZStack {
                Ellipse()
                    .fill(
                        RadialGradient(
                            colors: [
                                LookTheme.Colors.warmYellow.opacity(0.52),
                                LookTheme.Colors.primaryPink.opacity(0.2),
                                .clear
                            ],
                            center: .center,
                            startRadius: 1,
                            endRadius: isCompact ? 42 : 58
                        )
                    )
                    .frame(width: isCompact ? 76 : 110, height: isCompact ? 42 : 58)

                VStack(spacing: isCompact ? 1 : 2) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: isCompact ? 11 : 15, weight: .bold))
                        .foregroundColor(LookTheme.Colors.warmYellow)
                    Text(style.previewText)
                        .font(fontStyle.font(size: isCompact ? 15 : 20))
                        .foregroundColor(.white)
                        .shadow(color: LookTheme.Colors.warmYellow.opacity(0.95), radius: 9)
                }
            }
        case .glitchPulse:
            ZStack {
                ForEach(0..<3, id: \.self) { index in
                    Capsule()
                        .fill(index.isMultiple(of: 2) ? LookTheme.Colors.primaryPink.opacity(0.7) : LookTheme.Colors.electricBlue.opacity(0.7))
                        .frame(width: CGFloat((isCompact ? 36 : 52) - index * 7), height: isCompact ? 2 : 3)
                        .offset(x: CGFloat((index - 1) * 8), y: CGFloat((index - 1) * (isCompact ? 10 : 13)))
                }

                Text(style.previewText)
                    .font(.system(size: isCompact ? 16 : 22, weight: .black, design: .rounded))
                    .foregroundColor(LookTheme.Colors.electricBlue)
                    .offset(x: -2, y: 0)
                Text(style.previewText)
                    .font(.system(size: isCompact ? 16 : 22, weight: .black, design: .rounded))
                    .foregroundColor(LookTheme.Colors.hotPink)
                    .offset(x: 2, y: 0)
                Text(style.previewText)
                    .font(.system(size: isCompact ? 16 : 22, weight: .black, design: .rounded))
                    .foregroundColor(.white)
            }
        }
    }
}

private struct StyleAccessTag: View {
    let isPro: Bool

    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: isPro ? "crown.fill" : "sparkles")
                .font(.system(size: isPro ? 7.5 : 8.2, weight: .bold))
            Text(isPro ? "Pro" : "免费")
                .font(.system(size: 8, weight: .heavy, design: .rounded))
        }
        .foregroundColor(isPro ? LookTheme.Colors.backgroundBlack : LookTheme.Colors.textPrimary)
        .padding(.horizontal, 5)
        .padding(.vertical, 3)
        .background(
            Capsule()
                .fill(background)
        )
        .overlay(
            Capsule()
                .stroke(borderColor, lineWidth: 0.7)
        )
        .shadow(color: shadowColor, radius: 7)
    }

    private var background: LinearGradient {
        if isPro {
            LinearGradient(
                colors: [LookTheme.Colors.warmYellow, Color(hex: "#FFB703")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            LinearGradient(
                colors: [Color(hex: "#20112E").opacity(0.96), Color(hex: "#3A1633").opacity(0.96)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    private var borderColor: Color {
        isPro ? LookTheme.Colors.warmYellow.opacity(0.75) : LookTheme.Colors.primaryPink.opacity(0.5)
    }

    private var shadowColor: Color {
        isPro ? LookTheme.Colors.warmYellow.opacity(0.34) : LookTheme.Colors.primaryPink.opacity(0.2)
    }
}
