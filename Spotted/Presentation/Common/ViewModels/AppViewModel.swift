import Foundation
import Combine

@MainActor
class AppViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var currentUser: User
    @Published var allUsers: [User]
    @Published var locations: [Location]
    @Published var conversations: [Conversation]
    @Published var matches: [Match]
    @Published var selectedLocation: Location?
    @Published var likedUsers: Set<String> = []
    @Published var lastLikedUserId: String?
    @Published var celebratingMatchWithUserId: String?
    @Published var blockedUsers: Set<String> = []
    @Published var reportedUsers: Set<String> = []
    @Published var favoriteUsers: Set<String> = []
    @Published var profileViews: [String: [String]] = [:] // userId: [viewerUserIds]

    // MARK: - Computed Properties
    var unreadMessagesCount: Int {
        conversations.reduce(0) { count, conversation in
            let unreadCount = conversation.messages.filter { message in
                message.senderId != currentUser.id && !message.isRead
            }.count
            return count + unreadCount
        }
    }

    var newMatchesCount: Int {
        // Count matches from last 24 hours
        let dayAgo = Date().addingTimeInterval(-24 * 60 * 60)
        return matches.filter { $0.timestamp > dayAgo }.count
    }

    // MARK: - Services
    private let mockDataService = MockDataService.shared

    init() {
        // Initialize with mock data
        self.currentUser = mockDataService.generateCurrentUser()
        self.allUsers = mockDataService.generateMockUsers()
        self.locations = mockDataService.zurichLocations
        self.conversations = mockDataService.generateMockConversations(users: mockDataService.generateMockUsers())
        self.matches = mockDataService.generateMockMatches(users: mockDataService.generateMockUsers())
    }

    // MARK: - Check-in Methods
    func checkIn(at location: Location, caption: String? = nil, imageUrl: String? = nil) {
        // First, check out from any previous location
        if let previousCheckIn = currentUser.currentCheckIn {
            // Decrement previous location's active users
            if let index = locations.firstIndex(where: { $0.id == previousCheckIn.location.id }) {
                locations[index].activeUsers = max(0, locations[index].activeUsers - 1)
                print("AppViewModel: Checked out from \(previousCheckIn.location.name)")
            }
        }

        // Create new check-in
        let checkIn = CheckIn(
            userId: currentUser.id,
            location: location,
            caption: caption,
            imageUrl: imageUrl
        )

        // Update current user
        var updatedUser = currentUser
        updatedUser.currentCheckIn = checkIn
        currentUser = updatedUser

        // Add location to array if it doesn't exist (for custom locations)
        if !locations.contains(where: { $0.id == location.id }) {
            var newLocation = location
            newLocation.activeUsers = 1
            locations.append(newLocation)
            print("AppViewModel: Added new location to map: \(location.name)")
        } else {
            // Update existing location's active users count
            if let index = locations.firstIndex(where: { $0.id == location.id }) {
                locations[index].activeUsers += 1
            }
        }

        print("AppViewModel: Check-in completed for \(currentUser.name) at \(location.name)")
        print("AppViewModel: Location now has \(locations.first(where: { $0.id == location.id })?.activeUsers ?? 0) active users")

        // Show success toast
        Task { @MainActor in
            ToastManager.shared.showSuccess("Checked in at \(location.name)! 📍")
        }
    }

    func checkOut() {
        if let checkIn = currentUser.currentCheckIn,
           let index = locations.firstIndex(where: { $0.id == checkIn.location.id }) {
            locations[index].activeUsers = max(0, locations[index].activeUsers - 1)
            print("AppViewModel: Checked out from \(checkIn.location.name)")
        }

        currentUser.currentCheckIn = nil
    }

    // MARK: - Discovery Methods
    func getUsersAt(location: Location) -> [User] {
        // Include current user if they're checked in at this location
        var usersAtLocation = allUsers.filter { user in
            user.currentCheckIn?.location.id == location.id &&
            user.currentCheckIn?.isActive == true
        }

        // Add current user if checked in here
        if currentUser.currentCheckIn?.location.id == location.id &&
           currentUser.currentCheckIn?.isActive == true {
            usersAtLocation.insert(currentUser, at: 0) // Put current user first
        }

        return usersAtLocation
    }

    func getUsersWithFavorite(location: Location) -> [User] {
        allUsers.filter { user in
            user.favoriteHangouts.contains(where: { $0.id == location.id })
        }
    }

    // MARK: - Like/Match Methods
    func likeUser(_ user: User) {
        likedUsers.insert(user.id)
        lastLikedUserId = user.id

        // Simulate mutual like (30% chance for demo)
        if Double.random(in: 0...1) < 0.3 {
            createMatch(with: user)
            // Show match celebration instead of toast
            celebratingMatchWithUserId = user.id
        }
    }

    func undoLastLike() {
        guard let userId = lastLikedUserId else { return }

        // Remove from liked users
        likedUsers.remove(userId)

        // Remove any match that was created
        if let matchIndex = matches.firstIndex(where: {
            $0.users.contains(currentUser.id) && $0.users.contains(userId)
        }) {
            matches.remove(at: matchIndex)

            // Remove the conversation too
            if let conversationIndex = conversations.firstIndex(where: {
                $0.participants.contains(currentUser.id) && $0.participants.contains(userId)
            }) {
                conversations.remove(at: conversationIndex)
            }

            // Show appropriate toast
            if let user = getUser(by: userId) {
                Task { @MainActor in
                    ToastManager.shared.showInfo("Undid like with \(user.name)")
                }
            }
        } else {
            // Just undid a like, no match was created
            if let user = getUser(by: userId) {
                Task { @MainActor in
                    ToastManager.shared.showInfo("Undid like with \(user.name)")
                }
            }
        }

        // Clear last liked user
        lastLikedUserId = nil
    }

    func createMatch(with user: User) {
        let match = Match(
            users: [currentUser.id, user.id],
            location: currentUser.currentCheckIn?.location
        )
        matches.append(match)

        // Create conversation
        let conversation = Conversation(
            participants: [currentUser.id, user.id]
        )
        conversations.append(conversation)
    }

    func isLiked(_ userId: String) -> Bool {
        likedUsers.contains(userId)
    }

    func hasMatch(with userId: String) -> Bool {
        matches.contains { match in
            match.users.contains(currentUser.id) && match.users.contains(userId)
        }
    }

    // MARK: - Messaging Methods
    func sendMessage(to conversationId: String, text: String) {
        guard let index = conversations.firstIndex(where: { $0.id == conversationId }) else { return }

        // Create message with "sending" status
        let message = Message(senderId: currentUser.id, text: text, status: .sending)
        conversations[index].messages.append(message)

        // Simulate sending with delay
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds

            await MainActor.run {
                // Update to "sent"
                if let msgIndex = conversations[index].messages.firstIndex(where: { $0.id == message.id }) {
                    conversations[index].messages[msgIndex].status = .sent

                    // Simulate delivery after 1 more second
                    Task {
                        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                        await MainActor.run {
                            if let deliverIndex = conversations[index].messages.firstIndex(where: { $0.id == message.id }) {
                                conversations[index].messages[deliverIndex].status = .delivered
                            }
                        }
                    }
                }
            }
        }
    }

    func sendVoiceMemo(to conversationId: String, audioUrl: String, duration: TimeInterval) {
        guard let index = conversations.firstIndex(where: { $0.id == conversationId }) else { return }

        let message = Message(
            senderId: currentUser.id,
            text: "Voice message",
            type: .voiceMemo,
            voiceMemoUrl: audioUrl,
            voiceMemoDuration: duration
        )
        conversations[index].messages.append(message)
    }

    func sendGift(to conversationId: String, giftEmoji: String) {
        guard let index = conversations.firstIndex(where: { $0.id == conversationId }) else { return }

        let message = Message(
            senderId: currentUser.id,
            text: "Sent a gift",
            status: .sent,
            type: .gift,
            giftEmoji: giftEmoji
        )
        conversations[index].messages.append(message)
    }

    func sendGif(to conversationId: String, gifUrl: String, caption: String? = nil) {
        guard let index = conversations.firstIndex(where: { $0.id == conversationId }) else { return }

        let message = Message(
            senderId: currentUser.id,
            text: caption ?? "GIF",
            status: .sent,
            type: .gif,
            gifUrl: gifUrl
        )
        conversations[index].messages.append(message)
    }

    func markMessagesAsRead(in conversationId: String) {
        guard let index = conversations.firstIndex(where: { $0.id == conversationId }) else { return }

        // Mark all unread messages from other user as read
        for (msgIndex, message) in conversations[index].messages.enumerated() {
            if message.senderId != currentUser.id && !message.isRead {
                conversations[index].messages[msgIndex].isRead = true
                conversations[index].messages[msgIndex].status = .read
            }
        }
    }

    func getConversation(with userId: String) -> Conversation? {
        conversations.first { conversation in
            conversation.participants.contains(currentUser.id) &&
            conversation.participants.contains(userId)
        }
    }

    func getUser(by id: String) -> User? {
        if id == currentUser.id {
            return currentUser
        }
        return allUsers.first { $0.id == id }
    }

    // MARK: - Profile Update Methods
    func updateCurrentUser(
        name: String,
        bio: String,
        age: Int,
        height: String?,
        job: String?,
        hometown: String?,
        sexuality: String?,
        lookingFor: String?,
        drinking: String?,
        smoking: String?,
        kids: String?,
        interests: [String]
    ) {
        var updatedUser = currentUser
        updatedUser.name = name
        updatedUser.bio = bio
        updatedUser.age = age
        updatedUser.height = height
        updatedUser.job = job
        updatedUser.hometown = hometown
        updatedUser.sexuality = sexuality
        updatedUser.lookingFor = lookingFor
        updatedUser.drinking = drinking
        updatedUser.smoking = smoking
        updatedUser.kids = kids
        updatedUser.interests = interests
        currentUser = updatedUser

        print("AppViewModel: Profile updated for \(currentUser.name)")

        // Show success toast
        Task { @MainActor in
            ToastManager.shared.showSuccess("Profile updated successfully!")
        }
    }

    func updateUserPhotos(_ photos: [String]) {
        var updatedUser = currentUser
        updatedUser.photos = photos
        currentUser = updatedUser

        print("AppViewModel: Photos updated - \(photos.count) photos")
    }

    func logout() {
        // Reset to default/demo user
        // In production, this would clear auth tokens and navigate to login screen
        print("AppViewModel: User logged out")

        // Clear user session (for now, just reset to initial state)
        // In production: clear UserDefaults, Keychain tokens, etc.

        // Show toast
        Task { @MainActor in
            ToastManager.shared.showInfo("Logged out successfully")
        }

        // Note: This is a simplified logout - in production you would:
        // 1. Clear auth tokens from Keychain
        // 2. Clear UserDefaults
        // 3. Navigate to login/welcome screen
        // 4. Clear any cached data
    }

    // MARK: - Block/Report/Favorite Methods
    func blockUser(_ userId: String) {
        blockedUsers.insert(userId)

        // Remove from matches
        matches.removeAll { match in
            match.users.contains(userId)
        }

        // Remove conversations
        conversations.removeAll { conversation in
            conversation.participants.contains(userId)
        }

        // Remove from liked
        likedUsers.remove(userId)

        print("AppViewModel: Blocked user \(userId)")

        Task { @MainActor in
            ToastManager.shared.showSuccess("User blocked successfully")
        }
    }

    func unblockUser(_ userId: String) {
        blockedUsers.remove(userId)

        print("AppViewModel: Unblocked user \(userId)")

        Task { @MainActor in
            ToastManager.shared.showSuccess("User unblocked")
        }
    }

    func reportUser(_ userId: String, reason: String) {
        reportedUsers.insert(userId)

        print("AppViewModel: Reported user \(userId) for: \(reason)")

        // In production: Send report to backend
        Task { @MainActor in
            ToastManager.shared.showSuccess("Report submitted. Thank you for helping keep Spotted safe.")
        }
    }

    func toggleFavorite(_ userId: String) {
        if favoriteUsers.contains(userId) {
            favoriteUsers.remove(userId)
            Task { @MainActor in
                ToastManager.shared.showInfo("Removed from favorites")
            }
        } else {
            favoriteUsers.insert(userId)
            Task { @MainActor in
                ToastManager.shared.showSuccess("Added to favorites ⭐")
            }
        }
    }

    func trackProfileView(userId: String) {
        // Track that current user viewed this profile
        if profileViews[userId] == nil {
            profileViews[userId] = []
        }

        if !profileViews[userId]!.contains(currentUser.id) {
            profileViews[userId]?.append(currentUser.id)
            print("AppViewModel: Tracked profile view for user \(userId)")
        }
    }

    func getProfileViewCount(for userId: String) -> Int {
        return profileViews[userId]?.count ?? 0
    }

    func getBlockedUsersList() -> [User] {
        return allUsers.filter { blockedUsers.contains($0.id) }
    }

    func getFavoriteUsersList() -> [User] {
        return allUsers.filter { favoriteUsers.contains($0.id) }
    }

    // MARK: - Story Methods
    func postStory(at location: Location, imageUrl: String, caption: String?) {
        let story = Story(
            userId: currentUser.id,
            location: location,
            imageUrl: imageUrl,
            caption: caption
        )
        currentUser.stories.append(story)
    }

    func getActiveStories(for location: Location) -> [Story] {
        var stories: [Story] = []

        // Current user stories
        stories.append(contentsOf: currentUser.stories.filter {
            $0.location.id == location.id && $0.isActive
        })

        // Other users' stories
        for user in allUsers {
            stories.append(contentsOf: user.stories.filter {
                $0.location.id == location.id && $0.isActive
            })
        }

        return stories.sorted { $0.timestamp > $1.timestamp }
    }

    // MARK: - Hotspot Recommendations
    func getHotspotRecommendations() -> [Location] {
        locations.sorted { $0.activeUsers > $1.activeUsers }.prefix(5).map { $0 }
    }
}
