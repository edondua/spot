import SwiftUI

// MARK: - Theme Manager
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
}

@main
struct SpottedApp: App {
    @StateObject private var appViewModel = AppViewModel()
    @StateObject private var themeManager = ThemeManager.shared
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                ContentView()
                    .environmentObject(appViewModel)
                    .preferredColorScheme(themeManager.appTheme.colorScheme)
            } else {
                OnboardingView()
                    .environmentObject(appViewModel)
                    .preferredColorScheme(themeManager.appTheme.colorScheme)
            }
        }
    }
}

// MARK: - Content View (Main App)
struct ContentView: View {
    var body: some View {
        MainTabView()
    }
}
