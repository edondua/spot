import SwiftUI

struct CategoryDetailView: View {
    @EnvironmentObject var viewModel: AppViewModel
    let category: DiscoveryCategory
    @State private var currentIndex = 0
    @State private var offset = CGSize.zero
    @State private var rotation: Double = 0

    var categoryUsers: [User] {
        let filtered = viewModel.allUsers.filter { user in
            user.interests.contains(category.rawValue)
        }
        print("CategoryDetailView: Found \(filtered.count) users for category '\(category.rawValue)' out of \(viewModel.allUsers.count) total users")
        return filtered
    }

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [category.color.opacity(0.1), Color(.systemBackground)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                categoryHeader

                if categoryUsers.isEmpty {
                    emptyState
                } else if currentIndex < categoryUsers.count {
                    // Tinder-style card stack
                    ZStack {
                        // Show next 2 cards in background
                        ForEach(Array(categoryUsers.enumerated().reversed()), id: \.element.id) { index, user in
                            if index >= currentIndex && index < currentIndex + 3 {
                                SwipeableCard(
                                    user: user,
                                    category: category,
                                    onRemove: { direction in
                                        handleSwipe(direction: direction)
                                    }
                                )
                                .zIndex(Double(categoryUsers.count - index))
                                .offset(x: 0, y: CGFloat((index - currentIndex) * 10))
                                .scaleEffect(1.0 - CGFloat(index - currentIndex) * 0.05)
                                .opacity(index == currentIndex ? 1.0 : 0.8)
                                .allowsHitTesting(index == currentIndex)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)

                    Spacer()

                    // Action buttons
                    actionButtons
                } else {
                    allDoneState
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    private var categoryHeader: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: category.icon)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(category.color)

                Text(category.rawValue)
                    .font(.system(size: 22, weight: .bold))

                Spacer()

                // Remaining count
                Text("\(max(0, categoryUsers.count - currentIndex))")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(category.color)
                    .cornerRadius(20)
            }

            Text(category.description)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(Color(.systemBackground))
    }

    private var actionButtons: some View {
        HStack(spacing: 20) {
            // Pass button
            Button(action: {
                handleSwipe(direction: .left)
            }) {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 60, height: 60)
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)

                    Image(systemName: "xmark")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.red)
                }
            }

            Spacer()

            // Super like button
            Button(action: {
                handleSwipe(direction: .up)
            }) {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 60, height: 60)
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)

                    Image(systemName: "star.fill")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.blue)
                }
            }

            Spacer()

            // Like button
            Button(action: {
                handleSwipe(direction: .right)
            }) {
                ZStack {
                    Circle()
                        .fill(category.color)
                        .frame(width: 70, height: 70)
                        .shadow(color: category.color.opacity(0.4), radius: 10, x: 0, y: 4)

                    Image(systemName: "heart.fill")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                }
            }
        }
        .padding(.horizontal, 40)
        .padding(.bottom, 30)
    }

    private var emptyState: some View {
        VStack(spacing: 18) {
            Image(systemName: category.icon)
                .font(.system(size: 70))
                .foregroundColor(category.color)

            Text("No one here yet")
                .font(.system(size: 28, weight: .bold))

            Text("Check back later to find people in this category")
                .font(.system(size: 16))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxHeight: .infinity)
    }

    private var allDoneState: some View {
        VStack(spacing: 18) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 70))
                .foregroundColor(category.color)

            Text("That's Everyone!")
                .font(.system(size: 28, weight: .bold))

            Text("You've seen all \(category.rawValue.lowercased()) in your area")
                .font(.system(size: 16))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxHeight: .infinity)
    }

    private func handleSwipe(direction: SwipeDirection) {
        guard currentIndex < categoryUsers.count else { return }

        let user = categoryUsers[currentIndex]

        switch direction {
        case .right:
            // Like
            viewModel.likeUser(user)
        case .left:
            // Pass
            break
        case .up:
            // Super like
            viewModel.likeUser(user)
        }

        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            currentIndex += 1
        }
    }
}

// MARK: - Swipeable Card
struct SwipeableCard: View {
    @EnvironmentObject var viewModel: AppViewModel
    let user: User
    let category: DiscoveryCategory
    let onRemove: (SwipeDirection) -> Void

    @State private var offset = CGSize.zero
    @State private var rotation: Double = 0
    @State private var currentPhotoIndex = 0

    var body: some View {
        ZStack(alignment: .topLeading) {
            // Main card content - full scrollable profile
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    // Photo carousel
                    ZStack(alignment: .bottom) {
                        TabView(selection: $currentPhotoIndex) {
                            ForEach(Array(user.photos.enumerated()), id: \.offset) { index, photo in
                                PhotoPlaceholderView(photoId: photo, aspectRatio: 3/4)
                                    .frame(height: 520)
                                    .tag(index)
                            }
                        }
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                        .frame(height: 520)

                        // Photo indicator dots
                        HStack(spacing: 6) {
                            ForEach(0..<user.photos.count, id: \.self) { index in
                                Circle()
                                    .fill(index == currentPhotoIndex ? Color.white : Color.white.opacity(0.5))
                                    .frame(width: 8, height: 8)
                            }
                        }
                        .padding(.bottom, 12)

                        // Gradient overlay at bottom
                        LinearGradient(
                            colors: [.clear, .black.opacity(0.5)],
                            startPoint: .center,
                            endPoint: .bottom
                        )
                        .frame(height: 150)
                        .allowsHitTesting(false)
                    }

                    // Full profile details section
                    VStack(alignment: .leading, spacing: 20) {
                        // Name and verification
                        HStack(spacing: 8) {
                            Text(user.displayName)
                                .font(.system(size: 28, weight: .bold))

                            if user.isVerified {
                                Image(systemName: "checkmark.seal.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.blue)
                            }

                            Spacer()
                        }

                        // Ethnicity
                        if let ethnicity = user.ethnicity {
                            HStack(spacing: 8) {
                                Image(systemName: "person.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                                Text(ethnicity)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.primary)
                            }
                        }

                        Divider()

                        // Bio section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("About")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.primary)

                            Text(user.bio)
                                .font(.system(size: 16))
                                .foregroundColor(.primary)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        Divider()

                        // Interests section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Interests")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.primary)

                            LazyVGrid(columns: [
                                GridItem(.adaptive(minimum: 100), spacing: 8)
                            ], spacing: 8) {
                                ForEach(user.interests, id: \.self) { interest in
                                    if let category = DiscoveryCategory.allCases.first(where: { $0.rawValue == interest }) {
                                        HStack(spacing: 6) {
                                            Image(systemName: category.icon)
                                                .font(.system(size: 12, weight: .bold))
                                            Text(category.rawValue)
                                                .font(.system(size: 14, weight: .semibold))
                                        }
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 8)
                                        .background(category.color)
                                        .cornerRadius(20)
                                    }
                                }
                            }
                        }

                        Divider()

                        // Current location
                        if let checkIn = user.currentCheckIn, checkIn.isActive {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Right Now")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.primary)

                                HStack(spacing: 12) {
                                    Image(systemName: "location.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(category.color)

                                    VStack(alignment: .leading, spacing: 3) {
                                        Text("Here now")
                                            .font(.system(size: 13, weight: .semibold))
                                            .foregroundColor(.secondary)

                                        Text(checkIn.location.name)
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(.primary)
                                    }

                                    Spacer()

                                    Text(checkIn.timeRemaining)
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(.secondary)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(Color(.systemGray6))
                                        .cornerRadius(12)
                                }
                            }

                            Divider()
                        }

                        // Favorite hangouts
                        if !user.favoriteHangouts.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Favorite Hangouts")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.primary)

                                VStack(spacing: 10) {
                                    ForEach(user.favoriteHangouts) { location in
                                        HStack(spacing: 12) {
                                            Image(systemName: location.type.icon)
                                                .font(.system(size: 18))
                                                .foregroundColor(category.color)
                                                .frame(width: 40, height: 40)
                                                .background(category.color.opacity(0.1))
                                                .cornerRadius(10)

                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(location.name)
                                                    .font(.system(size: 15, weight: .semibold))
                                                    .foregroundColor(.primary)

                                                Text(location.type.rawValue)
                                                    .font(.system(size: 13))
                                                    .foregroundColor(.secondary)
                                            }

                                            Spacer()
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(20)
                }
            }
            .background(Color(.systemBackground))
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.15), radius: 15, x: 0, y: 10)

            // Swipe indicators
            if offset.width > 50 {
                likeIndicator
            } else if offset.width < -50 {
                passIndicator
            }
        }
        .offset(x: offset.width, y: offset.height)
        .rotationEffect(.degrees(rotation))
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    offset = gesture.translation
                    rotation = Double(gesture.translation.width / 20)
                }
                .onEnded { gesture in
                    if abs(gesture.translation.width) > 150 {
                        // Swipe completed
                        let direction: SwipeDirection = gesture.translation.width > 0 ? .right : .left
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            offset = CGSize(
                                width: gesture.translation.width > 0 ? 500 : -500,
                                height: gesture.translation.height
                            )
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            onRemove(direction)
                            offset = .zero
                            rotation = 0
                        }
                    } else {
                        // Return to center
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            offset = .zero
                            rotation = 0
                        }
                    }
                }
        )
    }

    private var likeIndicator: some View {
        Text("LIKE")
            .font(.system(size: 40, weight: .black))
            .foregroundColor(category.color)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(category.color, lineWidth: 5)
            )
            .rotationEffect(.degrees(-25))
            .padding(40)
    }

    private var passIndicator: some View {
        HStack {
            Spacer()
            Text("NOPE")
                .font(.system(size: 40, weight: .black))
                .foregroundColor(.red)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.red, lineWidth: 5)
                )
                .rotationEffect(.degrees(25))
                .padding(40)
        }
    }
}

enum SwipeDirection {
    case left, right, up
}

#Preview {
    NavigationStack {
        CategoryDetailView(category: .gamers)
            .environmentObject(AppViewModel())
    }
}
