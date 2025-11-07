import SwiftUI

// MARK: - Card Styles

/// Card style enum
enum CardStyle {
    case elevated
    case flat
    case outlined
}

/// Elevated Card - Standard card with shadow
struct ElevatedCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(DesignTokens.Colors.backgroundPrimary)
            .cornerRadius(DesignTokens.CornerRadius.md)
            .shadowMedium()
    }
}

/// Flat Card - No shadow, just background
struct FlatCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(DesignTokens.Colors.backgroundSecondary)
            .cornerRadius(DesignTokens.CornerRadius.md)
    }
}

/// Outlined Card - Border with no shadow
struct OutlinedCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(DesignTokens.Colors.backgroundPrimary)
            .cornerRadius(DesignTokens.CornerRadius.md)
            .overlay(
                RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.md)
                    .stroke(DesignTokens.Colors.border, lineWidth: 1)
            )
    }
}

// MARK: - Card Component

/// Standard Card Component
struct SpottedCard<Content: View>: View {
    let style: CardStyle
    let padding: CGFloat
    let content: Content

    init(
        style: CardStyle = .elevated,
        padding: CGFloat = DesignTokens.Spacing.md,
        @ViewBuilder content: () -> Content
    ) {
        self.style = style
        self.padding = padding
        self.content = content()
    }

    var body: some View {
        Group {
            switch style {
            case .elevated:
                content
                    .padding(padding)
                    .modifier(ElevatedCardStyle())
            case .flat:
                content
                    .padding(padding)
                    .modifier(FlatCardStyle())
            case .outlined:
                content
                    .padding(padding)
                    .modifier(OutlinedCardStyle())
            }
        }
    }
}

// MARK: - Specialized Cards

/// User Card - For profile listings
struct UserCard: View {
    let userName: String
    let userAge: Int
    let userBio: String
    let profileImage: String
    let onTap: () -> Void

    var body: some View {
        Button(action: {
            HapticFeedback.buttonTap()
            onTap()
        }) {
            SpottedCard(style: .elevated) {
                HStack(spacing: DesignTokens.Spacing.md) {
                    // Profile image
                    Circle()
                        .fill(DesignTokens.Colors.backgroundSecondary)
                        .frame(width: 60, height: 60)
                        .overlay(
                            Image(systemName: "person.fill")
                                .foregroundColor(DesignTokens.Colors.textSecondary)
                        )

                    // User info
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 4) {
                            Text(userName)
                                .heading4()
                                .foregroundColor(DesignTokens.Colors.textPrimary)

                            Text("\(userAge)")
                                .bodyMedium()
                                .foregroundColor(DesignTokens.Colors.textSecondary)
                        }

                        Text(userBio)
                            .bodySmall()
                            .foregroundColor(DesignTokens.Colors.textSecondary)
                            .lineLimit(2)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .foregroundColor(DesignTokens.Colors.textTertiary)
                        .font(.system(size: 14))
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

/// Location Card - For places/check-ins
struct LocationCard: View {
    let locationName: String
    let locationAddress: String
    let activeUsers: Int
    let onTap: () -> Void

    var body: some View {
        Button(action: {
            HapticFeedback.buttonTap()
            onTap()
        }) {
            SpottedCard(style: .elevated) {
                HStack(spacing: DesignTokens.Spacing.md) {
                    // Location icon
                    Circle()
                        .fill(DesignTokens.Colors.primary.opacity(0.1))
                        .frame(width: 48, height: 48)
                        .overlay(
                            Image(systemName: "mappin.circle.fill")
                                .foregroundColor(DesignTokens.Colors.primary)
                                .font(.system(size: 24))
                        )

                    // Location info
                    VStack(alignment: .leading, spacing: 4) {
                        Text(locationName)
                            .heading4()
                            .foregroundColor(DesignTokens.Colors.textPrimary)

                        Text(locationAddress)
                            .captionMedium()
                            .foregroundColor(DesignTokens.Colors.textSecondary)
                            .lineLimit(1)

                        HStack(spacing: 4) {
                            Image(systemName: "person.2.fill")
                                .font(.system(size: 10))

                            Text("\(activeUsers) here now")
                                .captionSmall()
                        }
                        .foregroundColor(DesignTokens.Colors.primary)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .foregroundColor(DesignTokens.Colors.textTertiary)
                        .font(.system(size: 14))
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

/// Info Card - For tips/information
struct InfoCard: View {
    enum InfoType {
        case tip
        case warning
        case error
        case success

        var icon: String {
            switch self {
            case .tip: return "lightbulb.fill"
            case .warning: return "exclamationmark.triangle.fill"
            case .error: return "xmark.circle.fill"
            case .success: return "checkmark.circle.fill"
            }
        }

        var color: Color {
            switch self {
            case .tip: return DesignTokens.Colors.info
            case .warning: return DesignTokens.Colors.warning
            case .error: return DesignTokens.Colors.error
            case .success: return DesignTokens.Colors.success
            }
        }
    }

    let type: InfoType
    let title: String
    let message: String

    var body: some View {
        SpottedCard(style: .flat) {
            HStack(alignment: .top, spacing: DesignTokens.Spacing.sm) {
                Image(systemName: type.icon)
                    .foregroundColor(type.color)
                    .font(.system(size: 20))

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .labelMedium()
                        .foregroundColor(DesignTokens.Colors.textPrimary)

                    Text(message)
                        .captionLarge()
                        .foregroundColor(DesignTokens.Colors.textSecondary)
                }

                Spacer()
            }
        }
    }
}

// MARK: - Card View Extensions

extension View {
    func elevatedCard(padding: CGFloat = DesignTokens.Spacing.md) -> some View {
        self.padding(padding)
            .modifier(ElevatedCardStyle())
    }

    func flatCard(padding: CGFloat = DesignTokens.Spacing.md) -> some View {
        self.padding(padding)
            .modifier(FlatCardStyle())
    }

    func outlinedCard(padding: CGFloat = DesignTokens.Spacing.md) -> some View {
        self.padding(padding)
            .modifier(OutlinedCardStyle())
    }
}

// MARK: - Preview

#Preview("Cards") {
    ScrollView {
        VStack(spacing: DesignTokens.Spacing.lg) {
            Text("Card Variants")
                .heading1()

            // Elevated card
            SpottedCard(style: .elevated) {
                Text("Elevated Card")
                    .heading3()
            }

            // Flat card
            SpottedCard(style: .flat) {
                Text("Flat Card")
                    .heading3()
            }

            // Outlined card
            SpottedCard(style: .outlined) {
                Text("Outlined Card")
                    .heading3()
            }

            // User card
            UserCard(
                userName: "Sarah",
                userAge: 27,
                userBio: "Love exploring new coffee shops and hiking trails",
                profileImage: "person"
            ) {
                print("User tapped")
            }

            // Location card
            LocationCard(
                locationName: "Zürich Hauptbahnhof",
                locationAddress: "Bahnhofplatz, 8001 Zürich",
                activeUsers: 24
            ) {
                print("Location tapped")
            }

            // Info cards
            InfoCard(
                type: .tip,
                title: "Pro Tip",
                message: "Add 6 photos to get more matches!"
            )

            InfoCard(
                type: .success,
                title: "Profile Complete",
                message: "Your profile looks great!"
            )

            InfoCard(
                type: .warning,
                title: "Missing Photos",
                message: "Add more photos to improve your profile"
            )

            InfoCard(
                type: .error,
                title: "Connection Error",
                message: "Check your internet connection"
            )
        }
        .padding()
    }
}

// MARK: - Usage Examples
/*

 // Simple card
 SpottedCard {
     Text("Content")
 }

 // Card with style
 SpottedCard(style: .elevated) {
     VStack {
         Text("Title")
         Text("Description")
     }
 }

 // User card
 UserCard(
     userName: "John",
     userAge: 28,
     userBio: "Coffee enthusiast",
     profileImage: "user1"
 ) {
     navigateToProfile()
 }

 // Using extensions
 VStack {
     Text("Content")
 }
 .elevatedCard()

 */
