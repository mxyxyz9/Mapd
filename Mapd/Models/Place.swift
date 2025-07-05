//
//  Place.swift
//  Mapd
//
//  Created by Pala Rushil on 7/5/25.
//

import Foundation
import CoreLocation
import SwiftUI

struct Place: Identifiable, Codable {
    let id = UUID()
    var name: String
    var country: String
    var city: String
    var coordinate: CLLocationCoordinate2D
    var dateVisited: Date?
    var rating: Int?
    var notes: String
    var photos: [String] // Photo file names
    var tags: [String]
    var isVisited: Bool
    var isInBucketList: Bool
    
    init(name: String, country: String, city: String, coordinate: CLLocationCoordinate2D, dateVisited: Date? = nil, rating: Int? = nil, notes: String = "", photos: [String] = [], tags: [String] = [], isVisited: Bool = false, isInBucketList: Bool = false) {
        self.name = name
        self.country = country
        self.city = city
        self.coordinate = coordinate
        self.dateVisited = dateVisited
        self.rating = rating
        self.notes = notes
        self.photos = photos
        self.tags = tags
        self.isVisited = isVisited
        self.isInBucketList = isInBucketList
    }
}

// MARK: - CLLocationCoordinate2D Codable Extension
extension CLLocationCoordinate2D: Codable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let latitude = try container.decode(Double.self, forKey: .latitude)
        let longitude = try container.decode(Double.self, forKey: .longitude)
        self.init(latitude: latitude, longitude: longitude)
    }
    
    private enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
    }
}

// MARK: - Sample Data
extension Place {
    static let samplePlaces = [
        Place(name: "Eiffel Tower", country: "France", city: "Paris", coordinate: CLLocationCoordinate2D(latitude: 48.8584, longitude: 2.2945), dateVisited: Date(), rating: 5, notes: "Amazing sunset view!", tags: ["Romantic", "Architecture"], isVisited: true),
        Place(name: "Tokyo Tower", country: "Japan", city: "Tokyo", coordinate: CLLocationCoordinate2D(latitude: 35.6586, longitude: 139.7454), isInBucketList: true),
        Place(name: "Statue of Liberty", country: "USA", city: "New York", coordinate: CLLocationCoordinate2D(latitude: 40.6892, longitude: -74.0445), dateVisited: Date().addingTimeInterval(-86400 * 30), rating: 4, tags: ["History", "Culture"], isVisited: true)
    ]
}