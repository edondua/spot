import Foundation
import CoreLocation
import Combine

@MainActor
class LocationManager: NSObject, ObservableObject {
    static let shared = LocationManager()

    @Published var userLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var locationError: String?

    private let locationManager = CLLocationManager()

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 50 // Update every 50 meters
    }

    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }

    func startUpdatingLocation() {
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            locationError = "Location permission not granted"
            return
        }
        locationManager.startUpdatingLocation()
    }

    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }

    // Calculate distance between user and another coordinate
    func distance(to coordinate: CLLocationCoordinate2D) -> Double? {
        guard let userLocation = userLocation else { return nil }

        let targetLocation = CLLocation(
            latitude: coordinate.latitude,
            longitude: coordinate.longitude
        )

        // Distance in meters
        let distanceMeters = userLocation.distance(from: targetLocation)

        // Convert to kilometers
        return distanceMeters / 1000.0
    }

    // Check if coordinate is within max distance
    func isWithinDistance(_ coordinate: CLLocationCoordinate2D, maxDistanceKm: Double) -> Bool {
        guard let distance = distance(to: coordinate) else { return false }
        return distance <= maxDistanceKm
    }
}

extension LocationManager: CLLocationManagerDelegate {
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            authorizationStatus = manager.authorizationStatus

            switch manager.authorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                startUpdatingLocation()
                locationError = nil
            case .denied, .restricted:
                locationError = "Location access denied. Enable in Settings."
                ToastManager.shared.showError("Location access denied")
            case .notDetermined:
                break
            @unknown default:
                break
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        Task { @MainActor in
            guard let location = locations.last else { return }
            userLocation = location
            locationError = nil
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            locationError = error.localizedDescription
            ToastManager.shared.showError("Failed to get location: \(error.localizedDescription)")
        }
    }
}
