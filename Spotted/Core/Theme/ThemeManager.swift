import SwiftUI

/// Theme manager for app-wide appearance
class ThemeManager: ObservableObject {
    static let shared = ThemeManager()

    @AppStorage("appTheme") var appTheme: AppTheme = .system

    enum AppTheme: String, CaseIterable, Identifiable {
        case light = "Light"
        case dark = "Dark"
        case system = "System"

        var id: String { rawValue }

        var colorScheme: ColorScheme? {
            switch self {
            case .light: return .light
            case .dark: return .dark
            case .system: return nil
            }
        }

        var icon: String {
            switch self {
            case .light: return "sun.max.fill"
            case .dark: return "moon.fill"
            case .system: return "circle.lefthalf.filled"
            }
        }
    }

    func setTheme(_ theme: AppTheme) {
        appTheme = theme
        objectWillChange.send()
    }
}

// MARK: - Theme Colors
extension Color {
    static let theme = ThemeColors()

    struct ThemeColors {
        // Primary colors
        let tinderPink = Color(red: 252/255, green: 108/255, blue: 133/255)
        let tinderPinkDark = Color(red: 234/255, green: 88/255, blue: 120/255)

        // Background colors (adapt to dark mode)
        var background: Color {
            Color(UIColor.systemBackground)
        }

        var secondaryBackground: Color {
            Color(UIColor.secondarySystemBackground)
        }

        var tertiaryBackground: Color {
            Color(UIColor.tertiarySystemBackground)
        }

        // Text colors (adapt to dark mode)
        var primaryText: Color {
            Color(UIColor.label)
        }

        var secondaryText: Color {
            Color(UIColor.secondaryLabel)
        }

        var tertiaryText: Color {
            Color(UIColor.tertiaryLabel)
        }

        // Card colors
        var cardBackground: Color {
            Color(UIColor.secondarySystemBackground)
        }

        // Separator
        var separator: Color {
            Color(UIColor.separator)
        }
    }
}
