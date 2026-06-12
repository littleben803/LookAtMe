import SwiftUI

struct LEDDisplayPreviewView: View {
    let draft: BannerDraft

    @Environment(\.dismiss) private var dismiss
    @State private var isPlaying = true
    @State private var speed: Double
    @State private var fontScale: Double
    @State private var offsetX: CGFloat = 0

    init(draft: BannerDraft) {
        self.draft = draft
        self._speed = State(initialValue: draft.speed)
        self._fontScale = State(initialValue: draft.fontScale)
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                displayBackground

                if draft.selectedStyle.type == .heartRain {
                    heartRainLayer
                }

                displayText(width: proxy.size.width)

                VStack {
                    topBar
                    Spacer()
                    DisplayPreviewControlPanel(
                        isPlaying: $isPlaying,
                        speed: $speed,
                        fontScale: $fontScale
                    )
                    .padding(.horizontal, LookSpacing.pageHorizontal)
                    .padding(.bottom, LookSpacing.xl)
                }
            }
            .onAppear {
                startMarquee(width: proxy.size.width)
            }
            .onChange(of: isPlaying) { _, playing in
                if playing {
                    startMarquee(width: proxy.size.width)
                }
            }
            .onChange(of: speed) { _, _ in
                if isPlaying {
                    startMarquee(width: proxy.size.width)
                }
            }
        }
        .statusBarHidden()
    }

    private var displayBackground: some View {
        ZStack {
            LinearGradient(
                colors: [
                    draft.backgroundColor,
                    LookTheme.Colors.backgroundPurple,
                    LookTheme.Colors.backgroundBlack
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            RadialGradient(
                colors: [
                    displayAccentColor.opacity(0.22),
                    .clear
                ],
                center: .center,
                startRadius: 24,
                endRadius: 280
            )
            .ignoresSafeArea()
        }
    }

    private var topBar: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(LookTheme.Colors.textPrimary)
                    .frame(width: 42, height: 42)
                    .background(Circle().fill(LookTheme.Colors.cardPurple.opacity(0.86)))
                    .overlay(Circle().stroke(LookTheme.Colors.primaryPink.opacity(0.42), lineWidth: 1))
            }
            .buttonStyle(.plain)

            Spacer()

            Text(draft.selectedStyle.name)
                .font(LookTypography.caption)
                .foregroundColor(LookTheme.Colors.textTertiary)
                .padding(.horizontal, LookSpacing.sm)
                .padding(.vertical, LookSpacing.xs)
                .background(Capsule().fill(LookTheme.Colors.cardPurple.opacity(0.72)))
        }
        .padding(.horizontal, LookSpacing.pageHorizontal)
        .padding(.top, LookSpacing.lg)
    }

    private func displayText(width: CGFloat) -> some View {
        Text(draft.text)
            .font(.system(size: 70 * fontScale, weight: .heavy, design: .rounded))
            .lineLimit(1)
            .minimumScaleFactor(0.55)
            .foregroundStyle(textStyle)
            .shadow(color: displayAccentColor.opacity(1.0), radius: 9)
            .shadow(color: displayAccentColor.opacity(0.78), radius: 24)
            .shadow(color: displayAccentColor.opacity(0.42), radius: 44)
            .offset(x: shouldMarquee ? offsetX : 0)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, LookSpacing.pageHorizontal)
    }

    private var heartRainLayer: some View {
        TimelineView(.animation) { timeline in
            let seconds = timeline.date.timeIntervalSinceReferenceDate
            ZStack {
                ForEach(0..<18, id: \.self) { index in
                    let progress = (seconds * (0.08 + Double(index % 5) * 0.012) + Double(index) * 0.09).truncatingRemainder(dividingBy: 1)
                    Image(systemName: "heart.fill")
                        .font(.system(size: CGFloat(10 + (index % 4) * 6), weight: .bold))
                        .foregroundColor(index.isMultiple(of: 2) ? LookTheme.Colors.primaryPink.opacity(0.9) : LookTheme.Colors.hotPink.opacity(0.72))
                        .offset(
                            x: CGFloat((index % 6) * 56 - 150),
                            y: CGFloat(progress * 720 - 360)
                        )
                        .shadow(color: LookTheme.Colors.primaryPink.opacity(0.6), radius: 8)
                }
            }
        }
        .ignoresSafeArea()
    }

    private var displayAccentColor: Color {
        switch draft.selectedStyle.type {
        case .marquee:
            LookTheme.Colors.primaryPink
        case .neonBlink:
            LookTheme.Colors.electricBlue
        case .heartRain:
            LookTheme.Colors.hotPink
        case .rainbow:
            LookTheme.Colors.neonPurple
        }
    }

    private var textStyle: some ShapeStyle {
        switch draft.selectedStyle.type {
        case .rainbow:
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
        case .neonBlink:
            LinearGradient(
                colors: [
                    LookTheme.Colors.textPrimary,
                    LookTheme.Colors.electricBlue,
                    LookTheme.Colors.hotPink
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        default:
            LinearGradient(
                colors: [
                    LookTheme.Colors.textPrimary,
                    draft.textColor,
                    LookTheme.Colors.hotPink
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }

    private var shouldMarquee: Bool {
        draft.selectedStyle.type == .marquee && isPlaying
    }

    private func startMarquee(width: CGFloat) {
        guard draft.selectedStyle.type == .marquee else {
            return
        }

        offsetX = width
        let duration = max(3.0, 7.0 / speed)
        withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
            offsetX = -width
        }
    }
}

#Preview {
    LEDDisplayPreviewView(
        draft: BannerDraft(
            text: "周深我爱你！",
            selectedScene: .concert,
            selectedStyle: StyleStore().styles[0],
            textColor: LookTheme.Colors.primaryPink,
            backgroundColor: LookTheme.Colors.backgroundBlack,
            fontScale: 1,
            speed: 1
        )
    )
}

