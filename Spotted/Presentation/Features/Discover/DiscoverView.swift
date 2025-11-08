import SwiftUI

struct DiscoverView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @StateObject private var locationManager = LocationManager.shared
    @State private var showFilters = false
    @State private var isLoading = true
    @State private var isRefreshing = false
    @State private var searchText = ""
    @FocusState private var isSearchFocused: Bool

    // Filter settings (synced with Settings)
    @AppStorage("maxDistance") private var maxDistance: Double = 50
    @AppStorage("minAge") private var minAge: Double = 18
    @AppStorage("maxAge") private var maxAge: Double = 35
    @AppStorage("useDistanceFilter") private var useDistanceFilter: Bool = true

    // Advanced filters
    @AppStorage("selectedInterests") private var selectedInterestsData: Data = Data()
    @AppStorage("selectedDrinking") private var selectedDrinkingData: Data = Data()
    @AppStorage("selectedSmoking") private var selectedSmokingData: Data = Data()
    @AppStorage("selectedKids") private var selectedKidsData: Data = Data()

    // Helper computed properties for Set<String> conversion
    private var selectedInterests: Set<String> {
        get {
            (try? JSONDecoder().decode(Set<String>.self, from: selectedInterestsData)) ?? []
        }
        set {
            selectedInterestsData = (try? JSONEncoder().encode(newValue)) ?? Data()
        }
    }

    private var selectedDrinking: Set<String> {
        get {
            (try? JSONDecoder().decode(Set<String>.self, from: selectedDrinkingData)) ?? []
        }
        set {
            selectedDrinkingData = (try? JSONEncoder().encode(newValue)) ?? Data()
        }
    }

    private var selectedSmoking: Set<String> {
        get {
            (try? JSONDecoder().decode(Set<String>.self, from: selectedSmokingData)) ?? []
        }
        set {
            selectedSmokingData = (try? JSONEncoder().encode(newValue)) ?? Data()
        }
    }

    private var selectedKids: Set<String> {
        get {
            (try? JSONDecoder().decode(Set<String>.self, from: selectedKidsData)) ?? []
        }
        set {
            selectedKidsData = (try? JSONEncoder().encode(newValue)) ?? Data()
        }
    }

    // Filtered users
    var filteredUsers: [User] {
        viewModel.allUsers.filter { user in
            // Search filter
            var searchMatch = true
            if !searchText.isEmpty {
                let lowercasedSearch = searchText.lowercased()
                searchMatch = user.name.lowercased().contains(lowercasedSearch) ||
                              user.bio.lowercased().contains(lowercasedSearch) ||
                              user.interests.contains { $0.lowercased().contains(lowercasedSearch) } ||
                              user.job?.lowercased().contains(lowercasedSearch) == true ||
                              user.company?.lowercased().contains(lowercasedSearch) == true
            }

            // Age filter
            let ageMatch = user.age >= Int(minAge) && user.age <= Int(maxAge)

            // Distance filter (if enabled and location available)
            var distanceMatch = true
            if useDistanceFilter, let checkIn = user.currentCheckIn {
                if let distance = locationManager.distance(to: checkIn.location.coordinate.clLocationCoordinate) {
                    distanceMatch = distance <= maxDistance
                } else {
                    // If can't calculate distance, include user
                    distanceMatch = true
                }
            }

            // Interests filter
            var interestsMatch = true
            if !selectedInterests.isEmpty {
                // User must have at least one matching interest
                interestsMatch = user.interests.contains { selectedInterests.contains($0) }
            }

            // Drinking filter
            var drinkingMatch = true
            if !selectedDrinking.isEmpty {
                if let userDrinking = user.drinking {
                    drinkingMatch = selectedDrinking.contains(userDrinking)
                } else {
                    drinkingMatch = false
                }
            }

            // Smoking filter
            var smokingMatch = true
            if !selectedSmoking.isEmpty {
                if let userSmoking = user.smoking {
                    smokingMatch = selectedSmoking.contains(userSmoking)
                } else {
                    smokingMatch = false
                }
            }

            // Kids filter
            var kidsMatch = true
            if !selectedKids.isEmpty {
                if let userKids = user.kids {
                    kidsMatch = selectedKids.contains(userKids)
                } else {
                    kidsMatch = false
                }
            }

            return searchMatch && ageMatch && distanceMatch && interestsMatch && drinkingMatch && smokingMatch && kidsMatch
        }
    }

    var spontaneousUsers: [User] {
        filteredUsers.filter { $0.isCurrentlySpontaneous }
    }

    private var loadingView: some View {
        ScrollView {
                        VStack(spacing: 20) {
                            // Featured category skeleton
                            VStack(alignment: .leading, spacing: 16) {
                                LegacySkeletonView(width: 180, height: 28)
                                    .padding(.horizontal)

                                LegacySkeletonView(height: 200, cornerRadius: 16)
                                    .padding(.horizontal)
                            }

                            // Spontaneous users skeleton
                            VStack(alignment: .leading, spacing: 12) {
                                LegacySkeletonView(width: 120, height: 24)
                                    .padding(.horizontal)

                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(0..<3, id: \.self) { _ in
                                            LegacySkeletonView(width: 140, height: 180, cornerRadius: 16)
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }

                            // Activity feed skeleton
                            VStack(spacing: 8) {
                                ForEach(0..<3, id: \.self) { _ in
                                    SkeletonActivityItem()
                                }
                            }

                            // Category grid skeleton
                            LazyVGrid(columns: [
                                GridItem(.flexible(), spacing: 12),
                                GridItem(.flexible(), spacing: 12)
                            ], spacing: 12) {
                                ForEach(0..<4, id: \.self) { _ in
                                    LegacySkeletonView(height: 120, cornerRadius: 16)
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.vertical)
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    loadingView
                } else {
                    // Actual content - Show search results if searching, otherwise show discovery
                    if !searchText.isEmpty {
                        // Search results view
                        searchResultsView
                    } else {
                        // Normal discovery content
                        ScrollView {
                            VStack(spacing: 20) {
                                // 1. Featured Category - BIG CARD FIRST
                                VStack(alignment: .leading, spacing: 16) {
                                    Text("Find Your Vibe")
                                        .font(.system(size: 24, weight: .bold))
                                        .padding(.horizontal)

                                    // Featured category (first one - larger)
                                    if let featuredCategory = DiscoveryCategory.allCases.first {
                                        NavigationLink(destination: CategoryDetailView(category: featuredCategory)) {
                                            FeaturedCategoryBox(category: featuredCategory)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                        .padding(.horizontal)
                                    }
                                }
                            }

                            // 2. Free Now - Spontaneous Users
                            spontaneousUsersSection

                            // 3. Live Activity Feed
                            ActivityFeedView()

                            // 4. Rest of category boxes with staggered animation
                            LazyVGrid(columns: [
                                GridItem(.flexible(), spacing: 12),
                                GridItem(.flexible(), spacing: 12)
                            ], spacing: 12) {
                                ForEach(Array(DiscoveryCategory.allCases.dropFirst().enumerated()), id: \.element.id) { index, category in
                                    NavigationLink(destination: CategoryDetailView(category: category)) {
                                        CategoryBox(category: category)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .slideIn(delay: Double(index) * 0.1)
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.vertical)
                    }
                }
            }
            .refreshable {
                await refreshData()
            }
            .navigationTitle("Discover")
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search people, interests, jobs...")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showFilters = true
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "slider.horizontal.3")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Filters")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundColor(Color(red: 252/255, green: 108/255, blue: 133/255))
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                // Undo button
                if viewModel.lastLikedUserId != nil {
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            viewModel.undoLastLike()
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.uturn.backward")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Undo")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 14)
                        .background(
                            Capsule()
                                .fill(Color(red: 252/255, green: 108/255, blue: 133/255))
                                .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                        )
                    }
                    .padding(.bottom, 10)
                    .frame(maxWidth: .infinity)
                    .background(Color.clear)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                } else {
                    EmptyView()
                }
            }
            .sheet(isPresented: $showFilters) {
                FilterSheetView(
                    maxDistance: $maxDistance,
                    minAge: $minAge,
                    maxAge: $maxAge,
                    selectedInterests: Binding(
                        get: {
                            (try? JSONDecoder().decode(Set<String>.self, from: selectedInterestsData)) ?? []
                        },
                        set: { newValue in
                            selectedInterestsData = (try? JSONEncoder().encode(newValue)) ?? Data()
                        }
                    ),
                    selectedDrinking: Binding(
                        get: {
                            (try? JSONDecoder().decode(Set<String>.self, from: selectedDrinkingData)) ?? []
                        },
                        set: { newValue in
                            selectedDrinkingData = (try? JSONEncoder().encode(newValue)) ?? Data()
                        }
                    ),
                    selectedSmoking: Binding(
                        get: {
                            (try? JSONDecoder().decode(Set<String>.self, from: selectedSmokingData)) ?? []
                        },
                        set: { newValue in
                            selectedSmokingData = (try? JSONEncoder().encode(newValue)) ?? Data()
                        }
                    ),
                    selectedKids: Binding(
                        get: {
                            (try? JSONDecoder().decode(Set<String>.self, from: selectedKidsData)) ?? []
                        },
                        set: { newValue in
                            selectedKidsData = (try? JSONEncoder().encode(newValue)) ?? Data()
                        }
                    )
                )
            }
            .onAppear {
                // Request location permission if needed
                if locationManager.authorizationStatus == .notDetermined {
                    locationManager.requestLocationPermission()
                }

                // Simulate initial loading
                if isLoading {
                    Task {
                        try? await Task.sleep(nanoseconds: 800_000_000) // 0.8 seconds
                        withAnimation {
                            isLoading = false
                        }
                    }
                }
            }
        }
    }

    private func refreshData() async {
        isRefreshing = true
        // Simulate network refresh
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        isRefreshing = false

        // Show success toast
        await MainActor.run {
            ToastManager.shared.showSuccess("Discover refreshed!")
        }
    }

    private var checkInPromptCard: some View {
        VStack(spacing: 12) {
            Image(systemName: "flame.fill")
                .font(.system(size: 50))
                .foregroundColor(.pink)

            Text("Check in to see who's around")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)

            Text("Discover people at cafes, bars, and hangout spots in Zurich")
                .font(.system(size: 15))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .padding(.horizontal, 20)
        .background(Color(.systemGray6))
        .cornerRadius(20)
        .padding(.horizontal)
    }

    private var currentLocationCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let checkIn = viewModel.currentUser.currentCheckIn {
                HStack(spacing: 14) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.pink)

                    VStack(alignment: .leading, spacing: 3) {
                        Text("You're here")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.secondary)

                        Text(checkIn.location.name)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.primary)
                    }

                    Spacer()

                    VStack(spacing: 2) {
                        Text("\(viewModel.getUsersAt(location: checkIn.location).count)")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(.pink)

                        Text("people")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(16)
        .background(Color(.systemGray6))
        .cornerRadius(16)
        .padding(.horizontal)
    }

    // INNOVATIVE: Spontaneous users section
    private var spontaneousUsersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "clock.badge.checkmark.fill")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.orange)

                    Text("Free Now")
                        .font(.system(size: 20, weight: .bold))
                }

                Spacer()

                Text("\(spontaneousUsers.count)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.orange)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(0.15))
                    .cornerRadius(10)
            }
            .padding(.horizontal)

            if !spontaneousUsers.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 16) {
                        ForEach(Array(spontaneousUsers.enumerated()), id: \.element.id) { index, user in
                            SpontaneousUserCard(user: user)
                                .padding(.leading, index == 0 ? 20 : 0)
                                .padding(.trailing, index == spontaneousUsers.count - 1 ? 20 : 0)
                        }
                    }
                    .padding(.vertical, 8)
                }
                .frame(height: 250)
            } else {
                // Empty state
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "clock.badge.xmark")
                            .font(.system(size: 40))
                            .foregroundColor(.gray.opacity(0.5))
                        Text("No one is free right now")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 40)
                    Spacer()
                }
                .padding(.horizontal)
            }
        }
    }

    // Search Results View
    private var searchResultsView: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Search results header
                HStack {
                    Text("Results for \"\(searchText)\"")
                        .font(.system(size: 20, weight: .bold))

                    Spacer()

                    Text("\(filteredUsers.count) people")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                .padding(.top)

                if filteredUsers.isEmpty {
                    // Empty state
                    VStack(spacing: 16) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary.opacity(0.5))
                            .padding(.top, 60)

                        Text("No results found")
                            .font(.system(size: 20, weight: .semibold))

                        Text("Try searching for different names, interests, or jobs")
                            .font(.system(size: 15))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                } else {
                    // Results grid with staggered animation
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 12),
                        GridItem(.flexible(), spacing: 12)
                    ], spacing: 16) {
                        ForEach(Array(filteredUsers.enumerated()), id: \.element.id) { index, user in
                            NavigationLink(destination: UserProfileView(user: user)) {
                                SearchResultCard(user: user)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .slideIn(delay: Double(index) * 0.05)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.bottom)
        }
    }
}

// MARK: - Spontaneous User Card
struct SpontaneousUserCard: View {
    let user: User
    @State private var isPressed = false

    var body: some View {
        NavigationLink(destination: UserProfileView(user: user)) {
            VStack(alignment: .leading, spacing: 10) {
                // User photo with spontaneous badge
                ZStack(alignment: .topLeading) {
                    ProfileImageView(user: user, size: 140)
                        .frame(width: 140, height: 180)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)

                    // Spontaneous badge with pulsing effect
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 8, height: 8)

                        if let activity = user.spontaneousActivity {
                            Text(activity)
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color.orange)
                            .shadow(color: .orange.opacity(0.4), radius: 6, x: 0, y: 2)
                    )
                    .padding(8)
                }

                // User info
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Text(user.name)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.primary)
                            .lineLimit(1)

                        if user.isVerified {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.blue)
                        }
                    }

                    if let until = user.spontaneousUntil {
                        let minutes = Int(until.timeIntervalSinceNow / 60)
                        HStack(spacing: 4) {
                            Image(systemName: "clock.fill")
                                .font(.system(size: 10))
                                .foregroundColor(.orange)
                            Text("Free for \(minutes)m")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.orange)
                        }
                    }
                }
                .frame(width: 140, alignment: .leading)
                .padding(.horizontal, 4)
            }
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color(.systemBackground))
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
        .onLongPressGesture(minimumDuration: 0.0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
            if pressing {
                let impact = UIImpactFeedbackGenerator(style: .light)
                impact.impactOccurred()
            }
        }, perform: {})
    }
}

// MARK: - Featured Category Box (Large)
struct FeaturedCategoryBox: View {
    @EnvironmentObject var viewModel: AppViewModel
    let category: DiscoveryCategory
    @State private var isPressed = false

    var userCount: Int {
        viewModel.allUsers.filter { user in
            user.interests.contains(category.rawValue)
        }.count
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Top section with icon and badge
            ZStack(alignment: .topTrailing) {
                // Background gradient
                LinearGradient(
                    colors: [category.color, category.color.opacity(0.8)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(height: 180)

                // Large icon
                HStack {
                    Image(systemName: category.icon)
                        .font(.system(size: 60, weight: .bold))
                        .foregroundColor(.white.opacity(0.9))
                        .padding(.leading, 24)
                        .padding(.top, 24)

                    Spacer()
                }

                // User count badge
                Text("\(userCount)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.25))
                    .cornerRadius(20)
                    .padding(.trailing, 20)
                    .padding(.top, 20)
            }

            // Bottom section with text
            VStack(alignment: .leading, spacing: 8) {
                Text(category.rawValue)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.primary)

                Text(category.description)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.secondary)

                // "Explore" indicator
                HStack(spacing: 6) {
                    Text("Explore now")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(category.color)

                    Image(systemName: "arrow.right")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(category.color)
                }
                .padding(.top, 4)
            }
            .padding(20)
            .background(Color(.systemBackground))
        }
        .background(Color(.systemBackground))
        .cornerRadius(24)
        .shadow(color: category.color.opacity(0.3), radius: 15, x: 0, y: 8)
        .scaleEffect(isPressed ? 0.96 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
        .onLongPressGesture(minimumDuration: 0.0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
            if pressing {
                let impactMed = UIImpactFeedbackGenerator(style: .medium)
                impactMed.impactOccurred()
            }
        }, perform: {})
    }
}

// MARK: - Category Box
struct CategoryBox: View {
    @EnvironmentObject var viewModel: AppViewModel
    let category: DiscoveryCategory
    @State private var isPressed = false

    var userCount: Int {
        viewModel.allUsers.filter { user in
            user.interests.contains(category.rawValue)
        }.count
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Icon and count
            HStack {
                Image(systemName: category.icon)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)

                Spacer()

                // User count badge
                Text("\(userCount)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.white.opacity(0.3))
                    .cornerRadius(10)
            }

            // Category name
            VStack(alignment: .leading, spacing: 3) {
                Text(category.rawValue)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.white)

                Text(category.description)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
            }
        }
        .padding(16)
        .frame(height: 140)
        .background(
            LinearGradient(
                colors: [category.color, category.color.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(20)
        .shadow(color: category.color.opacity(0.4), radius: 8, x: 0, y: 4)
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
        .onLongPressGesture(minimumDuration: 0.0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
            if pressing {
                let impactLight = UIImpactFeedbackGenerator(style: .light)
                impactLight.impactOccurred()
            }
        }, perform: {})
    }
}

// MARK: - User Discovery Card
struct UserDiscoveryCard: View {
    @EnvironmentObject var viewModel: AppViewModel
    let user: User
    @State private var isHeartAnimating = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Profile image with user info overlay
            ZStack(alignment: .bottomLeading) {
                // Main photo - using the first photo from their gallery
                if let firstPhoto = user.photos.first {
                    PhotoPlaceholderView(photoId: firstPhoto, aspectRatio: 4/5)
                        .frame(height: 450)
                }

                // Gradient overlay for text readability
                LinearGradient(
                    colors: [.clear, .black.opacity(0.9)],
                    startPoint: .center,
                    endPoint: .bottom
                )
                .frame(height: 450)

                // Floating hearts animation overlay
                if isHeartAnimating {
                    ForEach(0..<3, id: \.self) { index in
                        FloatingHeart(delay: Double(index) * 0.2)
                    }
                }

                // User info overlay
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Text(user.displayName)
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)

                        if user.isVerified {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.blue)
                        }
                    }

                    if let ethnicity = user.ethnicity {
                        Text(ethnicity)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))
                    }

                    Text(user.bio)
                        .font(.system(size: 15))
                        .foregroundColor(.white.opacity(0.9))
                        .lineLimit(2)
                        .padding(.top, 2)
                }
                .padding(20)
            }

            // Current location or favorite hangouts
            VStack(alignment: .leading, spacing: 14) {
                if let checkIn = user.currentCheckIn, checkIn.isActive {
                    HStack(spacing: 10) {
                        Image(systemName: "location.fill")
                            .foregroundColor(.pink)
                            .font(.system(size: 16, weight: .semibold))

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Here now")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.secondary)

                            Text(checkIn.location.name)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.primary)
                        }

                        Spacer()

                        Text(checkIn.timeRemaining)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    .padding(.bottom, 6)
                } else if !user.favoriteHangouts.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Hangs out at")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.secondary)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(user.favoriteHangouts.prefix(3)) { location in
                                    HStack(spacing: 5) {
                                        Image(systemName: location.type.icon)
                                            .font(.system(size: 11, weight: .medium))
                                        Text(location.name)
                                            .font(.system(size: 13, weight: .medium))
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 7)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(14)
                                }
                            }
                        }
                    }
                    .padding(.bottom, 6)
                }

                // Like button
                HStack(spacing: 20) {
                    Button(action: {
                        // Pass action
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 60, height: 60)
                                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)

                            Image(systemName: "xmark")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(Color(red: 252/255, green: 108/255, blue: 133/255))
                        }
                    }

                    Spacer()

                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            isHeartAnimating = true
                        }
                        viewModel.likeUser(user)

                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            isHeartAnimating = false
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color(red: 252/255, green: 108/255, blue: 133/255))
                                .frame(width: 70, height: 70)
                                .shadow(color: Color(red: 252/255, green: 108/255, blue: 133/255).opacity(0.4), radius: 10, x: 0, y: 4)

                            Image(systemName: "heart.fill")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }

                    Spacer()

                    Button(action: {
                        // Super like action
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 60, height: 60)
                                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)

                            Image(systemName: "star.fill")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(Color(red: 29/255, green: 161/255, blue: 242/255))
                        }
                    }
                }
                .padding(.vertical, 10)
            }
            .padding(20)
        }
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

// MARK: - Floating Heart Animation
struct FloatingHeart: View {
    let delay: Double
    @State private var offset: CGFloat = 0
    @State private var opacity: Double = 0

    var body: some View {
        Image(systemName: "heart.fill")
            .font(.system(size: CGFloat.random(in: 20...40)))
            .foregroundColor(.pink)
            .opacity(opacity)
            .offset(x: CGFloat.random(in: -50...50), y: offset)
            .onAppear {
                withAnimation(
                    Animation.easeOut(duration: 1.5)
                        .delay(delay)
                ) {
                    offset = -400
                    opacity = 1
                }

                withAnimation(
                    Animation.easeIn(duration: 0.5)
                        .delay(delay + 1)
                ) {
                    opacity = 0
                }
            }
    }
}

// MARK: - Filter Sheet
struct FilterSheetView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var maxDistance: Double
    @Binding var minAge: Double
    @Binding var maxAge: Double
    @Binding var selectedInterests: Set<String>
    @Binding var selectedDrinking: Set<String>
    @Binding var selectedSmoking: Set<String>
    @Binding var selectedKids: Set<String>

    let allInterests = ["Short-term Fun", "Long-term Partner", "Gamers", "Creatives", "Foodies", "Travel Buddies", "Binge Watchers", "Sports", "Music Lovers", "Spiritual"]
    let drinkingOptions = ["Socially", "Never", "Frequently", "Sober"]
    let smokingOptions = ["No", "Socially", "Yes", "Trying to quit"]
    let kidsOptions = ["Don't have kids", "Have kids", "Want kids", "Don't want kids", "Open to kids"]

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Maximum Distance")
                                .font(.system(size: 16, weight: .medium))

                            Spacer()

                            Text("\(Int(maxDistance)) km")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(Color(red: 252/255, green: 108/255, blue: 133/255))
                        }

                        Slider(value: $maxDistance, in: 1...100, step: 1)
                            .tint(Color(red: 252/255, green: 108/255, blue: 133/255))

                        Text("Only show people within this distance")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 8)
                } header: {
                    Text("Distance")
                }

                Section {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Age Range")
                                .font(.system(size: 16, weight: .medium))

                            Spacer()

                            Text("\(Int(minAge)) - \(Int(maxAge))")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(Color(red: 252/255, green: 108/255, blue: 133/255))
                        }

                        VStack(alignment: .leading, spacing: 12) {
                            Text("Minimum Age: \(Int(minAge))")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)

                            Slider(value: $minAge, in: 18...max(18, maxAge - 1), step: 1)
                                .tint(Color(red: 252/255, green: 108/255, blue: 133/255))
                        }

                        VStack(alignment: .leading, spacing: 12) {
                            Text("Maximum Age: \(Int(maxAge))")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)

                            Slider(value: $maxAge, in: min(minAge + 1, 99)...99, step: 1)
                                .tint(Color(red: 252/255, green: 108/255, blue: 133/255))
                        }

                        Text("Only show people within this age range")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 8)
                } header: {
                    Text("Age Range")
                }

                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        if selectedInterests.isEmpty {
                            Text("Select interests to match with")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        } else {
                            Text("\(selectedInterests.count) selected")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color(red: 252/255, green: 108/255, blue: 133/255))
                        }

                        LegacyFlowLayout(spacing: 8) {
                            ForEach(allInterests, id: \.self) { interest in
                                InterestChip(
                                    text: interest,
                                    isSelected: selectedInterests.contains(interest)
                                ) {
                                    if selectedInterests.contains(interest) {
                                        selectedInterests.remove(interest)
                                    } else {
                                        selectedInterests.insert(interest)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.vertical, 8)
                } header: {
                    Text("Interests")
                } footer: {
                    Text("Show people with at least one matching interest")
                }

                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        if selectedDrinking.isEmpty {
                            Text("Any preference")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        } else {
                            Text("\(selectedDrinking.count) selected")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color(red: 252/255, green: 108/255, blue: 133/255))
                        }

                        LegacyFlowLayout(spacing: 8) {
                            ForEach(drinkingOptions, id: \.self) { option in
                                InterestChip(
                                    text: option,
                                    isSelected: selectedDrinking.contains(option)
                                ) {
                                    if selectedDrinking.contains(option) {
                                        selectedDrinking.remove(option)
                                    } else {
                                        selectedDrinking.insert(option)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.vertical, 8)
                } header: {
                    Text("Drinking")
                }

                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        if selectedSmoking.isEmpty {
                            Text("Any preference")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        } else {
                            Text("\(selectedSmoking.count) selected")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color(red: 252/255, green: 108/255, blue: 133/255))
                        }

                        LegacyFlowLayout(spacing: 8) {
                            ForEach(smokingOptions, id: \.self) { option in
                                InterestChip(
                                    text: option,
                                    isSelected: selectedSmoking.contains(option)
                                ) {
                                    if selectedSmoking.contains(option) {
                                        selectedSmoking.remove(option)
                                    } else {
                                        selectedSmoking.insert(option)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.vertical, 8)
                } header: {
                    Text("Smoking")
                }

                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        if selectedKids.isEmpty {
                            Text("Any preference")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        } else {
                            Text("\(selectedKids.count) selected")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color(red: 252/255, green: 108/255, blue: 133/255))
                        }

                        LegacyFlowLayout(spacing: 8) {
                            ForEach(kidsOptions, id: \.self) { option in
                                InterestChip(
                                    text: option,
                                    isSelected: selectedKids.contains(option)
                                ) {
                                    if selectedKids.contains(option) {
                                        selectedKids.remove(option)
                                    } else {
                                        selectedKids.insert(option)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.vertical, 8)
                } header: {
                    Text("Kids")
                }

                Section {
                    Button {
                        selectedInterests.removeAll()
                        selectedDrinking.removeAll()
                        selectedSmoking.removeAll()
                        selectedKids.removeAll()
                    } label: {
                        HStack {
                            Spacer()
                            Text("Clear All Filters")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color(red: 252/255, green: 108/255, blue: 133/255))
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.bold)
                    .foregroundColor(Color(red: 252/255, green: 108/255, blue: 133/255))
                }
            }
        }
    }
}

// Interest chip for multi-select
struct InterestChip: View {
    let text: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.system(size: 14, weight: .medium))
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    isSelected
                        ? Color(red: 252/255, green: 108/255, blue: 133/255)
                        : Color(UIColor.systemGray6)
                )
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Flow layout for wrapping chips (Legacy - use DesignSystem Badges/FlowLayout instead)
struct LegacyFlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.frames[index].minX,
                                     y: bounds.minY + result.frames[index].minY),
                         proposal: .unspecified)
        }
    }

    struct FlowResult {
        var size: CGSize
        var frames: [CGRect]

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var frames: [CGRect] = []
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if currentX + size.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }

                frames.append(CGRect(x: currentX, y: currentY, width: size.width, height: size.height))
                lineHeight = max(lineHeight, size.height)
                currentX += size.width + spacing
            }

            self.frames = frames
            self.size = CGSize(width: maxWidth, height: currentY + lineHeight)
        }
    }
}

// MARK: - Search Result Card
struct SearchResultCard: View {
    let user: User

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Profile image
            ProfileImageView(user: user, size: 180)
                .frame(height: 220)
                .clipped()

            // User info
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
                    Text(user.name)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.primary)
                        .lineLimit(1)

                    if user.isVerified {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.blue)
                    }
                }

                Text("\(user.age)")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)

                // Interests preview
                if !user.interests.isEmpty {
                    HStack(spacing: 4) {
                        ForEach(user.interests.prefix(2), id: \.self) { interest in
                            Text(interest)
                                .font(.system(size: 11, weight: .medium))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color(red: 252/255, green: 108/255, blue: 133/255).opacity(0.15))
                                .foregroundColor(Color(red: 252/255, green: 108/255, blue: 133/255))
                                .cornerRadius(8)
                        }
                    }
                    .padding(.top, 4)
                }
            }
            .padding(12)
        }
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        .pressableScale()
    }
}

#Preview {
    DiscoverView()
        .environmentObject(AppViewModel())
}
