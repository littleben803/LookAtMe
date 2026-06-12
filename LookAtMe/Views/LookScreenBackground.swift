import SwiftUI

struct LookScreenBackground: View {
    var body: some View {
        ZStack {
            LookTheme.appBackground
            RadialGradient(
                colors: [
                    LookTheme.Colors.primaryPink.opacity(0.24),
                    LookTheme.Colors.neonPurple.opacity(0.12),
                    .clear
                ],
                center: .top,
                startRadius: 16,
                endRadius: 360
            )
            RadialGradient(
                colors: [
                    LookTheme.Colors.electricBlue.opacity(0.12),
                    .clear
                ],
                center: .bottomTrailing,
                startRadius: 20,
                endRadius: 300
            )
        }
        .ignoresSafeArea()
    }
}

