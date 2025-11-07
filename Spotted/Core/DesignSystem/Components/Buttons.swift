import SwiftUI

// MARK: - Button Styles

/// Primary button - Main call-to-action
struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Typography.buttonLarge)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: DesignTokens.Size.Button.large)
            .background(
                LinearGradient(
                    colors: isEnabled ? [
                        DesignTokens.Colors.primary,
                        DesignTokens.Colors.secondary
                    ] : [
                        DesignTokens.Colors.buttonDisabled,
                        DesignTokens.Colors.buttonDisabled
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(DesignTokens.CornerRadius.lg)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .shadowMedium()
    }
}

/// Secondary button - Alternative actions
struct SecondaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Typography.buttonMedium)
            .foregroundColor(isEnabled ? DesignTokens.Colors.primary : DesignTokens.Colors.textDisabled)
            .frame(maxWidth: .infinity)
            .frame(height: DesignTokens.Size.Button.large)
            .background(DesignTokens.Colors.backgroundSecondary)
            .cornerRadius(DesignTokens.CornerRadius.lg)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .overlay(
                RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.lg)
                    .stroke(DesignTokens.Colors.primary.opacity(0.3), lineWidth: 1)
            )
    }
}

/// Tertiary button - Subtle actions
struct TertiaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Typography.buttonMedium)
            .foregroundColor(isEnabled ? DesignTokens.Colors.primary : DesignTokens.Colors.textDisabled)
            .frame(height: DesignTokens.Size.Button.medium)
            .padding(.horizontal, DesignTokens.Spacing.md)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

/// Ghost button - Minimal styling
struct GhostButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Typography.buttonSmall)
            .foregroundColor(DesignTokens.Colors.textSecondary)
            .opacity(configuration.isPressed ? 0.6 : 1.0)
    }
}

/// Destructive button - For delete/remove actions
struct DestructiveButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Typography.buttonMedium)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: DesignTokens.Size.Button.large)
            .background(isEnabled ? DesignTokens.Colors.error : DesignTokens.Colors.buttonDisabled)
            .cornerRadius(DesignTokens.CornerRadius.lg)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .shadowSmall()
    }
}

/// Icon button - Circular icon-only button
struct IconButtonStyle: ButtonStyle {
    let size: CGFloat

    init(size: CGFloat = 44) {
        self.size = size
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: size, height: size)
            .background(DesignTokens.Colors.backgroundSecondary)
            .clipShape(Circle())
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .shadowSmall()
    }
}

// MARK: - Button Components

/// Spotted Button - Reusable button component
struct SpottedButton: View {
    enum Style {
        case primary
        case secondary
        case tertiary
        case ghost
        case destructive
    }

    let title: String
    let style: Style
    let action: () -> Void

    var body: some View {
        Button(action: {
            HapticFeedback.buttonTap()
            action()
        }) {
            Text(title)
        }
        .buttonStyle(getButtonStyle())
    }

    private func getButtonStyle() -> AnyButtonStyle {
        switch style {
        case .primary:
            return AnyButtonStyle(PrimaryButtonStyle())
        case .secondary:
            return AnyButtonStyle(SecondaryButtonStyle())
        case .tertiary:
            return AnyButtonStyle(TertiaryButtonStyle())
        case .ghost:
            return AnyButtonStyle(GhostButtonStyle())
        case .destructive:
            return AnyButtonStyle(DestructiveButtonStyle())
        }
    }
}

/// Icon Button Component
struct SpottedIconButton: View {
    let icon: String
    let size: CGFloat
    let action: () -> Void

    init(icon: String, size: CGFloat = 44, action: @escaping () -> Void) {
        self.icon = icon
        self.size = size
        self.action = action
    }

    var body: some View {
        Button(action: {
            HapticFeedback.buttonTap()
            action()
        }) {
            Image(systemName: icon)
                .font(.system(size: size * 0.5))
                .foregroundColor(DesignTokens.Colors.textPrimary)
        }
        .buttonStyle(IconButtonStyle(size: size))
    }
}

/// Floating Action Button - FAB component
struct FloatingActionButton: View {
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: {
            HapticFeedback.buttonTap()
            action()
        }) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(
                    LinearGradient(
                        colors: [DesignTokens.Colors.primary, DesignTokens.Colors.secondary],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(Circle())
                .shadowLarge()
        }
    }
}

// MARK: - Button View Extensions

extension View {
    func primaryButtonStyle() -> some View {
        buttonStyle(PrimaryButtonStyle())
    }

    func secondaryButtonStyle() -> some View {
        buttonStyle(SecondaryButtonStyle())
    }

    func tertiaryButtonStyle() -> some View {
        buttonStyle(TertiaryButtonStyle())
    }

    func ghostButtonStyle() -> some View {
        buttonStyle(GhostButtonStyle())
    }

    func destructiveButtonStyle() -> some View {
        buttonStyle(DestructiveButtonStyle())
    }

    func iconButtonStyle(size: CGFloat = 44) -> some View {
        buttonStyle(IconButtonStyle(size: size))
    }
}

// MARK: - Preview

#Preview("Buttons") {
    VStack(spacing: DesignTokens.Spacing.lg) {
        SpottedButton(title: "Primary Button", style: .primary) {
            print("Primary tapped")
        }

        SpottedButton(title: "Secondary Button", style: .secondary) {
            print("Secondary tapped")
        }

        SpottedButton(title: "Tertiary Button", style: .tertiary) {
            print("Tertiary tapped")
        }

        SpottedButton(title: "Ghost Button", style: .ghost) {
            print("Ghost tapped")
        }

        SpottedButton(title: "Delete Account", style: .destructive) {
            print("Destructive tapped")
        }

        HStack(spacing: DesignTokens.Spacing.md) {
            SpottedIconButton(icon: "heart.fill") {
                print("Icon tapped")
            }

            SpottedIconButton(icon: "message.fill") {
                print("Message tapped")
            }

            SpottedIconButton(icon: "gearshape.fill") {
                print("Settings tapped")
            }
        }

        FloatingActionButton(icon: "plus") {
            print("FAB tapped")
        }
    }
    .padding()
}

// MARK: - Usage Examples
/*

 // Primary button
 SpottedButton(title: "Continue", style: .primary) {
     navigateNext()
 }

 // Secondary button
 SpottedButton(title: "Cancel", style: .secondary) {
     dismiss()
 }

 // Icon button
 SpottedIconButton(icon: "heart.fill") {
     likeUser()
 }

 // FAB
 FloatingActionButton(icon: "plus") {
     createNewPost()
 }

 // Using button styles directly
 Button("Custom Button") {
     action()
 }
 .primaryButtonStyle()

 */
