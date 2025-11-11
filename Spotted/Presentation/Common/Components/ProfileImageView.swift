import SwiftUI
import UIKit

/// Reusable profile image component with beautiful gradient placeholders
struct ProfileImageView: View {
    let user: User
    let size: CGFloat
    let showVerificationBadge: Bool

    init(user: User, size: CGFloat = 120, showVerificationBadge: Bool = true) {
        self.user = user
        self.size = size
        self.showVerificationBadge = showVerificationBadge
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Circle()
                .fill(gradientForUser(user))
                .frame(width: size, height: size)
                .overlay(
                    // User initial or icon
                    Group {
                        if let initial = user.name.first {
                            Text(String(initial).uppercased())
                                .font(.system(size: size * 0.4, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }
                    }
                )
                .overlay(
                    // Subtle pattern overlay
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 2)
                )

            // Verification badge
            if user.isVerified && showVerificationBadge {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: size * 0.25))
                    .foregroundStyle(.blue)
                    .background(
                        Circle()
                            .fill(.white)
                            .frame(width: size * 0.28, height: size * 0.28)
                    )
                    .offset(x: -size * 0.05, y: -size * 0.05)
            }
        }
    }

    private func gradientForUser(_ user: User) -> LinearGradient {
        // Generate consistent gradient based on user ID
        let hash = abs(user.id.hashValue)
        let gradients: [LinearGradient] = [
            LinearGradient(colors: [.pink, .purple], startPoint: .topLeading, endPoint: .bottomTrailing),
            LinearGradient(colors: [.blue, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing),
            LinearGradient(colors: [.orange, .red], startPoint: .topLeading, endPoint: .bottomTrailing),
            LinearGradient(colors: [.green, .mint], startPoint: .topLeading, endPoint: .bottomTrailing),
            LinearGradient(colors: [.purple, .indigo], startPoint: .topLeading, endPoint: .bottomTrailing),
            LinearGradient(colors: [.teal, .blue], startPoint: .topLeading, endPoint: .bottomTrailing),
        ]
        return gradients[hash % gradients.count]
    }
}

/// Photo placeholder for profile galleries
struct PhotoPlaceholderView: View {
    let photoId: String
    let aspectRatio: CGFloat

    init(photoId: String, aspectRatio: CGFloat = 1.0) {
        self.photoId = photoId
        self.aspectRatio = aspectRatio
    }

    var body: some View {
        Group {
            // Check if photoId is a remote URL
            if photoId.hasPrefix("http://") || photoId.hasPrefix("https://") {
                AsyncImage(url: URL(string: photoId)) { phase in
                    switch phase {
                    case .empty:
                        // Loading placeholder
                        ZStack {
                            Rectangle()
                                .fill(gradientForPhoto(photoId))
                            ProgressView()
                                .tint(.white)
                        }
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        // Failed to load - show gradient placeholder
                        ZStack {
                            Rectangle()
                                .fill(gradientForPhoto(photoId))
                            VStack(spacing: 12) {
                                Image(systemName: photoIcon)
                                    .font(.system(size: 60))
                                    .foregroundColor(.white.opacity(0.5))
                                Text("Photo Unavailable")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                        }
                    @unknown default:
                        EmptyView()
                    }
                }
            } else if let uiImage = resolvedImage() {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                // Colorful gradient placeholder
                ZStack {
                    Rectangle()
                        .fill(gradientForPhoto(photoId))

                    VStack(spacing: 12) {
                        Image(systemName: photoIcon)
                            .font(.system(size: 60))
                            .foregroundColor(.white.opacity(0.5))

                        Text("Photo Unavailable")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
            }
        }
        .aspectRatio(aspectRatio, contentMode: .fill)
        .clipped()
    }

    private var photoIcon: String {
        let icons = ["camera.fill", "photo.fill", "person.fill", "heart.fill", "star.fill"]
        let hash = abs(photoId.hashValue)
        return icons[hash % icons.count]
    }

    private func resolvedImage() -> UIImage? {
        // 1. Absolute file path (newly added photos)
        if photoId.hasPrefix("/") {
            return UIImage(contentsOfFile: photoId)
        }

        // 2. File URL string (just in case)
        if let url = URL(string: photoId), url.isFileURL {
            return UIImage(contentsOfFile: url.path)
        }

        // 3. Previously saved temp files where only the identifier was stored
        let tempDir = FileManager.default.temporaryDirectory
        let candidates = [
            tempDir.appendingPathComponent(photoId),
            tempDir.appendingPathComponent("\(photoId).jpg"),
            tempDir.appendingPathComponent("\(photoId).png")
        ]

        for url in candidates {
            if FileManager.default.fileExists(atPath: url.path),
               let image = UIImage(contentsOfFile: url.path) {
                return image
            }
        }

        // 4. Asset catalog fallback
        if let bundled = UIImage(named: photoId) {
            return bundled
        }

        return nil
    }

    private func gradientForPhoto(_ photoId: String) -> LinearGradient {
        let hash = abs(photoId.hashValue)
        let gradients: [LinearGradient] = [
            LinearGradient(colors: [.pink.opacity(0.7), .purple.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing),
            LinearGradient(colors: [.blue.opacity(0.7), .cyan.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing),
            LinearGradient(colors: [.orange.opacity(0.7), .red.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing),
            LinearGradient(colors: [.green.opacity(0.7), .mint.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing),
            LinearGradient(colors: [.purple.opacity(0.7), .indigo.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing),
            LinearGradient(colors: [.teal.opacity(0.7), .blue.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing),
        ]
        return gradients[hash % gradients.count]
    }
}

/// Location image placeholder
struct LocationImageView: View {
    let location: Location
    let height: CGFloat

    init(location: Location, height: CGFloat = 200) {
        self.location = location
        self.height = height
    }

    var body: some View {
        ZStack {
            Rectangle()
                .fill(gradientForLocation(location.type))
                .frame(height: height)

            VStack {
                Image(systemName: location.type.icon)
                    .font(.system(size: 60))
                    .foregroundColor(.white.opacity(0.9))

                Text(location.name)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
    }

    private func gradientForLocation(_ type: LocationType) -> LinearGradient {
        switch type {
        case .trainStation:
            return LinearGradient(colors: [.blue, .indigo], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .airport:
            return LinearGradient(colors: [.cyan, .blue], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .park:
            return LinearGradient(colors: [.green, .teal], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .cafe:
            return LinearGradient(colors: [.orange, .brown], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .bar:
            return LinearGradient(colors: [.purple, .pink], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .gym:
            return LinearGradient(colors: [.red, .orange], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .other:
            return LinearGradient(colors: [.gray, .secondary], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
}

#Preview("Profile Images") {
    VStack(spacing: 20) {
        ProfileImageView(
            user: User(name: "Anna", age: 25, bio: "Test", profilePhoto: "test", isVerified: true),
            size: 120
        )

        ProfileImageView(
            user: User(name: "Marco", age: 28, bio: "Test", profilePhoto: "test", isVerified: false),
            size: 80
        )

        PhotoPlaceholderView(photoId: "photo_1")
            .frame(height: 200)
    }
    .padding()
}
