import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @Environment(\.dismiss) var dismiss

    // Settings State
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("matchNotifications") private var matchNotifications = true
    @AppStorage("messageNotifications") private var messageNotifications = true
    @AppStorage("checkInNotifications") private var checkInNotifications = true
    @AppStorage("maxDistance") private var maxDistance: Double = 50
    @AppStorage("minAge") private var minAge: Double = 18
    @AppStorage("maxAge") private var maxAge: Double = 35
    @AppStorage("showDistance") private var showDistance = true
    @AppStorage("showAge") private var showAge = true
    @AppStorage("incognitoMode") private var incognitoMode = false

    var body: some View {
        NavigationStack {
            List {
                // Account Section
                Section {
                    NavigationLink(destination: EditProfileView()) {
                        HStack(spacing: 12) {
                            ProfileImageView(user: viewModel.currentUser, size: 50)

                            VStack(alignment: .leading, spacing: 3) {
                                Text(viewModel.currentUser.name)
                                    .font(.system(size: 16, weight: .semibold))

                                Text("Edit Profile")
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                            }

                            Spacer()
                        }
                    }
                } header: {
                    Text("Account")
                }

                // Discovery Preferences
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Maximum Distance")
                                .font(.system(size: 15))

                            Spacer()

                            Text("\(Int(maxDistance)) km")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(Color(red: 252/255, green: 108/255, blue: 133/255))
                        }

                        Slider(value: $maxDistance, in: 1...100, step: 1)
                            .tint(Color(red: 252/255, green: 108/255, blue: 133/255))
                    }
                    .padding(.vertical, 4)

                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Age Range")
                                .font(.system(size: 15))

                            Spacer()

                            Text("\(Int(minAge)) - \(Int(maxAge))")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(Color(red: 252/255, green: 108/255, blue: 133/255))
                        }

                        HStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Min: \(Int(minAge))")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                                Slider(value: $minAge, in: 18...max(18, maxAge - 1), step: 1)
                                    .tint(Color(red: 252/255, green: 108/255, blue: 133/255))
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Max: \(Int(maxAge))")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                                Slider(value: $maxAge, in: min(minAge + 1, 99)...99, step: 1)
                                    .tint(Color(red: 252/255, green: 108/255, blue: 133/255))
                            }
                        }
                    }
                    .padding(.vertical, 4)

                } header: {
                    Text("Discovery Preferences")
                } footer: {
                    Text("Only show profiles within this distance and age range")
                }

                // Notifications
                Section {
                    Toggle(isOn: $notificationsEnabled) {
                        HStack(spacing: 12) {
                            Image(systemName: "bell.fill")
                                .font(.system(size: 16))
                                .foregroundColor(Color(red: 252/255, green: 108/255, blue: 133/255))
                                .frame(width: 28)

                            Text("All Notifications")
                        }
                    }
                    .tint(Color(red: 252/255, green: 108/255, blue: 133/255))

                    if notificationsEnabled {
                        Toggle(isOn: $matchNotifications) {
                            HStack(spacing: 12) {
                                Image(systemName: "heart.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(.pink)
                                    .frame(width: 28)

                                Text("New Matches")
                            }
                        }
                        .tint(Color(red: 252/255, green: 108/255, blue: 133/255))

                        Toggle(isOn: $messageNotifications) {
                            HStack(spacing: 12) {
                                Image(systemName: "message.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(.blue)
                                    .frame(width: 28)

                                Text("New Messages")
                            }
                        }
                        .tint(Color(red: 252/255, green: 108/255, blue: 133/255))

                        Toggle(isOn: $checkInNotifications) {
                            HStack(spacing: 12) {
                                Image(systemName: "location.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(.orange)
                                    .frame(width: 28)

                                Text("Nearby Check-ins")
                            }
                        }
                        .tint(Color(red: 252/255, green: 108/255, blue: 133/255))
                    }
                } header: {
                    Text("Notifications")
                } footer: {
                    Text("Get notified about matches, messages, and activity near you")
                }

                // Privacy
                Section {
                    Toggle(isOn: $showDistance) {
                        HStack(spacing: 12) {
                            Image(systemName: "location.circle.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.green)
                                .frame(width: 28)

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Show Distance")
                                Text("Display your distance to other users")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .tint(Color(red: 252/255, green: 108/255, blue: 133/255))

                    Toggle(isOn: $showAge) {
                        HStack(spacing: 12) {
                            Image(systemName: "calendar.circle.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.purple)
                                .frame(width: 28)

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Show Age")
                                Text("Display your age on your profile")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .tint(Color(red: 252/255, green: 108/255, blue: 133/255))

                    Toggle(isOn: $incognitoMode) {
                        HStack(spacing: 12) {
                            Image(systemName: "eye.slash.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                                .frame(width: 28)

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Incognito Mode")
                                Text("Only people you like can see your profile")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .tint(Color(red: 252/255, green: 108/255, blue: 133/255))
                } header: {
                    Text("Privacy")
                }

                // About
                Section {
                    NavigationLink(destination: Text("Privacy Policy")) {
                        HStack(spacing: 12) {
                            Image(systemName: "lock.shield.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.blue)
                                .frame(width: 28)

                            Text("Privacy Policy")
                        }
                    }

                    NavigationLink(destination: Text("Terms of Service")) {
                        HStack(spacing: 12) {
                            Image(systemName: "doc.text.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.orange)
                                .frame(width: 28)

                            Text("Terms of Service")
                        }
                    }

                    NavigationLink(destination: Text("Help & Support")) {
                        HStack(spacing: 12) {
                            Image(systemName: "questionmark.circle.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.green)
                                .frame(width: 28)

                            Text("Help & Support")
                        }
                    }

                    Button(action: {
                        shareApp()
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "square.and.arrow.up.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.purple)
                                .frame(width: 28)

                            Text("Share Spotted")
                                .foregroundColor(.primary)

                            Spacer()
                        }
                    }
                } header: {
                    Text("About")
                }

                // App Info
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }

                // Data & Account Management
                Section {
                    Button(action: {
                        exportData()
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "square.and.arrow.down.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.blue)
                                .frame(width: 28)

                            Text("Download My Data")
                                .foregroundColor(.primary)

                            Spacer()
                        }
                    }

                    NavigationLink(destination: BlockedUsersView()) {
                        HStack(spacing: 12) {
                            Image(systemName: "hand.raised.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.orange)
                                .frame(width: 28)

                            Text("Blocked Users")

                            Spacer()
                        }
                    }
                } header: {
                    Text("Data Management")
                } footer: {
                    Text("Export your profile data or manage blocked users")
                }

                // Danger Zone
                Section {
                    Button(action: {
                        logout()
                    }) {
                        HStack {
                            Spacer()
                            Text("Log Out")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.red)
                            Spacer()
                        }
                    }

                    Button(action: {
                        deleteAccount()
                    }) {
                        HStack {
                            Spacer()
                            Text("Delete Account")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.red)
                            Spacer()
                        }
                    }
                } header: {
                    Text("Account Actions")
                } footer: {
                    Text("Deleting your account is permanent and cannot be undone")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }

    private func shareApp() {
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()

        let shareText = "Check out Spotted - Meet people nearby! 📍❤️"
        let items: [Any] = [shareText]

        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)

        // Present the share sheet
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootViewController = window.rootViewController {

            // For iPad: set the source view
            if let popover = activityVC.popoverPresentationController {
                popover.sourceView = window
                popover.sourceRect = CGRect(x: window.bounds.midX, y: window.bounds.midY, width: 0, height: 0)
                popover.permittedArrowDirections = []
            }

            rootViewController.present(activityVC, animated: true)
        }
    }

    private func exportData() {
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()

        Task { @MainActor in
            ToastManager.shared.showSuccess("Preparing your data export...")
        }

        // In production, this would generate a JSON file with user data
        // For now, just show a success message
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            Task { @MainActor in
                ToastManager.shared.showSuccess("Data export ready! Check your email.")
            }
        }
    }

    private func deleteAccount() {
        let impact = UIImpactFeedbackGenerator(style: .heavy)
        impact.impactOccurred()

        // Show confirmation alert
        let alert = UIAlertController(
            title: "Delete Account?",
            message: "This action cannot be undone. All your data will be permanently deleted.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
            Task { @MainActor in
                ToastManager.shared.showInfo("Account deletion initiated")
            }
            // In production: API call to delete account
            dismiss()
        })

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootViewController = window.rootViewController {
            rootViewController.present(alert, animated: true)
        }
    }

    private func logout() {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()

        // Clear user session
        viewModel.logout()

        // Dismiss settings
        dismiss()
    }
}

// MARK: - Blocked Users View
struct BlockedUsersView: View {
    @State private var blockedUsers: [User] = []

    var body: some View {
        List {
            if blockedUsers.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "hand.raised.slash")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary)

                    Text("No Blocked Users")
                        .font(.system(size: 20, weight: .semibold))

                    Text("Users you block will appear here")
                        .font(.system(size: 15))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 60)
                .listRowBackground(Color.clear)
            } else {
                ForEach(blockedUsers) { user in
                    HStack(spacing: 12) {
                        ProfileImageView(user: user, size: 50)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(user.name)
                                .font(.system(size: 16, weight: .semibold))

                            Text("Blocked")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        Button("Unblock") {
                            // Unblock user
                        }
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(red: 252/255, green: 108/255, blue: 133/255))
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("Blocked Users")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppViewModel())
}
