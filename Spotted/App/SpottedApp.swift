import SwiftUI

@main
struct SpottedApp: App {
    @StateObject private var appViewModel = AppViewModel()
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                ContentView()
                    .environmentObject(appViewModel)
            } else {
                OnboardingView()
                    .environmentObject(appViewModel)
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
