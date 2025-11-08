import SwiftUI

struct LocationDetailView: View {
    @EnvironmentObject var viewModel: AppViewModel
    let location: Location
    @State private var showStoryCreation = false

    var usersAtLocation: [User] {
        viewModel.getUsersAt(location: location)
    }

    var usersWithFavorite: [User] {
        viewModel.getUsersWithFavorite(location: location)
    }

    var activeStories: [Story] {
        viewModel.getActiveStories(for: location)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Location header
                VStack(spacing: 12) {
                    Image(systemName: location.type.icon)
                        .font(.system(size: 50))
                        .foregroundColor(.pink)
                        .padding()
                        .background(Color.pink.opacity(0.1))
                        .clipShape(Circle())

                    Text(location.name)
                        .font(.title2)
                        .fontWeight(.bold)

                    Text(location.address)
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    // Active users
                    HStack {
                        Image(systemName: "person.2.fill")
                            .foregroundColor(.pink)
                        Text("\(location.activeUsers) spotted here")
                            .font(.headline)
                            .foregroundColor(.pink)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.pink.opacity(0.1))
                    .cornerRadius(20)
                }
                .padding()

                Divider()

                // People checked in now
                if !usersAtLocation.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("🎯 Here Right Now")
                            .font(.title3)
                            .fontWeight(.bold)
                            .padding(.horizontal)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(usersAtLocation) { user in
                                    NavigationLink(destination: UserProfileView(user: user)) {
                                        VStack(spacing: 8) {
                                            ProfileImageView(user: user, size: 80)

                                            Text(user.name)
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.primary)

                                            Text("\(user.age)")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }

                    Divider()
                }

                // Stories
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("📸 Stories")
                            .font(.title3)
                            .fontWeight(.bold)

                        Spacer()

                        Button(action: {
                            showStoryCreation = true
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "plus.circle.fill")
                                Text("Add Story")
                            }
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Color(red: 252/255, green: 108/255, blue: 133/255))
                        }
                    }
                    .padding(.horizontal)

                    if !activeStories.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(activeStories) { story in
                                    StoryCard(story: story)
                                }
                            }
                            .padding(.horizontal)
                        }
                    } else {
                        // Empty state for stories
                        VStack(spacing: 12) {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.secondary.opacity(0.5))

                            Text("No stories yet")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.secondary)

                            Text("Be the first to share what's happening here!")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary.opacity(0.8))
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                    }
                }

                Divider()

                // Regular visitors
                if !usersWithFavorite.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("⭐️ Regular Visitors")
                            .font(.title3)
                            .fontWeight(.bold)
                            .padding(.horizontal)

                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            ForEach(usersWithFavorite) { user in
                                NavigationLink(destination: UserProfileView(user: user)) {
                                    VStack(spacing: 8) {
                                        ProfileImageView(user: user, size: 70, showVerificationBadge: false)

                                        Text(user.name)
                                            .font(.caption)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.primary)

                                        Text("\(user.age)")
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .padding(.vertical)
        }
        .navigationTitle(location.name)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showStoryCreation) {
            StoryCreationView(location: location)
                .environmentObject(viewModel)
        }
    }
}

// MARK: - Story Card
struct StoryCard: View {
    @EnvironmentObject var viewModel: AppViewModel
    let story: Story
    @State private var showStoryViewer = false

    var body: some View {
        Button {
            showStoryViewer = true
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                PhotoPlaceholderView(photoId: story.imageUrl, aspectRatio: 9/16)
                    .frame(width: 120, height: 180)
                    .cornerRadius(12)
                    .overlay(
                        VStack {
                            Spacer()

                            if let caption = story.caption {
                                Text(caption)
                                    .font(.caption2)
                                    .foregroundColor(.white)
                                    .lineLimit(2)
                                    .padding(8)
                                    .frame(maxWidth: .infinity)
                                    .background(Color.black.opacity(0.5))
                            }

                            HStack {
                                Text(story.timeAgo)
                                    .font(.caption2)
                                    .foregroundColor(.white)

                                Spacer()

                                HStack(spacing: 4) {
                                    Image(systemName: "eye.fill")
                                    Text("\(story.viewCount)")
                                }
                                .font(.caption2)
                                .foregroundColor(.white)
                            }
                            .padding(8)
                            .background(Color.black.opacity(0.5))
                        }
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

// MARK: - Full Screen Story Viewer
struct StoryViewerScreen: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: AppViewModel
    let story: Story
    let allStories: [Story]

    @State private var currentIndex: Int = 0
    @State private var progress: CGFloat = 0
    @State private var timer: Timer?
    @State private var isPaused = false
    @GestureState private var dragOffset: CGFloat = 0

    private let storyDuration: TimeInterval = 5.0

    var currentStory: Story {
        allStories[currentIndex]
    }

    var user: User? {
        viewModel.getUser(by: currentStory.userId)
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            // Story image - full screen
            GeometryReader { geometry in
                PhotoPlaceholderView(photoId: currentStory.imageUrl, aspectRatio: 9/16)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
            }
            .ignoresSafeArea()

            // Top gradient overlay
            VStack {
                LinearGradient(
                    colors: [Color.black.opacity(0.7), Color.clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 200)

                Spacer()
            }
            .ignoresSafeArea()

            // Content overlay
            VStack(spacing: 0) {
                // Progress bars
                HStack(spacing: 4) {
                    ForEach(allStories.indices, id: \.self) { index in
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .fill(Color.white.opacity(0.3))

                                Rectangle()
                                    .fill(Color.white)
                                    .frame(width: index == currentIndex ? geometry.size.width * progress : (index < currentIndex ? geometry.size.width : 0))
                            }
                        }
                        .frame(height: 3)
                        .cornerRadius(1.5)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.top, 50)

                // User info header (tappable)
                HStack(spacing: 12) {
                    if let user = user {
                        // Tappable user profile area
                        NavigationLink(destination: UserProfileView(user: user)) {
                            HStack(spacing: 12) {
                                ProfileImageView(user: user, size: 40)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(user.name)
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)

                                    Text(currentStory.timeAgo)
                                        .font(.system(size: 13))
                                        .foregroundColor(.white.opacity(0.8))
                                }
                            }
                        }
                    }

                    Spacer()

                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.black.opacity(0.3))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)

                Spacer()

                // Caption at bottom
                if let caption = currentStory.caption {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(caption)
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)

                        HStack(spacing: 16) {
                            HStack(spacing: 4) {
                                Image(systemName: "eye.fill")
                                Text("\(currentStory.viewCount)")
                            }
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.8))

                            HStack(spacing: 4) {
                                Image(systemName: "location.fill")
                                Text(currentStory.location.name)
                            }
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(
                        LinearGradient(
                            colors: [Color.clear, Color.black.opacity(0.7)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
            }

            // Tap areas for navigation
            HStack(spacing: 0) {
                Rectangle()
                    .fill(Color.clear)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        previousStory()
                    }

                Rectangle()
                    .fill(Color.clear)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        nextStory()
                    }
            }
        }
        .gesture(
            DragGesture()
                .updating($dragOffset) { value, state, _ in
                    state = value.translation.height
                }
                .onEnded { value in
                    if value.translation.height > 100 {
                        dismiss()
                    }
                }
        )
        .onAppear {
            // Find initial index
            if let index = allStories.firstIndex(where: { $0.id == story.id }) {
                currentIndex = index
            }
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
        .statusBarHidden()
    }

    private func startTimer() {
        progress = 0
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            if !isPaused {
                progress += 0.05 / storyDuration
                if progress >= 1.0 {
                    nextStory()
                }
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func nextStory() {
        if currentIndex < allStories.count - 1 {
            currentIndex += 1
            stopTimer()
            startTimer()
        } else {
            dismiss()
        }
    }

    private func previousStory() {
        if progress < 0.1 && currentIndex > 0 {
            currentIndex -= 1
            stopTimer()
            startTimer()
        } else {
            stopTimer()
            startTimer()
        }
    }
}

#Preview {
    NavigationView {
        LocationDetailView(location: Location(
            name: "Zürich Hauptbahnhof",
            type: .trainStation,
            address: "Bahnhofplatz, 8001 Zürich",
            latitude: 47.3779,
            longitude: 8.5403,
            activeUsers: 24
        ))
        .environmentObject(AppViewModel())
    }
}
