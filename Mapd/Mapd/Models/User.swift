//
//  User.swift
//  Mapd
//
//  Created by Pala Rushil on 7/5/25.
//

import Foundation
import SwiftUI
import CoreLocation

struct User: Codable {
    var name: String
    var profileImageName: String?
    var travelStyle: TravelStyle
    var interests: [TravelInterest]
    var hasCompletedOnboarding: Bool
    var hasLocationPermission: Bool
    var visitedPlaces: [Place]
    var bucketList: [Place]
    var trips: [Trip]
    
    init(name: String = "", profileImageName: String? = nil, travelStyle: TravelStyle = .adventure, interests: [TravelInterest] = [], hasCompletedOnboarding: Bool = false, hasLocationPermission: Bool = false) {
        self.name = name
        self.profileImageName = profileImageName
        self.travelStyle = travelStyle
        self.interests = interests
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.hasLocationPermission = hasLocationPermission
        self.visitedPlaces = []
        self.bucketList = []
        self.trips = []
    }
    
    var visitedPlacesCount: Int {
        visitedPlaces.count
    }
    
    var countriesVisited: Int {
        Set(visitedPlaces.map { $0.country }).count
    }
    
    var bucketListCount: Int {
        bucketList.count
    }
    
    var totalDistance: Double {
        // Calculate total distance traveled between visited places
        guard visitedPlaces.count > 1 else { return 0 }
        
        var totalDistance: Double = 0
        for i in 0..<visitedPlaces.count - 1 {
            let location1 = visitedPlaces[i].coordinate
            let location2 = visitedPlaces[i + 1].coordinate
            
            let distance = calculateDistance(from: location1, to: location2)
            totalDistance += distance
        }
        
        return totalDistance
    }
    
    private func calculateDistance(from coord1: CLLocationCoordinate2D, to coord2: CLLocationCoordinate2D) -> Double {
        let location1 = CLLocation(latitude: coord1.latitude, longitude: coord1.longitude)
        let location2 = CLLocation(latitude: coord2.latitude, longitude: coord2.longitude)
        return location1.distance(from: location2) / 1000 // Convert to kilometers
    }
}

enum TravelStyle: String, CaseIterable, Codable {
    case adventure = "Adventure"
    case relaxation = "Relaxation"
    case cultural = "Cultural"
    case foodAndDrink = "Food & Drink"
    
    var icon: String {
        switch self {
        case .adventure: return "mountain.2.fill"
        case .relaxation: return "beach.umbrella.fill"
        case .cultural: return "building.columns.fill"
        case .foodAndDrink: return "fork.knife"
        }
    }
    
    var description: String {
        switch self {
        case .adventure: return "Seeking thrills and outdoor activities"
        case .relaxation: return "Preferring peaceful and restorative experiences"
        case .cultural: return "Interested in history, art, and local traditions"
        case .foodAndDrink: return "Exploring culinary experiences and local cuisine"
        }
    }
    
    var color: Color {
        switch self {
        case .adventure: return .orange
        case .relaxation: return .blue
        case .cultural: return .brown
        case .foodAndDrink: return .red
        }
    }
}

enum TravelInterest: String, CaseIterable, Codable {
    case museums = "Museums"
    case nature = "Nature"
    case food = "Food"
    case nightlife = "Nightlife"
    case history = "History"
    case adventure = "Adventure"
    case beaches = "Beaches"
    case architecture = "Architecture"
    case shopping = "Shopping"
    case photography = "Photography"
    case wildlife = "Wildlife"
    case festivals = "Festivals"
    case wellness = "Wellness"
    case luxury = "Luxury"
    
    var icon: String {
        switch self {
        case .museums: return "building.columns"
        case .nature: return "leaf.fill"
        case .food: return "fork.knife"
        case .nightlife: return "moon.stars.fill"
        case .history: return "book.fill"
        case .adventure: return "figure.hiking"
        case .beaches: return "beach.umbrella"
        case .architecture: return "building.2.fill"
        case .shopping: return "bag.fill"
        case .photography: return "camera.fill"
        case .wildlife: return "pawprint.fill"
        case .festivals: return "party.popper.fill"
        case .wellness: return "heart.circle.fill"
        case .luxury: return "crown.fill"
        }
    }

    var description: String {
        switch self {
        case .museums: return "Explore art, history, and science"
        case .nature: return "Discover natural landscapes and wildlife"
        case .food: return "Indulge in culinary delights and local cuisine"
        case .nightlife: return "Experience vibrant evenings and entertainment"
        case .history: return "Delve into the past and historical sites"
        case .adventure: return "Seek thrilling activities and outdoor sports"
        case .beaches: return "Relax by the sea and enjoy coastal views"
        case .architecture: return "Admire unique buildings and urban design"
        case .shopping: return "Discover local markets and retail therapy"
        case .photography: return "Capture beautiful moments and scenery"
        case .wildlife: return "Observe animals in their natural habitats"
        case .festivals: return "Immerse in cultural celebrations and events"
        case .wellness: return "Focus on health, relaxation, and well-being"
        case .luxury: return "Enjoy high-end experiences and exclusive services"
        }
    }
    
    var color: Color {
        switch self {
        case .museums: return .blue
        case .nature: return .green
        case .food: return .orange
        case .nightlife: return .purple
        case .history: return .brown
        case .adventure: return .red
        case .beaches: return .cyan
        case .architecture: return .gray
        case .shopping: return .pink
        case .photography: return .yellow
        case .wildlife: return .mint
        case .festivals: return .indigo
        case .wellness: return .teal
        case .luxury: return .purple
        }
    }
}

// MARK: - Sample Data
extension User {
    static let sampleUser = User(
        name: "Alex Johnson",
        travelStyle: .adventure,
        interests: [.nature, .adventure, .photography, .food],
        hasCompletedOnboarding: true,
        hasLocationPermission: true
    )
}