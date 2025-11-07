import SwiftUI

// MARK: - Text Field Styles

/// Standard text field style
struct StandardTextFieldStyle: TextFieldStyle {
    @FocusState private var isFocused: Bool

    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(Typography.bodyLarge)
            .padding(DesignTokens.Spacing.sm)
            .background(DesignTokens.Colors.backgroundSecondary)
            .cornerRadius(DesignTokens.CornerRadius.md)
            .overlay(
                RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.md)
                    .stroke(
                        isFocused ? DesignTokens.Colors.primary : DesignTokens.Colors.border,
                        lineWidth: isFocused ? 2 : 1
                    )
            )
    }
}

// MARK: - Text Field Components

/// Spotted Text Field - Standard text input
struct SpottedTextField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var icon: String? = nil
    var errorMessage: String? = nil
    var maxLength: Int? = nil

    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xxs) {
            // Label
            if !label.isEmpty {
                Text(label)
                    .labelMedium()
                    .foregroundColor(DesignTokens.Colors.textSecondary)
            }

            // Text field with icon
            HStack(spacing: DesignTokens.Spacing.sm) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: DesignTokens.Size.Icon.medium))
                        .foregroundColor(isFocused ? DesignTokens.Colors.primary : DesignTokens.Colors.textTertiary)
                }

                TextField(placeholder, text: $text)
                    .font(Typography.bodyLarge)
                    .foregroundColor(DesignTokens.Colors.textPrimary)
                    .focused($isFocused)
                    .onChange(of: text) { _, newValue in
                        if let maxLength = maxLength, newValue.count > maxLength {
                            text = String(newValue.prefix(maxLength))
                        }
                    }

                // Character count
                if let maxLength = maxLength {
                    Text("\(text.count)/\(maxLength)")
                        .captionSmall()
                        .foregroundColor(
                            text.count >= maxLength ? DesignTokens.Colors.warning : DesignTokens.Colors.textTertiary
                        )
                }
            }
            .padding(DesignTokens.Spacing.sm)
            .background(DesignTokens.Colors.backgroundSecondary)
            .cornerRadius(DesignTokens.CornerRadius.md)
            .overlay(
                RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.md)
                    .stroke(
                        errorMessage != nil ? DesignTokens.Colors.error :
                        isFocused ? DesignTokens.Colors.primary : DesignTokens.Colors.border,
                        lineWidth: isFocused || errorMessage != nil ? 2 : 1
                    )
            )

            // Error message
            if let errorMessage = errorMessage {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.system(size: 12))

                    Text(errorMessage)
                        .captionMedium()
                }
                .foregroundColor(DesignTokens.Colors.error)
            }
        }
    }
}

/// Spotted Secure Field - Password input
struct SpottedSecureField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var errorMessage: String? = nil

    @State private var isSecure: Bool = true
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xxs) {
            // Label
            if !label.isEmpty {
                Text(label)
                    .labelMedium()
                    .foregroundColor(DesignTokens.Colors.textSecondary)
            }

            // Secure field
            HStack(spacing: DesignTokens.Spacing.sm) {
                Image(systemName: "lock.fill")
                    .font(.system(size: DesignTokens.Size.Icon.medium))
                    .foregroundColor(isFocused ? DesignTokens.Colors.primary : DesignTokens.Colors.textTertiary)

                if isSecure {
                    SecureField(placeholder, text: $text)
                        .font(Typography.bodyLarge)
                        .foregroundColor(DesignTokens.Colors.textPrimary)
                        .focused($isFocused)
                } else {
                    TextField(placeholder, text: $text)
                        .font(Typography.bodyLarge)
                        .foregroundColor(DesignTokens.Colors.textPrimary)
                        .focused($isFocused)
                }

                // Toggle visibility button
                Button(action: {
                    isSecure.toggle()
                    HapticFeedback.impact(.light)
                }) {
                    Image(systemName: isSecure ? "eye.slash.fill" : "eye.fill")
                        .font(.system(size: DesignTokens.Size.Icon.medium))
                        .foregroundColor(DesignTokens.Colors.textTertiary)
                }
            }
            .padding(DesignTokens.Spacing.sm)
            .background(DesignTokens.Colors.backgroundSecondary)
            .cornerRadius(DesignTokens.CornerRadius.md)
            .overlay(
                RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.md)
                    .stroke(
                        errorMessage != nil ? DesignTokens.Colors.error :
                        isFocused ? DesignTokens.Colors.primary : DesignTokens.Colors.border,
                        lineWidth: isFocused || errorMessage != nil ? 2 : 1
                    )
            )

            // Error message
            if let errorMessage = errorMessage {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.system(size: 12))

                    Text(errorMessage)
                        .captionMedium()
                }
                .foregroundColor(DesignTokens.Colors.error)
            }
        }
    }
}

/// Spotted Text Editor - Multi-line text input
struct SpottedTextEditor: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var maxLength: Int? = nil
    var minHeight: CGFloat = 100

    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xxs) {
            // Label with character count
            HStack {
                if !label.isEmpty {
                    Text(label)
                        .labelMedium()
                        .foregroundColor(DesignTokens.Colors.textSecondary)
                }

                Spacer()

                if let maxLength = maxLength {
                    Text("\(text.count)/\(maxLength)")
                        .captionSmall()
                        .foregroundColor(
                            text.count >= maxLength ? DesignTokens.Colors.warning : DesignTokens.Colors.textTertiary
                        )
                }
            }

            // Text editor
            ZStack(alignment: .topLeading) {
                // Placeholder
                if text.isEmpty {
                    Text(placeholder)
                        .font(Typography.bodyLarge)
                        .foregroundColor(DesignTokens.Colors.textTertiary)
                        .padding(.top, 8)
                        .padding(.leading, 5)
                }

                TextEditor(text: $text)
                    .font(Typography.bodyLarge)
                    .foregroundColor(DesignTokens.Colors.textPrimary)
                    .focused($isFocused)
                    .scrollContentBackground(.hidden)
                    .onChange(of: text) { _, newValue in
                        if let maxLength = maxLength, newValue.count > maxLength {
                            text = String(newValue.prefix(maxLength))
                        }
                    }
            }
            .frame(minHeight: minHeight)
            .padding(DesignTokens.Spacing.sm)
            .background(DesignTokens.Colors.backgroundSecondary)
            .cornerRadius(DesignTokens.CornerRadius.md)
            .overlay(
                RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.md)
                    .stroke(
                        isFocused ? DesignTokens.Colors.primary : DesignTokens.Colors.border,
                        lineWidth: isFocused ? 2 : 1
                    )
            )
        }
    }
}

/// Search Field - Specialized for search
struct SpottedSearchField: View {
    let placeholder: String
    @Binding var text: String
    var onSubmit: (() -> Void)? = nil

    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: DesignTokens.Spacing.sm) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: DesignTokens.Size.Icon.medium))
                .foregroundColor(DesignTokens.Colors.textTertiary)

            TextField(placeholder, text: $text)
                .font(Typography.bodyLarge)
                .foregroundColor(DesignTokens.Colors.textPrimary)
                .focused($isFocused)
                .onSubmit {
                    onSubmit?()
                }

            if !text.isEmpty {
                Button(action: {
                    text = ""
                    HapticFeedback.impact(.light)
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: DesignTokens.Size.Icon.medium))
                        .foregroundColor(DesignTokens.Colors.textTertiary)
                }
            }
        }
        .padding(DesignTokens.Spacing.sm)
        .background(DesignTokens.Colors.backgroundSecondary)
        .cornerRadius(DesignTokens.CornerRadius.lg)
    }
}

// MARK: - Preview

#Preview("Text Fields") {
    ScrollView {
        VStack(spacing: DesignTokens.Spacing.lg) {
            Text("Text Field Components")
                .heading1()

            // Standard text field
            SpottedTextField(
                label: "Name",
                placeholder: "Enter your name",
                text: .constant("John Doe")
            )

            // Text field with icon
            SpottedTextField(
                label: "Email",
                placeholder: "your@email.com",
                text: .constant(""),
                icon: "envelope.fill"
            )

            // Text field with character limit
            SpottedTextField(
                label: "Bio",
                placeholder: "Tell us about yourself",
                text: .constant(""),
                icon: "person.fill",
                maxLength: 150
            )

            // Text field with error
            SpottedTextField(
                label: "Age",
                placeholder: "18-99",
                text: .constant("15"),
                icon: "calendar",
                errorMessage: "Must be 18 or older"
            )

            // Secure field
            SpottedSecureField(
                label: "Password",
                placeholder: "Enter password",
                text: .constant("")
            )

            // Secure field with error
            SpottedSecureField(
                label: "Confirm Password",
                placeholder: "Re-enter password",
                text: .constant(""),
                errorMessage: "Passwords do not match"
            )

            // Text editor
            SpottedTextEditor(
                label: "About Me",
                placeholder: "Share your interests, hobbies, and what you're looking for...",
                text: .constant(""),
                maxLength: 500
            )

            // Search field
            SpottedSearchField(
                placeholder: "Search locations",
                text: .constant("")
            )

            // Search field with text
            SpottedSearchField(
                placeholder: "Search",
                text: .constant("Coffee shop")
            )
        }
        .padding()
    }
}

// MARK: - Usage Examples
/*

 // Standard text field
 @State private var name = ""

 SpottedTextField(
     label: "Name",
     placeholder: "Enter your name",
     text: $name
 )

 // Text field with icon and validation
 @State private var email = ""

 SpottedTextField(
     label: "Email",
     placeholder: "your@email.com",
     text: $email,
     icon: "envelope.fill",
     errorMessage: isValidEmail ? nil : "Invalid email format"
 )

 // Password field
 @State private var password = ""

 SpottedSecureField(
     label: "Password",
     placeholder: "Enter password",
     text: $password
 )

 // Bio editor
 @State private var bio = ""

 SpottedTextEditor(
     label: "About Me",
     placeholder: "Tell us about yourself...",
     text: $bio,
     maxLength: 500
 )

 // Search field
 @State private var searchQuery = ""

 SpottedSearchField(
     placeholder: "Search",
     text: $searchQuery,
     onSubmit: {
         performSearch()
     }
 )

 */
