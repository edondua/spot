import Foundation

struct Conversation: Identifiable, Codable, Hashable {
    let id: String
    let participants: [String] // User IDs
    var messages: [Message]
    let matchedAt: Date
    var lastMessage: Message? {
        messages.last
    }

    init(id: String = UUID().uuidString,
         participants: [String],
         messages: [Message] = [],
         matchedAt: Date = Date()) {
        self.id = id
        self.participants = participants
        self.messages = messages
        self.matchedAt = matchedAt
    }
}

enum MessageType: String, Codable {
    case text
    case voiceMemo
    case gift
    case gif
    case photo
}

enum MessageStatus: String, Codable {
    case sending    // Message is being sent
    case sent       // Message sent to server
    case delivered  // Message delivered to recipient
    case read       // Message read by recipient
    case failed     // Message failed to send
}

struct Message: Identifiable, Codable, Hashable {
    let id: String
    let senderId: String
    let text: String
    let timestamp: Date
    var isRead: Bool
    var status: MessageStatus
    var type: MessageType
    var voiceMemoUrl: String? // Path to audio file
    var voiceMemoDuration: TimeInterval? // Duration in seconds
    var giftEmoji: String? // Gift emoji (🎁, 🌹, ☕️, 🍷, etc.)
    var gifUrl: String? // Remote or local URL for GIF media
    var photoUrl: String? // Local asset id or file URL for attached photo
    // Reactions stored as emoji -> set of userIds who reacted with that emoji
    var reactions: [String: Set<String>]? 
    var replyTo: MessageReplyContext? // Lightweight context for replied-to message

    var timeDisplay: String {
        let formatter = DateFormatter()
        let calendar = Calendar.current

        if calendar.isDateInToday(timestamp) {
            formatter.dateFormat = "HH:mm"
        } else if calendar.isDateInYesterday(timestamp) {
            return "Yesterday"
        } else {
            formatter.dateFormat = "MMM d"
        }

        return formatter.string(from: timestamp)
    }

    init(id: String = UUID().uuidString,
         senderId: String,
         text: String,
         timestamp: Date = Date(),
         isRead: Bool = false,
         status: MessageStatus = .sent,
         type: MessageType = .text,
         voiceMemoUrl: String? = nil,
         voiceMemoDuration: TimeInterval? = nil,
         giftEmoji: String? = nil,
         gifUrl: String? = nil,
         photoUrl: String? = nil,
         reactions: [String: Set<String>]? = [:],
         replyTo: MessageReplyContext? = nil) {
        self.id = id
        self.senderId = senderId
        self.text = text
        self.timestamp = timestamp
        self.isRead = isRead
        self.status = status
        self.type = type
        self.voiceMemoUrl = voiceMemoUrl
        self.voiceMemoDuration = voiceMemoDuration
        self.giftEmoji = giftEmoji
        self.gifUrl = gifUrl
        self.photoUrl = photoUrl
        self.reactions = reactions
        self.replyTo = replyTo
    }
}

struct MessageReplyContext: Codable, Hashable {
    let messageId: String
    let senderId: String
    let senderName: String
    let summary: String
}

struct Match: Identifiable, Codable, Hashable {
    let id: String
    let users: [String] // Two user IDs
    let timestamp: Date
    let location: Location? // Where they matched (if at same location)

    init(id: String = UUID().uuidString,
         users: [String],
         timestamp: Date = Date(),
         location: Location? = nil) {
        self.id = id
        self.users = users
        self.timestamp = timestamp
        self.location = location
    }
}
