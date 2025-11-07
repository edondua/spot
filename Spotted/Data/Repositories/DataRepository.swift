import Foundation

// MARK: - Repository Protocol (Dependency Inversion)
protocol DataRepositoryProtocol {
    func fetchUsers() async throws -> [User]
    func fetchLocations() async throws -> [Location]
    func fetchConversations(for userId: String) async throws -> [Conversation]
    func fetchMatches(for userId: String) async throws -> [Match]
    func createCheckIn(userId: String, location: Location, caption: String?) async throws -> CheckIn
    func deleteCheckIn(checkInId: String) async throws
    func likeUser(currentUserId: String, targetUserId: String) async throws -> Match?
    func sendMessage(conversationId: String, senderId: String, text: String) async throws -> Message
    func createStory(userId: String, location: Location, imageUrl: String, caption: String?) async throws -> Story
}

// MARK: - Mock Repository (for prototype)
class MockDataRepository: DataRepositoryProtocol {
    private let mockDataService = MockDataService.shared

    func fetchUsers() async throws -> [User] {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        return mockDataService.generateMockUsers()
    }

    func fetchLocations() async throws -> [Location] {
        try await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
        return mockDataService.zurichLocations
    }

    func fetchConversations(for userId: String) async throws -> [Conversation] {
        try await Task.sleep(nanoseconds: 400_000_000)
        return mockDataService.generateMockConversations(users: mockDataService.generateMockUsers())
    }

    func fetchMatches(for userId: String) async throws -> [Match] {
        try await Task.sleep(nanoseconds: 400_000_000)
        return mockDataService.generateMockMatches(users: mockDataService.generateMockUsers())
    }

    func createCheckIn(userId: String, location: Location, caption: String?) async throws -> CheckIn {
        try await Task.sleep(nanoseconds: 200_000_000)
        return CheckIn(userId: userId, location: location, caption: caption)
    }

    func deleteCheckIn(checkInId: String) async throws {
        try await Task.sleep(nanoseconds: 200_000_000)
        // In real app: API call to delete check-in
    }

    func likeUser(currentUserId: String, targetUserId: String) async throws -> Match? {
        try await Task.sleep(nanoseconds: 300_000_000)

        // 30% chance of mutual like (demo)
        if Double.random(in: 0...1) < 0.3 {
            return Match(users: [currentUserId, targetUserId])
        }
        return nil
    }

    func sendMessage(conversationId: String, senderId: String, text: String) async throws -> Message {
        try await Task.sleep(nanoseconds: 200_000_000)
        return Message(senderId: senderId, text: text)
    }

    func createStory(userId: String, location: Location, imageUrl: String, caption: String?) async throws -> Story {
        try await Task.sleep(nanoseconds: 300_000_000)
        return Story(userId: userId, location: location, imageUrl: imageUrl, caption: caption)
    }
}

// MARK: - Future: Real API Repository
// Uncomment when backend is ready
/*
class APIDataRepository: DataRepositoryProtocol {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func fetchUsers() async throws -> [User] {
        try await apiClient.get("/users")
    }

    func fetchLocations() async throws -> [Location] {
        try await apiClient.get("/locations")
    }

    // ... implement all protocol methods with real API calls
}
*/
