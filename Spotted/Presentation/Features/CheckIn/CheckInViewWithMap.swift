import SwiftUI
import MapKit

// MARK: - Modern Check-In View with Snapchat-Style Map

struct CheckInViewWithMap: View {
    @EnvironmentObject var viewModel: AppViewModel
    @State private var showMapView = true
    @State private var showListView = false

    var body: some View {
        ZStack {
            if showMapView {
                // Snapchat-style map view (primary)
                SpottedMapView()
                    .transition(.opacity)
            } else {
                // List view (alternative)
                CheckInListView()
                    .transition(.move(edge: .trailing))
            }

            // Toggle button (top right)
            VStack {
                HStack {
                    Spacer()
                    toggleViewButton
                        .padding(.trailing)
                        .padding(.top, 60)
                }
                Spacer()
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showMapView)
    }

    private var toggleViewButton: some View {
        Button(action: {
            showMapView.toggle()
        }) {
            Image(systemName: showMapView ? "list.bullet" : "map.fill")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(Color.black.opacity(0.5))
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
        }
    }
}

// MARK: - List View (Alternative to Map)

struct CheckInListView: View {
    @EnvironmentObject var viewModel: AppViewModel
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

                    // Hotspots Header with Snapchat style
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("🔥")
                                .font(.system(size: 32))
                            Text("HOT SPOTS")
                                .font(.system(size: 28, weight: .black, design: .rounded))
                                .foregroundColor(.primary)
                        }
                        .padding(.horizontal)

                        Text("Check in and see who's vibing")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    // Top hotspots with heat indicators
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(viewModel.getHotspotRecommendations()) { location in
                                SnapchatHotspotCard(location: location)
                                    .onTapGesture {
                                        selectedLocation = location
                                        showingCheckInSheet = true
                                    }
                            }
                        }
                        .padding(.horizontal)
                    }

                    Divider()
                        .padding(.vertical)

                    // All Locations with activity levels
                    VStack(spacing: 12) {
                        ForEach(filteredLocations) { location in
                            SnapchatLocationRow(location: location)
                                .onTapGesture {
                                    selectedLocation = location
                                    showingCheckInSheet = true
                                }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .searchable(text: $searchText, prompt: "Search spots...")
            .navigationTitle("Spotted")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showingCheckInSheet) {
            if let location = selectedLocation {
                CheckInDetailView(location: location, isPresented: $showingCheckInSheet)
            }
        }
    }

    @ViewBuilder
    private func currentCheckInCard(checkIn: CheckIn) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: checkIn.location.type.icon)
                    .font(.title2)
                    .foregroundColor(.yellow)

                VStack(alignment: .leading, spacing: 4) {
                    Text("YOU'RE CHECKED IN")
                        .font(.system(size: 12, weight: .black, design: .rounded))
                        .foregroundColor(.yellow)

                    Text(checkIn.location.name)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text(checkIn.timeRemaining)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.yellow)

                    Button(action: {
                        viewModel.checkOut()
                    }) {
                        Text("Leave")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.black)
                            .cornerRadius(12)
                    }
                }
            }

            // People here now
            let usersHere = viewModel.getUsersAt(location: checkIn.location)
            if !usersHere.isEmpty {
                NavigationLink(destination: LocationDetailView(location: checkIn.location)) {
                    HStack {
                        Text("\(usersHere.count) people spotted here")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.yellow)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.yellow)
                    }
                }
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [.black.opacity(0.8), .black.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.yellow, lineWidth: 2)
        )
        .padding(.horizontal)
        .shadow(color: .yellow.opacity(0.3), radius: 10, x: 0, y: 5)
    }
}

// MARK: - Snapchat-Style Hotspot Card

struct SnapchatHotspotCard: View {
    let location: Location
    @State private var isPulsing = false

    var heatColor: Color {
        if location.activeUsers > 20 {
            return .red
        } else if location.activeUsers > 10 {
            return .orange
        } else if location.activeUsers > 5 {
            return .yellow
        } else {
            return .green
        }
    }

    var heatEmoji: String {
        if location.activeUsers > 20 {
            return "🔥🔥🔥"
        } else if location.activeUsers > 10 {
            return "🔥🔥"
        } else if location.activeUsers > 5 {
            return "🔥"
        } else {
            return "✨"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // Icon with heat indicator
                ZStack {
                    Circle()
                        .fill(heatColor.opacity(0.2))
                        .frame(width: 60, height: 60)

                    Image(systemName: location.type.icon)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(heatColor)
                }
                .scaleEffect(isPulsing ? 1.05 : 1.0)

                Spacer()

                // Activity count with emoji
                VStack(spacing: 2) {
                    Text(heatEmoji)
                        .font(.system(size: 20))

                    Text("\(location.activeUsers)")
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .foregroundColor(heatColor)
                }
            }

            Text(location.name)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .lineLimit(2)
                .frame(height: 44, alignment: .topLeading)

            HStack {
                Text(location.type.rawValue)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(.secondary)

                Spacer()

                Text("SPOTTED")
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .foregroundColor(heatColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(heatColor.opacity(0.2))
                    .cornerRadius(8)
            }
        }
        .padding()
        .frame(width: 200, height: 180)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(heatColor.opacity(0.5), lineWidth: 2)
        )
        .shadow(color: heatColor.opacity(0.3), radius: 10, x: 0, y: 5)
        .onAppear {
            if location.activeUsers > 10 {
                withAnimation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                    isPulsing = true
                }
            }
        }
    }
}

// MARK: - Snapchat-Style Location Row

struct SnapchatLocationRow: View {
    let location: Location

    var heatColor: Color {
        if location.activeUsers > 20 {
            return .red
        } else if location.activeUsers > 10 {
            return .orange
        } else if location.activeUsers > 5 {
            return .yellow
        } else {
            return .green
        }
    }

    var heatLevel: String {
        if location.activeUsers > 20 {
            return "🔥 SUPER HOT"
        } else if location.activeUsers > 10 {
            return "🔥 HOT"
        } else if location.activeUsers > 5 {
            return "✨ WARM"
        } else {
            return "🌟 CHILL"
        }
    }

    var body: some View {
        HStack(spacing: 16) {
            // Icon with heat background
            ZStack {
                Circle()
                    .fill(heatColor.opacity(0.2))
                    .frame(width: 60, height: 60)

                Image(systemName: location.type.icon)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(heatColor)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(location.name)
                    .font(.system(size: 18, weight: .bold, design: .rounded))

                Text(location.address)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)
                    .lineLimit(1)

                // Heat level indicator
                Text(heatLevel)
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .foregroundColor(heatColor)
            }

            Spacer()

            // Activity count
            VStack(spacing: 4) {
                Text("\(location.activeUsers)")
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .foregroundColor(heatColor)

                Text("spotted")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(heatColor.opacity(0.3), lineWidth: 2)
        )
    }
}

#Preview {
    CheckInViewWithMap()
        .environmentObject(AppViewModel())
}
