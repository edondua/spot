import Foundation

// MARK: - Icebreaker Game Models
struct IcebreakerGame: Identifiable, Codable {
    let id: String
    let type: GameType
    let locationId: String
    let hostUserId: String // Who initiated the game
    let participants: [String] // User IDs
    var status: GameStatus
    var rounds: [GameRound]
    let createdAt: Date
    var expiresAt: Date

    enum GameType: String, Codable, CaseIterable {
        case quickFire = "Quick Fire"
        case thisOrThat = "This or That"
        case truthOrDare = "Truth or Dare"
        case photoChallenge = "Photo Challenge"
        case trivia = "Trivia Battle"
        case emojiStory = "Emoji Story"

        var icon: String {
            switch self {
            case .quickFire: return "bolt.fill"
            case .thisOrThat: return "arrow.left.arrow.right"
            case .truthOrDare: return "sparkles"
            case .photoChallenge: return "camera.fill"
            case .trivia: return "brain.head.profile"
            case .emojiStory: return "face.smiling"
            }
        }

        var color: String {
            switch self {
            case .quickFire: return "orange"
            case .thisOrThat: return "purple"
            case .truthOrDare: return "pink"
            case .photoChallenge: return "blue"
            case .trivia: return "green"
            case .emojiStory: return "yellow"
            }
        }

        var description: String {
            switch self {
            case .quickFire: return "Answer rapid-fire questions in 10 seconds!"
            case .thisOrThat: return "Choose between two options - see if you match!"
            case .truthOrDare: return "Brave enough for truth or dare?"
            case .photoChallenge: return "Complete fun photo challenges together"
            case .trivia: return "Test your knowledge - compete for bragging rights"
            case .emojiStory: return "Create stories using only emojis"
            }
        }
    }

    enum GameStatus: String, Codable {
        case pending    // Invitation sent, waiting for acceptance
        case active     // Game in progress
        case completed  // Game finished
        case declined   // Invitation declined
        case expired    // Time ran out
    }
}

struct GameRound: Identifiable, Codable {
    let id: String
    let question: String
    var responses: [String: String] // userId: response
    let correctAnswer: String?      // For trivia
    let options: [String]?          // For this-or-that
    let timestamp: Date
}

// MARK: - Icebreaker Questions/Prompts
struct IcebreakerContent {
    static let quickFireQuestions = [
        "Pineapple on pizza: yes or no?",
        "Morning person or night owl?",
        "Beach vacation or mountain adventure?",
        "Coffee or tea?",
        "Cats or dogs?",
        "Sweet or savory?",
        "Netflix or YouTube?",
        "Text or call?",
        "Summer or winter?",
        "Spontaneous or planned?"
    ]

    static let thisOrThatPairs = [
        ("🍕 Pizza", "🍔 Burger"),
        ("🎬 Movies", "📚 Books"),
        ("🏖️ Beach", "⛰️ Mountains"),
        ("☕ Coffee", "🍵 Tea"),
        ("🎵 Music", "🎙️ Podcasts"),
        ("🌃 Night Out", "🏠 Cozy Night In"),
        ("✈️ Travel", "💰 Save Money"),
        ("🎨 Art", "🔬 Science"),
        ("🍦 Ice Cream", "🍰 Cake"),
        ("🎮 Video Games", "🏀 Sports")
    ]

    static let truthPrompts = [
        "What's your most embarrassing moment?",
        "Who was your first crush?",
        "What's a secret talent you have?",
        "What's the craziest thing you've done?",
        "What's your biggest fear?",
        "What's one thing on your bucket list?",
        "What's your guilty pleasure?",
        "What's the best advice you've received?"
    ]

    static let darePrompts = [
        "Do your best dance move right now",
        "Sing a song out loud",
        "Tell a joke to someone nearby",
        "Do 10 jumping jacks",
        "Strike your best pose for a photo",
        "Compliment a stranger",
        "Share your most recent photo",
        "Do an impression of a celebrity"
    ]

    static let photoChallenges = [
        "Take a group selfie making silly faces",
        "Recreate a famous movie scene",
        "Find something heart-shaped",
        "Jump shot with everyone in the air",
        "Human pyramid or tower",
        "Mirror each other's poses",
        "Spell a word with your bodies",
        "Create a funny shadow art"
    ]

    static let triviaQuestions = [
        (question: "What year did the first iPhone launch?", answer: "2007", options: ["2005", "2007", "2009", "2010"]),
        (question: "What's the capital of Switzerland?", answer: "Bern", options: ["Zurich", "Geneva", "Bern", "Basel"]),
        (question: "How many continents are there?", answer: "7", options: ["5", "6", "7", "8"]),
        (question: "What's the smallest country in the world?", answer: "Vatican City", options: ["Monaco", "Vatican City", "San Marino", "Liechtenstein"]),
        (question: "What does HTTP stand for?", answer: "HyperText Transfer Protocol", options: ["HyperText Transfer Protocol", "High Tech Transfer Protocol", "HyperText Transmission Process", "Home Tool Transfer Protocol"])
    ]

    static let emojiStoryPrompts = [
        "Describe your perfect date in 5 emojis",
        "Tell us about your day in emojis",
        "What's your life motto in emoji form?",
        "Describe your dream vacation with emojis",
        "Show your favorite hobby using emojis"
    ]
}

// MARK: - Game Invitation
struct GameInvitation: Identifiable, Codable {
    let id: String
    let gameType: IcebreakerGame.GameType
    let fromUserId: String
    let toUserIds: [String]
    let locationId: String
    let message: String?
    let timestamp: Date
    var expiresAt: Date
    var status: InvitationStatus

    enum InvitationStatus: String, Codable {
        case pending
        case accepted
        case declined
        case expired
    }

    var isExpired: Bool {
        Date() > expiresAt
    }
}
