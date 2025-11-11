
import Foundation
import SwiftUI

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

