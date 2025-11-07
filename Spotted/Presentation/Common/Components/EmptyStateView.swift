import SwiftUI

// MARK: - Empty State View (Legacy - use DesignSystem LoadingStates instead)
struct LegacyEmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    let actionTitle: String?
    let action: (() -> Void)?

    @State private var showContent = false

    init(
        icon: String,
        title: String,
        subtitle: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.actionTitle = actionTitle
        self.action = action
    }

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            VStack(spacing: 20) {
                // Icon
                Image(systemName: icon)
                    .font(.system(size: 70, weight: .light))
                    .foregroundColor(Color(red: 252/255, green: 108/255, blue: 133/255).opacity(0.6))
                    .scaleEffect(showContent ? 1 : 0.5)
                    .opacity(showContent ? 1 : 0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.7), value: showContent)

                VStack(spacing: 12) {
                    Text(title)
                        .font(.system(size: 24, weight: .bold))
                        .multilineTextAlignment(.center)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)

                    Text(subtitle)
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                }
                .animation(.easeOut(duration: 0.5).delay(0.2), value: showContent)

                if let actionTitle = actionTitle, let action = action {
                    Button(action: action) {
                        Text(actionTitle)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 14)
                            .background(Color(red: 252/255, green: 108/255, blue: 133/255))
                            .cornerRadius(25)
                    }
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
                    .animation(.easeOut(duration: 0.5).delay(0.4), value: showContent)
                }
            }

            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            showContent = true
        }
    }
}

// MARK: - Specific Empty States
struct NoUsersNearbyView: View {
    let action: () -> Void

    var body: some View {
        LegacyEmptyStateView(
            icon: "person.2.slash",
            title: "No one nearby",
            subtitle: "Try checking in at popular spots or adjusting your distance filters",
            actionTitle: "Adjust Filters",
            action: action
        )
    }
}

struct NoMatchesYetView: View {
    var body: some View {
        LegacyEmptyStateView(
            icon: "heart.slash",
            title: "No matches yet",
            subtitle: "Start swiping and check in at locations to meet people nearby"
        )
    }
}

struct NoMessagesView: View {
    var body: some View {
        LegacyEmptyStateView(
            icon: "bubble.left.and.bubble.right",
            title: "No messages yet",
            subtitle: "When you match with someone, you'll be able to chat here"
        )
    }
}

struct NoStoriesView: View {
    var body: some View {
        LegacyEmptyStateView(
            icon: "camera.slash",
            title: "No stories yet",
            subtitle: "Be the first to share what you're up to at this location!"
        )
    }
}

struct NotCheckedInView: View {
    let action: () -> Void

    var body: some View {
        LegacyEmptyStateView(
            icon: "mappin.slash",
            title: "You're not checked in",
            subtitle: "Check in at a location to start discovering people nearby",
            actionTitle: "Find Spots",
            action: action
        )
    }
}

struct SearchNoResultsView: View {
    let searchText: String

    var body: some View {
        LegacyEmptyStateView(
            icon: "magnifyingglass",
            title: "No results found",
            subtitle: "Try searching for something else"
        )
    }
}

#Preview {
    VStack {
        NoUsersNearbyView(action: {})
    }
}
