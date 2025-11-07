import Foundation
import Combine

// MARK: - Modern ViewModel with Dependency Injection & Async/Await

@MainActor
class AppViewModelModern: ObservableObject {
    // MARK: - Published Properties
    @Published var currentUser: User
    @Published var allUsers: [User] = []
    @Published var locations: [Location] = []
    @Published var conversations: [Conversation] = []
    @Published var matches: [Match] = []
    @Published var likedUsers: Set<String> = []

    // MARK: - Loading States
    @Published var isLoadingUsers = false
    @Published var isLoadingLocations = false
    @Published var isCheckingIn = false

    // MARK: - Error Handling
    @Published var errorMessage: String?

    // MARK: - Dependencies (Injected)
    private let repository: DataRepositoryProtocol

    // MARK: - Initialization with Dependency Injection
    init(repository: DataRepositoryProtocol, currentUser: User? = nil) {
        self.repository = repository
        self.currentUser = currentUser ?? MockDataService.shared.generateCurrentUser()

        // Load initial data
        Task {
            await loadInitialData()
        }
    }

    // MARK: - Data Loading with Async/Await
    func loadInitialData() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.loadUsers() }
            group.addTask { await self.loadLocations() }
            group.addTask { await self.loadConversations() }
            group.addTask { await self.loadMatches() }
        }
    }

    private func loadUsers() async {
        isLoadingUsers = true
        defer { isLoadingUsers = false }

        do {
            allUsers = try await repository.fetchUsers()
        } catch {
            handleError(error)
        }
    }

    private func loadLocations() async {
        isLoadingLocations = true
        defer { isLoadingLocations = false }

        do {
            locations = try await repository.fetchLocations()
        } catch {
            handleError(error)
        }
    }

    private func loadConversations() async {
        do {
            conversations = try await repository.fetchConversations(for: currentUser.id)
        } catch {
            handleError(error)
        }
    }

    private func loadMatches() async {
        do {
            matches = try await repository.fetchMatches(for: currentUser.id)
        } catch {
            handleError(error)
        }
    }

    // MARK: - Check-in Methods with Async/Await
    func checkIn(at location: Location, caption: String? = nil) async {
        isCheckingIn = true
        defer { isCheckingIn = false }

        do {
            let checkIn = try await repository.createCheckIn(
                userId: currentUser.id,
                location: location,
                caption: caption
            )

            currentUser.currentCheckIn = checkIn

            // Update location active users
            if let index = locations.firstIndex(where: { $0.id == location.id }) {
                locations[index].activeUsers += 1
            }
        } catch {
            handleError(error)
        }
    }

    func checkOut() async {
        guard let checkIn = currentUser.currentCheckIn else { return }

        do {
            try await repository.deleteCheckIn(checkInId: checkIn.id)

            // Update location active users
            if let index = locations.firstIndex(where: { $0.id == checkIn.location.id }) {
                locations[index].activeUsers = max(0, locations[index].activeUsers - 1)
            }

            currentUser.currentCheckIn = nil
        } catch {
            handleError(error)
        }
    }

    // MARK: - Discovery Methods
    func getUsersAt(location: Location) -> [User] {
        allUsers.filter { user in
            user.currentCheckIn?.location.id == location.id &&
            user.currentCheckIn?.isActive == true
        }
    }

    func getUsersWithFavorite(location: Location) -> [User] {
        allUsers.filter { user in
            user.favoriteHangouts.contains(where: { $0.id == location.id })
        }
    }

    // MARK: - Like/Match Methods with Async/Await
    func likeUser(_ user: User) async {
        likedUsers.insert(user.id)

        do {
            if let match = try await repository.likeUser(
                currentUserId: currentUser.id,
                targetUserId: user.id
            ) {
                // Mutual like! Create match
                matches.append(match)

                // Create conversation
                let conversation = Conversation(
                    participants: [currentUser.id, user.id]
                )
                conversations.append(conversation)
            }
        } catch {
            handleError(error)
        }
    }

    func isLiked(_ userId: String) -> Bool {
        likedUsers.contains(userId)
    }

    func hasMatch(with userId: String) -> Bool {
        matches.contains { match in
            match.users.contains(currentUser.id) && match.users.contains(userId)
        }
    }

    // MARK: - Messaging Methods with Async/Await
    func sendMessage(to conversationId: String, text: String) async {
        guard let index = conversations.firstIndex(where: { $0.id == conversationId }) else { return }

        do {
            let message = try await repository.sendMessage(
                conversationId: conversationId,
                senderId: currentUser.id,
                text: text
            )
            conversations[index].messages.append(message)
        } catch {
            handleError(error)
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

    // MARK: - Story Methods with Async/Await
    func postStory(at location: Location, imageUrl: String, caption: String?) async {
        do {
            let story = try await repository.createStory(
                userId: currentUser.id,
                location: location,
                imageUrl: imageUrl,
                caption: caption
            )
            currentUser.stories.append(story)
        } catch {
            handleError(error)
        }
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
        Array(locations.sorted { $0.activeUsers > $1.activeUsers }.prefix(5))
    }

    // MARK: - Error Handling
    private func handleError(_ error: Error) {
        errorMessage = error.localizedDescription
        print("❌ Error: \(error.localizedDescription)")
    }

    func clearError() {
        errorMessage = nil
    }
}
