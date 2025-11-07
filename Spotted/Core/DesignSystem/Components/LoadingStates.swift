import SwiftUI

// MARK: - Loading Indicators

/// Standard loading spinner
struct LoadingSpinner: View {
    let size: CGFloat
    let color: Color

    init(size: CGFloat = 44, color: Color = DesignTokens.Colors.primary) {
        self.size = size
        self.color = color
    }

    var body: some View {
        ProgressView()
            .scaleEffect(size / 44)
            .tint(color)
            .frame(width: size, height: size)
    }
}

/// Pulsing loading indicator
struct PulsingLoader: View {
    @State private var isAnimating = false

    let color: Color

    init(color: Color = DesignTokens.Colors.primary) {
        self.color = color
    }

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(color)
                    .frame(width: 12, height: 12)
                    .scaleEffect(isAnimating ? 1.0 : 0.5)
                    .opacity(isAnimating ? 1.0 : 0.3)
                    .animation(
                        Animation
                            .easeInOut(duration: 0.6)
                            .repeatForever()
                            .delay(Double(index) * 0.2),
                        value: isAnimating
                    )
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

/// Gradient loading bar
struct LoadingBar: View {
    @State private var isAnimating = false

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background
                Rectangle()
                    .fill(DesignTokens.Colors.backgroundSecondary)
                    .cornerRadius(2)

                // Animated gradient
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                DesignTokens.Colors.primary,
                                DesignTokens.Colors.secondary
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * 0.3)
                    .cornerRadius(2)
                    .offset(x: isAnimating ? geometry.size.width * 0.7 : -geometry.size.width * 0.3)
                    .animation(
                        Animation.linear(duration: 1.5).repeatForever(autoreverses: false),
                        value: isAnimating
                    )
            }
        }
        .frame(height: 4)
        .onAppear {
            isAnimating = true
        }
    }
}

/// Progress bar with percentage
struct ProgressBar: View {
    let progress: Double // 0.0 to 1.0
    let showPercentage: Bool

    init(progress: Double, showPercentage: Bool = true) {
        self.progress = min(max(progress, 0.0), 1.0)
        self.showPercentage = showPercentage
    }

    var body: some View {
        VStack(spacing: DesignTokens.Spacing.xxs) {
            if showPercentage {
                HStack {
                    Spacer()
                    Text("\(Int(progress * 100))%")
                        .captionMedium()
                        .foregroundColor(DesignTokens.Colors.textSecondary)
                }
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    Rectangle()
                        .fill(DesignTokens.Colors.backgroundSecondary)
                        .cornerRadius(4)

                    // Progress
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    DesignTokens.Colors.primary,
                                    DesignTokens.Colors.secondary
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * progress)
                        .cornerRadius(4)
                        .animation(DesignTokens.Animations.smooth, value: progress)
                }
            }
            .frame(height: 8)
        }
    }
}

// MARK: - Loading Views

/// Full-screen loading view
struct LoadingView: View {
    let message: String

    init(message: String = "Loading...") {
        self.message = message
    }

    var body: some View {
        VStack(spacing: DesignTokens.Spacing.lg) {
            LoadingSpinner(size: 60)

            Text(message)
                .bodyLarge()
                .foregroundColor(DesignTokens.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DesignTokens.Colors.backgroundPrimary)
    }
}

/// Inline loading view (for list items)
struct InlineLoadingView: View {
    let message: String

    init(message: String = "Loading more...") {
        self.message = message
    }

    var body: some View {
        HStack(spacing: DesignTokens.Spacing.sm) {
            ProgressView()
                .scaleEffect(0.8)

            Text(message)
                .bodyMedium()
                .foregroundColor(DesignTokens.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(DesignTokens.Spacing.md)
    }
}

// MARK: - Empty States

/// Generic empty state view
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?

    init(
        icon: String,
        title: String,
        message: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }

    var body: some View {
        VStack(spacing: DesignTokens.Spacing.lg) {
            // Icon
            Image(systemName: icon)
                .font(.system(size: 64))
                .foregroundColor(DesignTokens.Colors.textTertiary)

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
                .padding(.horizontal, DesignTokens.Spacing.xl)

            // Action button
            if let actionTitle = actionTitle, let action = action {
                Button(action: {
                    HapticFeedback.impact()
                    action()
                }) {
                    Text(actionTitle)
                        .padding(.horizontal, DesignTokens.Spacing.xl)
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.top, DesignTokens.Spacing.sm)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DesignTokens.Colors.backgroundPrimary)
    }
}

/// No results empty state
struct NoResultsView: View {
    let searchQuery: String
    let onClearSearch: (() -> Void)?

    init(searchQuery: String = "", onClearSearch: (() -> Void)? = nil) {
        self.searchQuery = searchQuery
        self.onClearSearch = onClearSearch
    }

    var body: some View {
        EmptyStateView(
            icon: "magnifyingglass",
            title: "No Results Found",
            message: searchQuery.isEmpty ?
                "Try adjusting your filters or search criteria." :
                "No results for \"\(searchQuery)\". Try a different search term.",
            actionTitle: searchQuery.isEmpty ? nil : "Clear Search",
            action: onClearSearch
        )
    }
}

// MARK: - Error States

/// Generic error view
struct ErrorStateView: View {
    let title: String
    let message: String
    let retryTitle: String
    let onRetry: () -> Void

    init(
        title: String = "Something Went Wrong",
        message: String = "We encountered an error. Please try again.",
        retryTitle: String = "Try Again",
        onRetry: @escaping () -> Void
    ) {
        self.title = title
        self.message = message
        self.retryTitle = retryTitle
        self.onRetry = onRetry
    }

    var body: some View {
        VStack(spacing: DesignTokens.Spacing.lg) {
            // Error icon
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 64))
                .foregroundColor(DesignTokens.Colors.error)

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
                .padding(.horizontal, DesignTokens.Spacing.xl)

            // Retry button
            Button(action: {
                HapticFeedback.impact()
                onRetry()
            }) {
                Text(retryTitle)
                    .padding(.horizontal, DesignTokens.Spacing.xl)
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.top, DesignTokens.Spacing.sm)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DesignTokens.Colors.backgroundPrimary)
    }
}

/// Network error view
struct NetworkErrorView: View {
    let onRetry: () -> Void

    var body: some View {
        ErrorStateView(
            title: "No Internet Connection",
            message: "Please check your internet connection and try again.",
            retryTitle: "Retry",
            onRetry: onRetry
        )
    }
}

// MARK: - Skeleton Loaders

/// Skeleton loading placeholder
struct SkeletonView: View {
    @State private var isAnimating = false

    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [
                        DesignTokens.Colors.backgroundSecondary,
                        DesignTokens.Colors.backgroundTertiary,
                        DesignTokens.Colors.backgroundSecondary
                    ],
                    startPoint: isAnimating ? .leading : .trailing,
                    endPoint: isAnimating ? .trailing : .leading
                )
            )
            .onAppear {
                withAnimation(
                    Animation.linear(duration: 1.5).repeatForever(autoreverses: false)
                ) {
                    isAnimating = true
                }
            }
    }
}

/// Skeleton card for list items
struct SkeletonCard: View {
    var body: some View {
        HStack(spacing: DesignTokens.Spacing.md) {
            // Avatar skeleton
            SkeletonView()
                .frame(width: 60, height: 60)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 8) {
                // Name skeleton
                SkeletonView()
                    .frame(width: 120, height: 16)
                    .cornerRadius(4)

                // Bio skeleton
                SkeletonView()
                    .frame(width: 200, height: 12)
                    .cornerRadius(4)

                SkeletonView()
                    .frame(width: 160, height: 12)
                    .cornerRadius(4)
            }

            Spacer()
        }
        .padding(DesignTokens.Spacing.md)
        .background(DesignTokens.Colors.backgroundPrimary)
        .cornerRadius(DesignTokens.CornerRadius.md)
    }
}

// MARK: - View State Wrapper

/// Wrapper for handling loading, error, and empty states
struct AsyncContentView<Content: View, EmptyView: View>: View {
    enum ViewState {
        case idle
        case loading
        case loaded
        case empty
        case error(Error)
    }

    let state: ViewState
    let content: () -> Content
    let emptyView: () -> EmptyView
    let onRetry: () -> Void

    init(
        state: ViewState,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder emptyView: @escaping () -> EmptyView,
        onRetry: @escaping () -> Void
    ) {
        self.state = state
        self.content = content
        self.emptyView = emptyView
        self.onRetry = onRetry
    }

    var body: some View {
        switch state {
        case .idle:
            Color.clear

        case .loading:
            LoadingView()

        case .loaded:
            content()

        case .empty:
            emptyView()

        case .error(let error):
            ErrorStateView(
                message: error.localizedDescription,
                onRetry: onRetry
            )
        }
    }
}

// MARK: - Preview

#Preview("Loading States") {
    ScrollView {
        VStack(spacing: DesignTokens.Spacing.xl) {
            Text("Loading & State Components")
                .heading1()

            // Loading indicators
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                Text("Loading Indicators")
                    .heading3()

                HStack(spacing: DesignTokens.Spacing.lg) {
                    LoadingSpinner(size: 32)
                    LoadingSpinner(size: 44)
                    LoadingSpinner(size: 60)
                }

                PulsingLoader()

                LoadingBar()
                    .frame(height: 4)

                ProgressBar(progress: 0.65)
            }

            Divider()

            // Loading views
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                Text("Loading Views")
                    .heading3()

                InlineLoadingView(message: "Loading more users...")
            }

            Divider()

            // Skeleton loaders
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                Text("Skeleton Loaders")
                    .heading3()

                SkeletonCard()
                SkeletonCard()
            }

            Divider()

            // Empty states
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                Text("Empty State (Preview)")
                    .heading3()

                EmptyStateView(
                    icon: "person.2.slash",
                    title: "No Matches Yet",
                    message: "Start swiping to find your perfect match!",
                    actionTitle: "Start Swiping",
                    action: { print("Start swiping") }
                )
                .frame(height: 400)
                .background(DesignTokens.Colors.backgroundPrimary)
                .cornerRadius(DesignTokens.CornerRadius.lg)
            }

            Divider()

            // Error states
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                Text("Error State (Preview)")
                    .heading3()

                ErrorStateView(
                    title: "Failed to Load",
                    message: "Could not connect to the server.",
                    onRetry: { print("Retry") }
                )
                .frame(height: 400)
                .background(DesignTokens.Colors.backgroundPrimary)
                .cornerRadius(DesignTokens.CornerRadius.lg)
            }
        }
        .padding()
    }
}

// MARK: - Usage Examples
/*

 // Loading spinner
 LoadingSpinner(size: 44)

 // Pulsing loader
 PulsingLoader()

 // Progress bar
 @State private var progress: Double = 0.5
 ProgressBar(progress: progress)

 // Full-screen loading
 if isLoading {
     LoadingView(message: "Loading your matches...")
 }

 // Inline loading (bottom of list)
 if isLoadingMore {
     InlineLoadingView(message: "Loading more...")
 }

 // Empty state
 if users.isEmpty {
     EmptyStateView(
         icon: "person.2.slash",
         title: "No Users Found",
         message: "Try adjusting your search filters.",
         actionTitle: "Reset Filters",
         action: resetFilters
     )
 }

 // No search results
 if searchResults.isEmpty {
     NoResultsView(
         searchQuery: searchText,
         onClearSearch: { searchText = "" }
     )
 }

 // Error state
 if let error = errorMessage {
     ErrorStateView(
         title: "Oops!",
         message: error,
         onRetry: loadData
     )
 }

 // Network error
 if !hasConnection {
     NetworkErrorView(onRetry: retryConnection)
 }

 // Skeleton loading
 if isLoading {
     ForEach(0..<5) { _ in
         SkeletonCard()
     }
 } else {
     ForEach(users) { user in
         UserCard(user: user)
     }
 }

 // Async content wrapper
 enum LoadingState {
     case idle, loading, loaded, empty, error(Error)
 }

 @State private var loadingState: LoadingState = .loading

 AsyncContentView(
     state: loadingState,
     content: {
         List(items) { item in
             ItemRow(item: item)
         }
     },
     emptyView: {
         EmptyStateView(
             icon: "tray",
             title: "No Items",
             message: "You don't have any items yet."
         )
     },
     onRetry: {
         loadData()
     }
 )

 */
