import SwiftUI

struct ProfileView: View {
    let user: User
    let isCurrentUser: Bool
    @State private var showSettings = false

    var body: some View {
        NavigationStack {
            ProfileContent(
                user: user,
                isCurrentUser: isCurrentUser,
                allowsSocialActions: false
            )
            .navigationTitle(isCurrentUser ? "My Profile" : "Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if isCurrentUser {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            showSettings = true
                        } label: {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 18))
                                .foregroundColor(Color(red: 252/255, green: 108/255, blue: 133/255))
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
    }
}

/// Shared scroll content used by both the current-user profile and public profile screens
private struct ProfileContent: View {
    let user: User
    let isCurrentUser: Bool
    let allowsSocialActions: Bool

    @EnvironmentObject private var viewModel: AppViewModel
    @State private var showContent = false
    @State private var showVoiceIntroRecorder = false

    // Prefer a voice prompt if available; otherwise the first prompt
    private var featuredPromptIndex: Int? {
        if let voiceIndex = user.prompts.firstIndex(where: { $0.hasVoiceRecording }) {
            return voiceIndex
        }
        return user.prompts.isEmpty ? nil : 0
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(alignment: .leading, spacing: 20) {
                headerSection

                if shouldShowCompletionBanner {
                    ProfileCompletionBanner(completion: user.profileCompletion)
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                        .transition(.opacity)
                }

                // Hero photo
                photoCard(at: 0, animated: true)

                // Featured prompt (voice if available, else first prompt)
                if let idx = featuredPromptIndex {
                    PromptCard(prompt: user.prompts[idx], user: allowsSocialActions ? user : nil)
                        .padding(.horizontal, 20)
                } else if isCurrentUser {
                    // CTA to add a voice intro if none exist
                    Button {
                        showVoiceIntroRecorder = true
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "mic.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Add a voice intro")
                                    .font(.system(size: 16, weight: .semibold))
                                Text("Share a quick hello — it helps you stand out")
                                    .font(.system(size: 12))
                                    .opacity(0.9)
                            }
                            Spacer()
                        }
                        .padding(16)
                        .background(Color(red: 252/255, green: 108/255, blue: 133/255))
                        .cornerRadius(14)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                    }
                    .buttonStyle(ScaleButtonStyle())
                }

                // Key stats
                ComprehensiveStatsSection(user: user)
                    .padding(.horizontal, 20)

                // Photo 1 - After stats
                photoCard(at: 1)

                // Remaining prompts (excluding the featured one)
                remainingPrompts(excluding: featuredPromptIndex)

                // Photo 2 - After prompts
                photoCard(at: 2)

                // Interests section
                interestsSection
                    .padding(.horizontal, 20)

                // Photo 3 - After interests
                photoCard(at: 3)

                // Current check-in
                currentCheckInSection
                    .padding(.horizontal, 20)

                // Photo 4 - After check-in
                photoCard(at: 4)

                // Favorite hangouts
                favoriteHangoutsSection
                    .padding(.horizontal, 20)

                // Photo 5 - After hangouts
                photoCard(at: 5)

                // Social actions
                if allowsSocialActions {
                    mutualFriendsSection
                        .padding(.horizontal, 20)
                    friendButtonSection
                        .padding(.horizontal, 20)
                    matchActionSection
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.4)) {
                showContent = true
            }
        }
        .sheet(isPresented: $showVoiceIntroRecorder) {
            VoiceIntroRecorderSheet { duration, note in
                viewModel.saveVoiceIntro(duration: duration, text: note)
            }
        }
    }

    private var shouldShowCompletionBanner: Bool {
        isCurrentUser && user.profileCompletion < 100
    }

    @ViewBuilder
    private var headerSection: some View {
        HStack(spacing: 8) {
            Text(user.displayName)
                .font(.system(size: 28, weight: .bold))

            if user.isVerified {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.blue)
                    .scaleEffect(showContent ? 1 : 0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.2), value: showContent)
            }

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .opacity(showContent ? 1 : 0)
        .offset(y: showContent ? 0 : -20)
        .animation(.easeOut(duration: 0.4), value: showContent)
    }

    @ViewBuilder
    private func photoCard(at index: Int, animated: Bool = false) -> some View {
        if user.photos.indices.contains(index) {
            let content = Group {
                if allowsSocialActions {
                    LikablePhoto(photoId: user.photos[index], user: user, photoIndex: index)
                } else {
                    ProfilePhotoCard(photoId: user.photos[index])
                }
            }
            .padding(.horizontal, 20)

            if animated {
                content
                    .opacity(showContent ? 1 : 0)
                    .scaleEffect(showContent ? 1 : 0.9)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1), value: showContent)
            } else {
                content
            }
        }
    }

    @ViewBuilder
    private func promptCards(in range: Range<Int>) -> some View {
        ForEach(range, id: \.self) { index in
            if user.prompts.indices.contains(index) {
                PromptCard(
                    prompt: user.prompts[index],
                    user: allowsSocialActions ? user : nil
                )
                .padding(.horizontal, 20)
            }
        }
    }

    @ViewBuilder
    private func remainingPrompts(excluding excludeIndex: Int?) -> some View {
        ForEach(user.prompts.indices, id: \.self) { i in
            if excludeIndex != i {
                PromptCard(prompt: user.prompts[i], user: allowsSocialActions ? user : nil)
                    .padding(.horizontal, 20)
            }
        }
    }

    @ViewBuilder
    private var additionalContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            interestsSection
            photoCard(at: 4)
            currentCheckInSection
            photoCard(at: 5)
            favoriteHangoutsSection
            if allowsSocialActions {
                mutualFriendsSection
                friendButtonSection
                matchActionSection
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }

    @ViewBuilder
    private var interestsSection: some View {
        if !user.interests.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("Interests")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 8)], spacing: 8) {
                    ForEach(user.interests, id: \.self) { interest in
                        if let category = DiscoveryCategory.allCases.first(where: { $0.rawValue == interest }) {
                            NavigationLink(destination: CategoryDetailView(category: category)) {
                                HStack(spacing: 6) {
                                    Image(systemName: category.icon)
                                        .font(.system(size: 12, weight: .bold))
                                    Text(category.rawValue)
                                        .font(.system(size: 14, weight: .semibold))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(category.color)
                                .cornerRadius(20)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var currentCheckInSection: some View {
        if let checkIn = user.currentCheckIn, checkIn.isActive {
            VStack(alignment: .leading, spacing: 12) {
                Text("Right Now")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)

                HStack(spacing: 12) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 20))
                        .foregroundColor(Color(red: 252/255, green: 108/255, blue: 133/255))

                    VStack(alignment: .leading, spacing: 3) {
                        Text("Here now")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.secondary)

                        Text(checkIn.location.name)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                    }

                    Spacer()

                    Text(checkIn.timeRemaining)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                }
            }
        }
    }

    @ViewBuilder
    private var favoriteHangoutsSection: some View {
        if !user.favoriteHangouts.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("Favorite Hangouts")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)

                VStack(spacing: 10) {
                    ForEach(user.favoriteHangouts) { location in
                        HStack(spacing: 12) {
                            Image(systemName: location.type.icon)
                                .font(.system(size: 18))
                                .foregroundColor(Color(red: 252/255, green: 108/255, blue: 133/255))
                                .frame(width: 40, height: 40)
                                .background(Color(red: 252/255, green: 108/255, blue: 133/255).opacity(0.1))
                                .cornerRadius(10)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(location.name)
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.primary)

                                Text(location.type.rawValue)
                                    .font(.system(size: 13))
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            Text("\(location.activeUsers) here now")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var mutualFriendsSection: some View {
        let mutualFriends = viewModel.getMutualFriends(with: user.id)

        if !mutualFriends.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("Mutual Friends")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)

                HStack(spacing: 12) {
                    // Show up to 5 friend avatars
                    HStack(spacing: -12) {
                        ForEach(Array(mutualFriends.prefix(5).enumerated()), id: \.element.id) { index, friend in
                            ProfileImageView(user: friend, size: 40)
                                .overlay(
                                    Circle()
                                        .stroke(Color(.systemBackground), lineWidth: 2)
                                )
                                .zIndex(Double(5 - index))
                        }
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        if mutualFriends.count == 1 {
                            Text(mutualFriends[0].name)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.primary)
                        } else {
                            Text("\(mutualFriends.count) mutual friends")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.primary)
                        }

                        Text("Friends on Spotted")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }

                    Spacer()
                }
                .padding(16)
                .background(Color(.systemGray6).opacity(0.5))
                .cornerRadius(12)
            }
        }
    }

    @ViewBuilder
    private var friendButtonSection: some View {
        let isFriend = viewModel.isFriend(user.id)
        let hasSentRequest = viewModel.hasSentFriendRequest(to: user.id)
        let hasReceivedRequest = viewModel.hasReceivedFriendRequest(from: user.id)

        VStack(spacing: 12) {
            if hasReceivedRequest {
                // Show accept/reject buttons
                HStack(spacing: 12) {
                    Button(action: {
                        viewModel.acceptFriendRequest(from: user.id)
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 16, weight: .bold))
                            Text("Accept Friend Request")
                                .font(.system(size: 16, weight: .bold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .foregroundColor(.white)
                        .background(Color(red: 252/255, green: 108/255, blue: 133/255))
                        .cornerRadius(14)
                    }
                    .buttonStyle(ScaleButtonStyle())

                    Button(action: {
                        viewModel.rejectFriendRequest(from: user.id)
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.secondary)
                            .frame(width: 50, height: 50)
                            .background(Color(.systemGray5))
                            .cornerRadius(14)
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
            } else if isFriend {
                // Show friends status
                Button(action: {
                    // Could show options to unfriend
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 18, weight: .bold))
                        Text("Friends")
                            .font(.system(size: 16, weight: .bold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .foregroundColor(Color(red: 252/255, green: 108/255, blue: 133/255))
                    .background(Color(.systemGray6))
                    .cornerRadius(14)
                }
                .buttonStyle(ScaleButtonStyle())
                .disabled(true)
            } else if hasSentRequest {
                // Show pending status
                Button(action: {
                    viewModel.cancelFriendRequest(to: user.id)
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "clock")
                            .font(.system(size: 18, weight: .bold))
                        Text("Friend Request Sent")
                            .font(.system(size: 16, weight: .bold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .foregroundColor(.secondary)
                    .background(Color(.systemGray6))
                    .cornerRadius(14)
                }
                .buttonStyle(ScaleButtonStyle())
            } else {
                // Show add friend button
                Button(action: {
                    viewModel.sendFriendRequest(to: user.id)
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "person.badge.plus")
                            .font(.system(size: 18, weight: .bold))
                        Text("Add Friend")
                            .font(.system(size: 16, weight: .bold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .foregroundColor(.white)
                    .background(
                        LinearGradient(
                            colors: [
                                Color(red: 252/255, green: 108/255, blue: 133/255),
                                Color(red: 255/255, green: 149/255, blue: 0/255)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(14)
                }
                .buttonStyle(ScaleButtonStyle())
                .simultaneousGesture(TapGesture().onEnded {
                    let impactMed = UIImpactFeedbackGenerator(style: .medium)
                    impactMed.impactOccurred()
                })
            }
        }
    }

    @ViewBuilder
    private var matchActionSection: some View {
        if viewModel.hasMatch(with: user.id) {
            if let conversation = viewModel.getConversation(with: user.id) {
                NavigationLink(destination: ChatContainerView(conversation: conversation)) {
                    HStack(spacing: 8) {
                        Image(systemName: "message.fill")
                            .font(.system(size: 18, weight: .bold))
                        Text("Message")
                            .font(.system(size: 16, weight: .bold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .foregroundColor(.white)
                    .background(Color(red: 252/255, green: 108/255, blue: 133/255))
                    .cornerRadius(14)
                }
                .buttonStyle(ScaleButtonStyle())
                .simultaneousGesture(TapGesture().onEnded {
                    let impactMed = UIImpactFeedbackGenerator(style: .light)
                    impactMed.impactOccurred()
                })
            }
        } else {
            VStack(spacing: 12) {
                Image(systemName: "hand.tap.fill")
                    .font(.system(size: 40))
                    .foregroundColor(Color(red: 252/255, green: 108/255, blue: 133/255).opacity(0.6))

                Text("Tap photos or prompts to like")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 30)
        }
    }
}

/// Static photo card (no like interactions) for the current-user profile flow
private struct ProfilePhotoCard: View {
    let photoId: String

    var body: some View {
        PhotoPlaceholderView(photoId: photoId, aspectRatio: 4/5)
            .frame(height: 500)
            .cornerRadius(16)
    }
}

// MARK: - Likable Photo Component
struct LikablePhoto: View {
    let photoId: String
    let user: User
    let photoIndex: Int
    @EnvironmentObject var viewModel: AppViewModel
    @State private var showLikeButton = false
    @State private var isLiked = false
    @State private var heartScale: CGFloat = 1.0
    @State private var heartOpacity: Double = 0

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            PhotoPlaceholderView(photoId: photoId, aspectRatio: 4/5)
                .frame(height: 500)
                .cornerRadius(16)
                .overlay(
                    // Gradient overlay for better button visibility
                    LinearGradient(
                        colors: [.clear, .black.opacity(0.3)],
                        startPoint: .center,
                        endPoint: .bottom
                    )
                    .cornerRadius(16)
                )
                .overlay(
                    // Large heart animation on like
                    Image(systemName: "heart.fill")
                        .font(.system(size: 100, weight: .bold))
                        .foregroundColor(.white)
                        .scaleEffect(heartScale)
                        .opacity(heartOpacity)
                )

            // Like button
            if showLikeButton && !viewModel.hasMatch(with: user.id) {
                Button(action: {
                    likePhoto()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: isLiked ? "heart.fill" : "heart")
                            .font(.system(size: 18, weight: .bold))
                        Text(isLiked ? "Liked" : "Like")
                            .font(.system(size: 15, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        Capsule()
                            .fill(Color(red: 252/255, green: 108/255, blue: 133/255))
                            .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                    )
                }
                .buttonStyle(ScaleButtonStyle())
                .padding(20)
                .disabled(isLiked)
                .opacity(isLiked ? 0.6 : 1.0)
            }
        }
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                showLikeButton.toggle()
            }
        }
    }

    private func likePhoto() {
        let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
        impactHeavy.impactOccurred()

        // Heart animation
        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
            heartScale = 1.2
            heartOpacity = 1.0
        }

        withAnimation(.easeOut(duration: 0.5).delay(0.2)) {
            heartScale = 1.5
            heartOpacity = 0
        }

        // Reset after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            heartScale = 1.0
        }

        isLiked = true
        viewModel.likeUser(user)
    }
}

// MARK: - Prompt Card Component
struct PromptCard: View {
    let prompt: ProfilePrompt
    @State private var isPressed = false
    @State private var showLikeButton = false
    @State private var isLiked = false
    @State private var isPlayingVoice = false
    @EnvironmentObject var viewModel: AppViewModel

    // We need access to the user to like them
    var user: User?

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Text(prompt.question)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)

                    Spacer()

                    // Small inline play control for voice prompts
                    if prompt.hasVoiceRecording {
                        HStack(spacing: 8) {
                            Button(action: { isPlayingVoice.toggle() }) {
                                Image(systemName: isPlayingVoice ? "pause.circle.fill" : "play.circle.fill")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(Color(red: 252/255, green: 108/255, blue: 133/255))
                            }
                            .buttonStyle(PlainButtonStyle())

                            if let duration = prompt.durationDisplay {
                                Text(duration)
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }

                // Voice player if has recording
                if prompt.hasVoiceRecording {
                    VoicePlayerView(prompt: prompt, isPlaying: $isPlayingVoice)
                }

                Text(prompt.answer)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.primary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemGray6))
            .cornerRadius(16)

            // Like button for prompts
            if let user = user, showLikeButton && !viewModel.hasMatch(with: user.id) {
                Button(action: {
                    likePrompt()
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: isLiked ? "heart.fill" : "heart")
                            .font(.system(size: 16, weight: .bold))
                        Text(isLiked ? "Liked" : "Like")
                            .font(.system(size: 14, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(Color(red: 252/255, green: 108/255, blue: 133/255))
                    )
                }
                .buttonStyle(ScaleButtonStyle())
                .padding(16)
                .disabled(isLiked)
                .opacity(isLiked ? 0.6 : 1.0)
            }
        }
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                showLikeButton.toggle()
            }
            let impactMed = UIImpactFeedbackGenerator(style: .light)
            impactMed.impactOccurred()
            isPressed = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
            }
        }
    }

    private func likePrompt() {
        guard let user = user else { return }

        let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
        impactHeavy.impactOccurred()

        isLiked = true
        viewModel.likeUser(user)
    }
}

// MARK: - Comprehensive Stats Section
struct ComprehensiveStatsSection: View {
    let user: User

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("About Me")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)

            // Grid layout for stats
            VStack(spacing: 14) {
                // Row 1: Profession & Education
                HStack(spacing: 12) {
                    if let job = user.job {
                        let company = user.company
                        StatItem(icon: "briefcase", label: "Profession", value: company != nil ? "\(job) @ \(company!)" : job)
                    }
                    if let education = user.education {
                        StatItem(icon: "book.closed", label: "Education", value: education)
                    } else if let school = user.school {
                        StatItem(icon: "book.closed", label: "School", value: school)
                    }
                }

                // Row 2: Location & Height
                HStack(spacing: 12) {
                    if let hometown = user.hometown {
                        StatItem(icon: "mappin.circle", label: "Location", value: hometown)
                    }
                    if let height = user.height {
                        StatItem(icon: "ruler", label: "Height", value: height)
                    }
                }

                // Row 3: Age & Looking for
                HStack(spacing: 12) {
                    StatItem(icon: "calendar", label: "Age", value: "\(user.age)")
                    if let lookingFor = user.lookingFor {
                        StatItem(icon: "sparkles", label: "Looking for", value: lookingFor)
                    }
                }

                // Row 4: Drinking & Smoking
                HStack(spacing: 12) {
                    if let drinking = user.drinking {
                        StatItem(icon: "wineglass", label: "Drinking", value: drinking)
                    }
                    if let smoking = user.smoking {
                        StatItem(icon: "smoke", label: "Smoking", value: smoking)
                    }
                }

                // Row 5: Kids & Sexuality
                HStack(spacing: 12) {
                    if let kids = user.kids {
                        StatItem(icon: "figure.2.and.child.holdinghands", label: "Kids", value: kids)
                    }
                    if let sexuality = user.sexuality {
                        StatItem(icon: "heart.circle", label: "Sexuality", value: sexuality)
                    }
                }

                // Bio if available
                if !user.bio.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Bio")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)

                        Text(user.bio)
                            .font(.system(size: 16))
                            .foregroundColor(.primary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.top, 4)
                }
            }
        }
        .padding(20)
        .background(Color(.systemGray6).opacity(0.5))
        .cornerRadius(20)
    }
}

// MARK: - Stat Item Component
struct StatItem: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color(red: 252/255, green: 108/255, blue: 133/255))
                .frame(width: 32, height: 32)
                .background(Color(red: 252/255, green: 108/255, blue: 133/255).opacity(0.1))
                .cornerRadius(8)

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)

                Text(value)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Voice Player View
struct VoicePlayerView: View {
    let prompt: ProfilePrompt
    @Binding var isPlaying: Bool
    @State private var progress: Double = 0.0

    var body: some View {
        HStack(spacing: 12) {
            // Play/Pause button
            Button(action: {
                togglePlayback()
            }) {
                Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 36))
                    .foregroundColor(Color(red: 252/255, green: 108/255, blue: 133/255))
            }
            .buttonStyle(PlainButtonStyle())

            // Waveform visualization
            HStack(spacing: 2) {
                ForEach(0..<30, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(index < Int(progress * 30) ?
                              Color(red: 252/255, green: 108/255, blue: 133/255) :
                              Color.secondary.opacity(0.3))
                        .frame(width: 3, height: CGFloat.random(in: 8...24))
                        .animation(.easeInOut(duration: 0.3), value: progress)
                }
            }
            .frame(maxWidth: .infinity)

            // Duration
            if let duration = prompt.durationDisplay {
                Text(duration)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)
                    .monospacedDigit()
            }
        }
        .padding(12)
        .background(Color(.systemGray5))
        .cornerRadius(12)
    }

    private func togglePlayback() {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()

        isPlaying.toggle()

        if isPlaying {
            // Simulate playback
            animateProgress()
        }
    }

    private func animateProgress() {
        guard isPlaying, let duration = prompt.voiceDuration else { return }

        withAnimation(.linear(duration: Double(duration))) {
            progress = 1.0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + Double(duration)) {
            isPlaying = false
            progress = 0
        }
    }
}

// MARK: - Scale Button Style
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Voice Intro Recorder Sheet
struct VoiceIntroRecorderSheet: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var recorder = AudioRecorderService()
    @State private var isRecording = false
    @State private var note: String = ""

    let onSave: (Int, String?) -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Record a quick voice intro")
                    .font(.title3).bold()
                    .padding(.top, 8)

                // Simple recorder UI
                VStack(spacing: 12) {
                    Text(timeString(recorder.recordingDuration))
                        .font(.system(size: 28, weight: .semibold))
                        .monospacedDigit()

                    Button(action: toggleRecording) {
                        Circle()
                            .fill(isRecording ? Color.red : Color.pink)
                            .frame(width: 72, height: 72)
                            .overlay(
                                Image(systemName: isRecording ? "stop.fill" : "mic.fill")
                                    .foregroundColor(.white)
                                    .font(.system(size: 28, weight: .bold))
                            )
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(16)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Optional note")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    TextField("Add a short caption...", text: $note)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(Int(recorder.recordingDuration) == 0 || isRecording)
                }
            }
            .onAppear { recorder.checkPermission() }
        }
    }

    private func toggleRecording() {
        if isRecording {
            recorder.stopRecording { _, _ in }
            isRecording = false
        } else {
            recorder.startRecording()
            isRecording = true
        }
    }

    private func save() {
        let duration = Int(max(1, recorder.recordingDuration.rounded()))
        onSave(duration, note.isEmpty ? nil : note)
        dismiss()
    }

    private func timeString(_ t: TimeInterval) -> String {
        let m = Int(t) / 60
        let s = Int(t) % 60
        return String(format: "%d:%02d", m, s)
    }
}

// MARK: - User Profile View (for non-current users)
struct UserProfileView: View {
    @EnvironmentObject var viewModel: AppViewModel
    let user: User
    @State private var showUserActions = false

    var body: some View {
        ProfileContent(
            user: user,
            isCurrentUser: false,
            allowsSocialActions: true
        )
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showUserActions = true
                }) {
                    Image(systemName: "ellipsis.circle")
                        .font(.system(size: 20))
                        .foregroundColor(Color(red: 252/255, green: 108/255, blue: 133/255))
                }
            }
        }
        .sheet(isPresented: $showUserActions) {
            UserActionSheet(user: user)
                .environmentObject(viewModel)
        }
        .onAppear {
            // Track profile view
            viewModel.trackProfileView(userId: user.id)
        }
    }
}

// MARK: - Profile Completion Banner
struct ProfileCompletionBanner: View {
    let completion: Int

    var body: some View {
        NavigationLink(destination: EditProfileView()) {
            HStack(spacing: 12) {
                // Circular progress indicator
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 3)
                        .frame(width: 44, height: 44)

                    Circle()
                        .trim(from: 0, to: CGFloat(completion) / 100)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color(red: 252/255, green: 108/255, blue: 133/255),
                                    Color(red: 255/255, green: 149/255, blue: 0/255)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            style: StrokeStyle(lineWidth: 3, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .frame(width: 44, height: 44)

                    Text("\(completion)%")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.primary)
                }

                // Text content
                VStack(alignment: .leading, spacing: 2) {
                    Text("Complete your profile")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)

                    Text("Get more matches with a complete profile")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            .padding(16)
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ProfileView(user: MockDataService.shared.generateCurrentUser(), isCurrentUser: true)
}

// MARK: - User Action Sheet
/// Reusable action sheet for user actions (block, report, favorite)
struct UserActionSheet: View {
    @EnvironmentObject var viewModel: AppViewModel
    @Environment(\.dismiss) var dismiss
    let user: User

    @State private var showReportReasons = false
    @State private var showBlockConfirmation = false

    var body: some View {
        VStack(spacing: 0) {
            // Handle
            RoundedRectangle(cornerRadius: 3)
                .fill(Color(.systemGray4))
                .frame(width: 40, height: 5)
                .padding(.top, 10)

            // Header
            VStack(spacing: 12) {
                ProfileImageView(user: user, size: 60)

                Text(user.name)
                    .font(.system(size: 18, weight: .semibold))
            }
            .padding(.vertical, 20)

            Divider()

            // Actions
            VStack(spacing: 0) {
                // Favorite
                UserActionButton(
                    icon: viewModel.favoriteUsers.contains(user.id) ? "star.fill" : "star",
                    title: viewModel.favoriteUsers.contains(user.id) ? "Remove from Favorites" : "Add to Favorites",
                    color: .yellow
                ) {
                    viewModel.toggleFavorite(user.id)
                    dismiss()
                }

                Divider()
                    .padding(.leading, 60)

                // Report
                UserActionButton(
                    icon: "exclamationmark.shield",
                    title: "Report",
                    color: .orange
                ) {
                    showReportReasons = true
                }

                Divider()
                    .padding(.leading, 60)

                // Block
                UserActionButton(
                    icon: "hand.raised.fill",
                    title: "Block",
                    color: .red
                ) {
                    showBlockConfirmation = true
                }
            }

            Spacer()
        }
        .presentationDetents([.height(350)])
        .sheet(isPresented: $showReportReasons) {
            ReportReasonsSheet(user: user, onReport: {
                dismiss()
            })
        }
        .alert("Block \(user.name)?", isPresented: $showBlockConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Block", role: .destructive) {
                viewModel.blockUser(user.id)
                dismiss()
            }
        } message: {
            Text("They won't be able to see your profile or message you. You can unblock them later from Settings.")
        }
    }
}

// MARK: - User Action Button
struct UserActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
                    .frame(width: 44, height: 44)
                    .background(color.opacity(0.1))
                    .cornerRadius(22)

                Text(title)
                    .font(.system(size: 16))
                    .foregroundColor(.primary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Report Reasons Sheet
struct ReportReasonsSheet: View {
    @EnvironmentObject var viewModel: AppViewModel
    @Environment(\.dismiss) var dismiss
    let user: User
    let onReport: () -> Void

    @State private var selectedReason: String?

    let reportReasons = [
        ("Inappropriate content", "photo.on.rectangle.angled"),
        ("Harassment or bullying", "exclamationmark.bubble"),
        ("Spam or scam", "envelope.badge"),
        ("Fake profile", "person.crop.circle.badge.xmark"),
        ("Underage user", "18.circle"),
        ("Other", "ellipsis.circle")
    ]

    var body: some View {
        NavigationStack {
            List {
                ForEach(reportReasons, id: \.0) { reason, icon in
                    Button(action: {
                        selectedReason = reason
                        viewModel.reportUser(user.id, reason: reason)
                        dismiss()
                        onReport()
                    }) {
                        HStack(spacing: 16) {
                            Image(systemName: icon)
                                .font(.system(size: 20))
                                .foregroundColor(.red)
                                .frame(width: 32)

                            Text(reason)
                                .font(.system(size: 16))
                                .foregroundColor(.primary)

                            Spacer()
                        }
                        .padding(.vertical, 8)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .navigationTitle("Report \(user.name)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}
