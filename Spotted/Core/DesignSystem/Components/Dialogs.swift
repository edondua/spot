import SwiftUI

// MARK: - Dialog Types

/// Dialog type with icon and color
enum DialogType {
    case success
    case error
    case warning
    case info
    case destructive

    var icon: String {
        switch self {
        case .success: return "checkmark.circle.fill"
        case .error: return "xmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .info: return "info.circle.fill"
        case .destructive: return "trash.fill"
        }
    }

    var color: Color {
        switch self {
        case .success: return DesignTokens.Colors.success
        case .error: return DesignTokens.Colors.error
        case .warning: return DesignTokens.Colors.warning
        case .info: return DesignTokens.Colors.info
        case .destructive: return DesignTokens.Colors.error
        }
    }
}

// MARK: - Alert Dialog

/// Standard alert dialog
struct AlertDialog: View {
    let type: DialogType
    let title: String
    let message: String
    let primaryButton: String
    let secondaryButton: String?
    let onPrimary: () -> Void
    let onSecondary: (() -> Void)?

    init(
        type: DialogType = .info,
        title: String,
        message: String,
        primaryButton: String = "OK",
        secondaryButton: String? = nil,
        onPrimary: @escaping () -> Void,
        onSecondary: (() -> Void)? = nil
    ) {
        self.type = type
        self.title = title
        self.message = message
        self.primaryButton = primaryButton
        self.secondaryButton = secondaryButton
        self.onPrimary = onPrimary
        self.onSecondary = onSecondary
    }

    var body: some View {
        VStack(spacing: DesignTokens.Spacing.lg) {
            // Icon
            Image(systemName: type.icon)
                .font(.system(size: 48))
                .foregroundColor(type.color)

            // Title
            Text(title)
                .heading2()
                .foregroundColor(DesignTokens.Colors.textPrimary)
                .multilineTextAlignment(.center)

            // Message
            Text(message)
                .bodyMedium()
                .foregroundColor(DesignTokens.Colors.textSecondary)
                .multilineTextAlignment(.center)

            // Buttons
            VStack(spacing: DesignTokens.Spacing.sm) {
                // Primary button
                Button(action: {
                    HapticFeedback.impact()
                    onPrimary()
                }) {
                    Text(primaryButton)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(
                    type == .destructive ?
                    AnyButtonStyle(DestructiveButtonStyle()) :
                    AnyButtonStyle(PrimaryButtonStyle())
                )

                // Secondary button
                if let secondaryButton = secondaryButton, let onSecondary = onSecondary {
                    Button(action: {
                        HapticFeedback.impact(.light)
                        onSecondary()
                    }) {
                        Text(secondaryButton)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(SecondaryButtonStyle())
                }
            }
        }
        .padding(DesignTokens.Spacing.lg)
        .background(DesignTokens.Colors.backgroundPrimary)
        .cornerRadius(DesignTokens.CornerRadius.lg)
        .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
        .padding(DesignTokens.Spacing.lg)
    }
}

// MARK: - Confirmation Dialog

/// Simple confirmation dialog
struct ConfirmationDialog: View {
    let title: String
    let message: String
    let confirmText: String
    let cancelText: String
    let isDestructive: Bool
    let onConfirm: () -> Void
    let onCancel: () -> Void

    init(
        title: String,
        message: String,
        confirmText: String = "Confirm",
        cancelText: String = "Cancel",
        isDestructive: Bool = false,
        onConfirm: @escaping () -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.title = title
        self.message = message
        self.confirmText = confirmText
        self.cancelText = cancelText
        self.isDestructive = isDestructive
        self.onConfirm = onConfirm
        self.onCancel = onCancel
    }

    var body: some View {
        VStack(spacing: DesignTokens.Spacing.md) {
            // Title
            Text(title)
                .heading3()
                .foregroundColor(DesignTokens.Colors.textPrimary)
                .multilineTextAlignment(.center)

            // Message
            Text(message)
                .bodyMedium()
                .foregroundColor(DesignTokens.Colors.textSecondary)
                .multilineTextAlignment(.center)

            // Buttons
            HStack(spacing: DesignTokens.Spacing.sm) {
                // Cancel
                Button(action: {
                    HapticFeedback.impact(.light)
                    onCancel()
                }) {
                    Text(cancelText)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(SecondaryButtonStyle())

                // Confirm
                Button(action: {
                    HapticFeedback.impact()
                    onConfirm()
                }) {
                    Text(confirmText)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(
                    isDestructive ?
                    AnyButtonStyle(DestructiveButtonStyle()) :
                    AnyButtonStyle(PrimaryButtonStyle())
                )
            }
        }
        .padding(DesignTokens.Spacing.lg)
        .background(DesignTokens.Colors.backgroundPrimary)
        .cornerRadius(DesignTokens.CornerRadius.lg)
        .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
        .padding(DesignTokens.Spacing.lg)
    }
}

// MARK: - Bottom Sheet Dialog

/// Bottom sheet dialog
struct BottomSheetDialog<Content: View>: View {
    @Binding var isPresented: Bool
    let content: Content

    init(isPresented: Binding<Bool>, @ViewBuilder content: () -> Content) {
        self._isPresented = isPresented
        self.content = content()
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            // Overlay
            if isPresented {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(DesignTokens.Animations.smooth) {
                            isPresented = false
                        }
                    }
                    .transition(.opacity)
            }

            // Sheet content
            if isPresented {
                VStack(spacing: 0) {
                    // Handle
                    RoundedRectangle(cornerRadius: 2.5)
                        .fill(DesignTokens.Colors.textTertiary)
                        .frame(width: 36, height: 5)
                        .padding(.top, 12)

                    content
                        .padding(.top, DesignTokens.Spacing.md)
                }
                .background(DesignTokens.Colors.backgroundPrimary)
                .cornerRadius(DesignTokens.CornerRadius.lg, corners: [.topLeft, .topRight])
                .transition(.move(edge: .bottom))
            }
        }
        .animation(DesignTokens.Animations.smooth, value: isPresented)
    }
}

// MARK: - Loading Dialog

/// Loading dialog with spinner
struct LoadingDialog: View {
    let message: String

    init(message: String = "Loading...") {
        self.message = message
    }

    var body: some View {
        VStack(spacing: DesignTokens.Spacing.md) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(DesignTokens.Colors.primary)

            Text(message)
                .bodyMedium()
                .foregroundColor(DesignTokens.Colors.textSecondary)
        }
        .padding(DesignTokens.Spacing.xl)
        .background(DesignTokens.Colors.backgroundPrimary)
        .cornerRadius(DesignTokens.CornerRadius.lg)
        .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
    }
}

// MARK: - Input Dialog

/// Dialog with text input
struct InputDialog: View {
    let title: String
    let message: String
    let placeholder: String
    @Binding var text: String
    let confirmText: String
    let cancelText: String
    let onConfirm: () -> Void
    let onCancel: () -> Void

    init(
        title: String,
        message: String = "",
        placeholder: String,
        text: Binding<String>,
        confirmText: String = "Confirm",
        cancelText: String = "Cancel",
        onConfirm: @escaping () -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.title = title
        self.message = message
        self.placeholder = placeholder
        self._text = text
        self.confirmText = confirmText
        self.cancelText = cancelText
        self.onConfirm = onConfirm
        self.onCancel = onCancel
    }

    var body: some View {
        VStack(spacing: DesignTokens.Spacing.md) {
            // Title
            Text(title)
                .heading3()
                .foregroundColor(DesignTokens.Colors.textPrimary)
                .multilineTextAlignment(.center)

            // Message
            if !message.isEmpty {
                Text(message)
                    .bodyMedium()
                    .foregroundColor(DesignTokens.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }

            // Text field
            TextField(placeholder, text: $text)
                .font(Typography.bodyLarge)
                .padding(DesignTokens.Spacing.sm)
                .background(DesignTokens.Colors.backgroundSecondary)
                .cornerRadius(DesignTokens.CornerRadius.md)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.md)
                        .stroke(DesignTokens.Colors.border, lineWidth: 1)
                )

            // Buttons
            HStack(spacing: DesignTokens.Spacing.sm) {
                Button(action: {
                    HapticFeedback.impact(.light)
                    onCancel()
                }) {
                    Text(cancelText)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(SecondaryButtonStyle())

                Button(action: {
                    HapticFeedback.impact()
                    onConfirm()
                }) {
                    Text(confirmText)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryButtonStyle())
            }
        }
        .padding(DesignTokens.Spacing.lg)
        .background(DesignTokens.Colors.backgroundPrimary)
        .cornerRadius(DesignTokens.CornerRadius.lg)
        .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
        .padding(DesignTokens.Spacing.lg)
    }
}

// MARK: - Helper Extensions

/// Type-erased ButtonStyle for conditional styling
struct AnyButtonStyle: ButtonStyle {
    private let _makeBody: (Configuration) -> AnyView

    init<S: ButtonStyle>(_ style: S) {
        _makeBody = { configuration in
            AnyView(style.makeBody(configuration: configuration))
        }
    }

    func makeBody(configuration: Configuration) -> some View {
        _makeBody(configuration)
    }
}

/// Corner radius for specific corners (Already defined in View+Extensions.swift)
// extension View {
//     func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
//         clipShape(RoundedCorner(radius: radius, corners: corners))
//     }
// }
//
// struct RoundedCorner: Shape {
//     var radius: CGFloat = .infinity
//     var corners: UIRectCorner = .allCorners
//
//     func path(in rect: CGRect) -> Path {
//         let path = UIBezierPath(
//             roundedRect: rect,
//             byRoundingCorners: corners,
//             cornerRadii: CGSize(width: radius, height: radius)
//         )
//         return Path(path.cgPath)
//     }
// }

// MARK: - Dialog Modifier

struct DialogModifier<DialogContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    let dialogContent: DialogContent

    func body(content: Content) -> some View {
        ZStack {
            content

            if isPresented {
                ZStack {
                    // Overlay
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            // Dismiss on background tap (optional)
                        }

                    // Dialog
                    dialogContent
                }
                .transition(.opacity)
                .animation(DesignTokens.Animations.smooth, value: isPresented)
            }
        }
    }
}

extension View {
    func dialog<Content: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: () -> Content
    ) -> some View {
        modifier(DialogModifier(isPresented: isPresented, dialogContent: content()))
    }
}

// MARK: - Preview

#Preview("Dialogs") {
    ScrollView {
        VStack(spacing: DesignTokens.Spacing.xl) {
            Text("Dialog Components")
                .heading1()

            // Alert dialogs
            VStack(spacing: DesignTokens.Spacing.md) {
                Text("Alert Dialogs")
                    .heading3()

                AlertDialog(
                    type: .success,
                    title: "Success!",
                    message: "Your profile has been updated successfully.",
                    primaryButton: "Great"
                ) {
                    print("Success confirmed")
                }
                .frame(maxWidth: 400)

                AlertDialog(
                    type: .error,
                    title: "Error",
                    message: "Something went wrong. Please try again.",
                    primaryButton: "Retry",
                    secondaryButton: "Cancel",
                    onPrimary: { print("Retry") },
                    onSecondary: { print("Cancel") }
                )
                .frame(maxWidth: 400)

                AlertDialog(
                    type: .warning,
                    title: "Warning",
                    message: "This action cannot be undone.",
                    primaryButton: "Continue",
                    secondaryButton: "Go Back",
                    onPrimary: { print("Continue") },
                    onSecondary: { print("Go Back") }
                )
                .frame(maxWidth: 400)
            }

            Divider()

            // Confirmation dialog
            VStack(spacing: DesignTokens.Spacing.md) {
                Text("Confirmation Dialogs")
                    .heading3()

                ConfirmationDialog(
                    title: "Delete Account?",
                    message: "This will permanently delete your account and all data.",
                    confirmText: "Delete",
                    isDestructive: true,
                    onConfirm: { print("Confirmed") },
                    onCancel: { print("Cancelled") }
                )
                .frame(maxWidth: 400)
            }

            Divider()

            // Loading dialog
            VStack(spacing: DesignTokens.Spacing.md) {
                Text("Loading Dialog")
                    .heading3()

                LoadingDialog(message: "Uploading photos...")
            }

            Divider()

            // Input dialog
            VStack(spacing: DesignTokens.Spacing.md) {
                Text("Input Dialog")
                    .heading3()

                InputDialog(
                    title: "Report User",
                    message: "Please tell us why you're reporting this user.",
                    placeholder: "Enter reason...",
                    text: .constant(""),
                    confirmText: "Submit",
                    onConfirm: { print("Submitted") },
                    onCancel: { print("Cancelled") }
                )
                .frame(maxWidth: 400)
            }
        }
        .padding()
    }
}

// MARK: - Usage Examples
/*

 // Alert dialog
 @State private var showAlert = false

 .dialog(isPresented: $showAlert) {
     AlertDialog(
         type: .success,
         title: "Success!",
         message: "Your changes have been saved.",
         primaryButton: "OK"
     ) {
         showAlert = false
     }
 }

 // Confirmation dialog
 @State private var showConfirmation = false

 .dialog(isPresented: $showConfirmation) {
     ConfirmationDialog(
         title: "Delete Photo?",
         message: "This cannot be undone.",
         confirmText: "Delete",
         isDestructive: true,
         onConfirm: {
             deletePhoto()
             showConfirmation = false
         },
         onCancel: {
             showConfirmation = false
         }
     )
 }

 // Bottom sheet
 @State private var showSheet = false

 BottomSheetDialog(isPresented: $showSheet) {
     VStack(spacing: 16) {
         Text("Share Profile")
             .heading2()

         // Share options
     }
     .padding()
 }

 // Loading overlay
 @State private var isLoading = false

 ZStack {
     ContentView()

     if isLoading {
         Color.black.opacity(0.4)
             .ignoresSafeArea()

         LoadingDialog(message: "Saving...")
     }
 }

 // Input dialog
 @State private var showInput = false
 @State private var inputText = ""

 .dialog(isPresented: $showInput) {
     InputDialog(
         title: "Enter Name",
         placeholder: "Your name",
         text: $inputText,
         onConfirm: {
             saveName(inputText)
             showInput = false
         },
         onCancel: {
             showInput = false
         }
     )
 }

 */
