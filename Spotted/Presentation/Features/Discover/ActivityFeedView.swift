import SwiftUI

// MARK: - Live Activity Feed
struct ActivityFeedView: View {
    @EnvironmentObject var viewModel: AppViewModel

    // Get all recent activities from users
    var recentActivities: [UserActivity] {
        viewModel.allUsers
            .compactMap { $0.lastActivity }
            .sorted { $0.timestamp > $1.timestamp }
            .prefix(20)
            .map { $0 }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color(red: 252/255, green: 108/255, blue: 133/255))

                    Text("Live Activity")
                        .font(.system(size: 22, weight: .bold))
                }

                Spacer()

                // Auto-refresh indicator
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)

                    Text("Live")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal)

            // Activity feed
            if recentActivities.isEmpty {
                emptyStateView
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(recentActivities) { activity in
                            ActivityCard(activity: activity)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "antenna.radiowaves.left.and.right")
                .font(.system(size: 40))
                .foregroundColor(.secondary)

            Text("No recent activity")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

// MARK: - Activity Card
struct ActivityCard: View {
    @EnvironmentObject var viewModel: AppViewModel
    let activity: UserActivity

    var user: User? {
        viewModel.getUser(by: activity.userId)
    }

    var body: some View {
        NavigationLink(destination: userDestination) {
            VStack(alignment: .leading, spacing: 12) {
                // User info
                HStack(spacing: 10) {
                    if let user = user {
                        ProfileImageView(user: user, size: 44)

                        VStack(alignment: .leading, spacing: 2) {
                            HStack(spacing: 4) {
                                Text(user.name)
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(.primary)

                                if user.isVerified {
                                    Image(systemName: "checkmark.seal.fill")
                                        .font(.system(size: 12))
                                        .foregroundColor(.blue)
                                }
                            }

                            Text(activity.timeAgo)
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                    }
                }

                // Activity content
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 6) {
                        Text(activity.type.rawValue)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)

                        Text(activity.text)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.primary)
                    }

                    if let location = activity.location {
                        HStack(spacing: 6) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.system(size: 12))
                                .foregroundColor(Color(red: 252/255, green: 108/255, blue: 133/255))

                            Text(location.name)
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                    }
                }

                // Reactions
                if !activity.reactions.isEmpty {
                    HStack(spacing: 8) {
                        ForEach(Array(activity.reactions.keys.sorted()), id: \.self) { emoji in
                            if let count = activity.reactions[emoji], count > 0 {
                                HStack(spacing: 4) {
                                    Text(emoji)
                                        .font(.system(size: 14))

                                    Text("\(count)")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.secondary)
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                            }
                        }

                        // Add reaction button
                        Button(action: {
                            let impact = UIImpactFeedbackGenerator(style: .light)
                            impact.impactOccurred()
                        }) {
                            Image(systemName: "plus.circle")
                                .font(.system(size: 16))
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .padding(16)
            .frame(width: 280)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color(.systemGray5), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    @ViewBuilder
    private var userDestination: some View {
        if let user = user {
            UserProfileView(user: user)
        } else {
            EmptyView()
        }
    }
}

#Preview {
    ActivityFeedView()
        .environmentObject(AppViewModel())
}
