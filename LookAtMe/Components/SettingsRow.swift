import SwiftUI

struct SettingsRow: View {
    let title: String
    var value: String? = nil
    var colorSwatch: Color? = nil
    var systemImage: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        Button(action: { action?() }) {
            HStack(spacing: LookSpacing.sm) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(LookTheme.Colors.primaryPink)
                        .frame(width: 22)
                }

                Text(L10n.key(title))
                    .font(LookTypography.body)
                    .foregroundColor(LookTheme.Colors.textPrimary)

                Spacer()

                if let colorSwatch {
                    Circle()
                        .fill(colorSwatch)
                        .frame(width: 18, height: 18)
                        .overlay(Circle().stroke(LookTheme.Colors.textPrimary.opacity(0.32), lineWidth: 1))
                }

                if let value {
                    Text(value)
                        .font(LookTypography.caption)
                        .foregroundColor(LookTheme.Colors.textTertiary)
                }

                if action != nil {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(LookTheme.Colors.textDisabled)
                }
            }
            .contentShape(Rectangle())
            .padding(.vertical, LookSpacing.sm)
        }
        .buttonStyle(.plain)
    }
}

struct SettingsToggleRow: View {
    let title: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: LookSpacing.sm) {
            Text(L10n.key(title))
                .font(LookTypography.body)
                .foregroundColor(LookTheme.Colors.textPrimary)
            Spacer()
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(LookTheme.Colors.primaryPink)
        }
        .padding(.vertical, LookSpacing.xs)
    }
}
