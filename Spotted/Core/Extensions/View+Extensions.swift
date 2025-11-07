import SwiftUI

// MARK: - View Extensions

extension View {

    /// Applies a corner radius to specific corners
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }

    /// Hide keyboard
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    /// Conditional modifier
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    /// Card style
    func cardStyle(padding: CGFloat = 16, radius: CGFloat = 16) -> some View {
        self
            .padding(padding)
            .background(Color(.systemBackground))
            .cornerRadius(radius)
            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    }

    /// Primary button style (Legacy - use DesignSystem Buttons instead)
    func legacyPrimaryButtonStyle() -> some View {
        self
            .font(.system(size: 18, weight: .bold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                LinearGradient(
                    colors: [AppConstants.Design.primaryColor, AppConstants.Design.secondaryColor],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
            .shadow(color: AppConstants.Design.primaryColor.opacity(0.5), radius: 20, y: 10)
    }

    /// Secondary button style (Legacy - use DesignSystem Buttons instead)
    func legacySecondaryButtonStyle() -> some View {
        self
            .font(.system(size: 18, weight: .bold))
            .foregroundColor(AppConstants.Design.primaryColor)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(Color(.systemGray6))
            .cornerRadius(16)
    }
}

// MARK: - Helper Shapes

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
