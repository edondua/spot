import Foundation

struct Story: Identifiable, Codable, Hashable {
    let id: String
    let userId: String
    let location: Location
    let imageUrl: String
    let caption: String?
    let timestamp: Date
    let expiresAt: Date
    var viewCount: Int

    var isActive: Bool {
        Date() < expiresAt
    }

    var timeAgo: String {
        let interval = Date().timeIntervalSince(timestamp)
        let hours = Int(interval) / 3600
        let minutes = Int(interval) / 60

        if hours > 0 {
            return "\(hours)h ago"
        } else if minutes > 0 {
            return "\(minutes)m ago"
        } else {
            return "Just now"
        }
    }

    init(id: String = UUID().uuidString,
         userId: String,
         location: Location,
         imageUrl: String,
         caption: String? = nil,
         timestamp: Date = Date(),
         expiresAt: Date? = nil,
         viewCount: Int = 0) {
        self.id = id
        self.userId = userId
        self.location = location
        self.imageUrl = imageUrl
        self.caption = caption
        self.timestamp = timestamp
        // Stories expire after 24 hours
        self.expiresAt = expiresAt ?? timestamp.addingTimeInterval(24 * 60 * 60)
        self.viewCount = viewCount
    }
}
