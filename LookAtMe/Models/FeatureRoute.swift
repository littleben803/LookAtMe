import Foundation

enum FeatureRoute: Hashable {
    case more
    case stylePicker
    case templateCenter
    case textColor
    case backgroundColor
    case fontPicker
    case displaySettings
    case help
    case about
    case legal(LegalDocument)
}

enum LegalDocument: String, Hashable, Identifiable {
    case privacy
    case terms

    var id: String { rawValue }

    var title: String {
        switch self {
        case .privacy:
            "隐私政策"
        case .terms:
            "用户协议"
        }
    }
}
