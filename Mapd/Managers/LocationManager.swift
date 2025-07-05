//
//  LocationManager.swift
//  Mapd
//
//  Created by Pala Rushil on 7/5/25.
//

import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject {
    @Published var location: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var nearbyPlaces: [Place] = []
    
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        authorizationStatus = locationManager.authorizationStatus
    }
    
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startLocationUpdates() {
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            return
        }
        locationManager.startUpdatingLocation()
    }
    
    func stopLocationUpdates() {
        locationManager.stopUpdatingLocation()
    }
    
    func getCurrentLocationName(completion: @escaping (String?) -> Void) {
        guard let location = location else {
            completion(nil)
            return
        }
        
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let placemark = placemarks?.first {
                let city = placemark.locality ?? ""
                let country = placemark.country ?? ""
                completion("\(city), \(country)")
            } else {
                completion(nil)
            }
        }
    }
    
    func searchPlaces(query: String, completion: @escaping ([Place]) -> Void) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        
        if let location = location {
            request.region = MKCoordinateRegion(
                center: location.coordinate,
                latitudinalMeters: 50000,
                longitudinalMeters: 50000
            )
        }
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let response = response else {
                completion([])
                return
            }
            
            let places = response.mapItems.compactMap { item -> Place? in
                guard let name = item.name,
                      let placemark = item.placemark.location else { return nil }
                
                return Place(
                    name: name,
                    country: item.placemark.country ?? "Unknown",
                    city: item.placemark.locality ?? "Unknown",
                    coordinate: placemark.coordinate
                )
            }
            
            DispatchQueue.main.async {
                completion(places)
            }
        }
    }
    
    func findNearbyPlaces() {
        guard let location = location else { return }
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "tourist attractions"
        request.region = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: 10000,
            longitudinalMeters: 10000
        )
        
        let search = MKLocalSearch(request: request)
        search.start { [weak self] response, error in
            guard let response = response else { return }
            
            let places = response.mapItems.compactMap { item -> Place? in
                guard let name = item.name,
                      let placemark = item.placemark.location else { return nil }
                
                return Place(
                    name: name,
                    country: item.placemark.country ?? "Unknown",
                    city: item.placemark.locality ?? "Unknown",
                    coordinate: placemark.coordinate
                )
            }
            
            DispatchQueue.main.async {
                self?.nearbyPlaces = places
            }
        }
    }
    
    func getRandomDestination(preferences: RandomDestinationPreferences, completion: @escaping (Place?) -> Void) {
        // This would typically connect to a travel API
        // For now, we'll return a random destination from a predefined list
        let destinations = getPopularDestinations()
        let filteredDestinations = destinations.filter { destination in
            // Apply basic filtering based on preferences
            if preferences.domesticOnly {
                return destination.country == "USA" // Assuming US-based app
            }
            return true
        }
        
        let randomDestination = filteredDestinations.randomElement()
        completion(randomDestination)
    }
    
    private func getPopularDestinations() -> [Place] {
        return [
            Place(name: "Machu Picchu", country: "Peru", city: "Cusco", coordinate: CLLocationCoordinate2D(latitude: -13.1631, longitude: -72.5450)),
            Place(name: "Great Wall of China", country: "China", city: "Beijing", coordinate: CLLocationCoordinate2D(latitude: 40.4319, longitude: 116.5704)),
            Place(name: "Santorini", country: "Greece", city: "Santorini", coordinate: CLLocationCoordinate2D(latitude: 36.3932, longitude: 25.4615)),
            Place(name: "Bali", country: "Indonesia", city: "Denpasar", coordinate: CLLocationCoordinate2D(latitude: -8.3405, longitude: 115.0920)),
            Place(name: "Iceland Blue Lagoon", country: "Iceland", city: "Reykjavik", coordinate: CLLocationCoordinate2D(latitude: 63.8804, longitude: -22.4495)),
            Place(name: "Safari Kenya", country: "Kenya", city: "Nairobi", coordinate: CLLocationCoordinate2D(latitude: -1.2921, longitude: 36.8219)),
            Place(name: "Taj Mahal", country: "India", city: "Agra", coordinate: CLLocationCoordinate2D(latitude: 27.1751, longitude: 78.0421)),
            Place(name: "Northern Lights Norway", country: "Norway", city: "Tromsø", coordinate: CLLocationCoordinate2D(latitude: 69.6492, longitude: 18.9553)),
            Place(name: "Grand Canyon", country: "USA", city: "Arizona", coordinate: CLLocationCoordinate2D(latitude: 36.1069, longitude: -112.1129)),
            Place(name: "Cherry Blossoms Japan", country: "Japan", city: "Tokyo", coordinate: CLLocationCoordinate2D(latitude: 35.6762, longitude: 139.6503))
        ]
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.location = location
        findNearbyPlaces()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed with error: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizationStatus = status
        
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            startLocationUpdates()
        case .denied, .restricted:
            stopLocationUpdates()
        case .notDetermined:
            break
        @unknown default:
            break
        }
    }
}

// MARK: - Supporting Types
struct RandomDestinationPreferences {
    var budgetRange: ClosedRange<Double> = 500...5000
    var maxDistanceKm: Double = 10000
    var domesticOnly: Bool = false
    var season: Season = .any
    var duration: TripDuration = .week
}

enum Season: String, CaseIterable {
    case spring = "Spring"
    case summer = "Summer"
    case fall = "Fall"
    case winter = "Winter"
    case any = "Any"
}

enum TripDuration: String, CaseIterable {
    case weekend = "Weekend"
    case week = "Week"
    case month = "Month"
    case any = "Any"
}

import MapKit