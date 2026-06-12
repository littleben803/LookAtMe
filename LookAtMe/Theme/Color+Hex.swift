import Foundation
import SwiftUI

public extension Color {
    init(hex: String, opacity overrideOpacity: Double? = nil) {
        var value = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if value.hasPrefix("#") {
            value.removeFirst()
        }

        var rawValue: UInt64 = 0
        Scanner(string: value).scanHexInt64(&rawValue)

        let red: Double
        let green: Double
        let blue: Double
        let opacity: Double

        switch value.count {
        case 3:
            red = Double((rawValue & 0xF00) >> 8) / 15.0
            green = Double((rawValue & 0x0F0) >> 4) / 15.0
            blue = Double(rawValue & 0x00F) / 15.0
            opacity = 1.0
        case 6:
            red = Double((rawValue & 0xFF0000) >> 16) / 255.0
            green = Double((rawValue & 0x00FF00) >> 8) / 255.0
            blue = Double(rawValue & 0x0000FF) / 255.0
            opacity = 1.0
        case 8:
            opacity = Double((rawValue & 0xFF000000) >> 24) / 255.0
            red = Double((rawValue & 0x00FF0000) >> 16) / 255.0
            green = Double((rawValue & 0x0000FF00) >> 8) / 255.0
            blue = Double(rawValue & 0x000000FF) / 255.0
        default:
            red = 1.0
            green = 1.0
            blue = 1.0
            opacity = 1.0
        }

        self.init(.sRGB, red: red, green: green, blue: blue, opacity: overrideOpacity ?? opacity)
    }
}

