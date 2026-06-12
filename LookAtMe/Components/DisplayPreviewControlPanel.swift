import SwiftUI

struct DisplayPreviewControlPanel: View {
    @Binding var isPlaying: Bool
    @Binding var speed: Double
    @Binding var fontScale: Double

    var body: some View {
        VStack(spacing: LookSpacing.md) {
            HStack(spacing: LookSpacing.md) {
                Button {
                    isPlaying.toggle()
                } label: {
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(LookTheme.Colors.textPrimary)
                        .frame(width: 54, height: 54)
                        .background(Circle().fill(LookTheme.primaryButtonGradient))
                        .shadow(color: LookTheme.Colors.primaryPink.opacity(0.52), radius: 16)
                }
                .buttonStyle(.plain)

                VStack(spacing: LookSpacing.sm) {
                    controlSlider(title: "速度", value: $speed, range: 0.6...1.8, valueText: "\(Int(speed * 100))%")
                    controlSlider(title: "大小", value: $fontScale, range: 0.7...1.35, valueText: "\(Int(fontScale * 100))%")
                }
            }
        }
        .padding(LookSpacing.md)
        .background(.ultraThinMaterial.opacity(0.58), in: RoundedRectangle(cornerRadius: 26, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(LookTheme.Colors.primaryPink.opacity(0.35), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.36), radius: 20, y: 10)
        .tint(LookTheme.Colors.primaryPink)
    }

    private func controlSlider(title: String, value: Binding<Double>, range: ClosedRange<Double>, valueText: String) -> some View {
        VStack(spacing: LookSpacing.xs) {
            HStack {
                Text(title)
                    .font(LookTypography.caption)
                    .foregroundColor(LookTheme.Colors.textSecondary)
                Spacer()
                Text(valueText)
                    .font(LookTypography.caption.monospacedDigit())
                    .foregroundColor(LookTheme.Colors.textTertiary)
            }
            Slider(value: value, in: range)
        }
    }
}

