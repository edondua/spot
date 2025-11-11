import Foundation
import SwiftUI

enum DiscoveryCategory: String, Identifiable, CaseIterable {
    case shortTerm = "Short-term Fun"
    case longTerm = "Long-term Partner"
    case gamers = "Gamers"
    case creatives = "Creatives"
    case foodies = "Foodies"
    case travel = "Travel Buddies"
    case binge = "Binge Watchers"
    case sports = "Sports"
    case music = "Music Lovers"
    case spiritual = "Spiritual"

    var id: String { rawValue }

    var color: Color {
        switch self {
        case .shortTerm:
            return Color(red: 252/255, green: 108/255, blue: 133/255) // Tinder pink
        case .longTerm:
            return Color(red: 255/255, green: 45/255, blue: 85/255) // Deep pink/red
        case .gamers:
            return Color(red: 88/255, green: 101/255, blue: 242/255) // Discord purple
        case .creatives:
            return Color(red: 255/255, green: 149/255, blue: 0/255) // Orange
        case .foodies:
            return Color(red: 255/255, green: 59/255, blue: 48/255) // Red
        case .travel:
            return Color(red: 52/255, green: 199/255, blue: 89/255) // Green
        case .binge:
            return Color(red: 191/255, green: 90/255, blue: 242/255) // Purple
        case .sports:
            return Color(red: 255/255, green: 204/255, blue: 0/255) // Yellow
        case .music:
            return Color(red: 255/255, green: 45/255, blue: 85/255) // Pink
        case .spiritual:
            return Color(red: 94/255, green: 92/255, blue: 230/255) // Indigo
        }
    }

    var icon: String {
        switch self {
        case .shortTerm:
            return "flame.fill"
        case .longTerm:
            return "heart.fill"
        case .gamers:
            return "gamecontroller.fill"
        case .creatives:
            return "paintbrush.fill"
        case .foodies:
            return "fork.knife"
        case .travel:
            return "airplane"
        case .binge:
            return "tv.fill"
        case .sports:
            return "figure.run"
        case .music:
            return "music.note"
        case .spiritual:
            return "sparkles"
        }
    }

    var description: String {
        switch self {
        case .shortTerm:
            return "Keep it casual"
        case .longTerm:
            return "Find your person"
        case .gamers:
            return "Game together"
        case .creatives:
            return "Inspire each other"
        case .foodies:
            return "Eat, drink, enjoy"
        case .travel:
            return "Explore the world"
        case .binge:
            return "Netflix & chill"
        case .sports:
            return "Get active together"
        case .music:
            return "Share the vibe"
        case .spiritual:
            return "Connect deeper"
        }
    }
}

// MARK: - Heat Level for Check-in Heatmap
enum HeatLevel {
    case cool
    case warm
    case hot
    case veryHot

    var color: Color {
        switch self {
        case .cool:
            return .blue
        case .warm:
            return .yellow
        case .hot:
            return .orange
        case .veryHot:
            return .red
        }
    }

    var emoji: String {
        switch self {
        case .cool:
            return "❄️"
        case .warm:
            return "🔥"
        case .hot:
            return "🔥🔥"
        case .veryHot:
            return "🔥🔥🔥"
        }
    }

    var description: String {
        switch self {
        case .cool:
            return "Quiet"
        case .warm:
            return "Getting busy"
        case .hot:
            return "Popular spot"
        case .veryHot:
            return "Super hot!"
        }
    }
}
