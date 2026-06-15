import SwiftUI

struct NeonTextInput: View {
    @Binding var text: String
    let limit: Int
    let placeholder: String
    let example: String

    @FocusState private var isFocused: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(hex: "#13091F").opacity(0.9))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(
                            isFocused ? LookTheme.Colors.primaryPink.opacity(0.86) : LookTheme.Colors.primaryPink.opacity(0.45),
                            lineWidth: isFocused ? 1.2 : 0.8
                        )
                )
                .shadow(
                    color: LookTheme.Colors.primaryPink.opacity(isFocused ? 0.28 : 0.14),
                    radius: isFocused ? 14 : 8
                )

            TextEditor(text: $text)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(LookTheme.Colors.textPrimary)
                .focused($isFocused)
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .tint(LookTheme.Colors.primaryPink)
                .padding(.horizontal, 12)
                .padding(.top, 10)
                .padding(.bottom, 26)
                .onChange(of: text) { _, newValue in
                    if newValue.count > limit {
                        text = String(newValue.prefix(limit))
                    }
                }

            if text.isEmpty {
                VStack(alignment: .leading, spacing: 0) {
                    Text(L10n.key(placeholder))
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(LookTheme.Colors.textTertiary.opacity(0.82))
                        .padding(.top, 16)
                        .padding(.horizontal, 16)

                    Spacer()

                    HStack(alignment: .center) {
                        Spacer()
                        Text(L10n.key(example))
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundColor(LookTheme.Colors.softPink.opacity(0.78))
                        Spacer(minLength: 36)
                    }
                    .padding(.bottom, 17)
                }
                .allowsHitTesting(false)
            }

            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Text("\(text.count)/\(limit)")
                        .font(.system(size: 12, weight: .semibold, design: .rounded).monospacedDigit())
                        .foregroundColor(text.count >= limit ? LookTheme.Colors.warning : LookTheme.Colors.textTertiary.opacity(0.82))
                }
                .padding(.trailing, 14)
                .padding(.bottom, 17)
            }
        }
        .frame(height: 94)
    }
}
