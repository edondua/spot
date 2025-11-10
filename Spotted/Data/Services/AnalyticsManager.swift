import Foundation
import OSLog

/// Manages analytics tracking and crash reporting for the app
@MainActor
class AnalyticsManager {
    static let shared = AnalyticsManager()
    
    private let logger = Logger(subsystem: "com.spotted.app", category: "Analytics")
    @Published var isEnabled: Bool = true
    
    private init() {
        logger.info("AnalyticsManager initialized")
    }
    
    enum Event {
        // MARK: - Onboarding & Authentication
        case onboardingStarted
        case onboardingCompleted
        case profileCreated(userId: String)
        case signedIn(userId: String)
        case signedOut
        
        // MARK: - Check-ins & Location
        case checkedIn(location: String, userId: String)
        case checkedOut(location: String, userId: String)
        case locationViewed(location: String)
        case nearbyUsersViewed(count: Int)
        
        // MARK: - Matching & Likes
        case userLiked(userId: String, fromUserId: String)
        case userPassed(userId: String, fromUserId: String)
        case matchCreated(userId: String, matchedUserId: String)
        case matchDeleted(userId: String, matchedUserId: String)
        case photoLiked(userId: String, photoIndex: Int)
        
        // MARK: - Messaging
        case conversationStarted(userId: String, withUserId: String)
        case messageSent(conversationId: String, messageType: String)
        case messageReceived(conversationId: String, messageType: String)
        case voiceMessageRecorded(duration: TimeInterval)
        case photoSent(conversationId: String)
        
        // MARK: - Social Features
        case friendRequestSent(fromUserId: String, toUserId: String)
        case friendRequestAccepted(fromUserId: String, toUserId: String)
        case friendRequestDeclined(fromUserId: String, toUserId: String)
        case userBlocked(userId: String, blockedUserId: String)
        case userUnblocked(userId: String, unblockedUserId: String)
        case userReported(userId: String, reportedUserId: String, reason: String)
        case userFavorited(userId: String, favoritedUserId: String)
        case userUnfavorited(userId: String, unfavoritedUserId: String)
        
        // MARK: - Profile & Settings
        case profileViewed(userId: String, viewedUserId: String)
        case profileEdited(userId: String, fieldsChanged: [String])
        case photoUploaded(userId: String, photoCount: Int)
        case photoDeleted(userId: String)
        case verificationStarted(userId: String)
        case verificationCompleted(userId: String, success: Bool)
        case settingsChanged(userId: String, setting: String)
        
        // MARK: - Discovery
        case discoverTabOpened
        case searchPerformed(query: String, resultsCount: Int)
        case filterApplied(filterType: String, value: String)
        case userCardSwiped(direction: String)
        
        // MARK: - Stories
        case storyPosted(userId: String, mediaType: String)
        case storyViewed(userId: String, storyOwnerId: String)
        case storyDeleted(userId: String, storyId: String)
        
        // MARK: - App Lifecycle
        case appLaunched
        case appBackgrounded
        case appForegrounded
        case appCrashed(error: String)
        
        // MARK: - Errors
        case networkError(endpoint: String, error: String)
        case persistenceError(operation: String, error: String)
        case locationError(error: String)
    }
    
    /// Track an analytics event
    func track(_ event: Event) {
        guard isEnabled else { return }
        
        let eventName = eventDescription(for: event)
        let properties = eventProperties(for: event)
        
        // Log to OSLog (ready for Firebase Analytics, Mixpanel, etc.)
        logger.info("📊 Event: \(eventName) | Properties: \(properties)")
        
        // TODO: Add Firebase Analytics integration
        // Analytics.logEvent(eventName, parameters: properties)
        
        // TODO: Add Mixpanel integration
        // Mixpanel.mainInstance().track(event: eventName, properties: properties)
    }
    
    /// Log an error for crash reporting
    func logError(_ error: Error, context: String? = nil) {
        let errorDescription = error.localizedDescription
        let contextInfo = context.map { " | Context: \($0)" } ?? ""
        
        logger.error("❌ Error: \(errorDescription)\(contextInfo)")
        
        // TODO: Add Crashlytics integration
        // Crashlytics.crashlytics().record(error: error)
        
        track(.appCrashed(error: errorDescription))
    }
    
    /// Set user properties for analytics
    func setUserProperties(userId: String, properties: [String: Any]) {
        guard isEnabled else { return }
        
        logger.info("👤 User properties set for \(userId): \(properties)")
        
        // TODO: Add Firebase Analytics user properties
        // properties.forEach { key, value in
        //     Analytics.setUserProperty(String(describing: value), forName: key)
        // }
        
        // TODO: Add Mixpanel user properties
        // Mixpanel.mainInstance().people.set(properties: properties)
    }
    
    /// Track screen view
    func trackScreen(_ screenName: String) {
        guard isEnabled else { return }
        
        logger.info("📱 Screen viewed: \(screenName)")
        
        // TODO: Add Firebase Analytics screen tracking
        // Analytics.logEvent(AnalyticsEventScreenView, parameters: [
        //     AnalyticsParameterScreenName: screenName
        // ])
    }
    
    // MARK: - Private Helpers
    
    private func eventDescription(for event: Event) -> String {
        switch event {
        case .onboardingStarted: return "onboarding_started"
        case .onboardingCompleted: return "onboarding_completed"
        case .profileCreated: return "profile_created"
        case .signedIn: return "signed_in"
        case .signedOut: return "signed_out"
            
        case .checkedIn: return "checked_in"
        case .checkedOut: return "checked_out"
        case .locationViewed: return "location_viewed"
        case .nearbyUsersViewed: return "nearby_users_viewed"
            
        case .userLiked: return "user_liked"
        case .userPassed: return "user_passed"
        case .matchCreated: return "match_created"
        case .matchDeleted: return "match_deleted"
        case .photoLiked: return "photo_liked"
            
        case .conversationStarted: return "conversation_started"
        case .messageSent: return "message_sent"
        case .messageReceived: return "message_received"
        case .voiceMessageRecorded: return "voice_message_recorded"
        case .photoSent: return "photo_sent"
            
        case .friendRequestSent: return "friend_request_sent"
        case .friendRequestAccepted: return "friend_request_accepted"
        case .friendRequestDeclined: return "friend_request_declined"
        case .userBlocked: return "user_blocked"
        case .userUnblocked: return "user_unblocked"
        case .userReported: return "user_reported"
        case .userFavorited: return "user_favorited"
        case .userUnfavorited: return "user_unfavorited"
            
        case .profileViewed: return "profile_viewed"
        case .profileEdited: return "profile_edited"
        case .photoUploaded: return "photo_uploaded"
        case .photoDeleted: return "photo_deleted"
        case .verificationStarted: return "verification_started"
        case .verificationCompleted: return "verification_completed"
        case .settingsChanged: return "settings_changed"
            
        case .discoverTabOpened: return "discover_tab_opened"
        case .searchPerformed: return "search_performed"
        case .filterApplied: return "filter_applied"
        case .userCardSwiped: return "user_card_swiped"
            
        case .storyPosted: return "story_posted"
        case .storyViewed: return "story_viewed"
        case .storyDeleted: return "story_deleted"
            
        case .appLaunched: return "app_launched"
        case .appBackgrounded: return "app_backgrounded"
        case .appForegrounded: return "app_foregrounded"
        case .appCrashed: return "app_crashed"
            
        case .networkError: return "network_error"
        case .persistenceError: return "persistence_error"
        case .locationError: return "location_error"
        }
    }
    
    private func eventProperties(for event: Event) -> String {
        switch event {
        case .profileCreated(let userId), .signedIn(let userId):
            return "userId: \(userId)"
            
        case .checkedIn(let location, let userId), .checkedOut(let location, let userId):
            return "location: \(location), userId: \(userId)"
            
        case .locationViewed(let location):
            return "location: \(location)"
            
        case .nearbyUsersViewed(let count):
            return "count: \(count)"
            
        case .userLiked(let userId, let fromUserId), .userPassed(let userId, let fromUserId):
            return "userId: \(userId), fromUserId: \(fromUserId)"
            
        case .matchCreated(let userId, let matchedUserId), .matchDeleted(let userId, let matchedUserId):
            return "userId: \(userId), matchedUserId: \(matchedUserId)"
            
        case .photoLiked(let userId, let photoIndex):
            return "userId: \(userId), photoIndex: \(photoIndex)"
            
        case .conversationStarted(let userId, let withUserId):
            return "userId: \(userId), withUserId: \(withUserId)"
            
        case .messageSent(let conversationId, let messageType), .messageReceived(let conversationId, let messageType):
            return "conversationId: \(conversationId), messageType: \(messageType)"
            
        case .voiceMessageRecorded(let duration):
            return "duration: \(duration)s"
            
        case .photoSent(let conversationId):
            return "conversationId: \(conversationId)"
            
        case .friendRequestSent(let fromUserId, let toUserId), .friendRequestAccepted(let fromUserId, let toUserId), .friendRequestDeclined(let fromUserId, let toUserId):
            return "fromUserId: \(fromUserId), toUserId: \(toUserId)"
            
        case .userBlocked(let userId, let blockedUserId):
            return "userId: \(userId), targetUserId: \(blockedUserId)"

        case .userUnblocked(let userId, let unblockedUserId):
            return "userId: \(userId), targetUserId: \(unblockedUserId)"
            
        case .userReported(let userId, let reportedUserId, let reason):
            return "userId: \(userId), reportedUserId: \(reportedUserId), reason: \(reason)"
            
        case .userFavorited(let userId, let favoritedUserId):
            return "userId: \(userId), targetUserId: \(favoritedUserId)"

        case .userUnfavorited(let userId, let unfavoritedUserId):
            return "userId: \(userId), targetUserId: \(unfavoritedUserId)"
            
        case .profileViewed(let userId, let viewedUserId):
            return "userId: \(userId), viewedUserId: \(viewedUserId)"
            
        case .profileEdited(let userId, let fieldsChanged):
            return "userId: \(userId), fieldsChanged: \(fieldsChanged.joined(separator: ", "))"
            
        case .photoUploaded(let userId, let photoCount):
            return "userId: \(userId), photoCount: \(photoCount)"
            
        case .photoDeleted(let userId):
            return "userId: \(userId)"
            
        case .verificationStarted(let userId):
            return "userId: \(userId)"
            
        case .verificationCompleted(let userId, let success):
            return "userId: \(userId), success: \(success)"
            
        case .settingsChanged(let userId, let setting):
            return "userId: \(userId), setting: \(setting)"
            
        case .searchPerformed(let query, let resultsCount):
            return "query: \(query), resultsCount: \(resultsCount)"
            
        case .filterApplied(let filterType, let value):
            return "filterType: \(filterType), value: \(value)"
            
        case .userCardSwiped(let direction):
            return "direction: \(direction)"
            
        case .storyPosted(let userId, let mediaType):
            return "userId: \(userId), mediaType: \(mediaType)"
            
        case .storyViewed(let userId, let storyOwnerId):
            return "userId: \(userId), storyOwnerId: \(storyOwnerId)"
            
        case .storyDeleted(let userId, let storyId):
            return "userId: \(userId), storyId: \(storyId)"
            
        case .appCrashed(let error):
            return "error: \(error)"
            
        case .networkError(let endpoint, let error):
            return "endpoint: \(endpoint), error: \(error)"
            
        case .persistenceError(let operation, let error):
            return "operation: \(operation), error: \(error)"
            
        case .locationError(let error):
            return "error: \(error)"
            
        default:
            return ""
        }
    }
}
