import SwiftUI

enum AppColors {
    // Updated to match SplashView gradient palette
    static let teal = Color(hex: "#397CA7FF")
    static let seaMoss = Color(hex: "#8AB7A2FF")
    static let beige = Color(hex: "#F3EBDD")
    static let ink = Color(hex: "#233236")

    static let beigeShadow = Color.black.opacity(0.06)
    static let subtleShadow = Color.black.opacity(0.08)

    static var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [teal.opacity(0.25), seaMoss.opacity(0.25)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

enum AppSymbols {
    // Provide fallbacks for symbols that may vary by OS version
    static var insights: String { "cloud" } // fallback if thought.bubble missing
    static var add: String { "plus.circle.fill" }
    static var profile: String { "person.crop.circle" }
}

extension Color {
    init(hex: String) {
        let hexSanitized = hex.replacingOccurrences(of: "#", with: "")
        var int: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&int)
        let r, g, b: UInt64
        let a: UInt64
        switch hexSanitized.count {
        case 6:
            (r, g, b, a) = ((int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF, 0xFF)
        case 8:
            // Assume RGBA
            (r, g, b, a) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (r, g, b, a) = (0, 0, 0, 0xFF)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}


