import Foundation
import CoreLocation

struct User: Identifiable, Codable, Hashable {
    let id: String
    var name: String
    var age: Int
    var bio: String
    var photos: [String]
    var profilePhoto: String
    var ethnicity: String?
    var isVerified: Bool
    var favoriteHangouts: [Location]
    var currentCheckIn: CheckIn?
    var stories: [Story]
    var interests: [String] // Category raw values

    // Hinge-style details
    var prompts: [ProfilePrompt]
    var job: String?
    var company: String?
    var school: String?
    var height: String?
    var hometown: String?
    var lookingFor: String?
    var drinking: String?
    var smoking: String?
    var exercise: String?
    var education: String?
    var sexuality: String?
    var kids: String?

    // INNOVATIVE FEATURES
    var isSpontaneous: Bool = false // "Free now" status
    var spontaneousUntil: Date? // When spontaneous status expires
    var spontaneousActivity: String? // What they want to do: "Coffee", "Drinks", "Walk"
    var lastActivity: UserActivity? // Last thing they did

    // Computed property for display
    var displayName: String {
        "\(name), \(age)"
    }

    // Check if user is currently spontaneous
    var isCurrentlySpontaneous: Bool {
        guard isSpontaneous, let until = spontaneousUntil else { return false }
        return until > Date()
    }

    // Profile completion percentage
    var profileCompletion: Int {
        var completed = 0
        let total = 10

        // Required fields (always count as completed if user exists)
        completed += 1 // name, age (required)

        // Photos (worth 2 points)
        if photos.count >= 2 { completed += 2 }
        else if photos.count >= 1 { completed += 1 }

        // Bio
        if !bio.isEmpty { completed += 1 }

        // Interests
        if interests.count >= 3 { completed += 1 }

        // Job/Career
        if job != nil && !(job!.isEmpty) { completed += 1 }

        // Lifestyle (any 2)
        let lifestyleCount = [drinking, smoking, kids].compactMap { $0 }.filter { !$0.isEmpty }.count
        if lifestyleCount >= 2 { completed += 1 }

        // Stats (height, hometown, etc - any 2)
        let statsCount = [height, hometown, sexuality, lookingFor].compactMap { $0 }.filter { !$0.isEmpty }.count
        if statsCount >= 2 { completed += 1 }

        // Prompts
        if !prompts.isEmpty { completed += 1 }

        return (completed * 100) / total
    }

    init(id: String = UUID().uuidString,
         name: String,
         age: Int,
         bio: String,
         photos: [String] = [],
         profilePhoto: String,
         ethnicity: String? = nil,
         isVerified: Bool = false,
         favoriteHangouts: [Location] = [],
         currentCheckIn: CheckIn? = nil,
         stories: [Story] = [],
         interests: [String] = [],
         prompts: [ProfilePrompt] = [],
         job: String? = nil,
         company: String? = nil,
         school: String? = nil,
         height: String? = nil,
         hometown: String? = nil,
         lookingFor: String? = nil,
         drinking: String? = nil,
         smoking: String? = nil,
         exercise: String? = nil,
         education: String? = nil,
         sexuality: String? = nil,
         kids: String? = nil,
         isSpontaneous: Bool = false,
         spontaneousUntil: Date? = nil,
         spontaneousActivity: String? = nil,
         lastActivity: UserActivity? = nil) {
        self.id = id
        self.name = name
        self.age = age
        self.bio = bio
        self.photos = photos
        self.profilePhoto = profilePhoto
        self.ethnicity = ethnicity
        self.isVerified = isVerified
        self.favoriteHangouts = favoriteHangouts
        self.currentCheckIn = currentCheckIn
        self.stories = stories
        self.interests = interests
        self.prompts = prompts
        self.job = job
        self.company = company
        self.school = school
        self.height = height
        self.hometown = hometown
        self.lookingFor = lookingFor
        self.drinking = drinking
        self.smoking = smoking
        self.exercise = exercise
        self.education = education
        self.sexuality = sexuality
        self.kids = kids
        self.isSpontaneous = isSpontaneous
        self.spontaneousUntil = spontaneousUntil
        self.spontaneousActivity = spontaneousActivity
        self.lastActivity = lastActivity
    }
}

// MARK: - User Activity (for live feed)
struct UserActivity: Codable, Hashable, Identifiable {
    let id: String
    let userId: String
    let type: ActivityType
    let location: Location?
    let text: String
    let timestamp: Date
    var reactions: [String: Int] // emoji -> count

    enum ActivityType: String, Codable {
        case checkedIn = "checked in"
        case ordered = "just ordered"
        case looking = "looking for"
        case arrived = "just arrived at"
        case leaving = "leaving"
        case enjoying = "enjoying"
    }

    init(id: String = UUID().uuidString,
         userId: String,
         type: ActivityType,
         location: Location? = nil,
         text: String,
         timestamp: Date = Date(),
         reactions: [String: Int] = [:]) {
        self.id = id
        self.userId = userId
        self.type = type
        self.location = location
        self.text = text
        self.timestamp = timestamp
        self.reactions = reactions
    }

    var timeAgo: String {
        let seconds = Int(Date().timeIntervalSince(timestamp))
        if seconds < 60 {
            return "just now"
        } else if seconds < 3600 {
            let minutes = seconds / 60
            return "\(minutes)m ago"
        } else if seconds < 86400 {
            let hours = seconds / 3600
            return "\(hours)h ago"
        } else {
            return "1d ago"
        }
    }
}
