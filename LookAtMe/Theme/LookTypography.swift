import SwiftUI

public enum LookTypography {
    public static let largeTitle = Font.system(size: 36, weight: .heavy, design: .rounded)
    public static let pageTitle = Font.system(size: 24, weight: .bold, design: .rounded)
    public static let sectionTitle = Font.system(size: 18, weight: .bold, design: .rounded)
    public static let body = Font.system(size: 15, weight: .regular, design: .rounded)
    public static let caption = Font.system(size: 12, weight: .regular, design: .rounded)
    public static let button = Font.system(size: 17, weight: .bold, design: .rounded)

    public static func ledDisplay(size: CGFloat = 96) -> Font {
        Font.system(size: size, weight: .heavy, design: .rounded)
    }
}

