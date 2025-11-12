import SwiftUI

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
