import SwiftUI

struct SettingsRow: View {
    let title: String
    var value: String? = nil
    var colorSwatch: Color? = nil
    var systemImage: String? = nil
    var action: (() -> Void)? = nil
    @Environment(\.lookSkin) private var skin

    var body: some View {
        Button(action: { action?() }) {
            HStack(spacing: LookSpacing.sm) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(skin.primary)
                        .frame(width: 22)
                }

                Text(L10n.key(title))
                    .font(LookTypography.body)
                    .foregroundColor(skin.textPrimary)

                Spacer()

                if let colorSwatch {
                    Circle()
                        .fill(colorSwatch)
                        .frame(width: 18, height: 18)
                        .overlay(Circle().stroke(skin.textPrimary.opacity(0.32), lineWidth: 1))
                }

                if let value {
                    Text(value)
                        .font(LookTypography.caption)
                        .foregroundColor(skin.textTertiary)
                }

                if action != nil {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(skin.textTertiary.opacity(0.66))
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
    @Environment(\.lookSkin) private var skin

    var body: some View {
        HStack(spacing: LookSpacing.sm) {
            Text(L10n.key(title))
                .font(LookTypography.body)
                .foregroundColor(skin.textPrimary)
            Spacer()
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(skin.primary)
        }
        .padding(.vertical, LookSpacing.xs)
    }
}
