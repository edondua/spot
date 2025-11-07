import SwiftUI

// MARK: - Modern Custom ViewModifiers

// Card styling modifier (Legacy - use DesignSystem Cards instead)
struct LegacyCardModifier: ViewModifier {
    var padding: CGFloat = 16
    var cornerRadius: CGFloat = 16
    var shadowRadius: CGFloat = 8

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(Color(.systemBackground))
            .cornerRadius(cornerRadius)
            .shadow(color: .black.opacity(0.1), radius: shadowRadius, x: 0, y: 4)
    }
}

// Gradient background modifier
struct GradientBackground: ViewModifier {
    var colors: [Color] = [.pink, .purple]

    func body(content: Content) -> some View {
        content
            .background(
                LinearGradient(
                    colors: colors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
    }
}

// Shimmer loading effect
struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    colors: [
                        .clear,
                        .white.opacity(0.6),
                        .clear
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .rotationEffect(.degrees(30))
                .offset(x: phase)
                .onAppear {
                    withAnimation(
                        .linear(duration: 1.5)
                        .repeatForever(autoreverses: false)
                    ) {
                        phase = 400
                    }
                }
            )
            .clipped()
    }
}

// Primary button style (Legacy - use DesignSystem Buttons instead)
struct LegacyPrimaryButtonStyle: ButtonStyle {
    var isLoading: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        HStack {
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            }
            configuration.label
        }
        .frame(maxWidth: .infinity)
        .padding()
        .foregroundColor(.white)
        .background(
            LinearGradient(
                colors: [.pink, .purple],
                startPoint: .leading,
                endPoint: .trailing
            )
            .opacity(configuration.isPressed ? 0.8 : 1.0)
        )
        .cornerRadius(16)
        .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

// Error banner modifier
struct ErrorBanner: ViewModifier {
    @Binding var errorMessage: String?

    func body(content: Content) -> some View {
        ZStack(alignment: .top) {
            content

            if let error = errorMessage {
                VStack {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.white)

                        Text(error)
                            .font(.subheadline)
                            .foregroundColor(.white)

                        Spacer()

                        Button(action: {
                            withAnimation {
                                errorMessage = nil
                            }
                        }) {
                            Image(systemName: "xmark")
                                .foregroundColor(.white)
                        }
                    }
                    .padding()
                    .background(Color.red)
                    .cornerRadius(12)
                    .shadow(radius: 10)
                    .padding()
                }
                .transition(.move(edge: .top).combined(with: .opacity))
                .animation(.spring(), value: errorMessage)
            }
        }
    }
}

// MARK: - View Extensions
extension View {
    func legacyCardStyle(padding: CGFloat = 16, cornerRadius: CGFloat = 16, shadowRadius: CGFloat = 8) -> some View {
        modifier(LegacyCardModifier(padding: padding, cornerRadius: cornerRadius, shadowRadius: shadowRadius))
    }

    func gradientBackground(colors: [Color] = [.pink, .purple]) -> some View {
        modifier(GradientBackground(colors: colors))
    }

    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }

    func errorBanner(errorMessage: Binding<String?>) -> some View {
        modifier(ErrorBanner(errorMessage: errorMessage))
    }
}

// MARK: - Loading Views

struct LoadingCard: View {
    var height: CGFloat = 200

    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color(.systemGray6))
            .frame(height: height)
            .shimmer()
    }
}

struct LoadingProfileCard: View {
    var body: some View {
        VStack(spacing: 12) {
            Circle()
                .fill(Color(.systemGray6))
                .frame(width: 80, height: 80)
                .shimmer()

            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray6))
                .frame(width: 100, height: 20)
                .shimmer()

            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray6))
                .frame(width: 60, height: 16)
                .shimmer()
        }
    }
}

struct LoadingListItem: View {
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color(.systemGray6))
                .frame(width: 60, height: 60)
                .shimmer()

            VStack(alignment: .leading, spacing: 8) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemGray6))
                    .frame(height: 20)
                    .shimmer()

                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemGray6))
                    .frame(height: 16)
                    .frame(maxWidth: 200)
                    .shimmer()
            }

            Spacer()
        }
        .padding()
        .background(Color(.systemGray6).opacity(0.3))
        .cornerRadius(12)
    }
}

// MARK: - Preview
#Preview("Loading States") {
    VStack(spacing: 20) {
        LoadingCard()
        LoadingProfileCard()
        LoadingListItem()
    }
    .padding()
}

#Preview("Custom Styles") {
    VStack(spacing: 20) {
        Text("Card Style")
            .legacyCardStyle()

        Button("Primary Button") {}
            .buttonStyle(LegacyPrimaryButtonStyle())

        Button("Loading Button") {}
            .buttonStyle(LegacyPrimaryButtonStyle(isLoading: true))
    }
    .padding()
}
