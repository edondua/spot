import SwiftUI

struct CheckInDetailView: View {
    @EnvironmentObject var viewModel: AppViewModel
    let location: Location
    @Binding var isPresented: Bool
    @State private var caption = ""
    @State private var showingPeopleHere = false
    @State private var selectedUser: User?
    @State private var showingUserActions = false

    var usersAtLocation: [User] {
        viewModel.getUsersAt(location: location)
    }

    var usersWithFavorite: [User] {
        viewModel.getUsersWithFavorite(location: location)
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            ScrollView {
                VStack(spacing: 32) {
                    // Simplified Location Header
                    VStack(spacing: 16) {
                        // Icon with subtle background
                        ZStack {
                            Circle()
                                .fill(Color(red: 252/255, green: 108/255, blue: 133/255).opacity(0.15))
                                .frame(width: 100, height: 100)

                            Image(systemName: location.type.icon)
                                .font(.system(size: 44, weight: .medium))
                                .foregroundColor(Color(red: 252/255, green: 108/255, blue: 133/255))
                        }
                        .padding(.top, 60)

                        VStack(spacing: 8) {
                            Text(location.name)
                                .font(.system(size: 28, weight: .bold))
                                .multilineTextAlignment(.center)

                            Text(location.address)
                                .font(.system(size: 15))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }

                        // Active users - simpler design
                        if location.activeUsers > 0 {
                            HStack(spacing: 8) {
                                ZStack {
                                    Circle()
                                        .fill(Color.green)
                                        .frame(width: 12, height: 12)

                                    Circle()
                                        .stroke(Color.green.opacity(0.3), lineWidth: 4)
                                        .frame(width: 20, height: 20)
                                }

                                Text("\(location.activeUsers) people here now")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.primary)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 24)

                    // People here section - with description
                    if !usersAtLocation.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Who's Here")
                                    .font(.system(size: 22, weight: .bold))

                                Text("These people are checked in right now")
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 24)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 20) {
                                    ForEach(usersAtLocation) { user in
                                        SmallUserCard(user: user)
                                            .onTapGesture {
                                                selectedUser = user
                                                showingUserActions = true
                                            }
                                    }
                                }
                                .padding(.horizontal, 24)
                            }
                        }
                    }

                    // Regular visitors section - with description
                    if !usersWithFavorite.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Regulars")
                                    .font(.system(size: 22, weight: .bold))

                                Text("People who frequently visit this spot")
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 24)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 20) {
                                    ForEach(usersWithFavorite.prefix(8)) { user in
                                        SmallUserCard(user: user)
                                            .onTapGesture {
                                                selectedUser = user
                                                showingUserActions = true
                                            }
                                    }
                                }
                                .padding(.horizontal, 24)
                            }
                        }
                    }

                    // Stories at this location
                    let stories = viewModel.getActiveStories(for: location)
                    if !stories.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Stories")
                                    .font(.system(size: 22, weight: .bold))

                                Text("Recent moments from this spot")
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 24)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(stories) { story in
                                        StoryThumbnail(story: story)
                                    }
                                }
                                .padding(.horizontal, 24)
                            }
                        }
                    }

                    // Caption input - cleaner design
                    VStack(alignment: .leading, spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Share Your Vibe")
                                .font(.system(size: 18, weight: .semibold))

                            Text("Optional - let others know what you're up to")
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                        }

                        TextField("What brings you here?", text: $caption)
                            .font(.system(size: 16))
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 24)

                    // Check-in button - prominent
                    Button(action: {
                        viewModel.checkIn(at: location, caption: caption.isEmpty ? nil : caption)
                        isPresented = false
                    }) {
                        HStack(spacing: 10) {
                            Image(systemName: "location.fill")
                                .font(.system(size: 18, weight: .bold))
                            Text("Check In")
                                .font(.system(size: 18, weight: .bold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .foregroundColor(.white)
                        .background(
                            LinearGradient(
                                colors: [.pink, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(14)
                        .shadow(color: Color.pink.opacity(0.3), radius: 10, x: 0, y: 4)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }

            // Close button - floating on top right
            Button(action: {
                isPresented = false
            }) {
                ZStack {
                    Circle()
                        .fill(Color(.systemBackground))
                        .frame(width: 36, height: 36)
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)

                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)
                }
            }
            .padding(.top, 16)
            .padding(.trailing, 16)
        }
        .sheet(isPresented: $showingUserActions) {
            if let user = selectedUser {
                QuickUserActionSheet(user: user)
                    .environmentObject(viewModel)
                    .presentationDetents([.height(400)])
            }
        }
    }
}

// MARK: - Quick User Action Sheet
struct QuickUserActionSheet: View {
    @EnvironmentObject var viewModel: AppViewModel
    @Environment(\.dismiss) var dismiss
    let user: User
    @State private var showingRelationshipPicker = false

    var isFriend: Bool {
        viewModel.isFriend(user.id)
    }

    var hasSentRequest: Bool {
        viewModel.hasSentFriendRequest(to: user.id)
    }

    var relationshipStatus: RelationshipStatus? {
        viewModel.getRelationshipStatus(with: user.id)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Handle bar
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 36, height: 5)
                .padding(.top, 12)
                .padding(.bottom, 20)

            // User info
            VStack(spacing: 12) {
                ProfileImageView(user: user, size: 80)

                Text(user.name)
                    .font(.title2)
                    .fontWeight(.bold)

                Text("\(user.age) • \(user.job ?? "Explorer")")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                // Relationship status display
                if let status = relationshipStatus {
                    HStack(spacing: 6) {
                        Text(status.emoji)
                        Text(status.rawValue)
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(status.color.opacity(0.15))
                    .foregroundColor(status.color)
                    .cornerRadius(12)
                }
            }
            .padding(.bottom, 20)

            // Actions
            VStack(spacing: 12) {
                // Friend action
                if isFriend {
                    Button(action: {
                        viewModel.removeFriend(user.id)
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "person.badge.minus")
                            Text("Remove Friend")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .foregroundColor(.red)
                        .cornerRadius(12)
                    }
                } else if hasSentRequest {
                    Button(action: {
                        viewModel.cancelFriendRequest(to: user.id)
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "xmark.circle")
                            Text("Cancel Friend Request")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .foregroundColor(.gray)
                        .cornerRadius(12)
                    }
                } else {
                    Button(action: {
                        viewModel.sendFriendRequest(to: user.id)
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "person.badge.plus.fill")
                            Text("Add Friend")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [.pink, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                }

                // Relationship status action
                Button(action: {
                    showingRelationshipPicker = true
                }) {
                    HStack {
                        Image(systemName: "heart.text.square")
                        Text(relationshipStatus == nil ? "Set Relationship Status" : "Change Status")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.purple.opacity(0.1))
                    .foregroundColor(.purple)
                    .cornerRadius(12)
                }

                // Like action
                Button(action: {
                    viewModel.likeUser(user)
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "heart.fill")
                        Text("Like")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.pink.opacity(0.1))
                    .foregroundColor(.pink)
                    .cornerRadius(12)
                }

                // Message action (if matched)
                if viewModel.hasMatch(with: user.id) {
                    Button(action: {
                        dismiss()
                        // TODO: Navigate to chat
                    }) {
                        HStack {
                            Image(systemName: "message.fill")
                            Text("Message")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(12)
                    }
                }
            }
            .padding(.horizontal, 24)

            Spacer()
        }
        .sheet(isPresented: $showingRelationshipPicker) {
            RelationshipStatusPicker(user: user)
                .environmentObject(viewModel)
                .presentationDetents([.height(500)])
        }
    }
}

// MARK: - Relationship Status Picker
struct RelationshipStatusPicker: View {
    @EnvironmentObject var viewModel: AppViewModel
    @Environment(\.dismiss) var dismiss
    let user: User

    var currentStatus: RelationshipStatus? {
        viewModel.getRelationshipStatus(with: user.id)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Handle bar
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 36, height: 5)
                .padding(.top, 12)
                .padding(.bottom, 20)

            // Header
            VStack(spacing: 8) {
                Text("Relationship Status")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("with \(user.name)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.bottom, 30)

            // Status options
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(RelationshipStatus.allCases, id: \.self) { status in
                        Button(action: {
                            viewModel.setRelationshipStatus(with: user.id, status: status)
                            dismiss()
                        }) {
                            HStack {
                                Text(status.emoji)
                                    .font(.title2)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(status.rawValue)
                                        .font(.headline)
                                        .foregroundColor(.primary)

                                    Text(status.description)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }

                                Spacer()

                                if currentStatus == status {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(status.color)
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(currentStatus == status ? status.color.opacity(0.1) : Color(.systemGray6))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(currentStatus == status ? status.color : Color.clear, lineWidth: 2)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }

                    // Remove status button
                    if currentStatus != nil {
                        Button(action: {
                            viewModel.removeRelationshipStatus(with: user.id)
                            dismiss()
                        }) {
                            HStack {
                                Image(systemName: "xmark.circle")
                                    .foregroundColor(.red)

                                Text("Remove Status")
                                    .font(.headline)
                                    .foregroundColor(.red)

                                Spacer()
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.red.opacity(0.1))
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 24)
            }

            Spacer()
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

// MARK: - Game Invitation Card (shown on CheckInDetailView)
struct IcebreakerGameInviteCard: View {
    @EnvironmentObject var viewModel: AppViewModel
    let location: Location
    let nearbyUsers: [User]
    @State private var showGamePicker = false
    @State private var showActiveGame = false
    @State private var selectedGameType: IcebreakerGame.GameType?

    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.pink, Color.purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 56, height: 56)

                    Image(systemName: "gamecontroller.fill")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Break the Ice! 🎮")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)

                    Text("\(nearbyUsers.count) people here now")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
            }

            // Description
            Text("Challenge nearby groups to quick games and make new friends!")
                .font(.system(size: 15))
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Start Game Button
            Button(action: {
                showGamePicker = true
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 16, weight: .bold))
                    Text("Start a Game")
                        .font(.system(size: 16, weight: .bold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(
                        colors: [Color.pink, Color.purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
        )
        .padding(.horizontal, 20)
        .sheet(isPresented: $showGamePicker) {
            GamePickerSheet(
                location: location,
                nearbyUsers: nearbyUsers,
                onGameSelected: { gameType in
                    selectedGameType = gameType
                    showGamePicker = false
                    showActiveGame = true
                }
            )
        }
        .fullScreenCover(isPresented: $showActiveGame) {
            if let gameType = selectedGameType {
                GameSessionView(
                    gameType: gameType,
                    location: location,
                    participants: nearbyUsers
                )
            }
        }
    }
}

// MARK: - Game Picker Sheet
struct GamePickerSheet: View {
    @Environment(\.dismiss) var dismiss
    let location: Location
    let nearbyUsers: [User]
    let onGameSelected: (IcebreakerGame.GameType) -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 8) {
                        Text("🎮 Choose a Game")
                            .font(.system(size: 28, weight: .bold))

                        Text("Pick an icebreaker to play with \(nearbyUsers.count) nearby people")
                            .font(.system(size: 15))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)

                    // Game Cards
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        ForEach(IcebreakerGame.GameType.allCases, id: \.self) { gameType in
                            GameTypeCard(gameType: gameType) {
                                onGameSelected(gameType)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 30)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Game Type Card
struct GameTypeCard: View {
    let gameType: IcebreakerGame.GameType
    let action: () -> Void
    @State private var isPressed = false

    var gameColor: Color {
        switch gameType.color {
        case "orange": return .orange
        case "purple": return .purple
        case "pink": return .pink
        case "blue": return .blue
        case "green": return .green
        case "yellow": return .yellow
        default: return .gray
        }
    }

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                // Icon
                ZStack {
                    Circle()
                        .fill(gameColor.opacity(0.2))
                        .frame(width: 56, height: 56)

                    Image(systemName: gameType.icon)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(gameColor)
                }

                // Title
                Text(gameType.rawValue)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.primary)

                // Description
                Text(gameType.description)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .frame(height: 180)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemGray6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(gameColor, lineWidth: 2)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Game Session View
struct GameSessionView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: AppViewModel
    let gameType: IcebreakerGame.GameType
    let location: Location
    let participants: [User]

    @State private var currentRound = 0
    @State private var timeRemaining = 10
    @State private var userAnswer: String = ""
    @State private var showResults = false
    @State private var gameContent: [String] = []

    var gameColor: Color {
        switch gameType.color {
        case "orange": return .orange
        case "purple": return .purple
        case "pink": return .pink
        case "blue": return .blue
        case "green": return .green
        case "yellow": return .yellow
        default: return .gray
        }
    }

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [gameColor.opacity(0.3), Color(.systemBackground)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                gameHeader

                Spacer()

                // Game Content
                if currentRound < 3 {
                    gameRoundView
                } else {
                    gameResultsView
                }

                Spacer()

                // Actions
                gameActions
            }
        }
        .onAppear {
            loadGameContent()
        }
    }

    private var gameHeader: some View {
        VStack(spacing: 12) {
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                        .frame(width: 40, height: 40)
                        .background(Color(.systemGray6))
                        .clipShape(Circle())
                }

                Spacer()

                VStack(spacing: 4) {
                    Image(systemName: gameType.icon)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(gameColor)

                    Text(gameType.rawValue)
                        .font(.system(size: 16, weight: .bold))
                }

                Spacer()

                // Round indicator
                Text("Round \(currentRound + 1)/3")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(gameColor)
                    .cornerRadius(20)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)

            // Timer
            if !showResults {
                HStack(spacing: 8) {
                    Image(systemName: "timer")
                        .font(.system(size: 14, weight: .semibold))
                    Text("\(timeRemaining)s")
                        .font(.system(size: 16, weight: .bold))
                        .monospacedDigit()
                }
                .foregroundColor(timeRemaining <= 3 ? .red : .secondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .cornerRadius(20)
            }
        }
        .padding(.bottom, 20)
    }

    @ViewBuilder
    private var gameRoundView: some View {
        VStack(spacing: 30) {
            // Question/Prompt
            if currentRound < gameContent.count {
                Text(gameContent[currentRound])
                    .font(.system(size: 24, weight: .bold))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }

            // Game-specific UI
            switch gameType {
            case .thisOrThat:
                thisOrThatOptions
            case .quickFire:
                quickFireInput
            case .truthOrDare:
                truthOrDareOptions
            case .photoChallenge:
                photoChallengeView
            case .trivia:
                triviaOptions
            case .emojiStory:
                emojiStoryInput
            }
        }
    }

    private var thisOrThatOptions: some View {
        HStack(spacing: 20) {
            ForEach(["Option A", "Option B"], id: \.self) { option in
                Button(action: {
                    userAnswer = option
                    nextRound()
                }) {
                    VStack(spacing: 12) {
                        Text(option == "Option A" ? "🍕" : "🍔")
                            .font(.system(size: 60))

                        Text(option)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                    .background(gameColor)
                    .cornerRadius(20)
                }
            }
        }
        .padding(.horizontal, 20)
    }

    private var quickFireInput: some View {
        VStack(spacing: 20) {
            TextField("Your answer...", text: $userAnswer)
                .font(.system(size: 18))
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal, 40)

            Button(action: nextRound) {
                Text("Submit")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(gameColor)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 40)
        }
    }

    private var truthOrDareOptions: some View {
        HStack(spacing: 20) {
            ForEach(["Truth", "Dare"], id: \.self) { choice in
                Button(action: {
                    userAnswer = choice
                    nextRound()
                }) {
                    VStack(spacing: 12) {
                        Image(systemName: choice == "Truth" ? "questionmark.circle.fill" : "flame.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.white)

                        Text(choice)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 50)
                    .background(choice == "Truth" ? Color.blue : Color.orange)
                    .cornerRadius(20)
                }
            }
        }
        .padding(.horizontal, 20)
    }

    private var photoChallengeView: some View {
        VStack(spacing: 20) {
            Image(systemName: "camera.fill")
                .font(.system(size: 80))
                .foregroundColor(gameColor)

            Text("Take the photo together!")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.secondary)

            Button(action: {
                // Would open camera
                nextRound()
            }) {
                HStack {
                    Image(systemName: "camera.fill")
                    Text("Open Camera")
                }
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(gameColor)
                .cornerRadius(12)
            }
            .padding(.horizontal, 40)
        }
    }

    private var triviaOptions: some View {
        VStack(spacing: 12) {
            ForEach(["A", "B", "C", "D"], id: \.self) { option in
                Button(action: {
                    userAnswer = option
                    nextRound()
                }) {
                    HStack {
                        Text(option)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(gameColor)
                            .clipShape(Circle())

                        Text("Option \(option)")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.primary)

                        Spacer()
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
            }
        }
        .padding(.horizontal, 40)
    }

    private var emojiStoryInput: some View {
        VStack(spacing: 20) {
            Text("Use emojis to tell your story!")
                .font(.system(size: 16))
                .foregroundColor(.secondary)

            TextField("😀🎉✨...", text: $userAnswer)
                .font(.system(size: 32))
                .multilineTextAlignment(.center)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal, 40)

            Button(action: nextRound) {
                Text("Submit Story")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(gameColor)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 40)
        }
    }

    private var gameResultsView: some View {
        VStack(spacing: 30) {
            // Trophy animation
            ZStack {
                Circle()
                    .fill(gameColor.opacity(0.2))
                    .frame(width: 140, height: 140)

                Image(systemName: "trophy.fill")
                    .font(.system(size: 70))
                    .foregroundColor(gameColor)
            }

            Text("Game Complete! 🎉")
                .font(.system(size: 28, weight: .bold))

            Text("You've broken the ice!\nNow go say hi in person 👋")
                .font(.system(size: 17))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            // Participants
            VStack(alignment: .leading, spacing: 12) {
                Text("Players")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.secondary)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(participants.prefix(10)) { user in
                            VStack(spacing: 6) {
                                ProfileImageView(user: user, size: 60, showVerificationBadge: false)

                                Text(user.name)
                                    .font(.system(size: 12, weight: .medium))
                                    .lineLimit(1)
                            }
                            .frame(width: 70)
                        }
                    }
                }
            }
            .padding(20)
            .background(Color(.systemGray6))
            .cornerRadius(16)
            .padding(.horizontal, 40)
        }
    }

    private var gameActions: some View {
        VStack(spacing: 12) {
            if currentRound >= 3 {
                Button(action: { dismiss() }) {
                    Text("Done")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(gameColor)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 40)
            }
        }
        .padding(.bottom, 30)
    }

    private func loadGameContent() {
        switch gameType {
        case .quickFire:
            gameContent = Array(IcebreakerContent.quickFireQuestions.shuffled().prefix(3))
        case .thisOrThat:
            gameContent = IcebreakerContent.thisOrThatPairs.shuffled().prefix(3).map { "\($0.0) or \($0.1)?" }
        case .truthOrDare:
            gameContent = (IcebreakerContent.truthPrompts + IcebreakerContent.darePrompts).shuffled().prefix(3).map { $0 }
        case .photoChallenge:
            gameContent = Array(IcebreakerContent.photoChallenges.shuffled().prefix(3))
        case .trivia:
            gameContent = IcebreakerContent.triviaQuestions.shuffled().prefix(3).map { $0.question }
        case .emojiStory:
            gameContent = Array(IcebreakerContent.emojiStoryPrompts.shuffled().prefix(3))
        }
    }

    private func nextRound() {
        withAnimation {
            currentRound += 1
            userAnswer = ""
            timeRemaining = 10
        }

        if currentRound >= 3 {
            showResults = true
        }
    }
}
