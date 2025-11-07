import UIKit

// MARK: - Haptic Feedback Manager

enum HapticFeedback {

    // MARK: - Impact Feedback

    enum ImpactStyle {
        case light
        case medium
        case heavy
        case soft
        case rigid

        var generator: UIImpactFeedbackGenerator {
            switch self {
            case .light:
                return UIImpactFeedbackGenerator(style: .light)
            case .medium:
                return UIImpactFeedbackGenerator(style: .medium)
            case .heavy:
                return UIImpactFeedbackGenerator(style: .heavy)
            case .soft:
                return UIImpactFeedbackGenerator(style: .soft)
            case .rigid:
                return UIImpactFeedbackGenerator(style: .rigid)
            }
        }
    }

    static func impact(_ style: ImpactStyle = .medium) {
        let generator = style.generator
        generator.impactOccurred()
    }

    // MARK: - Notification Feedback

    enum NotificationStyle {
        case success
        case warning
        case error

        var type: UINotificationFeedbackGenerator.FeedbackType {
            switch self {
            case .success: return .success
            case .warning: return .warning
            case .error: return .error
            }
        }
    }

    static func notification(_ style: NotificationStyle) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(style.type)
    }

    // MARK: - Selection Feedback

    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }

    // MARK: - Common Actions

    static func success() {
        notification(.success)
    }

    static func error() {
        notification(.error)
    }

    static func buttonTap() {
        impact(.light)
    }

    static func cardSwipe() {
        impact(.medium)
    }

    static func match() {
        impact(.heavy)
    }

    static func like() {
        impact(.medium)
    }

    static func checkIn() {
        impact(.heavy)
    }
}
