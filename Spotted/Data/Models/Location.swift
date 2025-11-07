import Foundation
import CoreLocation

enum LocationType: String, Codable, CaseIterable {
    case trainStation = "Train Station"
    case airport = "Airport"
    case park = "Park"
    case cafe = "Cafe"
    case bar = "Bar"
    case gym = "Gym"
    case other = "Other"

    var icon: String {
        switch self {
        case .trainStation: return "tram.fill"
        case .airport: return "airplane"
        case .park: return "leaf.fill"
        case .cafe: return "cup.and.saucer.fill"
        case .bar: return "wineglass.fill"
        case .gym: return "figure.strengthtraining.traditional"
        case .other: return "mappin.circle.fill"
        }
    }
}

struct Location: Identifiable, Codable, Hashable {
    let id: String
    var name: String
    var type: LocationType
    var address: String
    var coordinate: Coordinate
    var activeUsers: Int // Number of users currently checked in

    init(id: String = UUID().uuidString,
         name: String,
         type: LocationType,
         address: String,
         latitude: Double,
         longitude: Double,
         activeUsers: Int = 0) {
        self.id = id
        self.name = name
        self.type = type
        self.address = address
        self.coordinate = Coordinate(latitude: latitude, longitude: longitude)
        self.activeUsers = activeUsers
    }
}

// Custom Coordinate struct that conforms to Codable
struct Coordinate: Codable, Hashable {
    let latitude: Double
    let longitude: Double

    var clLocationCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
