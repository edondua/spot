import SwiftUI

/// Test view to verify design system is working
struct TestDesignSystemView: View {
    @State private var name = ""
    @State private var showAlert = false

    var body: some View {
        ScrollView {
            VStack(spacing: DesignTokens.Spacing.lg) {
                // Test typography
                Text("Design System Test")
                    .displayLarge()
                    .foregroundColor(DesignTokens.Colors.primary)

                // Test button
                SpottedButton(title: "Primary Button", style: .primary) {
                    print("Button tapped!")
                    showAlert = true
                }

                SpottedButton(title: "Secondary Button", style: .secondary) {
                    print("Secondary tapped!")
                }

                // Test text field
                SpottedTextField(
                    label: "Name",
                    placeholder: "Enter your name",
                    text: $name,
                    icon: "person.fill"
                )

                // Test card
                SpottedCard(style: .elevated) {
                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                        Text("Card Title")
                            .heading3()

                        Text("This is a test card to verify the design system is working properly.")
                            .bodyMedium()
                            .foregroundColor(DesignTokens.Colors.textSecondary)
                    }
                }

                // Test badges
                HStack(spacing: DesignTokens.Spacing.sm) {
                    SpottedBadge("New", color: .primary, style: .filled)
                    SpottedBadge("Active", color: .success, style: .outlined)
                    SpottedBadge("Premium", color: .secondary, style: .subtle)
                }

                // Test icon button
                HStack(spacing: DesignTokens.Spacing.md) {
                    SpottedIconButton(icon: "heart.fill") {
                        print("Like!")
                    }

                    SpottedIconButton(icon: "xmark") {
                        print("Pass!")
                    }

                    SpottedIconButton(icon: "message.fill") {
                        print("Message!")
                    }
                }

                // Success message
                InfoCard(
                    type: .success,
                    title: "Design System Working! ✅",
                    message: "All components are loaded and ready to use."
                )
            }
            .padding(DesignTokens.Spacing.lg)
        }
        .dialog(isPresented: $showAlert) {
            AlertDialog(
                type: .success,
                title: "It Works!",
                message: "The design system is successfully integrated.",
                primaryButton: "Awesome!"
            ) {
                showAlert = false
            }
        }
    }
}

#Preview("Design System Test") {
    TestDesignSystemView()
}
