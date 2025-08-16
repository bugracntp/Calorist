import Foundation
import CoreGraphics

struct Constants {
    struct UI {
        static let cornerRadius: CGFloat = 12
        static let padding: CGFloat = 16
        static let smallPadding: CGFloat = 8
        static let largePadding: CGFloat = 24
    }
    
    struct Health {
        static let minHeight: Double = 100 // cm
        static let maxHeight: Double = 250 // cm
        static let minWeight: Double = 30 // kg
        static let maxWeight: Double = 300 // kg
        static let minAge: Int = 13
        static let maxAge: Int = 100
    }
    
    struct Colors {
        static let primary = "AccentColor"
        static let background = "BackgroundColor"
        static let text = "TextColor"
        static let secondaryText = "SecondaryTextColor"
    }
}
