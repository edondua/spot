import Foundation

struct CheckIn: Identifiable, Codable, Hashable {
    let id: String
    let userId: String
    let location: Location
    let timestamp: Date
    let expiresAt: Date
    var caption: String?
    var imageUrl: String? // Photo from camera check-in

    var isActive: Bool {
        Date() < expiresAt
    }

    var timeRemaining: String {
        let interval = expiresAt.timeIntervalSince(Date())
        if interval <= 0 { return "Expired" }

        let hours = Int(interval) / 3600
        let minutes = Int(interval) / 60 % 60

        if hours > 0 {
            return "\(hours)h \(minutes)m left"
        } else {
            return "\(minutes)m left"
        }
    }

    init(id: String = UUID().uuidString,
         userId: String,
         location: Location,
         timestamp: Date = Date(),
         expiresAt: Date? = nil,
         caption: String? = nil,
         imageUrl: String? = nil) {
        self.id = id
        self.userId = userId
        self.location = location
        self.timestamp = timestamp
        // Default expiration: 3 hours from check-in
        self.expiresAt = expiresAt ?? timestamp.addingTimeInterval(3 * 60 * 60)
        self.caption = caption
        self.imageUrl = imageUrl
    }
}
