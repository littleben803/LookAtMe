import SwiftUI

public enum LookTheme {
    public enum Colors {
        public static let primaryPink = Color(hex: "#FF4DA6")
        public static let hotPink = Color(hex: "#FF73C5")
        public static let softPink = Color(hex: "#FFB3DE")

        public static let neonPurple = Color(hex: "#8B5CF6")
        public static let electricBlue = Color(hex: "#00F2FF")
        public static let warmYellow = Color(hex: "#FFD166")

        public static let backgroundBlack = Color(hex: "#0D0221")
        public static let backgroundPurple = Color(hex: "#160428")
        public static let cardPurple = Color(hex: "#1F0A36")
        public static let elevatedPurple = Color(hex: "#2A0E4D")

        public static let textPrimary = Color(hex: "#FFFFFF")
        public static let textSecondary = Color(hex: "#EDEDED")
        public static let textTertiary = Color(hex: "#BFB0D1")
        public static let textDisabled = Color(hex: "#7D7791")

        public static let success = Color(hex: "#17C964")
        public static let warning = Color(hex: "#FF9F0A")
        public static let danger = Color(hex: "#FF2D55")
        public static let info = Color(hex: "#5AC8FA")
    }

    public static let appBackground = LinearGradient(
        colors: [
            Colors.backgroundBlack,
            Colors.backgroundPurple
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    public static let primaryButtonGradient = LinearGradient(
        colors: [
            Colors.primaryPink,
            Colors.neonPurple
        ],
        startPoint: .leading,
        endPoint: .trailing
    )

    public static let neonBorderGradient = LinearGradient(
        colors: [
            Colors.primaryPink.opacity(0.85),
            Colors.electricBlue.opacity(0.65),
            Colors.neonPurple.opacity(0.75)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

