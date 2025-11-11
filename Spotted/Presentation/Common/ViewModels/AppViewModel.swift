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

    // Friend system
    @Published var friends: Set<String> = [] // User IDs of confirmed friends
    @Published var sentFriendRequests: Set<String> = [] // Pending requests sent by current user
    @Published var receivedFriendRequests: Set<String> = [] // Pending requests from others

    // Heatmap data - tracks check-in frequency per location
    @Published var checkInHeatmap: [String: Int] = [:] // locationId: check-in count
    @Published var recentCheckIns: [CheckIn] = [] // Last 50 check-ins for heatmap visualization

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

    // Get heatmap intensity for a location (0.0 to 1.0)
    func getHeatmapIntensity(for locationId: String) -> Double {
        guard !checkInHeatmap.isEmpty else { return 0.0 }

        let maxCheckIns = checkInHeatmap.values.max() ?? 1
        let locationCheckIns = checkInHeatmap[locationId] ?? 0

        return Double(locationCheckIns) / Double(maxCheckIns)
    }

    // Get heat level for UI display
    func getHeatLevel(for locationId: String) -> HeatLevel {
        let intensity = getHeatmapIntensity(for: locationId)

        switch intensity {
        case 0.8...1.0:
            return .veryHot
        case 0.5..<0.8:
            return .hot
        case 0.2..<0.5:
            return .warm
        default:
            return .cool
        }
    }

    // MARK: - Services
    private let mockDataService = MockDataService.shared
    private let persistenceManager = PersistenceManager.shared
    private let analyticsManager = AnalyticsManager.shared
    private var cancellables = Set<AnyCancellable>()

    init() {
        // Try to load persisted data first
        do {
            if let savedUser = try persistenceManager.loadCurrentUser() {
                self.currentUser = savedUser
                print("AppViewModel: Loaded persisted user data")
            } else {
                self.currentUser = mockDataService.generateCurrentUser()
                print("AppViewModel: Using mock user data")
            }

            // Load other persisted data
            self.conversations = try persistenceManager.loadConversations()
            self.matches = try persistenceManager.loadMatches()
            self.likedUsers = try persistenceManager.loadLikedUsers()

            let friendData = try persistenceManager.loadFriendData()
            self.friends = friendData.friends
            self.sentFriendRequests = friendData.sentRequests
            self.receivedFriendRequests = friendData.receivedRequests

            self.blockedUsers = try persistenceManager.loadBlockedUsers()
            self.favoriteUsers = try persistenceManager.loadFavoriteUsers()

            print("AppViewModel: Loaded all persisted data")
        } catch {
            // If loading fails, use mock data
            self.currentUser = mockDataService.generateCurrentUser()
            self.conversations = mockDataService.generateMockConversations(users: mockDataService.generateMockUsers())
            self.matches = mockDataService.generateMockMatches(users: mockDataService.generateMockUsers())
            print("AppViewModel: Error loading persisted data, using mock data: \(error)")
        }

        // Always use mock data for these
        self.allUsers = mockDataService.generateMockUsers()
        self.locations = mockDataService.zurichLocations

        // Set up demo relationships if no persisted data exists
        setupDemoRelationshipsIfNeeded()

        // Set up auto-save on data changes
        setupAutoSave()
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

        // Update current user - use objectWillChange to ensure SwiftUI updates
        objectWillChange.send()
        currentUser.currentCheckIn = checkIn

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
        print("AppViewModel: CheckIn details - ID: \(checkIn.id), Expires at: \(checkIn.expiresAt)")

        // Track analytics
        analyticsManager.track(.checkedIn(location: location.name, userId: currentUser.id))

        // Update heatmap data
        updateHeatmapForCheckIn(checkIn)

        // Show success toast
        Task { @MainActor in
            ToastManager.shared.showSuccess("Checked in at \(location.name)! 📍")
        }

        // Trigger haptic feedback for better UX
        HapticFeedback.success()
    }

    private func updateHeatmapForCheckIn(_ checkIn: CheckIn) {
        // Increment check-in count for this location
        let locationId = checkIn.location.id
        checkInHeatmap[locationId, default: 0] += 1

        // Add to recent check-ins (keep last 50)
        recentCheckIns.insert(checkIn, at: 0)
        if recentCheckIns.count > 50 {
            recentCheckIns.removeLast()
        }

        print("AppViewModel: Heatmap updated - \(checkIn.location.name) now has \(checkInHeatmap[locationId] ?? 0) total check-ins")
    }

    func checkOut() {
        guard let checkIn = currentUser.currentCheckIn else {
            print("AppViewModel: No active check-in to check out from")
            return
        }

        // Decrement location active users
        if let index = locations.firstIndex(where: { $0.id == checkIn.location.id }) {
            locations[index].activeUsers = max(0, locations[index].activeUsers - 1)
            print("AppViewModel: Checked out from \(checkIn.location.name)")
        }

        // Track analytics
        analyticsManager.track(.checkedOut(location: checkIn.location.name, userId: currentUser.id))

        // Update current user - use objectWillChange to ensure SwiftUI updates
        objectWillChange.send()
        currentUser.currentCheckIn = nil

        // Show success toast
        Task { @MainActor in
            ToastManager.shared.showSuccess("Checked out successfully! 👋")
        }

        // Trigger haptic feedback
        HapticFeedback.light()
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

        // Track analytics
        analyticsManager.track(.userLiked(userId: user.id, fromUserId: currentUser.id))

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

        // Track analytics
        analyticsManager.track(.matchCreated(userId: currentUser.id, matchedUserId: user.id))

        // Create conversation
        let conversation = Conversation(
            participants: [currentUser.id, user.id]
        )
        conversations.append(conversation)

        // Track conversation started
        analyticsManager.track(.conversationStarted(userId: currentUser.id, withUserId: user.id))
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

        // Track analytics
        analyticsManager.track(.messageSent(conversationId: conversationId, messageType: "text"))

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

        // Track analytics
        analyticsManager.track(.voiceMessageRecorded(duration: duration))
        analyticsManager.track(.messageSent(conversationId: conversationId, messageType: "voice"))
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

    func verifyCurrentUser() {
        var updatedUser = currentUser
        updatedUser.isVerified = true
        currentUser = updatedUser

        print("AppViewModel: User verified - \(currentUser.name)")

        // Show success toast
        Task { @MainActor in
            ToastManager.shared.showSuccess("Profile verified! ✓")
        }
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

        // Track analytics
        analyticsManager.track(.userBlocked(userId: currentUser.id, blockedUserId: userId))

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

        // Track analytics
        analyticsManager.track(.userReported(userId: currentUser.id, reportedUserId: userId, reason: reason))

        // In production: Send report to backend
        Task { @MainActor in
            ToastManager.shared.showSuccess("Report submitted. Thank you for helping keep Spotted safe.")
        }
    }

    func toggleFavorite(_ userId: String) {
        if favoriteUsers.contains(userId) {
            favoriteUsers.remove(userId)
            analyticsManager.track(.userUnfavorited(userId: currentUser.id, unfavoritedUserId: userId))
            Task { @MainActor in
                ToastManager.shared.showInfo("Removed from favorites")
            }
        } else {
            favoriteUsers.insert(userId)
            analyticsManager.track(.userFavorited(userId: currentUser.id, favoritedUserId: userId))
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

    // MARK: - Friend System Methods
    func sendFriendRequest(to userId: String) {
        guard !friends.contains(userId),
              !sentFriendRequests.contains(userId),
              !blockedUsers.contains(userId) else {
            return
        }

        sentFriendRequests.insert(userId)

        // Track analytics
        analyticsManager.track(.friendRequestSent(fromUserId: currentUser.id, toUserId: userId))

        Task { @MainActor in
            ToastManager.shared.showSuccess("Friend request sent!")
        }
    }

    func acceptFriendRequest(from userId: String) {
        guard receivedFriendRequests.contains(userId) else { return }

        receivedFriendRequests.remove(userId)
        friends.insert(userId)

        // Track analytics
        analyticsManager.track(.friendRequestAccepted(fromUserId: userId, toUserId: currentUser.id))

        Task { @MainActor in
            ToastManager.shared.showSuccess("Friend request accepted!")
        }
    }

    func rejectFriendRequest(from userId: String) {
        receivedFriendRequests.remove(userId)

        // Track analytics
        analyticsManager.track(.friendRequestDeclined(fromUserId: userId, toUserId: currentUser.id))

        Task { @MainActor in
            ToastManager.shared.showInfo("Friend request declined")
        }
    }

    func removeFriend(_ userId: String) {
        friends.remove(userId)

        Task { @MainActor in
            ToastManager.shared.showInfo("Friend removed")
        }
    }

    func cancelFriendRequest(to userId: String) {
        sentFriendRequests.remove(userId)
    }

    func isFriend(_ userId: String) -> Bool {
        return friends.contains(userId)
    }

    func hasSentFriendRequest(to userId: String) -> Bool {
        return sentFriendRequests.contains(userId)
    }

    func hasReceivedFriendRequest(from userId: String) -> Bool {
        return receivedFriendRequests.contains(userId)
    }

    func getFriendsList() -> [User] {
        return allUsers.filter { friends.contains($0.id) }
    }

    func getMutualFriends(with userId: String) -> [User] {
        // In a real app, we'd get the other user's friends from the server
        // For now, simulate some mutual friends
        let otherUserFriends = Set(allUsers.prefix(10).map { $0.id })
        let mutualFriendIds = friends.intersection(otherUserFriends)
        return allUsers.filter { mutualFriendIds.contains($0.id) }
    }

    func getFriendRequestsList() -> [User] {
        return allUsers.filter { receivedFriendRequests.contains($0.id) }
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

    // MARK: - Persistence Methods

    private func setupDemoRelationshipsIfNeeded() {
        // Only set up demo data if we don't have any existing relationships
        guard friends.isEmpty && sentFriendRequests.isEmpty &&
              receivedFriendRequests.isEmpty && matches.isEmpty else {
            print("AppViewModel: Existing relationships found, skipping demo setup")
            return
        }

        print("AppViewModel: Setting up demo relationships")

        // Add some friends (first 3 users)
        if allUsers.count >= 5 {
            friends.insert(allUsers[0].id)
            friends.insert(allUsers[1].id)
            friends.insert(allUsers[2].id)

            // Add received friend requests (next 2 users)
            receivedFriendRequests.insert(allUsers[3].id)
            receivedFriendRequests.insert(allUsers[4].id)

            // Add some sent requests if we have more users
            if allUsers.count >= 7 {
                sentFriendRequests.insert(allUsers[5].id)
                sentFriendRequests.insert(allUsers[6].id)
            }

            // Add some matches with existing conversations
            if conversations.isEmpty && allUsers.count >= 2 {
                conversations = mockDataService.generateMockConversations(users: allUsers)
            }
            if matches.isEmpty && allUsers.count >= 3 {
                matches = mockDataService.generateMockMatches(users: allUsers)
            }

            // Like a few users
            if allUsers.count >= 10 {
                likedUsers.insert(allUsers[7].id)
                likedUsers.insert(allUsers[8].id)
            }

            print("AppViewModel: Demo relationships set up - \(friends.count) friends, \(receivedFriendRequests.count) requests, \(matches.count) matches")
        }

        // Set up demo heatmap data if empty
        if checkInHeatmap.isEmpty {
            setupDemoHeatmap()
        }
    }

    private func setupDemoHeatmap() {
        print("AppViewModel: Setting up demo heatmap data")

        // Simulate historical check-ins at various locations
        let popularLocations = locations.prefix(5)
        for (index, location) in popularLocations.enumerated() {
            // More popular locations get more check-ins
            let checkInCount = (5 - index) * Int.random(in: 3...8)
            checkInHeatmap[location.id] = checkInCount

            print("AppViewModel: Heatmap - \(location.name) has \(checkInCount) historical check-ins")
        }

        // Add some recent check-ins
        for user in allUsers.prefix(10) {
            if let checkIn = user.currentCheckIn {
                recentCheckIns.append(checkIn)
            }
        }

        print("AppViewModel: Heatmap initialized with \(checkInHeatmap.count) locations and \(recentCheckIns.count) recent check-ins")
    }

    private func setupAutoSave() {
        // Save current user when it changes
        $currentUser
            .debounce(for: .seconds(1), scheduler: DispatchQueue.main)
            .sink { [weak self] user in
                self?.saveCurrentUser(user)
            }
            .store(in: &cancellables)

        // Save conversations when they change
        $conversations
            .debounce(for: .seconds(1), scheduler: DispatchQueue.main)
            .sink { [weak self] conversations in
                self?.saveConversations(conversations)
            }
            .store(in: &cancellables)

        // Save matches when they change
        $matches
            .debounce(for: .seconds(1), scheduler: DispatchQueue.main)
            .sink { [weak self] matches in
                self?.saveMatches(matches)
            }
            .store(in: &cancellables)

        // Save liked users when they change
        $likedUsers
            .debounce(for: .seconds(1), scheduler: DispatchQueue.main)
            .sink { [weak self] likedUsers in
                self?.saveLikedUsers(likedUsers)
            }
            .store(in: &cancellables)

        // Save friend data when it changes
        Publishers.CombineLatest3($friends, $sentFriendRequests, $receivedFriendRequests)
            .debounce(for: .seconds(1), scheduler: DispatchQueue.main)
            .sink { [weak self] friends, sentRequests, receivedRequests in
                self?.saveFriendData(friends: friends, sentRequests: sentRequests, receivedRequests: receivedRequests)
            }
            .store(in: &cancellables)

        // Save blocked users when they change
        $blockedUsers
            .debounce(for: .seconds(1), scheduler: DispatchQueue.main)
            .sink { [weak self] blockedUsers in
                self?.saveBlockedUsers(blockedUsers)
            }
            .store(in: &cancellables)

        // Save favorite users when they change
        $favoriteUsers
            .debounce(for: .seconds(1), scheduler: DispatchQueue.main)
            .sink { [weak self] favoriteUsers in
                self?.saveFavoriteUsers(favoriteUsers)
            }
            .store(in: &cancellables)

        print("AppViewModel: Auto-save configured")
    }

    private func saveCurrentUser(_ user: User) {
        Task {
            do {
                try persistenceManager.saveCurrentUser(user)
            } catch {
                print("AppViewModel: Error saving current user: \(error)")
            }
        }
    }

    private func saveConversations(_ conversations: [Conversation]) {
        Task {
            do {
                try persistenceManager.saveConversations(conversations)
            } catch {
                print("AppViewModel: Error saving conversations: \(error)")
            }
        }
    }

    private func saveMatches(_ matches: [Match]) {
        Task {
            do {
                try persistenceManager.saveMatches(matches)
            } catch {
                print("AppViewModel: Error saving matches: \(error)")
            }
        }
    }

    private func saveLikedUsers(_ likedUsers: Set<String>) {
        Task {
            do {
                try persistenceManager.saveLikedUsers(likedUsers)
            } catch {
                print("AppViewModel: Error saving liked users: \(error)")
            }
        }
    }

    private func saveFriendData(friends: Set<String>, sentRequests: Set<String>, receivedRequests: Set<String>) {
        Task {
            do {
                try persistenceManager.saveFriendData(friends: friends, sentRequests: sentRequests, receivedRequests: receivedRequests)
            } catch {
                print("AppViewModel: Error saving friend data: \(error)")
            }
        }
    }

    private func saveBlockedUsers(_ blockedUsers: Set<String>) {
        Task {
            do {
                try persistenceManager.saveBlockedUsers(blockedUsers)
            } catch {
                print("AppViewModel: Error saving blocked users: \(error)")
            }
        }
    }

    private func saveFavoriteUsers(_ favoriteUsers: Set<String>) {
        Task {
            do {
                try persistenceManager.saveFavoriteUsers(favoriteUsers)
            } catch {
                print("AppViewModel: Error saving favorite users: \(error)")
            }
        }
    }

    func clearAllPersistedData() {
        Task {
            do {
                try persistenceManager.clearAllData()
                print("AppViewModel: Cleared all persisted data")
            } catch {
                print("AppViewModel: Error clearing data: \(error)")
            }
        }
    }
}
