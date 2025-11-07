import SwiftUI

// MARK: - Design Tokens

/// Centralized design tokens for the Spotted app
/// Based on 8pt grid system and iOS Human Interface Guidelines
enum DesignTokens {

    // MARK: - Spacing (8pt Grid System)

    enum Spacing {
        /// 4pt - Minimal spacing
        static let xxxs: CGFloat = 4

        /// 8pt - Extra small spacing
        static let xxs: CGFloat = 8

        /// 12pt - Small spacing
        static let xs: CGFloat = 12

        /// 16pt - Standard spacing
        static let sm: CGFloat = 16

        /// 20pt - Medium spacing
        static let md: CGFloat = 20

        /// 24pt - Large spacing
        static let lg: CGFloat = 24

        /// 32pt - Extra large spacing
        static let xl: CGFloat = 32

        /// 40pt - Extra extra large spacing
        static let xxl: CGFloat = 40

        /// 48pt - Huge spacing
        static let xxxl: CGFloat = 48

        /// 64pt - Massive spacing
        static let huge: CGFloat = 64
    }

    // MARK: - Corner Radius

    enum CornerRadius {
        /// 4pt - Minimal radius
        static let xs: CGFloat = 4

        /// 8pt - Small radius (buttons, tags)
        static let sm: CGFloat = 8

        /// 12pt - Medium radius (cards, inputs)
        static let md: CGFloat = 12

        /// 16pt - Large radius (modal sheets)
        static let lg: CGFloat = 16

        /// 20pt - Extra large radius (pills, badges)
        static let xl: CGFloat = 20

        /// 24pt - Extra extra large radius
        static let xxl: CGFloat = 24

        /// Circle - Full circular (avatars)
        static let circle: CGFloat = 999
    }

    // MARK: - Colors

    enum Colors {

        // MARK: Brand Colors
        static let primary = Color(red: 252/255, green: 108/255, blue: 133/255)
        static let primaryDark = Color(red: 220/255, green: 90/255, blue: 115/255)
        static let primaryLight = Color(red: 255/255, green: 140/255, blue: 160/255)

        static let secondary = Color(red: 255/255, green: 149/255, blue: 0/255)
        static let secondaryDark = Color(red: 230/255, green: 130/255, blue: 0/255)
        static let secondaryLight = Color(red: 255/255, green: 170/255, blue: 40/255)

        // MARK: Semantic Colors
        static let success = Color.green
        static let successLight = Color(red: 52/255, green: 199/255, blue: 89/255)

        static let error = Color.red
        static let errorLight = Color(red: 255/255, green: 59/255, blue: 48/255)

        static let warning = Color.orange
        static let warningLight = Color(red: 255/255, green: 149/255, blue: 0/255)

        static let info = Color.blue
        static let infoLight = Color(red: 0/255, green: 122/255, blue: 255/255)

        // MARK: Neutral Colors
        static let textPrimary = Color.primary
        static let textSecondary = Color.secondary
        static let textTertiary = Color(UIColor.tertiaryLabel)
        static let textDisabled = Color(UIColor.quaternaryLabel)

        static let backgroundPrimary = Color(UIColor.systemBackground)
        static let backgroundSecondary = Color(UIColor.secondarySystemBackground)
        static let backgroundTertiary = Color(UIColor.tertiarySystemBackground)

        static let surfaceElevated = Color(UIColor.systemBackground)
        static let surfaceOverlay = Color.black.opacity(0.5)

        static let divider = Color(UIColor.separator)
        static let border = Color(UIColor.separator)

        // MARK: Interactive States
        static let linkDefault = Color.blue
        static let linkPressed = Color.blue.opacity(0.7)

        static let buttonDisabled = Color.gray.opacity(0.3)

        // MARK: Overlay Colors
        static let overlayLight = Color.white.opacity(0.1)
        static let overlayMedium = Color.white.opacity(0.2)
        static let overlayHeavy = Color.white.opacity(0.3)

        static let scrimLight = Color.black.opacity(0.2)
        static let scrimMedium = Color.black.opacity(0.4)
        static let scrimHeavy = Color.black.opacity(0.6)
    }

    // MARK: - Shadows

    enum Shadows {
        static let small = Shadow(
            color: Color.black.opacity(0.1),
            radius: 4,
            x: 0,
            y: 2
        )

        static let medium = Shadow(
            color: Color.black.opacity(0.15),
            radius: 8,
            x: 0,
            y: 4
        )

        static let large = Shadow(
            color: Color.black.opacity(0.2),
            radius: 16,
            x: 0,
            y: 8
        )

        static let extraLarge = Shadow(
            color: Color.black.opacity(0.25),
            radius: 24,
            x: 0,
            y: 12
        )
    }

    struct Shadow {
        let color: Color
        let radius: CGFloat
        let x: CGFloat
        let y: CGFloat
    }

    // MARK: - Animations

    enum Animations {
        /// Quick snap - 0.2s, 0.8 damping
        static let quick = Animation.spring(response: 0.2, dampingFraction: 0.8)

        /// Standard - 0.3s, 0.7 damping
        static let standard = Animation.spring(response: 0.3, dampingFraction: 0.7)

        /// Smooth - 0.4s, 0.7 damping
        static let smooth = Animation.spring(response: 0.4, dampingFraction: 0.7)

        /// Gentle - 0.5s, 0.8 damping
        static let gentle = Animation.spring(response: 0.5, dampingFraction: 0.8)

        /// Bouncy - 0.4s, 0.6 damping
        static let bouncy = Animation.spring(response: 0.4, dampingFraction: 0.6)

        /// Ease in-out - 0.3s
        static let easeInOut = Animation.easeInOut(duration: 0.3)

        /// Linear - 0.3s
        static let linear = Animation.linear(duration: 0.3)
    }

    // MARK: - Sizes

    enum Size {
        /// Icon sizes
        enum Icon {
            static let tiny: CGFloat = 12
            static let small: CGFloat = 16
            static let medium: CGFloat = 20
            static let large: CGFloat = 24
            static let extraLarge: CGFloat = 32
            static let huge: CGFloat = 48
        }

        /// Avatar sizes
        enum Avatar {
            static let tiny: CGFloat = 24
            static let small: CGFloat = 32
            static let medium: CGFloat = 40
            static let large: CGFloat = 56
            static let extraLarge: CGFloat = 80
            static let huge: CGFloat = 120
        }

        /// Button heights
        enum Button {
            static let small: CGFloat = 32
            static let medium: CGFloat = 44
            static let large: CGFloat = 56
        }

        /// Minimum touch target size (Apple HIG)
        static let minTouchTarget: CGFloat = 44
    }

    // MARK: - Opacity

    enum Opacity {
        static let invisible: Double = 0
        static let faint: Double = 0.1
        static let light: Double = 0.2
        static let medium: Double = 0.5
        static let heavy: Double = 0.8
        static let opaque: Double = 1.0
    }

    // MARK: - Z-Index Layers

    enum Layer {
        static let background: Double = 0
        static let content: Double = 1
        static let elevated: Double = 2
        static let overlay: Double = 3
        static let modal: Double = 4
        static let popover: Double = 5
        static let toast: Double = 6
        static let debug: Double = 999
    }
}

// MARK: - Design Token View Modifiers

extension View {

    // MARK: - Spacing

    func paddingXS() -> some View {
        self.padding(DesignTokens.Spacing.xs)
    }

    func paddingSM() -> some View {
        self.padding(DesignTokens.Spacing.sm)
    }

    func paddingMD() -> some View {
        self.padding(DesignTokens.Spacing.md)
    }

    func paddingLG() -> some View {
        self.padding(DesignTokens.Spacing.lg)
    }

    func paddingXL() -> some View {
        self.padding(DesignTokens.Spacing.xl)
    }

    // MARK: - Corner Radius

    func cornerRadiusSM() -> some View {
        self.cornerRadius(DesignTokens.CornerRadius.sm)
    }

    func cornerRadiusMD() -> some View {
        self.cornerRadius(DesignTokens.CornerRadius.md)
    }

    func cornerRadiusLG() -> some View {
        self.cornerRadius(DesignTokens.CornerRadius.lg)
    }

    func cornerRadiusXL() -> some View {
        self.cornerRadius(DesignTokens.CornerRadius.xl)
    }

    // MARK: - Shadows

    func shadowSmall() -> some View {
        let shadow = DesignTokens.Shadows.small
        return self.shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
    }

    func shadowMedium() -> some View {
        let shadow = DesignTokens.Shadows.medium
        return self.shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
    }

    func shadowLarge() -> some View {
        let shadow = DesignTokens.Shadows.large
        return self.shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
    }

    func shadowExtraLarge() -> some View {
        let shadow = DesignTokens.Shadows.extraLarge
        return self.shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
    }
}

// MARK: - Usage Examples
/*

 // Spacing
 Text("Hello")
     .paddingSM()

 VStack(spacing: DesignTokens.Spacing.md) {
     // content
 }

 // Colors
 Text("Primary")
     .foregroundColor(DesignTokens.Colors.primary)

 Rectangle()
     .fill(DesignTokens.Colors.backgroundSecondary)

 // Corner Radius
 RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.md)

 // Shadows
 Card()
     .shadowMedium()

 // Animations
 withAnimation(DesignTokens.Animations.smooth) {
     isExpanded.toggle()
 }

 // Sizes
 Image(systemName: "heart.fill")
     .font(.system(size: DesignTokens.Size.Icon.medium))

 Circle()
     .frame(width: DesignTokens.Size.Avatar.large, height: DesignTokens.Size.Avatar.large)

 */
