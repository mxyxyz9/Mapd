//
//  UserManager.swift
//  Mapd
//
//  Created by Pala Rushil on 7/5/25.
//

import Foundation
import Combine
import CoreLocation

class UserManager: ObservableObject {
    @Published var currentUser: User
    @Published var isOnboardingComplete: Bool
    
    private let userDefaultsKey = "MapdUser"
    private let firstLaunchKey = "mapd_first_launch"
    
    var isFirstLaunch: Bool {
        !UserDefaults.standard.bool(forKey: firstLaunchKey)
    }
    
    init() {
        if let userData = UserDefaults.standard.data(forKey: userDefaultsKey),
           let user = try? JSONDecoder().decode(User.self, from: userData) {
            self.currentUser = user
            self.isOnboardingComplete = user.hasCompletedOnboarding
        } else {
            self.currentUser = User()
            self.isOnboardingComplete = false
        }
        
        // Mark that the app has been launched
        if isFirstLaunch {
            UserDefaults.standard.set(true, forKey: firstLaunchKey)
        }
    }
    
    func saveUser() {
        if let userData = try? JSONEncoder().encode(currentUser) {
            UserDefaults.standard.set(userData, forKey: userDefaultsKey)
        }
    }
    
    func updateUserProfile(name: String, travelStyle: TravelStyle, interests: [TravelInterest]) {
        currentUser.name = name
        currentUser.travelStyle = travelStyle
        currentUser.interests = interests
        saveUser()
    }
    
    func completeOnboarding() {
        currentUser.hasCompletedOnboarding = true
        isOnboardingComplete = true
        saveUser()
    }
    
    func setLocationPermission(_ granted: Bool) {
        currentUser.hasLocationPermission = granted
        saveUser()
    }
    
    func addVisitedPlace(_ place: Place) {
        var updatedPlace = place
        updatedPlace.isVisited = true
        updatedPlace.dateVisited = Date()
        
        // Remove from bucket list if it exists there
        currentUser.bucketList.removeAll { $0.id == place.id }
        
        // Add to visited places if not already there
        if !currentUser.visitedPlaces.contains(where: { $0.id == place.id }) {
            currentUser.visitedPlaces.append(updatedPlace)
        }
        
        saveUser()
    }
    
    func addToBucketList(_ place: Place) {
        var updatedPlace = place
        updatedPlace.isInBucketList = true
        
        // Add to bucket list if not already there and not visited
        if !currentUser.bucketList.contains(where: { $0.id == place.id }) &&
           !currentUser.visitedPlaces.contains(where: { $0.id == place.id }) {
            currentUser.bucketList.append(updatedPlace)
        }
        
        saveUser()
    }
    
    func removeFromBucketList(_ place: Place) {
        currentUser.bucketList.removeAll { $0.id == place.id }
        saveUser()
    }
    
    func addTrip(_ trip: Trip) {
        currentUser.trips.append(trip)
        saveUser()
    }
    
    func updateTrip(_ trip: Trip) {
        if let index = currentUser.trips.firstIndex(where: { $0.id == trip.id }) {
            currentUser.trips[index] = trip
            saveUser()
        }
    }
    
    func deleteTrip(_ trip: Trip) {
        currentUser.trips.removeAll { $0.id == trip.id }
        saveUser()
    }
    
    func updateChecklistItem(_ tripId: UUID, _ item: ChecklistItem) {
        if let tripIndex = currentUser.trips.firstIndex(where: { $0.id == tripId }),
           let itemIndex = currentUser.trips[tripIndex].checklist.firstIndex(where: { $0.id == item.id }) {
            currentUser.trips[tripIndex].checklist[itemIndex] = item
            saveUser()
        }
    }
    
    func getRecentVisitedPlaces(limit: Int = 3) -> [Place] {
        return currentUser.visitedPlaces
            .sorted { ($0.dateVisited ?? Date.distantPast) > ($1.dateVisited ?? Date.distantPast) }
            .prefix(limit)
            .map { $0 }
    }
    
    func getUpcomingTrips() -> [Trip] {
        return currentUser.trips
            .filter { $0.startDate > Date() }
            .sorted { $0.startDate < $1.startDate }
    }
    
    func getActiveTrips() -> [Trip] {
        let now = Date()
        return currentUser.trips
            .filter { $0.startDate <= now && $0.endDate >= now }
    }
}