import SwiftUI

struct ToastView: View {
    let message: String

    var body: some View {
        Text(message)
            .font(LookTypography.body)
            .foregroundColor(LookTheme.Colors.textPrimary)
            .padding(.horizontal, LookSpacing.lg)
            .padding(.vertical, LookSpacing.sm)
            .background(
                Capsule()
                    .fill(LookTheme.Colors.elevatedPurple.opacity(0.96))
                    .overlay(
                        Capsule()
                            .stroke(LookTheme.Colors.primaryPink.opacity(0.5), lineWidth: 1)
                    )
            )
            .shadow(color: LookTheme.Colors.primaryPink.opacity(0.35), radius: 14)
    }
}

extension View {
    func lookToast(
        _ message: Binding<String?>,
        duration: Duration = .seconds(1.7),
        topPadding: CGFloat = LookSpacing.lg,
        includesSafeAreaTop: Bool = true
    ) -> some View {
        modifier(
            LookToastModifier(
                message: message,
                duration: duration,
                topPadding: topPadding,
                includesSafeAreaTop: includesSafeAreaTop
            )
        )
    }
}

private struct LookToastModifier: ViewModifier {
    @Binding var message: String?
    let duration: Duration
    let topPadding: CGFloat
    let includesSafeAreaTop: Bool

    @State private var dismissTask: Task<Void, Never>?

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) {
                if let message {
                    LookToastContainer(
                        message: message,
                        topPadding: topPadding,
                        includesSafeAreaTop: includesSafeAreaTop
                    )
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(1000)
                }
            }
            .animation(.spring(response: 0.28, dampingFraction: 0.86), value: message)
            .onChange(of: message) { _, newValue in
                scheduleDismiss(for: newValue)
            }
            .onDisappear {
                dismissTask?.cancel()
            }
    }

    private func scheduleDismiss(for message: String?) {
        dismissTask?.cancel()

        guard message != nil else {
            return
        }

        dismissTask = Task { @MainActor in
            try? await Task.sleep(for: duration)
            guard !Task.isCancelled else {
                return
            }
            self.message = nil
        }
    }
}

private struct LookToastContainer: View {
    let message: String
    let topPadding: CGFloat
    let includesSafeAreaTop: Bool

    var body: some View {
        GeometryReader { proxy in
            VStack {
                ToastView(message: message)
                    .padding(.horizontal, LookSpacing.pageHorizontal)
                    .padding(.top, topPadding + (includesSafeAreaTop ? proxy.safeAreaInsets.top : 0))

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .allowsHitTesting(false)
    }
}
