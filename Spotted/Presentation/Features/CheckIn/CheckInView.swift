import SwiftUI

struct CheckInView: View {
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
            ZStack {
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

                        Divider()
                            .padding(.vertical)

                        // All Locations
                        VStack(spacing: 12) {
                            ForEach(filteredLocations) { location in
                                LocationRow(location: location)
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
                .searchable(text: $searchText, prompt: "Search locations...")
            }
            .navigationTitle("Spotted")
            .sheet(isPresented: $showingCheckInSheet) {
                if let location = selectedLocation {
                    CheckInDetailView(location: location, isPresented: $showingCheckInSheet)
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
                        viewModel.checkOut()
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
        .background(
            LinearGradient(
                colors: [Color.pink.opacity(0.1), Color.purple.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .padding(.horizontal)
    }
}

// MARK: - Hotspot Card
struct HotspotCard: View {
    let location: Location

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: location.type.icon)
                    .font(.title2)
                    .foregroundColor(.pink)
                Spacer()
                Text("\(location.activeUsers)")
                    .font(.headline)
                    .foregroundColor(.pink)
            }

            Text(location.name)
                .font(.headline)
                .lineLimit(2)
                .frame(height: 44, alignment: .topLeading)

            Text(location.type.rawValue)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(width: 180, height: 140)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Location Row
struct LocationRow: View {
    let location: Location

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: location.type.icon)
                .font(.title2)
                .foregroundColor(.pink)
                .frame(width: 40, height: 40)
                .background(Color.pink.opacity(0.1))
                .cornerRadius(10)

            VStack(alignment: .leading, spacing: 4) {
                Text(location.name)
                    .font(.headline)

                Text(location.address)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("\(location.activeUsers)")
                    .font(.headline)
                    .foregroundColor(.pink)

                Text("spotted")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    CheckInView()
        .environmentObject(AppViewModel())
}
