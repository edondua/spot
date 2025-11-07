import Foundation
import SwiftUI

// MARK: - App Constants

enum AppConstants {

    // MARK: - API Configuration
    enum API {
        static let baseURL = "https://api.spotted.app"
        static let timeout: TimeInterval = 30.0
    }

    // MARK: - App Configuration
    enum App {
        static let appName = "Spotted"
        static let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        static let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }

    // MARK: - Design System
    enum Design {
        // Brand Colors
        static let primaryColor = Color(red: 252/255, green: 108/255, blue: 133/255)
        static let secondaryColor = Color(red: 255/255, green: 149/255, blue: 0/255)

        // Spacing
        static let smallSpacing: CGFloat = 8
        static let mediumSpacing: CGFloat = 16
        static let largeSpacing: CGFloat = 24
        static let extraLargeSpacing: CGFloat = 32

        // Corner Radius
        static let smallRadius: CGFloat = 8
        static let mediumRadius: CGFloat = 12
        static let largeRadius: CGFloat = 16
        static let extraLargeRadius: CGFloat = 20

        // Animation
        static let defaultAnimation: Animation = .spring(response: 0.4, dampingFraction: 0.7)
        static let quickAnimation: Animation = .spring(response: 0.2, dampingFraction: 0.8)
    }

    // MARK: - Features
    enum Features {
        static let maxPhotos = 6
        static let maxPrompts = 3
        static let maxDistance: Double = 100.0 // km
        static let minAge = 18
        static let maxAge = 99
        static let checkInRadius: Double = 500.0 // meters
    }

    // MARK: - Storage Keys
    enum StorageKeys {
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let userDefaults = "com.spotted.userdefaults"
    }
}
