import SwiftUI

struct NeonTextInput: View {
    @Binding var text: String
    let limit: Int
    let placeholder: String
    let example: String

    @FocusState private var isFocused: Bool

    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: LookRadius.input, style: .continuous)
                .fill(LookTheme.Colors.cardPurple.opacity(0.92))
                .overlay(
                    RoundedRectangle(cornerRadius: LookRadius.input, style: .continuous)
                        .stroke(
                            isFocused ? LookTheme.Colors.primaryPink : LookTheme.Colors.primaryPink.opacity(0.38),
                            lineWidth: isFocused ? 1.5 : 1
                        )
                )
                .shadow(
                    color: LookTheme.Colors.primaryPink.opacity(isFocused ? 0.42 : 0.18),
                    radius: isFocused ? 18 : 10
                )

            VStack(alignment: .leading, spacing: LookSpacing.xs) {
                ZStack(alignment: .topLeading) {
                    if text.isEmpty {
                        VStack(alignment: .leading, spacing: LookSpacing.xxs) {
                            Text(placeholder)
                                .font(LookTypography.body)
                                .foregroundColor(LookTheme.Colors.textTertiary)
                            Text(example)
                                .font(LookTypography.caption)
                                .foregroundColor(LookTheme.Colors.hotPink.opacity(0.76))
                        }
                        .padding(.top, LookSpacing.xs)
                        .padding(.horizontal, LookSpacing.xs)
                    }

                    TextEditor(text: $text)
                        .font(LookTypography.body)
                        .foregroundColor(LookTheme.Colors.textPrimary)
                        .focused($isFocused)
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                        .tint(LookTheme.Colors.primaryPink)
                        .frame(minHeight: 76, maxHeight: 96)
                        .padding(.horizontal, LookSpacing.xxs)
                        .onChange(of: text) { _, newValue in
                            if newValue.count > limit {
                                text = String(newValue.prefix(limit))
                            }
                        }
                }

                HStack {
                    Spacer()
                    Text("\(text.count)/\(limit)")
                        .font(LookTypography.caption.monospacedDigit())
                        .foregroundColor(text.count >= limit ? LookTheme.Colors.warning : LookTheme.Colors.textTertiary)
                }
            }
            .padding(LookSpacing.md)
        }
        .frame(minHeight: 132)
    }
}

