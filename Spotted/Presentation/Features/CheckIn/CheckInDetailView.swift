import SwiftUI

struct CheckInDetailView: View {
    @EnvironmentObject var viewModel: AppViewModel
    let location: Location
    @Binding var isPresented: Bool
    @State private var caption = ""
    @State private var showingPeopleHere = false

    var usersAtLocation: [User] {
        viewModel.getUsersAt(location: location)
    }

    var usersWithFavorite: [User] {
        viewModel.getUsersWithFavorite(location: location)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header with dismiss button
            HStack {
                Spacer()

                Button(action: {
                    isPresented = false
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.gray)
                }
                .padding()
            }
            .background(Color(.systemBackground))

            ScrollView {
                VStack(spacing: 24) {
                    // Location Header
                    VStack(spacing: 12) {
                        Image(systemName: location.type.icon)
                            .font(.system(size: 60))
                            .foregroundColor(.pink)
                            .padding()
                            .background(Color.pink.opacity(0.1))
                            .clipShape(Circle())

                        Text(location.name)
                            .font(.title)
                            .fontWeight(.bold)

                        Text(location.address)
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        // Active users count
                        HStack {
                            Image(systemName: "person.2.fill")
                                .foregroundColor(.pink)
                            Text("\(location.activeUsers) people spotted here")
                                .font(.headline)
                                .foregroundColor(.pink)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.pink.opacity(0.1))
                        .cornerRadius(20)
                    }
                    .padding()

                    // People here now
                    if !usersAtLocation.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("🎯 Spotted Here Now")
                                .font(.headline)
                                .padding(.horizontal)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(usersAtLocation) { user in
                                        NavigationLink(destination: UserProfileView(user: user)) {
                                            SmallUserCard(user: user)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }

                    // Regular visitors
                    if !usersWithFavorite.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("⭐️ Regular Visitors")
                                .font(.headline)
                                .padding(.horizontal)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(usersWithFavorite.prefix(6)) { user in
                                        NavigationLink(destination: UserProfileView(user: user)) {
                                            SmallUserCard(user: user)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }

                    // Stories at this location
                    let stories = viewModel.getActiveStories(for: location)
                    if !stories.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("📸 Recent Stories")
                                .font(.headline)
                                .padding(.horizontal)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(stories) { story in
                                        StoryThumbnail(story: story)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }

                    // Caption input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Add a caption (optional)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        TextField("What brings you here?", text: $caption)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    .padding(.horizontal)

                    // Check-in button
                    Button(action: {
                        viewModel.checkIn(at: location, caption: caption.isEmpty ? nil : caption)
                        isPresented = false
                    }) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Check In Here")
                                .fontWeight(.semibold)
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
                        )
                        .cornerRadius(16)
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            }
        }
    }
}

// MARK: - Small User Card
struct SmallUserCard: View {
    let user: User

    var body: some View {
        VStack(spacing: 8) {
            ProfileImageView(user: user, size: 80)

            Text(user.name)
                .font(.subheadline)
                .fontWeight(.semibold)

            Text("\(user.age)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(width: 100)
    }
}

// MARK: - Story Thumbnail
struct StoryThumbnail: View {
    @EnvironmentObject var viewModel: AppViewModel
    let story: Story
    @State private var showStoryViewer = false

    var body: some View {
        Button {
            showStoryViewer = true
        } label: {
            VStack {
                PhotoPlaceholderView(photoId: story.imageUrl, aspectRatio: 2/3)
                    .frame(width: 100, height: 150)
                    .cornerRadius(12)
                    .overlay(
                        VStack {
                            Spacer()
                            Text(story.timeAgo)
                                .font(.caption2)
                                .foregroundColor(.white)
                                .padding(6)
                                .background(Color.black.opacity(0.5))
                                .cornerRadius(8)
                        }
                        .padding(8)
                    )
            }
        }
        .buttonStyle(PlainButtonStyle())
        .fullScreenCover(isPresented: $showStoryViewer) {
            StoryViewerScreen(story: story, allStories: viewModel.getActiveStories(for: story.location))
                .environmentObject(viewModel)
        }
    }
}
