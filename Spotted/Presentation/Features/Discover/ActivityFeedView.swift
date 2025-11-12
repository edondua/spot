import SwiftUI

// MARK: - Activity Feed (Test-focused, note-like)
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
            HStack(spacing: 10) {
                Image(systemName: "note.text")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color(red: 252/255, green: 108/255, blue: 133/255))

                Text("Activity")
                    .font(.system(size: 22, weight: .bold))

                Spacer()

                Text("Test")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.orange)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.orange.opacity(0.15))
                    .cornerRadius(12)
            }
            .padding(.horizontal)

            // Vertical, note-like list with generous spacing
            if recentActivities.isEmpty {
                emptyStateView
            } else {
                VStack(alignment: .leading, spacing: 14) {
                    ForEach(recentActivities) { activity in
                        NoteActivityRow(activity: activity)
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 14) {
            Image(systemName: "note.text")
                .font(.system(size: 40))
                .foregroundColor(.secondary)

            Text("No recent activity")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 44)
    }
}

// MARK: - Note-like Activity Row
struct NoteActivityRow: View {
    @EnvironmentObject var viewModel: AppViewModel
    let activity: UserActivity

    var user: User? { viewModel.getUser(by: activity.userId) }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Title line: Name • type
            HStack(spacing: 6) {
                if let user = user {
                    Text(user.name)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.primary)
                }

                Text("•")
                    .foregroundColor(.secondary)

                Text(activity.type.rawValue)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }

            // Body text
            Text(activity.text)
                .font(.system(size: 15))
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)

            // Meta: location + time
            HStack(spacing: 8) {
                if let location = activity.location {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 12))
                        .foregroundColor(Color(red: 252/255, green: 108/255, blue: 133/255))
                    Text(location.name)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                Text(activity.timeAgo)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    ActivityFeedView()
        .environmentObject(AppViewModel())
}
