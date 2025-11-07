import Foundation

// MARK: - Date Extensions

extension Date {

    /// Time ago string (e.g., "2m ago", "1h ago", "yesterday")
    var timeAgoDisplay: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: self, relativeTo: Date())
    }

    /// Check if date is today
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }

    /// Check if date is yesterday
    var isYesterday: Bool {
        Calendar.current.isDateInYesterday(self)
    }

    /// Check if date is within last week
    var isWithinLastWeek: Bool {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return self > weekAgo
    }

    /// Format as time (e.g., "3:45 PM")
    var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }

    /// Format as date (e.g., "Jan 7, 2025")
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: self)
    }

    /// Format for chat display (e.g., "Today", "Yesterday", "Jan 7")
    var chatDisplayString: String {
        if isToday {
            return "Today"
        } else if isYesterday {
            return "Yesterday"
        } else if isWithinLastWeek {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE"
            return formatter.string(from: self)
        } else {
            return dateString
        }
    }

    /// Time remaining until date (for spontaneous status)
    var timeRemainingString: String {
        let components = Calendar.current.dateComponents([.hour, .minute], from: Date(), to: self)
        if let hours = components.hour, let minutes = components.minute {
            if hours > 0 {
                return "\(hours)h \(minutes)m"
            } else if minutes > 0 {
                return "\(minutes)m"
            } else {
                return "Expiring soon"
            }
        }
        return ""
    }
}
