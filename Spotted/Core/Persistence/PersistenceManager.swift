import Foundation

/// Manages data persistence using FileManager and Codable
@MainActor
class PersistenceManager {
    static let shared = PersistenceManager()
    
    private let fileManager = FileManager.default
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    private init() {
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
    }
    
    // MARK: - File Paths
    
    private var documentsDirectory: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    private var currentUserURL: URL {
        documentsDirectory.appendingPathComponent("currentUser.json")
    }
    
    private var conversationsURL: URL {
        documentsDirectory.appendingPathComponent("conversations.json")
    }
    
    private var matchesURL: URL {
        documentsDirectory.appendingPathComponent("matches.json")
    }
    
    private var likedUsersURL: URL {
        documentsDirectory.appendingPathComponent("likedUsers.json")
    }
    
    private var friendsURL: URL {
        documentsDirectory.appendingPathComponent("friends.json")
    }
    
    private var blockedUsersURL: URL {
        documentsDirectory.appendingPathComponent("blockedUsers.json")
    }
    
    private var favoriteUsersURL: URL {
        documentsDirectory.appendingPathComponent("favoriteUsers.json")
    }
    
    private var storiesURL: URL {
        documentsDirectory.appendingPathComponent("stories.json")
    }

    private var heatmapURL: URL {
        documentsDirectory.appendingPathComponent("heatmap.json")
    }

    private var recentCheckInsURL: URL {
        documentsDirectory.appendingPathComponent("recentCheckIns.json")
    }

    private var relationshipStatusesURL: URL {
        documentsDirectory.appendingPathComponent("relationshipStatuses.json")
    }

    // MARK: - Save Methods
    
    func saveCurrentUser(_ user: User) throws {
        let data = try encoder.encode(user)
        try data.write(to: currentUserURL)
        print("PersistenceManager: Saved current user")
    }
    
    func saveConversations(_ conversations: [Conversation]) throws {
        let data = try encoder.encode(conversations)
        try data.write(to: conversationsURL)
        print("PersistenceManager: Saved \(conversations.count) conversations")
    }
    
    func saveMatches(_ matches: [Match]) throws {
        let data = try encoder.encode(matches)
        try data.write(to: matchesURL)
        print("PersistenceManager: Saved \(matches.count) matches")
    }
    
    func saveLikedUsers(_ likedUsers: Set<String>) throws {
        let array = Array(likedUsers)
        let data = try encoder.encode(array)
        try data.write(to: likedUsersURL)
        print("PersistenceManager: Saved \(likedUsers.count) liked users")
    }
    
    func saveFriendData(friends: Set<String>, sentRequests: Set<String>, receivedRequests: Set<String>) throws {
        let friendData = FriendData(
            friends: Array(friends),
            sentRequests: Array(sentRequests),
            receivedRequests: Array(receivedRequests)
        )
        let data = try encoder.encode(friendData)
        try data.write(to: friendsURL)
        print("PersistenceManager: Saved friend data")
    }
    
    func saveBlockedUsers(_ blockedUsers: Set<String>) throws {
        let array = Array(blockedUsers)
        let data = try encoder.encode(array)
        try data.write(to: blockedUsersURL)
        print("PersistenceManager: Saved \(blockedUsers.count) blocked users")
    }
    
    func saveFavoriteUsers(_ favoriteUsers: Set<String>) throws {
        let array = Array(favoriteUsers)
        let data = try encoder.encode(array)
        try data.write(to: favoriteUsersURL)
        print("PersistenceManager: Saved \(favoriteUsers.count) favorite users")
    }
    
    func saveStories(_ stories: [Story]) throws {
        let data = try encoder.encode(stories)
        try data.write(to: storiesURL)
        print("PersistenceManager: Saved \(stories.count) stories")
    }

    func saveHeatmap(_ heatmap: [String: Int]) throws {
        let data = try encoder.encode(heatmap)
        try data.write(to: heatmapURL)
        print("PersistenceManager: Saved heatmap with \(heatmap.count) locations")
    }

    func saveRecentCheckIns(_ checkIns: [CheckIn]) throws {
        let data = try encoder.encode(checkIns)
        try data.write(to: recentCheckInsURL)
        print("PersistenceManager: Saved \(checkIns.count) recent check-ins")
    }

    func saveRelationshipStatuses(_ statuses: [String: RelationshipStatus]) throws {
        let data = try encoder.encode(statuses)
        try data.write(to: relationshipStatusesURL)
        print("PersistenceManager: Saved \(statuses.count) relationship statuses")
    }

    // MARK: - Load Methods
    
    func loadCurrentUser() throws -> User? {
        guard fileManager.fileExists(atPath: currentUserURL.path) else {
            print("PersistenceManager: No saved current user found")
            return nil
        }
        
        let data = try Data(contentsOf: currentUserURL)
        let user = try decoder.decode(User.self, from: data)
        print("PersistenceManager: Loaded current user")
        return user
    }
    
    func loadConversations() throws -> [Conversation] {
        guard fileManager.fileExists(atPath: conversationsURL.path) else {
            print("PersistenceManager: No saved conversations found")
            return []
        }
        
        let data = try Data(contentsOf: conversationsURL)
        let conversations = try decoder.decode([Conversation].self, from: data)
        print("PersistenceManager: Loaded \(conversations.count) conversations")
        return conversations
    }
    
    func loadMatches() throws -> [Match] {
        guard fileManager.fileExists(atPath: matchesURL.path) else {
            print("PersistenceManager: No saved matches found")
            return []
        }
        
        let data = try Data(contentsOf: matchesURL)
        let matches = try decoder.decode([Match].self, from: data)
        print("PersistenceManager: Loaded \(matches.count) matches")
        return matches
    }
    
    func loadLikedUsers() throws -> Set<String> {
        guard fileManager.fileExists(atPath: likedUsersURL.path) else {
            print("PersistenceManager: No saved liked users found")
            return []
        }
        
        let data = try Data(contentsOf: likedUsersURL)
        let array = try decoder.decode([String].self, from: data)
        print("PersistenceManager: Loaded \(array.count) liked users")
        return Set(array)
    }
    
    func loadFriendData() throws -> (friends: Set<String>, sentRequests: Set<String>, receivedRequests: Set<String>) {
        guard fileManager.fileExists(atPath: friendsURL.path) else {
            print("PersistenceManager: No saved friend data found")
            return ([], [], [])
        }
        
        let data = try Data(contentsOf: friendsURL)
        let friendData = try decoder.decode(FriendData.self, from: data)
        print("PersistenceManager: Loaded friend data")
        return (
            Set(friendData.friends),
            Set(friendData.sentRequests),
            Set(friendData.receivedRequests)
        )
    }
    
    func loadBlockedUsers() throws -> Set<String> {
        guard fileManager.fileExists(atPath: blockedUsersURL.path) else {
            print("PersistenceManager: No saved blocked users found")
            return []
        }
        
        let data = try Data(contentsOf: blockedUsersURL)
        let array = try decoder.decode([String].self, from: data)
        print("PersistenceManager: Loaded \(array.count) blocked users")
        return Set(array)
    }
    
    func loadFavoriteUsers() throws -> Set<String> {
        guard fileManager.fileExists(atPath: favoriteUsersURL.path) else {
            print("PersistenceManager: No saved favorite users found")
            return []
        }
        
        let data = try Data(contentsOf: favoriteUsersURL)
        let array = try decoder.decode([String].self, from: data)
        print("PersistenceManager: Loaded \(array.count) favorite users")
        return Set(array)
    }
    
    func loadStories() throws -> [Story] {
        guard fileManager.fileExists(atPath: storiesURL.path) else {
            print("PersistenceManager: No saved stories found")
            return []
        }

        let data = try Data(contentsOf: storiesURL)
        let stories = try decoder.decode([Story].self, from: data)
        print("PersistenceManager: Loaded \(stories.count) stories")
        return stories
    }

    func loadHeatmap() throws -> [String: Int] {
        guard fileManager.fileExists(atPath: heatmapURL.path) else {
            print("PersistenceManager: No saved heatmap found")
            return [:]
        }

        let data = try Data(contentsOf: heatmapURL)
        let heatmap = try decoder.decode([String: Int].self, from: data)
        print("PersistenceManager: Loaded heatmap with \(heatmap.count) locations")
        return heatmap
    }

    func loadRecentCheckIns() throws -> [CheckIn] {
        guard fileManager.fileExists(atPath: recentCheckInsURL.path) else {
            print("PersistenceManager: No saved recent check-ins found")
            return []
        }

        let data = try Data(contentsOf: recentCheckInsURL)
        let checkIns = try decoder.decode([CheckIn].self, from: data)
        print("PersistenceManager: Loaded \(checkIns.count) recent check-ins")
        return checkIns
    }

    func loadRelationshipStatuses() throws -> [String: RelationshipStatus] {
        guard fileManager.fileExists(atPath: relationshipStatusesURL.path) else {
            print("PersistenceManager: No saved relationship statuses found")
            return [:]
        }

        let data = try Data(contentsOf: relationshipStatusesURL)
        let statuses = try decoder.decode([String: RelationshipStatus].self, from: data)
        print("PersistenceManager: Loaded \(statuses.count) relationship statuses")
        return statuses
    }

    // MARK: - Clear Methods
    
    func clearAllData() throws {
        let urls = [
            currentUserURL,
            conversationsURL,
            matchesURL,
            likedUsersURL,
            friendsURL,
            blockedUsersURL,
            favoriteUsersURL,
            storiesURL,
            heatmapURL,
            recentCheckInsURL,
            relationshipStatusesURL
        ]
        
        for url in urls {
            if fileManager.fileExists(atPath: url.path) {
                try fileManager.removeItem(at: url)
            }
        }
        
        print("PersistenceManager: Cleared all persisted data")
    }
    
    func deleteFile(at url: URL) throws {
        if fileManager.fileExists(atPath: url.path) {
            try fileManager.removeItem(at: url)
            print("PersistenceManager: Deleted file at \(url.lastPathComponent)")
        }
    }
}

// MARK: - Helper Models

struct FriendData: Codable {
    let friends: [String]
    let sentRequests: [String]
    let receivedRequests: [String]
}
