import SwiftUI

// MARK: - Toast Type
enum ToastType {
    case success
    case error
    case info
    case warning

    var icon: String {
        switch self {
        case .success: return "checkmark.circle.fill"
        case .error: return "xmark.circle.fill"
        case .info: return "info.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        }
    }

    var color: Color {
        switch self {
        case .success: return .green
        case .error: return .red
        case .info: return .blue
        case .warning: return .orange
        }
    }
}

// MARK: - Toast Item
struct ToastItem: Identifiable, Equatable {
    let id = UUID()
    let message: String
    let type: ToastType
    let duration: TimeInterval

    init(message: String, type: ToastType, duration: TimeInterval = 3.0) {
        self.message = message
        self.type = type
        self.duration = duration
    }
}

// MARK: - Toast Manager
@MainActor
class ToastManager: ObservableObject {
    static let shared = ToastManager()

    @Published var currentToast: ToastItem?

    private init() {}

    func show(_ message: String, type: ToastType = .info, duration: TimeInterval = 3.0) {
        let toast = ToastItem(message: message, type: type, duration: duration)
        currentToast = toast

        // Auto-dismiss after duration
        Task {
            try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
            // Only dismiss if it's still the same toast
            if currentToast?.id == toast.id {
                withAnimation {
                    currentToast = nil
                }
            }
        }
    }

    func showSuccess(_ message: String) {
        show(message, type: .success)
    }

    func showError(_ message: String) {
        show(message, type: .error, duration: 4.0)
    }

    func showInfo(_ message: String) {
        show(message, type: .info)
    }

    func showWarning(_ message: String) {
        show(message, type: .warning)
    }

    func dismiss() {
        withAnimation {
            currentToast = nil
        }
    }
}

// MARK: - Toast View
struct ToastView: View {
    let toast: ToastItem
    let onDismiss: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: toast.type.icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)

            Text(toast.message)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)

            Spacer()

            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(toast.type.color.gradient)
                .shadow(color: .black.opacity(0.2), radius: 10, y: 5)
        )
        .padding(.horizontal, 20)
    }
}

// MARK: - Toast View Modifier
struct ToastModifier: ViewModifier {
    @StateObject private var toastManager = ToastManager.shared

    func body(content: Content) -> some View {
        ZStack {
            content

            // Overlay only intercepts touches when a toast is visible
            VStack {
                if let toast = toastManager.currentToast {
                    ToastView(toast: toast) {
                        toastManager.dismiss()
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .animation(.spring(response: 0.4, dampingFraction: 0.7), value: toastManager.currentToast)
                    .padding(.top, 50)
                }

                Spacer()
            }
            .allowsHitTesting(toastManager.currentToast != nil)
            .zIndex(999)
        }
    }
}

extension View {
    func toastView() -> some View {
        modifier(ToastModifier())
    }
}
