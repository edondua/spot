import SwiftUI

// MARK: - Skeleton Loading Animation (Legacy - use DesignSystem LoadingStates instead)
struct LegacySkeletonView: View {
    @State private var isAnimating = false

    let width: CGFloat?
    let height: CGFloat
    let cornerRadius: CGFloat

    init(width: CGFloat? = nil, height: CGFloat = 20, cornerRadius: CGFloat = 8) {
        self.width = width
        self.height = height
        self.cornerRadius = cornerRadius
    }

    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [
                        Color(.systemGray5),
                        Color(.systemGray6),
                        Color(.systemGray5)
                    ],
                    startPoint: isAnimating ? .leading : .trailing,
                    endPoint: isAnimating ? .trailing : .leading
                )
            )
            .frame(width: width, height: height)
            .cornerRadius(cornerRadius)
            .onAppear {
                withAnimation(
                    .linear(duration: 1.5)
                    .repeatForever(autoreverses: false)
                ) {
                    isAnimating.toggle()
                }
            }
    }
}

// MARK: - Skeleton Profile Card (for Discover)
struct SkeletonProfileCard: View {
    var body: some View {
        VStack(spacing: 0) {
            // Image skeleton
            LegacySkeletonView(height: 500, cornerRadius: 0)

            // Info section
            VStack(alignment: .leading, spacing: 12) {
                // Name
                LegacySkeletonView(width: 200, height: 24, cornerRadius: 6)

                // Bio
                LegacySkeletonView(width: 300, height: 16, cornerRadius: 4)
                LegacySkeletonView(width: 250, height: 16, cornerRadius: 4)

                // Interests
                HStack(spacing: 8) {
                    LegacySkeletonView(width: 80, height: 28, cornerRadius: 14)
                    LegacySkeletonView(width: 100, height: 28, cornerRadius: 14)
                    LegacySkeletonView(width: 90, height: 28, cornerRadius: 14)
                }
            }
            .padding(20)
            .background(Color(.systemBackground))
        }
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
    }
}

// MARK: - Skeleton Match Card
struct SkeletonMatchCard: View {
    var body: some View {
        HStack(spacing: 12) {
            // Profile image
            LegacySkeletonView(width: 60, height: 60, cornerRadius: 30)

            VStack(alignment: .leading, spacing: 6) {
                // Name
                LegacySkeletonView(width: 120, height: 16, cornerRadius: 4)

                // Last message
                LegacySkeletonView(width: 200, height: 14, cornerRadius: 4)
            }

            Spacer()

            // Time
            LegacySkeletonView(width: 40, height: 12, cornerRadius: 4)
        }
        .padding()
        .background(Color(.systemBackground))
    }
}

// MARK: - Skeleton Activity Item
struct SkeletonActivityItem: View {
    var body: some View {
        HStack(spacing: 12) {
            // Icon circle
            LegacySkeletonView(width: 40, height: 40, cornerRadius: 20)

            VStack(alignment: .leading, spacing: 6) {
                // Title
                LegacySkeletonView(width: 180, height: 14, cornerRadius: 4)

                // Subtitle
                LegacySkeletonView(width: 140, height: 12, cornerRadius: 4)
            }

            Spacer()

            // Time
            LegacySkeletonView(width: 50, height: 12, cornerRadius: 4)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
}

// MARK: - Loading Spinner (Legacy - use DesignSystem LoadingStates instead)
struct LegacyLoadingSpinner: View {
    @State private var isRotating = false

    var size: CGFloat = 40
    var color: Color = Color(red: 252/255, green: 108/255, blue: 133/255)

    var body: some View {
        Circle()
            .trim(from: 0, to: 0.7)
            .stroke(color, style: StrokeStyle(lineWidth: 4, lineCap: .round))
            .frame(width: size, height: size)
            .rotationEffect(.degrees(isRotating ? 360 : 0))
            .animation(
                .linear(duration: 1)
                .repeatForever(autoreverses: false),
                value: isRotating
            )
            .onAppear {
                isRotating = true
            }
    }
}

// MARK: - Inline Loading Indicator (Legacy - use DesignSystem LoadingStates instead)
struct LegacyInlineLoadingView: View {
    let message: String

    var body: some View {
        HStack(spacing: 12) {
            LegacyLoadingSpinner(size: 24)

            Text(message)
                .font(.system(size: 15))
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}
