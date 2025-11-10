import Foundation
import OSLog

/// Backend service protocol - abstracts the actual backend implementation
/// This allows swapping Firebase with Supabase or custom backend without changing app code
protocol BackendServiceProtocol {
    // Authentication
    func signUp(email: String, password: String) async throws -> String
    func signIn(email: String, password: String) async throws -> String
    func signOut() throws
    
    // Users
    func saveUser(_ user: User) async throws
    func getUser(id: String) async throws -> User?
    func getNearbyUsers(location: Location, radius: Double) async throws -> [User]
    
    // Check-ins
    func createCheckIn(_ checkIn: CheckIn) async throws
    func removeCheckIn(userId: String) async throws
    
    // Matches
    func createMatch(_ match: Match) async throws
    func getMatches(userId: String) async throws -> [Match]
    
    // Messaging
    func sendMessage(_ message: Message, conversationId: String) async throws
    func getMessages(conversationId: String, limit: Int) async throws -> [Message]
    
    // Storage
    func uploadPhoto(_ data: Data, userId: String, photoIndex: Int) async throws -> String
    func deletePhoto(url: String) async throws
}

/// Main backend service that delegates to Firebase (or other backend)
@MainActor
class BackendService: ObservableObject {
    static let shared = BackendService()
    
    private let logger = Logger(subsystem: "com.spotted.app", category: "Backend")
    private let firebase = FirebaseService.shared
    
    @Published var isConnected = false
    @Published var currentUserId: String?
    
    private init() {
        checkConnection()
    }
    
    private func checkConnection() {
        isConnected = firebase.isConfigured
        logger.info("Backend service initialized. Connected: \(self.isConnected)")
    }
}

// MARK: - Authentication
extension BackendService {
    func signUp(email: String, password: String, name: String) async throws -> User {
        logger.info("Backend: Sign up for \(email)")
        
        let userId = try await firebase.auth.signUp(email: email, password: password)
        currentUserId = userId
        
        // Create user profile
        let user = User(
            id: userId,
            name: name,
            age: 0,
            bio: "",
            photos: [],
            profilePhoto: "",
            interests: [],
            lookingFor: "Friends"
        )
        
        try await firebase.database.saveUser(user)
        
        AnalyticsManager.shared.track(.profileCreated(userId: userId))
        
        return user
    }
    
    func signIn(email: String, password: String) async throws -> User {
        logger.info("Backend: Sign in for \(email)")
        
        let userId = try await firebase.auth.signIn(email: email, password: password)
        currentUserId = userId
        
        AnalyticsManager.shared.track(.signedIn(userId: userId))
        
        guard let user = try await firebase.database.getUser(id: userId) else {
            throw BackendError.userNotFound
        }
        
        return user
    }
    
    func signOut() throws {
        logger.info("Backend: Sign out")
        
        try firebase.auth.signOut()
        currentUserId = nil
        
        AnalyticsManager.shared.track(.signedOut)
    }
    
    func deleteAccount() async throws {
        logger.info("Backend: Delete account")

        guard currentUserId != nil else {
            throw BackendError.notAuthenticated
        }

        // TODO: Delete user data from Firestore
        // TODO: Delete user photos from Storage

        try await firebase.auth.deleteAccount()
        currentUserId = nil
    }
}

// MARK: - User Operations
extension BackendService {
    func updateUser(_ user: User) async throws {
        logger.info("Backend: Update user \(user.id)")
        
        try await firebase.database.saveUser(user)
        
        AnalyticsManager.shared.track(.profileEdited(userId: user.id, fieldsChanged: ["profile"]))
    }
    
    func getUser(id: String) async throws -> User? {
        logger.info("Backend: Get user \(id)")
        
        return try await firebase.database.getUser(id: id)
    }
    
    func getNearbyUsers(location: Location, radius: Double = 1000) async throws -> [User] {
        logger.info("Backend: Get nearby users at \(location.name)")
        
        return try await firebase.database.getNearbyUsers(location: location, radius: radius)
    }
}

// MARK: - Check-in Operations
extension BackendService {
    func createCheckIn(_ checkIn: CheckIn) async throws {
        logger.info("Backend: Create check-in at \(checkIn.location.name)")
        
        try await firebase.database.createCheckIn(checkIn)
        
        AnalyticsManager.shared.track(.checkedIn(location: checkIn.location.name, userId: checkIn.userId))
    }
    
    func removeCheckIn(userId: String) async throws {
        logger.info("Backend: Remove check-in for \(userId)")
        
        try await firebase.database.removeCheckIn(userId: userId)
    }
}

// MARK: - Match Operations
extension BackendService {
    func createMatch(userId: String, matchedUserId: String, location: Location?) async throws {
        logger.info("Backend: Create match between \(userId) and \(matchedUserId)")
        
        let match = Match(
            users: [userId, matchedUserId],
            location: location
        )
        
        try await firebase.database.createMatch(match)
        
        AnalyticsManager.shared.track(.matchCreated(userId: userId, matchedUserId: matchedUserId))
        
        // TODO: Trigger push notification to both users
    }
    
    func getMatches(userId: String) async throws -> [Match] {
        logger.info("Backend: Get matches for \(userId)")
        
        return try await firebase.database.getMatches(userId: userId)
    }
}

// MARK: - Messaging Operations
extension BackendService {
    func sendMessage(_ message: Message, conversationId: String) async throws {
        logger.info("Backend: Send message in \(conversationId)")
        
        try await firebase.database.sendMessage(message, conversationId: conversationId)
        
        let messageType = message.type == .text ? "text" : 
                         message.type == .voiceMemo ? "voice" : "gift"
        AnalyticsManager.shared.track(.messageSent(conversationId: conversationId, messageType: messageType))
        
        // TODO: Trigger push notification to recipient
    }
    
    func getMessages(conversationId: String, limit: Int = 50) async throws -> [Message] {
        logger.info("Backend: Get messages for \(conversationId)")
        
        return try await firebase.database.getMessages(conversationId: conversationId, limit: limit)
    }
    
    func listenToConversation(conversationId: String, onUpdate: @escaping ([Message]) -> Void) {
        logger.info("Backend: Listen to conversation \(conversationId)")
        
        firebase.database.listenToConversation(conversationId: conversationId, onUpdate: onUpdate)
    }
}

// MARK: - Storage Operations
extension BackendService {
    func uploadProfilePhoto(_ imageData: Data, userId: String, photoIndex: Int) async throws -> String {
        logger.info("Backend: Upload profile photo for \(userId)")
        
        let url = try await firebase.storage.uploadProfilePhoto(imageData, userId: userId, photoIndex: photoIndex)
        
        AnalyticsManager.shared.track(.photoUploaded(userId: userId, photoCount: photoIndex + 1))
        
        return url
    }
    
    func uploadStoryMedia(_ imageData: Data, userId: String, storyId: String) async throws -> String {
        logger.info("Backend: Upload story media for \(userId)")
        
        let url = try await firebase.storage.uploadStoryMedia(imageData, userId: userId, storyId: storyId)
        
        AnalyticsManager.shared.track(.storyPosted(userId: userId, mediaType: "image"))
        
        return url
    }
    
    func uploadVoiceMemo(_ audioData: Data, conversationId: String) async throws -> String {
        logger.info("Backend: Upload voice memo")
        
        return try await firebase.storage.uploadVoiceMemo(audioData, conversationId: conversationId)
    }
    
    func deleteFile(url: String) async throws {
        logger.info("Backend: Delete file")
        
        try await firebase.storage.deleteFile(url: url)
    }
}

// MARK: - Push Notifications
extension BackendService {
    func requestNotificationPermission() async throws {
        logger.info("Backend: Request notification permission")
        
        try await firebase.messaging.requestPermission()
    }
    
    func saveFCMToken(_ token: String) async throws {
        logger.info("Backend: Save FCM token")
        
        guard let userId = currentUserId else {
            throw BackendError.notAuthenticated
        }
        
        try await firebase.messaging.saveFCMToken(token, userId: userId)
    }
}

// MARK: - Error Types
enum BackendError: LocalizedError {
    case notAuthenticated
    case userNotFound
    case invalidData
    case networkError
    case serverError(String)
    
    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "You must be signed in to perform this action"
        case .userNotFound:
            return "User not found"
        case .invalidData:
            return "Invalid data format"
        case .networkError:
            return "Network connection error"
        case .serverError(let message):
            return "Server error: \(message)"
        }
    }
}
