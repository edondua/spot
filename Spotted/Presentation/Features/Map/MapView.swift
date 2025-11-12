import SwiftUI
import MapKit

// MARK: - Enhanced Map View with Heat Maps and Moments

struct SpottedMapView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @StateObject private var locationManager = LocationManager.shared
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 47.3769, longitude: 8.5417), // Default to Zurich
        span: MKCoordinateSpan(latitudeDelta: 0.0167, longitudeDelta: 0.0167)
    )
    @State private var mapCameraPosition: MapCameraPosition = .automatic
    @State private var selectedLocation: Location?
    @State private var showLocationDetail = false
    @State private var showQuickCheckIn = false
    @State private var selectedCheckIn: (user: User, checkIn: CheckIn)?
    @State private var showCheckInDetail = false
    @State private var tappedCoordinate: CLLocationCoordinate2D?
    @State private var hasInitializedLocation = false
    @State private var showFilters = false
    @State private var showCameraCheckIn = false
    @State private var longPressTappedCoordinate: CLLocationCoordinate2D?

    var isZoomedIn: Bool {
        // Show profile images when zoomed in closer than 0.01
        region.span.latitudeDelta < 0.01
    }

    var body: some View {
        mainContent
    }

    private var mainContent: some View {
        let content = GeometryReader { mainGeometry in
            ZStack {
                // Pure map layer (no annotations) - desaturated to grey - FULLY INTERACTIVE
                Map(position: $mapCameraPosition) {
                }
                .mapStyle(.standard)
                .saturation(0)
                .brightness(-0.1)
                .edgesIgnoringSafeArea(.all)
                .onMapCameraChange { context in
                    region = context.region
                }

                // Distributed heat map layer (ambient across entire map)
                GeometryReader { geometry in
                // Main heat zones at locations (active ones)
                ForEach(viewModel.locations.filter { $0.activeUsers > 0 }) { location in
                    // Primary heat zone
                    AnimatedHeatZone(
                        location: location,
                        mapRegion: $region,
                        geometrySize: geometry.size,
                        offsetX: 0,
                        offsetY: 0,
                        isMain: true
                    )
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedLocation = location
                            showLocationDetail = true
                        }
                    }
                    .onLongPressGesture(minimumDuration: 0.5) {
                        let impact = UIImpactFeedbackGenerator(style: .medium)
                        impact.impactOccurred()
                        selectedLocation = location
                        showQuickCheckIn = true
                    }

                    // Secondary ambient zones around busy spots
                    if location.activeUsers > 5 {
                        AnimatedHeatZone(
                            location: location,
                            mapRegion: $region,
                            geometrySize: geometry.size,
                            offsetX: 40,
                            offsetY: -30,
                            isMain: false
                        )
                        AnimatedHeatZone(
                            location: location,
                            mapRegion: $region,
                            geometrySize: geometry.size,
                            offsetX: -35,
                            offsetY: 40,
                            isMain: false
                        )
                    }

                    // Extra ambient zones for very hot spots
                    if location.activeUsers > 15 {
                        AnimatedHeatZone(
                            location: location,
                            mapRegion: $region,
                            geometrySize: geometry.size,
                            offsetX: 60,
                            offsetY: 50,
                            isMain: false
                        )
                        AnimatedHeatZone(
                            location: location,
                            mapRegion: $region,
                            geometrySize: geometry.size,
                            offsetX: -50,
                            offsetY: -45,
                            isMain: false
                        )
                        AnimatedHeatZone(
                            location: location,
                            mapRegion: $region,
                            geometrySize: geometry.size,
                            offsetX: 0,
                            offsetY: 70,
                            isMain: false
                        )
                    }
                }
            }
            .allowsHitTesting(false)

            // Current user's check-in marker (always visible)
            GeometryReader { geometry in
                if let currentCheckIn = viewModel.currentUser.currentCheckIn,
                   currentCheckIn.isActive {
                    if currentCheckIn.imageUrl != nil {
                        // Current user with photo check-in
                        CheckInPhotoMarker(
                            user: viewModel.currentUser,
                            checkIn: currentCheckIn,
                            location: currentCheckIn.location,
                            mapRegion: $region,
                            geometrySize: geometry.size,
                            isCurrentUser: true
                        )
                        .zIndex(100) // Ensure it's always on top
                        .onTapGesture {
                            let impact = UIImpactFeedbackGenerator(style: .light)
                            impact.impactOccurred()
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedCheckIn = (viewModel.currentUser, currentCheckIn)
                                showCheckInDetail = true
                            }
                        }
                    } else {
                        // Current user without photo
                        ProfileMarker(
                            user: viewModel.currentUser,
                            location: currentCheckIn.location,
                            mapRegion: $region,
                            geometrySize: geometry.size
                        )
                        .zIndex(100) // Ensure it's always on top
                        .onTapGesture {
                            let impact = UIImpactFeedbackGenerator(style: .light)
                            impact.impactOccurred()
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedLocation = currentCheckIn.location
                                showLocationDetail = true
                            }
                        }
                    }
                }
            }
            .zIndex(100) // Ensure entire layer is on top

            // Other users' check-in photos and profile markers overlay (when zoomed in)
            GeometryReader { geometry in
                if isZoomedIn {
                    ForEach(viewModel.locations.filter { $0.activeUsers > 0 }) { location in
                        let usersHere = viewModel.getUsersAt(location: location).filter { $0.id != viewModel.currentUser.id }
                        ForEach(usersHere.prefix(5)) { user in
                            // Show check-in photo marker if user has a check-in with photo
                            if let checkIn = user.currentCheckIn,
                               checkIn.imageUrl != nil,
                               checkIn.location.id == location.id {
                                CheckInPhotoMarker(
                                    user: user,
                                    checkIn: checkIn,
                                    location: location,
                                    mapRegion: $region,
                                    geometrySize: geometry.size
                                )
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        selectedCheckIn = (user, checkIn)
                                        showCheckInDetail = true
                                    }
                                }
                            } else {
                                // Regular profile marker for users without check-in photos
                                ProfileMarker(
                                    user: user,
                                    location: location,
                                    mapRegion: $region,
                                    geometrySize: geometry.size
                                )
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        selectedLocation = location
                                        showLocationDetail = true
                                    }
                                }
                                .onLongPressGesture(minimumDuration: 0.5) {
                                    let impact = UIImpactFeedbackGenerator(style: .medium)
                                    impact.impactOccurred()
                                    selectedLocation = location
                                    showQuickCheckIn = true
                                }
                            }
                        }
                    }

                    // Inactive locations (no one checked in)
                    ForEach(viewModel.locations.filter { $0.activeUsers == 0 }) { location in
                        InactiveLocationMarker(
                            location: location,
                            mapRegion: $region,
                            geometrySize: geometry.size
                        )
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedLocation = location
                                showLocationDetail = true
                            }
                        }
                        .onLongPressGesture(minimumDuration: 0.5) {
                            let impact = UIImpactFeedbackGenerator(style: .medium)
                            impact.impactOccurred()
                            selectedLocation = location
                            showQuickCheckIn = true
                        }
                    }
                }
            }

            // Top bar
            VStack {
                tinderStyleHeader
                Spacer()
            }

            // Bottom card when location selected
            if showLocationDetail, let location = selectedLocation {
                VStack {
                    Spacer()
                    LocationBottomCard(location: location, isPresented: $showLocationDetail)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }

            // Floating controls
            VStack {
                Spacer()
                HStack {
                    Spacer()

                    VStack(spacing: 16) {
                        // Check-in button (larger, primary action)
                        checkInButton

                        // Recenter button (smaller, secondary action)
                        recenterButton
                    }
                }
                .padding()
            }
        }
        .onAppear {
            // Center on user's location when available
            if !hasInitializedLocation, let userLoc = locationManager.userLocation {
                withAnimation {
                    region.center = userLoc.coordinate
                    mapCameraPosition = .region(region)
                    hasInitializedLocation = true
                }
            } else {
                // Set initial camera position
                mapCameraPosition = .region(region)
            }
        }
        .onChange(of: locationManager.userLocation) { oldLoc, newLoc in
            // Update region when user location changes (first time)
            if !hasInitializedLocation, let userLoc = newLoc {
                withAnimation {
                    region.center = userLoc.coordinate
                    mapCameraPosition = .region(region)
                    hasInitializedLocation = true
                }
            }
        }
        .fullScreenCover(isPresented: $showCheckInDetail) {
            if let (user, checkIn) = selectedCheckIn {
                CheckInDetailSheet(user: user, checkIn: checkIn, isPresented: $showCheckInDetail)
                    .presentationBackground(.black)
            }
        }
        .fullScreenCover(isPresented: $showCameraCheckIn) {
            CameraCaptureView(tappedCoordinate: longPressTappedCoordinate)
                .environmentObject(viewModel)
        }
        .onChange(of: viewModel.currentUser.currentCheckIn) { oldCheckIn, newCheckIn in
            // Zoom to user's check-in location when they check in
            if let checkIn = newCheckIn, checkIn.isActive {
                withAnimation(.easeInOut(duration: 0.8)) {
                    region = MKCoordinateRegion(
                        center: checkIn.location.coordinate.clLocationCoordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008)
                    )
                }
            }
        }
        .sheet(isPresented: $showFilters) {
            FilterSheetSimpleView()
        }
        .sheet(isPresented: $showQuickCheckIn) {
            if let location = selectedLocation {
                CheckInDetailView(location: location, isPresented: $showQuickCheckIn)
                    .environmentObject(viewModel)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
        }
        }

        return content
    }

    // MARK: - Clean Header
    private var tinderStyleHeader: some View {
        EmptyView()
    }

    private var checkInButton: some View {
        Button(action: {
            let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
            impactHeavy.impactOccurred()

            // Open camera for check-in
            showCameraCheckIn = true
        }) {
            VStack(spacing: 6) {
                Image(systemName: "camera.fill")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)

                Text("Check In")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white)
            }
            .frame(width: 70, height: 70)
            .background(
                LinearGradient(
                    colors: [
                        Color(red: 252/255, green: 108/255, blue: 133/255),
                        Color(red: 234/255, green: 88/255, blue: 120/255)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(Circle())
            .shadow(color: Color(red: 252/255, green: 108/255, blue: 133/255).opacity(0.4), radius: 12, x: 0, y: 6)
            .overlay(
                Circle()
                    .stroke(Color.white.opacity(0.3), lineWidth: 2)
            )
        }
    }

    private var recenterButton: some View {
        Button(action: {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                // Center on user's location if available, otherwise Zurich
                if let userLoc = locationManager.userLocation {
                    region = MKCoordinateRegion(
                        center: userLoc.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.0167, longitudeDelta: 0.0167)
                    )
                } else {
                    region = MKCoordinateRegion(
                        center: CLLocationCoordinate2D(latitude: 47.3769, longitude: 8.5417),
                        span: MKCoordinateSpan(latitudeDelta: 0.0167, longitudeDelta: 0.0167)
                    )
                }
            }
        }) {
            Image(systemName: "location.fill")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(Color.white.opacity(0.9))
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 3)
        }
    }

    // Helper to convert location coordinates to screen position
    private func locationToScreenPosition(_ location: Location) -> CGPoint {
        // This is a simplified version - in production you'd calculate actual screen coords
        return CGPoint(x: 200, y: 300)
    }

    // Convert screen point to map coordinate
    private func screenPointToCoordinate(point: CGPoint, in size: CGSize) -> CLLocationCoordinate2D {
        // Calculate the relative position (0-1) in the view
        let relativeX = point.x / size.width
        let relativeY = point.y / size.height

        // Convert to map coordinates based on current region
        let longitudeDelta = region.span.longitudeDelta
        let latitudeDelta = region.span.latitudeDelta

        let longitude = region.center.longitude + (relativeX - 0.5) * longitudeDelta
        let latitude = region.center.latitude - (relativeY - 0.5) * latitudeDelta

        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    // Check if coordinate is in water (Zürichsee or other water bodies)
    private func isCoordinateInWater(_ coordinate: CLLocationCoordinate2D) -> Bool {
        // Zürichsee (Lake Zurich) boundaries (approximate)
        // Lake runs roughly from north (47.406, 8.546) to south (47.226, 8.588)
        let lakeMinLat = 47.226
        let lakeMaxLat = 47.406
        let lakeMinLon = 8.515
        let lakeMaxLon = 8.588

        // Check if coordinate is within lake boundaries
        if coordinate.latitude >= lakeMinLat && coordinate.latitude <= lakeMaxLat &&
           coordinate.longitude >= lakeMinLon && coordinate.longitude <= lakeMaxLon {

            // More precise check: Lake Zurich is roughly narrow
            // Distance from lake centerline
            let lakeCenterLon = 8.5465
            let lonDistance = abs(coordinate.longitude - lakeCenterLon)

            // Lake width varies, but roughly 0.02-0.04 degrees wide
            let maxLakeWidth = 0.025

            return lonDistance < maxLakeWidth
        }

        // Add more water body checks if needed
        return false
    }

    // Find nearest location to a coordinate
    private func findNearestLocation(to coordinate: CLLocationCoordinate2D) -> Location? {
        let tappedLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)

        // Find closest location within 500m
        let maxDistance: CLLocationDistance = 500 // meters

        var nearestLocation: Location?
        var nearestDistance: CLLocationDistance = maxDistance

        for location in viewModel.locations {
            let locationCoord = location.coordinate.clLocationCoordinate
            let locationCL = CLLocation(latitude: locationCoord.latitude, longitude: locationCoord.longitude)
            let distance = tappedLocation.distance(from: locationCL)

            if distance < nearestDistance {
                nearestDistance = distance
                nearestLocation = location
            }
        }

        return nearestLocation
    }
}

// MARK: - Heat Map Pin (Simplified for Heat Map View)

struct HeatMapPin: View {
    let location: Location
    let isSelected: Bool

    var activityColor: Color {
        let tinderPink = Color(red: 252/255, green: 108/255, blue: 133/255)
        if location.activeUsers > 15 {
            return tinderPink
        } else if location.activeUsers > 8 {
            return .orange
        } else if location.activeUsers > 3 {
            return .yellow
        } else {
            return .gray
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                // Main circle
                Circle()
                    .fill(activityColor)
                    .frame(width: isSelected ? 50 : 40, height: isSelected ? 50 : 40)
                    .shadow(color: activityColor.opacity(0.6), radius: 8, x: 0, y: 4)

                // White border
                Circle()
                    .stroke(Color.white, lineWidth: 2.5)
                    .frame(width: isSelected ? 50 : 40, height: isSelected ? 50 : 40)

                // Icon
                Image(systemName: location.type.icon)
                    .font(.system(size: isSelected ? 20 : 16, weight: .bold))
                    .foregroundColor(.white)

                // Count badge
                if location.activeUsers > 0 {
                    Text("\(location.activeUsers)")
                        .font(.system(size: 9, weight: .black))
                        .foregroundColor(.white)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(Color.black.opacity(0.7))
                        .clipShape(Capsule())
                        .offset(x: 18, y: -18)
                }
            }

            // Pointer
            Triangle()
                .fill(activityColor)
                .frame(width: 14, height: 10)
                .offset(y: -1)
        }
        .scaleEffect(isSelected ? 1.15 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

// MARK: - Animated Heat Zone with Proper Positioning

struct AnimatedHeatZone: View {
    let location: Location
    @Binding var mapRegion: MKCoordinateRegion
    let geometrySize: CGSize
    let offsetX: CGFloat
    let offsetY: CGFloat
    let isMain: Bool
    @State private var animate = false

    var heatLevel: (color: Color, radius: CGFloat, intensity: Double) {
        // Gradual color transition from gray -> yellow -> orange -> red based on active users
        let users = location.activeUsers

        // Main zones are more intense, ambient zones are softer
        let intensityMultiplier: Double = isMain ? 1.0 : 0.6
        let radiusMultiplier: CGFloat = isMain ? 1.0 : 0.8

        // Calculate color based on user count with smooth transitions
        let color: Color
        let baseIntensity: Double

        if users >= 20 {
            // Very hot - deep red
            color = Color(red: 220/255, green: 20/255, blue: 60/255) // Crimson
            baseIntensity = 0.8
        } else if users >= 15 {
            // Hot - red/pink
            color = Color(red: 252/255, green: 108/255, blue: 133/255) // Tinder pink
            baseIntensity = 0.7
        } else if users >= 10 {
            // Warm - orange-red
            color = Color(red: 255/255, green: 69/255, blue: 58/255) // Red-orange
            baseIntensity = 0.65
        } else if users >= 6 {
            // Medium - orange
            color = Color(red: 255/255, green: 149/255, blue: 0/255) // Orange
            baseIntensity = 0.6
        } else if users >= 3 {
            // Low-medium - yellow-orange
            color = Color(red: 255/255, green: 204/255, blue: 0/255) // Yellow-orange
            baseIntensity = 0.5
        } else if users >= 1 {
            // Low - yellow
            color = Color(red: 255/255, green: 220/255, blue: 100/255) // Soft yellow
            baseIntensity = 0.4
        } else {
            // No users - gray (shouldn't show)
            color = Color.gray
            baseIntensity = 0.2
        }

        // Scale radius based on user count
        let baseRadius: CGFloat = 40 + CGFloat(min(users, 25)) * 2.5

        return (color, baseRadius * radiusMultiplier, baseIntensity * intensityMultiplier)
    }

    var screenPosition: CGPoint {
        let coordinate = location.coordinate.clLocationCoordinate

        // Calculate relative position within the visible map region
        let latDelta = mapRegion.center.latitude - coordinate.latitude
        let lonDelta = mapRegion.center.longitude - coordinate.longitude

        // Convert to screen coordinates
        let x = geometrySize.width / 2 - (lonDelta / mapRegion.span.longitudeDelta) * geometrySize.width + offsetX
        let y = geometrySize.height / 2 + (latDelta / mapRegion.span.latitudeDelta) * geometrySize.height + offsetY

        return CGPoint(x: x, y: y)
    }

    var body: some View {
        ZStack {
            // Outer glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            heatLevel.color.opacity(animate ? 0.5 : 0.25),
                            heatLevel.color.opacity(animate ? 0.25 : 0.15),
                            heatLevel.color.opacity(0.08),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: heatLevel.radius * 0.9
                    )
                )
                .frame(width: heatLevel.radius * 2.2, height: heatLevel.radius * 2.2)
                .blur(radius: isMain ? 30 : 35)

            // Middle layer for depth
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            heatLevel.color.opacity(heatLevel.intensity * 0.8),
                            heatLevel.color.opacity(heatLevel.intensity * 0.4),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: heatLevel.radius * 0.6
                    )
                )
                .frame(width: heatLevel.radius * 1.4, height: heatLevel.radius * 1.4)
                .blur(radius: 20)

            // Inner core
            if isMain {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                heatLevel.color.opacity(heatLevel.intensity),
                                heatLevel.color.opacity(heatLevel.intensity * 0.6),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: heatLevel.radius * 0.4
                        )
                    )
                    .frame(width: heatLevel.radius, height: heatLevel.radius)
                    .blur(radius: 15)
            }
        }
        .scaleEffect(animate ? 1.12 : 0.92)
        .opacity(animate ? 0.85 : 0.55)
        .position(screenPosition)
        .onAppear {
            withAnimation(
                Animation
                    .easeInOut(duration: Double.random(in: 2.5...4.0))
                    .repeatForever(autoreverses: true)
                    .delay(Double.random(in: 0...1.5))
            ) {
                animate = true
            }
        }
    }
}

// MARK: - Profile Marker (User Avatars on Map When Zoomed)

struct ProfileMarker: View {
    let user: User
    let location: Location
    @Binding var mapRegion: MKCoordinateRegion
    let geometrySize: CGSize
    @State private var pulse = false

    var screenPosition: CGPoint {
        let coordinate = location.coordinate.clLocationCoordinate

        let latDelta = mapRegion.center.latitude - coordinate.latitude
        let lonDelta = mapRegion.center.longitude - coordinate.longitude

        // Spread out users at same location in a circle pattern
        let userHash = abs(user.id.hashValue)
        let angle = CGFloat(userHash % 360) * .pi / 180
        let distance: CGFloat = 35
        let randomOffset = CGPoint(
            x: cos(angle) * distance,
            y: sin(angle) * distance
        )

        let x = geometrySize.width / 2 - (lonDelta / mapRegion.span.longitudeDelta) * geometrySize.width + randomOffset.x
        let y = geometrySize.height / 2 + (latDelta / mapRegion.span.latitudeDelta) * geometrySize.height + randomOffset.y

        return CGPoint(x: x, y: y)
    }

    var body: some View {
        VStack(spacing: 2) {
            ZStack {
                // Pulsing outer ring
                Circle()
                    .fill(Color(red: 252/255, green: 108/255, blue: 133/255).opacity(0.3))
                    .frame(width: 50, height: 50)
                    .scaleEffect(pulse ? 1.2 : 1.0)

                // Profile avatar
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.pink, .purple, .blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 44, height: 44)
                    .overlay(
                        Text(String(user.name.prefix(1)))
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                    )
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 2.5)
                    )

                // Verified badge
                if user.isVerified {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.blue)
                        .background(Circle().fill(Color.white).frame(width: 16, height: 16))
                        .offset(x: 16, y: -16)
                }
            }

            // Name tag
            Text(user.name.components(separatedBy: " ").first ?? user.name)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(Color.black.opacity(0.75))
                .cornerRadius(8)
        }
        .position(screenPosition)
        .shadow(color: .black.opacity(0.3), radius: 6, x: 0, y: 3)
        .onAppear {
            withAnimation(
                Animation
                    .easeInOut(duration: 1.8)
                    .repeatForever(autoreverses: true)
                    .delay(Double.random(in: 0...0.5))
            ) {
                pulse = true
            }
        }
    }
}

// MARK: - Moment Bubble (User Stories on Map)

struct MomentBubble: View {
    let user: User
    let location: Location
    @Binding var mapRegion: MKCoordinateRegion
    let geometrySize: CGSize
    @State private var pulse = false

    var screenPosition: CGPoint {
        let coordinate = location.coordinate.clLocationCoordinate

        let latDelta = mapRegion.center.latitude - coordinate.latitude
        let lonDelta = mapRegion.center.longitude - coordinate.longitude

        // Small offset to spread out bubbles at same location, but keep them near the spot
        let userHash = abs(user.id.hashValue)
        let angle = CGFloat(userHash % 360) * .pi / 180
        let distance: CGFloat = 25
        let randomOffset = CGPoint(
            x: cos(angle) * distance,
            y: sin(angle) * distance
        )

        let x = geometrySize.width / 2 - (lonDelta / mapRegion.span.longitudeDelta) * geometrySize.width + randomOffset.x
        let y = geometrySize.height / 2 + (latDelta / mapRegion.span.latitudeDelta) * geometrySize.height + randomOffset.y

        return CGPoint(x: x, y: y)
    }

    var body: some View {
        VStack(spacing: 4) {
            // User avatar with story ring
            ZStack {
                // Pulsing story ring
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color(red: 252/255, green: 108/255, blue: 133/255),
                                .orange,
                                .yellow
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 3
                    )
                    .frame(width: 50, height: 50)
                    .scaleEffect(pulse ? 1.1 : 1.0)

                // Avatar
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.pink, .purple, .blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 44, height: 44)
                    .overlay(
                        Text(String(user.name.prefix(1)))
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                    )
            }

            // Name tag
            Text(user.name.components(separatedBy: " ").first ?? user.name)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.black.opacity(0.7))
                .cornerRadius(10)
        }
        .position(screenPosition)
        .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
        .onAppear {
            withAnimation(
                Animation
                    .easeInOut(duration: 1.5)
                    .repeatForever(autoreverses: true)
            ) {
                pulse = true
            }
        }
    }
}

// MARK: - Location Bottom Card (Snapchat style)

struct LocationBottomCard: View {
    @EnvironmentObject var viewModel: AppViewModel
    let location: Location
    @Binding var isPresented: Bool

    var usersHere: [User] {
        viewModel.getUsersAt(location: location)
    }

    var body: some View {
        VStack(spacing: 16) {
            // Drag handle
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 40, height: 5)
                .padding(.top, 8)

            // Location info
            HStack {
                Image(systemName: location.type.icon)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.pink)

                VStack(alignment: .leading, spacing: 4) {
                    Text(location.name)
                        .font(.system(size: 20, weight: .bold, design: .rounded))

                    Text(location.address)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }

                Spacer()

                // Activity indicator
                VStack(spacing: 4) {
                    ZStack {
                        Circle()
                            .fill(Color(red: 252/255, green: 108/255, blue: 133/255).opacity(0.15))
                            .frame(width: 50, height: 50)

                        Text("\(location.activeUsers)")
                            .font(.system(size: 20, weight: .black, design: .rounded))
                            .foregroundColor(Color(red: 252/255, green: 108/255, blue: 133/255))
                    }

                    Image(systemName: "flame.fill")
                        .font(.system(size: 16))
                        .foregroundColor(Color(red: 252/255, green: 108/255, blue: 133/255))
                }
            }
            .padding(.horizontal)

            // People here
            if !usersHere.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("\(usersHere.count) PEOPLE SPOTTED")
                        .font(.system(size: 14, weight: .black, design: .rounded))
                        .foregroundColor(.secondary)
                        .padding(.horizontal)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(usersHere.prefix(5)) { user in
                                SnapchatStyleUserCard(user: user)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }

            // Check-in button (Tinder style)
            Button(action: {
                viewModel.checkIn(at: location)
                isPresented = false
            }) {
                HStack {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 20, weight: .bold))
                    Text("Check In")
                        .font(.system(size: 18, weight: .bold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .foregroundColor(.white)
                .background(Color(red: 252/255, green: 108/255, blue: 133/255))
                .cornerRadius(30)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .background(
            RoundedRectangle(cornerRadius: 30)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: -5)
        )
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.height > 100 {
                        withAnimation(.spring()) {
                            isPresented = false
                        }
                    }
                }
        )
    }
}

// MARK: - Snapchat-Style User Card

struct SnapchatStyleUserCard: View {
    let user: User

    var body: some View {
        VStack(spacing: 6) {
            // Bitmoji-style avatar
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.pink, .purple, .blue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 60, height: 60)
                .overlay(
                    Text(String(user.name.prefix(1)))
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                )
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 3)
                )
                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)

            Text(user.name)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
        }
    }
}

// MARK: - Check-In Photo Marker (Shows actual check-in photos on map)

struct CheckInPhotoMarker: View {
    let user: User
    let checkIn: CheckIn
    let location: Location
    @Binding var mapRegion: MKCoordinateRegion
    let geometrySize: CGSize
    var isCurrentUser: Bool = false
    @State private var pulse = false

    var screenPosition: CGPoint {
        let coordinate = location.coordinate.clLocationCoordinate

        let latDelta = mapRegion.center.latitude - coordinate.latitude
        let lonDelta = mapRegion.center.longitude - coordinate.longitude

        // Spread out users at same location in a circle pattern
        let userHash = abs(user.id.hashValue)
        let angle = CGFloat(userHash % 360) * .pi / 180
        let distance: CGFloat = 35
        let randomOffset = CGPoint(
            x: cos(angle) * distance,
            y: sin(angle) * distance
        )

        let x = geometrySize.width / 2 - (lonDelta / mapRegion.span.longitudeDelta) * geometrySize.width + randomOffset.x
        let y = geometrySize.height / 2 + (latDelta / mapRegion.span.latitudeDelta) * geometrySize.height + randomOffset.y

        return CGPoint(x: x, y: y)
    }

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                // Pulsing outer ring (Snapchat/Instagram story style)
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: isCurrentUser ? [
                                Color(red: 252/255, green: 108/255, blue: 133/255),
                                .purple,
                                Color(red: 252/255, green: 108/255, blue: 133/255)
                            ] : [
                                Color(red: 252/255, green: 108/255, blue: 133/255),
                                .orange,
                                .yellow
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: isCurrentUser ? 4 : 3
                    )
                    .frame(width: isCurrentUser ? 70 : 66, height: isCurrentUser ? 70 : 66)
                    .scaleEffect(pulse ? 1.05 : 1.0)

                // Check-in photo
                if let imageUrl = checkIn.imageUrl,
                   let uiImage = UIImage(contentsOfFile: imageUrl) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: isCurrentUser ? 64 : 60, height: isCurrentUser ? 64 : 60)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 2.5)
                        )
                } else {
                    // Fallback to profile avatar if no photo
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.pink, .purple, .blue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: isCurrentUser ? 64 : 60, height: isCurrentUser ? 64 : 60)
                        .overlay(
                            Text(String(user.name.prefix(1)))
                                .font(.system(size: isCurrentUser ? 24 : 22, weight: .bold))
                                .foregroundColor(.white)
                        )
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 2.5)
                        )
                }

                // Caption indicator (if has caption)
                if checkIn.caption != nil {
                    Image(systemName: "text.bubble.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.white)
                        .padding(4)
                        .background(Color(red: 252/255, green: 108/255, blue: 133/255))
                        .clipShape(Circle())
                        .offset(x: 22, y: -22)
                }
            }

            // Name tag with time
            VStack(spacing: 2) {
                Text(user.name.components(separatedBy: " ").first ?? user.name)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white)

                Text(checkIn.timeRemaining)
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.black.opacity(0.75))
            .cornerRadius(10)
        }
        .position(screenPosition)
        .shadow(color: .black.opacity(0.4), radius: 8, x: 0, y: 4)
        .onAppear {
            withAnimation(
                Animation
                    .easeInOut(duration: 2.0)
                    .repeatForever(autoreverses: true)
                    .delay(Double.random(in: 0...0.5))
            ) {
                pulse = true
            }
        }
    }
}

// MARK: - Check-In Detail Sheet (Instagram/Snapchat Story Style)

struct CheckInDetailSheet: View {
    let user: User
    let checkIn: CheckIn
    @Binding var isPresented: Bool
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            // Black background
            Color.black
                .ignoresSafeArea()

            // Full-screen photo background
            if let imageUrl = checkIn.imageUrl,
               let uiImage = UIImage(contentsOfFile: imageUrl) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
            } else {
                // Fallback gradient background
                LinearGradient(
                    colors: [.pink, .purple, .blue],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            }

            // Dark overlay for readability
            LinearGradient(
                colors: [
                    Color.black.opacity(0.4),
                    Color.clear,
                    Color.clear,
                    Color.black.opacity(0.4)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack {
                // Top bar with user info and close button
                HStack(spacing: 12) {
                    // User avatar
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.pink, .purple, .blue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 44, height: 44)
                        .overlay(
                            Text(String(user.name.prefix(1)))
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                        )
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                        )

                    // User name and time
                    VStack(alignment: .leading, spacing: 2) {
                        Text(user.name)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)

                        Text(checkIn.timeRemaining)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white.opacity(0.8))
                    }

                    Spacer()

                    // Close button
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 32, height: 32)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                .padding(.bottom, 20)
                .background(
                    LinearGradient(
                        colors: [Color.black.opacity(0.6), Color.clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 140)
                )

                Spacer()

                // Caption (if available) - centered like Instagram stories
                if let caption = checkIn.caption {
                    Text(caption)
                        .font(.system(size: 28, weight: .bold))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.5), radius: 4, x: 0, y: 2)
                        .padding(.horizontal, 32)
                }

                Spacer()

                // Bottom info - Location
                VStack(spacing: 16) {
                    // Location card
                    HStack(spacing: 12) {
                        Image(systemName: checkIn.location.type.icon)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(checkIn.location.name)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)

                            Text(checkIn.location.address)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                        }

                        Spacer()
                    }
                    .padding(16)
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(16)
                    .padding(.horizontal, 20)

                    // View Profile Button
                    NavigationLink(destination: UserProfileView(user: user)) {
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 18, weight: .bold))
                            Text("View Profile")
                                .font(.system(size: 16, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(red: 252/255, green: 108/255, blue: 133/255))
                        .cornerRadius(30)
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.bottom, 40)
            }
        }
        .simultaneousGesture(
            DragGesture()
                .onEnded { value in
                    // Swipe down to dismiss
                    if value.translation.height > 100 {
                        dismiss()
                    }
                }
        )
    }
}

// MARK: - Filter Sheet Wrapper for Map View

struct FilterSheetSimpleView: View {
    @AppStorage("maxDistance") private var maxDistance: Double = 50
    @AppStorage("minAge") private var minAge: Double = 18
    @AppStorage("maxAge") private var maxAge: Double = 35
    @AppStorage("selectedInterests") private var selectedInterestsData: Data = Data()
    @AppStorage("selectedDrinking") private var selectedDrinkingData: Data = Data()
    @AppStorage("selectedSmoking") private var selectedSmokingData: Data = Data()
    @AppStorage("selectedKids") private var selectedKidsData: Data = Data()

    // Helper computed properties for Set<String> conversion
    private var selectedInterests: Binding<Set<String>> {
        Binding(
            get: { (try? JSONDecoder().decode(Set<String>.self, from: selectedInterestsData)) ?? [] },
            set: { selectedInterestsData = (try? JSONEncoder().encode($0)) ?? Data() }
        )
    }

    private var selectedDrinking: Binding<Set<String>> {
        Binding(
            get: { (try? JSONDecoder().decode(Set<String>.self, from: selectedDrinkingData)) ?? [] },
            set: { selectedDrinkingData = (try? JSONEncoder().encode($0)) ?? Data() }
        )
    }

    private var selectedSmoking: Binding<Set<String>> {
        Binding(
            get: { (try? JSONDecoder().decode(Set<String>.self, from: selectedSmokingData)) ?? [] },
            set: { selectedSmokingData = (try? JSONEncoder().encode($0)) ?? Data() }
        )
    }

    private var selectedKids: Binding<Set<String>> {
        Binding(
            get: { (try? JSONDecoder().decode(Set<String>.self, from: selectedKidsData)) ?? [] },
            set: { selectedKidsData = (try? JSONEncoder().encode($0)) ?? Data() }
        )
    }

    var body: some View {
        NavigationStack {
            FilterSheetView(
                maxDistance: $maxDistance,
                minAge: $minAge,
                maxAge: $maxAge,
                selectedInterests: selectedInterests,
                selectedDrinking: selectedDrinking,
                selectedSmoking: selectedSmoking,
                selectedKids: selectedKids
            )
        }
    }
}

// MARK: - Gesture Overlay for Map Touch Handling

struct GestureOverlay: View {
    let geometrySize: CGSize
    @Binding var showLocationDetail: Bool
    @Binding var selectedLocation: Location?
    @Binding var longPressTappedCoordinate: CLLocationCoordinate2D?
    @Binding var showCameraCheckIn: Bool

    let screenPointToCoordinate: (CGPoint, CGSize) -> CLLocationCoordinate2D
    let findNearestLocation: (CLLocationCoordinate2D) -> Location?

    @State private var pressLocation: CGPoint?
    @State private var longPressTimer: Timer?

    var body: some View {
        Color.clear
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        // Start long press timer on initial touch
                        if pressLocation == nil {
                            pressLocation = value.location

                            // Start timer for long press (0.5 seconds)
                            longPressTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
                                // Long press detected!
                                guard let location = pressLocation else { return }

                                let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
                                impactHeavy.impactOccurred()

                                // Capture the coordinate where user long-pressed
                                let coordinate = screenPointToCoordinate(location, geometrySize)
                                longPressTappedCoordinate = coordinate

                                showCameraCheckIn = true

                                // Clean up
                                pressLocation = nil
                            }
                        }

                        // If user moves finger too much, cancel long press
                        if let initial = pressLocation {
                            let distance = hypot(value.location.x - initial.x, value.location.y - initial.y)
                            if distance > 10 {
                                longPressTimer?.invalidate()
                                longPressTimer = nil
                            }
                        }
                    }
                    .onEnded { value in
                        // Cancel long press timer
                        longPressTimer?.invalidate()
                        longPressTimer = nil

                        // If this was a quick tap (not a long press), handle as tap
                        if let location = pressLocation {
                            let endDistance = hypot(value.location.x - location.x, value.location.y - location.y)

                            // Only trigger tap if finger didn't move much
                            if endDistance < 10 && !showLocationDetail {
                                let coordinate = screenPointToCoordinate(location, geometrySize)

                                // Find nearest location to tap
                                if let nearest = findNearestLocation(coordinate) {
                                    selectedLocation = nearest
                                    showLocationDetail = true
                                }
                            }
                        }

                        pressLocation = nil
                    }
            )
            .allowsHitTesting(true)
    }
}

// MARK: - Triangle Shape for Pin Pointer

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Inactive Location Marker
struct InactiveLocationMarker: View {
    let location: Location
    @Binding var mapRegion: MKCoordinateRegion
    let geometrySize: CGSize

    var screenPosition: CGPoint {
        let coordinate = location.coordinate.clLocationCoordinate

        let latDelta = mapRegion.center.latitude - coordinate.latitude
        let lonDelta = mapRegion.center.longitude - coordinate.longitude

        let x = geometrySize.width / 2 - (lonDelta / mapRegion.span.longitudeDelta) * geometrySize.width
        let y = geometrySize.height / 2 + (latDelta / mapRegion.span.latitudeDelta) * geometrySize.height

        return CGPoint(x: x, y: y)
    }

    var body: some View {
        ZStack {
            // Faded background circle
            Circle()
                .fill(Color.gray.opacity(0.15))
                .frame(width: 44, height: 44)

            // Border
            Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                .frame(width: 44, height: 44)

            // Icon
            Image(systemName: location.type.icon)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.gray.opacity(0.6))
        }
        .position(screenPosition)
    }
}

// MARK: - Preview

#Preview {
    SpottedMapView()
        .environmentObject(AppViewModel())
}
