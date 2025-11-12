import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            // Check-in / Discovery (Primary) - WITH COOL MAP!
            CheckInViewWithMap()
                .tabItem {
                    Label("Spots", systemImage: "map.fill")
                }
                .tag(0)

            // Discover people
            DiscoverView()
                .tabItem {
                    Label("Discover", systemImage: "person.2.fill")
                }
                .tag(1)

            // Matches / Messages
            MatchesView()
                .tabItem {
                    Label("Matches", systemImage: "heart.fill")
                }
                .badge(viewModel.unreadMessagesCount)
                .tag(2)

            // Profile
            ProfileView(user: viewModel.currentUser, isCurrentUser: true)
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle.fill")
                }
                .tag(3)
        }
        .accentColor(.pink)
        .toastView()
        .offlineBanner()
        .fullScreenCover(isPresented: Binding(
            get: { viewModel.celebratingMatchWithUserId != nil },
            set: { if !$0 { viewModel.celebratingMatchWithUserId = nil } }
        )) {
            if let matchedUserId = viewModel.celebratingMatchWithUserId,
               let matchedUser = viewModel.getUser(by: matchedUserId) {
                MatchCelebrationView(
                    isPresented: Binding(
                        get: { viewModel.celebratingMatchWithUserId != nil },
                        set: { if !$0 { viewModel.celebratingMatchWithUserId = nil } }
                    ),
                    matchedUser: matchedUser
                )
                .environmentObject(viewModel)
            } else {
                // Safety: if no matched user is found, immediately dismiss to avoid blocking touches
                Color.clear
                    .ignoresSafeArea()
                    .onAppear {
                        viewModel.celebratingMatchWithUserId = nil
                    }
            }
        }
    }
}
