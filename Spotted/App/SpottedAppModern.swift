import SwiftUI

// MARK: - Modern App Entry Point with Dependency Injection
// NOTE: Uncomment @main below to use the modern version instead of the basic version
// Remember to comment out @main in SpottedApp.swift first!

// @main
struct SpottedAppModern: App {
    // Dependency container
    private let repository: DataRepositoryProtocol

    init() {
        // Initialize dependencies
        // In production, this could switch based on environment:
        // - Development: MockDataRepository
        // - Production: APIDataRepository
        self.repository = MockDataRepository()
    }

    var body: some Scene {
        WindowGroup {
            // Create ViewModel with injected dependencies
            let viewModel = AppViewModelModern(repository: repository)

            MainTabViewModern()
                .environmentObject(viewModel)
        }
    }
}

// MARK: - Modern Main Tab View with Error Handling

struct MainTabViewModern: View {
    @EnvironmentObject var viewModel: AppViewModelModern
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            // Check-in / Discovery (Primary)
            CheckInViewModern()
                .tabItem {
                    Label("Spots", systemImage: "mappin.circle.fill")
                }
                .tag(0)

            // Discover people
            DiscoverViewModern()
                .tabItem {
                    Label("Discover", systemImage: "person.2.fill")
                }
                .tag(1)

            // Matches / Messages
            MatchesViewModern()
                .tabItem {
                    Label("Matches", systemImage: "heart.fill")
                }
                .badge(viewModel.conversations.count)
                .tag(2)

            // Profile
            ProfileView(user: viewModel.currentUser, isCurrentUser: true)
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle.fill")
                }
                .tag(3)
        }
        .accentColor(.pink)
        .errorBanner(errorMessage: $viewModel.errorMessage)
    }
}

// MARK: - Modern Check-In View with Loading States

struct CheckInViewModern: View {
    @EnvironmentObject var viewModel: AppViewModelModern
    @State private var selectedLocation: Location?
    @State private var showingCheckInSheet = false
    @State private var searchText = ""

    var filteredLocations: [Location] {
        if searchText.isEmpty {
            return viewModel.locations.sorted { $0.activeUsers > $1.activeUsers }
        }
        return viewModel.locations.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.type.rawValue.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Current Check-in Status
                    if let checkIn = viewModel.currentUser.currentCheckIn {
                        currentCheckInCard(checkIn: checkIn)
                    }

                    // Hotspots Header
                    VStack(alignment: .leading, spacing: 12) {
                        Text("🔥 Hot Spots Right Now")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)

                        Text("Check in and see who's around")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    // Loading or Content
                    if viewModel.isLoadingLocations {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(0..<3, id: \.self) { _ in
                                    LoadingCard(height: 140)
                                        .frame(width: 180)
                                }
                            }
                            .padding(.horizontal)
                        }
                    } else {
                        // Hotspot recommendations
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(viewModel.getHotspotRecommendations()) { location in
                                    HotspotCard(location: location)
                                        .onTapGesture {
                                            selectedLocation = location
                                            showingCheckInSheet = true
                                        }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }

                    Divider()
                        .padding(.vertical)

                    // All Locations
                    VStack(spacing: 12) {
                        if viewModel.isLoadingLocations {
                            ForEach(0..<5, id: \.self) { _ in
                                LoadingListItem()
                            }
                        } else {
                            ForEach(filteredLocations) { location in
                                LocationRow(location: location)
                                    .onTapGesture {
                                        selectedLocation = location
                                        showingCheckInSheet = true
                                    }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .searchable(text: $searchText, prompt: "Search locations...")
            .navigationTitle("Spotted")
            .sheet(isPresented: $showingCheckInSheet) {
                if let location = selectedLocation {
                    CheckInDetailViewModern(location: location, isPresented: $showingCheckInSheet)
                }
            }
        }
    }

    @ViewBuilder
    private func currentCheckInCard(checkIn: CheckIn) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: checkIn.location.type.icon)
                    .font(.title2)
                    .foregroundColor(.pink)

                VStack(alignment: .leading, spacing: 4) {
                    Text("You're checked in at")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text(checkIn.location.name)
                        .font(.headline)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text(checkIn.timeRemaining)
                        .font(.caption)
                        .foregroundColor(.pink)

                    Button(action: {
                        Task {
                            await viewModel.checkOut()
                        }
                    }) {
                        Text("Check Out")
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                }
            }

            // People here now
            let usersHere = viewModel.getUsersAt(location: checkIn.location)
            if !usersHere.isEmpty {
                NavigationLink(destination: LocationDetailView(location: checkIn.location)) {
                    HStack {
                        Text("\(usersHere.count) people spotted here")
                            .font(.subheadline)
                            .foregroundColor(.pink)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.pink)
                    }
                }
            }
        }
        .padding()
        .gradientBackground(colors: [.pink.opacity(0.1), .purple.opacity(0.1)])
        .cornerRadius(16)
        .padding(.horizontal)
    }
}

// MARK: - Modern Check-In Detail with Async Actions

struct CheckInDetailViewModern: View {
    @EnvironmentObject var viewModel: AppViewModelModern
    let location: Location
    @Binding var isPresented: Bool
    @State private var caption = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Location Header
                    VStack(spacing: 12) {
                        Image(systemName: location.type.icon)
                            .font(.system(size: 60))
                            .foregroundColor(.pink)
                            .padding()
                            .background(Color.pink.opacity(0.1))
                            .clipShape(Circle())

                        Text(location.name)
                            .font(.title)
                            .fontWeight(.bold)

                        Text(location.address)
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        HStack {
                            Image(systemName: "person.2.fill")
                                .foregroundColor(.pink)
                            Text("\(location.activeUsers) people spotted here")
                                .font(.headline)
                                .foregroundColor(.pink)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.pink.opacity(0.1))
                        .cornerRadius(20)
                    }
                    .padding()

                    // Caption input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Add a caption (optional)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        TextField("What brings you here?", text: $caption)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    .padding(.horizontal)

                    // Check-in button
                    Button(action: {
                        Task {
                            await viewModel.checkIn(at: location, caption: caption.isEmpty ? nil : caption)
                            isPresented = false
                        }
                    }) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Check In Here")
                                .fontWeight(.semibold)
                        }
                    }
                    .buttonStyle(LegacyPrimaryButtonStyle(isLoading: viewModel.isCheckingIn))
                    .disabled(viewModel.isCheckingIn)
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
        }
    }
}

// MARK: - Modern Discover View with Loading

struct DiscoverViewModern: View {
    @EnvironmentObject var viewModel: AppViewModelModern

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if viewModel.isLoadingUsers {
                        ForEach(0..<3, id: \.self) { _ in
                            LoadingCard(height: 400)
                                .padding(.horizontal)
                        }
                    } else {
                        ForEach(viewModel.allUsers) { user in
                            NavigationLink(destination: UserProfileView(user: user)) {
                                UserDiscoveryCard(user: user)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Discover")
        }
    }
}

// MARK: - Modern Matches View

struct MatchesViewModern: View {
    @EnvironmentObject var viewModel: AppViewModelModern
    @State private var selectedSegment = 0

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("View", selection: $selectedSegment) {
                    Text("Matches").tag(0)
                    Text("Messages").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                if selectedSegment == 0 {
                    matchesView
                } else {
                    messagesView
                }
            }
            .navigationTitle("Connections")
        }
    }

    private var matchesView: some View {
        ScrollView {
            VStack(spacing: 16) {
                if viewModel.matches.isEmpty {
                    emptyMatchesView
                } else {
                    ForEach(viewModel.matches) { match in
                        if let otherUserId = match.users.first(where: { $0 != viewModel.currentUser.id }),
                           let otherUser = viewModel.getUser(by: otherUserId) {
                            MatchCircle(match: match, otherUser: otherUser)
                        }
                    }
                }
            }
            .padding()
        }
    }

    private var messagesView: some View {
        ScrollView {
            VStack(spacing: 0) {
                if viewModel.conversations.isEmpty {
                    emptyMessagesView
                } else {
                    ForEach(viewModel.conversations) { conversation in
                        if let otherUserId = conversation.participants.first(where: { $0 != viewModel.currentUser.id }),
                           let otherUser = viewModel.getUser(by: otherUserId) {
                            NavigationLink(destination: ChatViewModern(conversation: conversation)) {
                                ConversationRow(conversation: conversation, otherUser: otherUser)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
            }
        }
    }

    private var emptyMatchesView: some View {
        VStack(spacing: 16) {
            Image(systemName: "heart.circle")
                .font(.system(size: 60))
                .foregroundColor(.pink)

            Text("No matches yet")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Start liking profiles to make connections!")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .padding(.top, 100)
    }

    private var emptyMessagesView: some View {
        VStack(spacing: 16) {
            Image(systemName: "message.circle")
                .font(.system(size: 60))
                .foregroundColor(.pink)

            Text("No messages yet")
                .font(.title2)
                .fontWeight(.semibold)

            Text("When you match with someone, you can start chatting!")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .padding(.top, 100)
    }
}

// MARK: - Modern Chat View with Async Messaging

struct ChatViewModern: View {
    @EnvironmentObject var viewModel: AppViewModelModern
    let conversation: Conversation
    @State private var messageText = ""

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(conversation.messages) { message in
                        MessageBubble(
                            message: message,
                            isCurrentUser: message.senderId == viewModel.currentUser.id
                        )
                    }
                }
                .padding()
            }

            HStack(spacing: 12) {
                TextField("Message...", text: $messageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Button(action: {
                    Task {
                        await sendMessage()
                    }
                }) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                        .foregroundColor(messageText.isEmpty ? .gray : .pink)
                }
                .disabled(messageText.isEmpty)
            }
            .padding()
            .background(Color(.systemGray6))
        }
        .navigationTitle(conversation.participants.first ?? "Chat")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func sendMessage() async {
        guard !messageText.isEmpty else { return }
        let text = messageText
        messageText = ""
        await viewModel.sendMessage(to: conversation.id, text: text)
    }
}
