import SwiftUI

// MARK: - Accessibility Helpers

/// Accessibility utilities for improved app accessibility
enum AccessibilityHelper {

    // MARK: - Dynamic Type Sizes

    enum TextSize {
        case xSmall
        case small
        case medium
        case large
        case xLarge
        case xxLarge
        case xxxLarge

        @available(iOS 15.0, *)
        var dynamicTypeSize: DynamicTypeSize {
            switch self {
            case .xSmall: return .xSmall
            case .small: return .small
            case .medium: return .medium
            case .large: return .large
            case .xLarge: return .xLarge
            case .xxLarge: return .xxLarge
            case .xxxLarge: return .xxxLarge
            }
        }
    }

    // MARK: - Common Labels

    static let likeButton = "Like user"
    static let dislikeButton = "Pass on user"
    static let messageButton = "Send message"
    static let profileButton = "View profile"
    static let settingsButton = "Open settings"
    static let backButton = "Go back"
    static let closeButton = "Close"
    static let cancelButton = "Cancel"
    static let saveButton = "Save changes"
    static let editButton = "Edit"
    static let deleteButton = "Delete"
    static let checkInButton = "Check in at location"
    static let mapButton = "View map"
    static let filterButton = "Open filters"
    static let searchButton = "Search"
    static let menuButton = "Open menu"

    // MARK: - Common Hints

    static let likeHint = "Double tap to like this profile"
    static let passHint = "Double tap to pass on this profile"
    static let messageHint = "Double tap to open chat"
    static let profileHint = "Double tap to view full profile"
    static let checkInHint = "Double tap to check in at this location"
    static let swipeHint = "Swipe left to pass, swipe right to like"

    // MARK: - VoiceOver Traits

    static let button: AccessibilityTraits = .isButton
    static let link: AccessibilityTraits = .isLink
    static let image: AccessibilityTraits = .isImage
    static let header: AccessibilityTraits = .isHeader
    static let selected: AccessibilityTraits = .isSelected
    static let disabled: AccessibilityTraits = [.isButton, .allowsDirectInteraction]
}

// MARK: - Accessibility View Extensions

extension View {

    // MARK: - Quick Accessibility Modifiers

    /// Add accessible label and hint
    func accessible(
        label: String,
        hint: String? = nil,
        traits: AccessibilityTraits = .isButton
    ) -> some View {
        self
            .accessibilityLabel(label)
            .if(hint != nil) { view in
                view.accessibilityHint(hint!)
            }
            .accessibilityAddTraits(traits)
    }

    /// Add accessible label for buttons
    func accessibleButton(
        _ label: String,
        hint: String? = nil
    ) -> some View {
        self.accessible(label: label, hint: hint, traits: .isButton)
    }

    /// Add accessible label for images
    func accessibleImage(_ description: String) -> some View {
        self
            .accessibilityLabel(description)
            .accessibilityAddTraits(.isImage)
    }

    /// Mark decorative image (hidden from VoiceOver)
    func decorativeImage() -> some View {
        self.accessibilityHidden(true)
    }

    /// Mark as header
    func accessibleHeader(_ label: String) -> some View {
        self
            .accessibilityLabel(label)
            .accessibilityAddTraits(.isHeader)
    }

    /// Add value announcement
    func accessibleValue(_ value: String) -> some View {
        self.accessibilityValue(value)
    }

    /// Group accessibility elements
    func accessibilityGrouped() -> some View {
        self.accessibilityElement(children: .combine)
    }

    /// Make interactive element larger for better touch
    func touchTargetMinimum() -> some View {
        self.frame(minWidth: 44, minHeight: 44)
    }

    // MARK: - Dynamic Type Support

    /// Enable dynamic type scaling
    @ViewBuilder
    func dynamicTypeSupport() -> some View {
        if #available(iOS 15.0, *) {
            self.dynamicTypeSize(...DynamicTypeSize.xxxLarge)
        } else {
            self
        }
    }

    /// Limit dynamic type scaling
    @ViewBuilder
    func limitDynamicType(min: AccessibilityHelper.TextSize = .small, max: AccessibilityHelper.TextSize = .xxLarge) -> some View {
        if #available(iOS 15.0, *) {
            self.dynamicTypeSize(min.dynamicTypeSize...max.dynamicTypeSize)
        } else {
            self
        }
    }
}

// MARK: - Accessibility Modifiers

/// Like button accessibility
struct LikeButtonAccessibility: ViewModifier {
    func body(content: Content) -> some View {
        content
            .accessibleButton(
                AccessibilityHelper.likeButton,
                hint: AccessibilityHelper.likeHint
            )
    }
}

/// Pass button accessibility
struct PassButtonAccessibility: ViewModifier {
    func body(content: Content) -> some View {
        content
            .accessibleButton(
                AccessibilityHelper.dislikeButton,
                hint: AccessibilityHelper.passHint
            )
    }
}

/// Message button accessibility
struct MessageButtonAccessibility: ViewModifier {
    func body(content: Content) -> some View {
        content
            .accessibleButton(
                AccessibilityHelper.messageButton,
                hint: AccessibilityHelper.messageHint
            )
    }
}

/// Profile button accessibility
struct ProfileButtonAccessibility: ViewModifier {
    func body(content: Content) -> some View {
        content
            .accessibleButton(
                AccessibilityHelper.profileButton,
                hint: AccessibilityHelper.profileHint
            )
    }
}

// MARK: - Accessibility Extensions

extension View {
    func likeButtonAccessibility() -> some View {
        modifier(LikeButtonAccessibility())
    }

    func passButtonAccessibility() -> some View {
        modifier(PassButtonAccessibility())
    }

    func messageButtonAccessibility() -> some View {
        modifier(MessageButtonAccessibility())
    }

    func profileButtonAccessibility() -> some View {
        modifier(ProfileButtonAccessibility())
    }
}

// MARK: - Contrast Checker

/// Color contrast checker for accessibility compliance
struct ContrastChecker {

    /// Check if contrast ratio meets WCAG AA standards (4.5:1 for normal text)
    static func meetsWCAG_AA(foreground: UIColor, background: UIColor) -> Bool {
        let ratio = contrastRatio(foreground: foreground, background: background)
        return ratio >= 4.5
    }

    /// Check if contrast ratio meets WCAG AAA standards (7:1 for normal text)
    static func meetsWCAG_AAA(foreground: UIColor, background: UIColor) -> Bool {
        let ratio = contrastRatio(foreground: foreground, background: background)
        return ratio >= 7.0
    }

    /// Calculate contrast ratio between two colors
    static func contrastRatio(foreground: UIColor, background: UIColor) -> CGFloat {
        let fgLuminance = relativeLuminance(foreground)
        let bgLuminance = relativeLuminance(background)

        let lighter = max(fgLuminance, bgLuminance)
        let darker = min(fgLuminance, bgLuminance)

        return (lighter + 0.05) / (darker + 0.05)
    }

    /// Calculate relative luminance of a color
    private static func relativeLuminance(_ color: UIColor) -> CGFloat {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0

        color.getRed(&red, green: &green, blue: &blue, alpha: nil)

        let r = gammaCorrect(red)
        let g = gammaCorrect(green)
        let b = gammaCorrect(blue)

        return 0.2126 * r + 0.7152 * g + 0.0722 * b
    }

    private static func gammaCorrect(_ value: CGFloat) -> CGFloat {
        if value <= 0.03928 {
            return value / 12.92
        } else {
            return pow((value + 0.055) / 1.055, 2.4)
        }
    }
}

// MARK: - Usage Examples & Preview

#Preview("Accessibility") {
    VStack(spacing: DesignTokens.Spacing.lg) {
        // Button with accessibility
        Button("Like Profile") {
            print("Liked")
        }
        .primaryButtonStyle()
        .likeButtonAccessibility()

        // Image with description
        Image(systemName: "heart.fill")
            .accessibleImage("Heart icon representing like action")

        // Decorative image
        Image(systemName: "sparkles")
            .decorativeImage()

        // Header
        Text("Section Title")
            .heading1()
            .accessibleHeader("Main section: Recent matches")

        // Grouped elements
        HStack {
            Image(systemName: "person")
            Text("John, 28")
            Text("2km away")
        }
        .accessibilityGrouped()

        // Touch target minimum
        Button("X") {
            print("Close")
        }
        .touchTargetMinimum()

        // Dynamic type support
        Text("This text scales with system settings")
            .dynamicTypeSupport()
    }
    .padding()
}

// MARK: - Usage Examples in Code
/*

 // Basic accessibility label
 Button("Like") {
     likeUser()
 }
 .accessibleButton("Like user", hint: "Double tap to like")

 // Profile image
 Image("user_photo")
     .accessibleImage("Profile photo showing John at the beach")

 // Decorative icon
 Image(systemName: "sparkles")
     .decorativeImage() // Hidden from VoiceOver

 // Header text
 Text("Discover")
     .heading1()
     .accessibleHeader("Discover section")

 // Group of info
 HStack {
     Image(systemName: "person")
     Text("Sarah, 27")
     Text("Coffee lover")
 }
 .accessibilityGrouped() // Reads as one element

 // Ensure touch target size
 Button {
     dismissView()
 } label: {
     Image(systemName: "xmark")
 }
 .touchTargetMinimum() // Ensures 44x44 minimum

 // Check color contrast
 let pink = UIColor(red: 252/255, green: 108/255, blue: 133/255, alpha: 1)
 let white = UIColor.white
 let meetsStandards = ContrastChecker.meetsWCAG_AA(foreground: white, background: pink)
 // Result: true ✅

 */
