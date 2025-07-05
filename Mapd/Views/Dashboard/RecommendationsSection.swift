//
//  RecommendationsSection.swift
//  Mapd
//
//  Created by Pala Rushil on 7/5/25.
//

import SwiftUI
import MapKit

struct RecommendationsSection: View {
    let userInterests: [TravelInterest]
    @ObservedObject var locationManager: LocationManager
    
    @State private var nearbyPlaces: [MKMapItem] = []
    @State private var randomDestinations: [RandomDestination] = []
    @State private var isLoadingNearby = false
    @State private var isLoadingDestinations = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: MapdSpacing.lg) {
            // Section Header
            HStack {
                Text("Recommendations")
                    .font(MapdTypography.heading2)
                    .foregroundColor(MapdColors.darkText)
                
                Spacer()
                
                Button("Refresh") {
                    loadRecommendations()
                }
                .font(MapdTypography.caption)
                .foregroundColor(MapdColors.accent)
            }
            
            // Nearby Places
            if locationManager.hasLocationPermission {
                NearbyPlacesSubsection(
                    places: nearbyPlaces,
                    isLoading: isLoadingNearby,
                    onRefresh: loadNearbyPlaces
                )
            }
            
            // Random Destinations
            RandomDestinationsSubsection(
                destinations: randomDestinations,
                isLoading: isLoadingDestinations,
                onRefresh: loadRandomDestinations
            )
            
            // Interest-based Recommendations
            InterestBasedRecommendations(interests: userInterests)
        }
        .onAppear {
            loadRecommendations()
        }
    }
    
    private func loadRecommendations() {
        loadNearbyPlaces()
        loadRandomDestinations()
    }
    
    private func loadNearbyPlaces() {
        guard locationManager.hasLocationPermission,
              let location = locationManager.currentLocation else { return }
        
        isLoadingNearby = true
        
        Task {
            do {
                let places = try await locationManager.findNearbyPlaces(
                    coordinate: location.coordinate,
                    radius: 10000, // 10km
                    categories: ["restaurant", "tourist_attraction", "park", "museum"]
                )
                
                await MainActor.run {
                    self.nearbyPlaces = Array(places.prefix(5))
                    self.isLoadingNearby = false
                }
            } catch {
                await MainActor.run {
                    self.isLoadingNearby = false
                }
            }
        }
    }
    
    private func loadRandomDestinations() {
        isLoadingDestinations = true
        
        Task {
            let preferences = RandomDestinationPreferences(
                interests: userInterests,
                season: getCurrentSeason(),
                duration: .week,
                budget: .medium
            )
            
            let destinations = await locationManager.getRandomDestinations(
                count: 3,
                preferences: preferences
            )
            
            await MainActor.run {
                self.randomDestinations = destinations
                self.isLoadingDestinations = false
            }
        }
    }
    
    private func getCurrentSeason() -> Season {
        let month = Calendar.current.component(.month, from: Date())
        switch month {
        case 3...5: return .spring
        case 6...8: return .summer
        case 9...11: return .autumn
        default: return .winter
        }
    }
}

// MARK: - Nearby Places Subsection
struct NearbyPlacesSubsection: View {
    let places: [MKMapItem]
    let isLoading: Bool
    let onRefresh: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: MapdSpacing.md) {
            HStack {
                Text("Nearby Places")
                    .font(MapdTypography.heading3)
                    .foregroundColor(MapdColors.darkText)
                
                Spacer()
                
                if !places.isEmpty {
                    Button("View All") {
                        // Navigate to nearby places
                    }
                    .font(MapdTypography.small)
                    .foregroundColor(MapdColors.accent)
                }
            }
            
            if isLoading {
                LoadingPlacesView()
            } else if places.isEmpty {
                EmptyNearbyPlacesView(onRefresh: onRefresh)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: MapdSpacing.md) {
                        ForEach(places, id: \.self) { place in
                            NearbyPlaceCard(place: place)
                                .frame(width: 200)
                        }
                    }
                    .padding(.horizontal, MapdSpacing.screenPadding)
                }
                .padding(.horizontal, -MapdSpacing.screenPadding)
            }
        }
    }
}

struct NearbyPlaceCard: View {
    let place: MKMapItem
    
    private var distance: String {
        guard let location = place.placemark.location else { return "" }
        let distanceInMeters = location.distance(from: CLLocation(latitude: 0, longitude: 0)) // This would need actual user location
        let distanceInKm = distanceInMeters / 1000
        return String(format: "%.1f km", distanceInKm)
    }
    
    var body: some View {
        MapdCard(variant: .elevated) {
            VStack(alignment: .leading, spacing: MapdSpacing.md) {
                // Category Icon
                HStack {
                    Image(systemName: categoryIcon)
                        .font(.title3)
                        .foregroundColor(MapdColors.accent)
                    
                    Spacer()
                    
                    Text(distance)
                        .font(MapdTypography.small)
                        .foregroundColor(MapdColors.mediumGray)
                }
                
                // Place Info
                VStack(alignment: .leading, spacing: MapdSpacing.xs) {
                    Text(place.name ?? "Unknown Place")
                        .font(MapdTypography.bodyBold)
                        .foregroundColor(MapdColors.darkText)
                        .lineLimit(2)
                    
                    if let category = place.pointOfInterestCategory?.rawValue {
                        Text(category.capitalized)
                            .font(MapdTypography.small)
                            .foregroundColor(MapdColors.mediumGray)
                    }
                    
                    if let address = place.placemark.thoroughfare {
                        Text(address)
                            .font(MapdTypography.small)
                            .foregroundColor(MapdColors.mediumGray)
                            .lineLimit(1)
                    }
                }
                
                // Action Buttons
                HStack(spacing: MapdSpacing.sm) {
                    ChipButton("Directions", style: .secondary) {
                        openInMaps()
                    }
                    
                    ChipButton("Save", style: .primary) {
                        // Add to bucket list
                    }
                }
            }
        }
    }
    
    private var categoryIcon: String {
        guard let category = place.pointOfInterestCategory else { return "mappin" }
        
        switch category {
        case .restaurant: return "fork.knife"
        case .museum: return "building.columns"
        case .park: return "tree"
        case .beach: return "beach.umbrella"
        case .hospital: return "cross"
        case .school: return "graduationcap"
        case .store: return "bag"
        default: return "mappin"
        }
    }
    
    private func openInMaps() {
        place.openInMaps()
    }
}

// MARK: - Random Destinations Subsection
struct RandomDestinationsSubsection: View {
    let destinations: [RandomDestination]
    let isLoading: Bool
    let onRefresh: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: MapdSpacing.md) {
            HStack {
                Text("Discover New Places")
                    .font(MapdTypography.heading3)
                    .foregroundColor(MapdColors.darkText)
                
                Spacer()
                
                Button("More") {
                    onRefresh()
                }
                .font(MapdTypography.small)
                .foregroundColor(MapdColors.accent)
            }
            
            if isLoading {
                LoadingDestinationsView()
            } else if destinations.isEmpty {
                EmptyDestinationsView(onRefresh: onRefresh)
            } else {
                VStack(spacing: MapdSpacing.sm) {
                    ForEach(destinations, id: \.name) { destination in
                        RandomDestinationCard(destination: destination)
                    }
                }
            }
        }
    }
}

struct RandomDestinationCard: View {
    let destination: RandomDestination
    
    var body: some View {
        MapdCard {
            HStack(spacing: MapdSpacing.md) {
                // Destination Image/Icon
                ZStack {
                    RoundedRectangle(cornerRadius: MapdRadius.small)
                        .fill(destination.color.opacity(0.2))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: destination.icon)
                        .font(.title2)
                        .foregroundColor(destination.color)
                }
                
                // Destination Info
                VStack(alignment: .leading, spacing: MapdSpacing.xs) {
                    Text(destination.name)
                        .font(MapdTypography.bodyBold)
                        .foregroundColor(MapdColors.darkText)
                    
                    Text(destination.country)
                        .font(MapdTypography.caption)
                        .foregroundColor(MapdColors.mediumGray)
                    
                    Text(destination.description)
                        .font(MapdTypography.small)
                        .foregroundColor(MapdColors.mediumGray)
                        .lineLimit(2)
                }
                
                Spacer()
                
                // Action Button
                VStack(spacing: MapdSpacing.xs) {
                    IconButton(icon: "heart", size: .small) {
                        // Add to bucket list
                    }
                    
                    IconButton(icon: "info.circle", size: .small) {
                        // Show more info
                    }
                }
            }
        }
    }
}

// MARK: - Interest-based Recommendations
struct InterestBasedRecommendations: View {
    let interests: [TravelInterest]
    
    var body: some View {
        VStack(alignment: .leading, spacing: MapdSpacing.md) {
            Text("Based on Your Interests")
                .font(MapdTypography.heading3)
                .foregroundColor(MapdColors.darkText)
            
            if interests.isEmpty {
                EmptyInterestsView()
            } else {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: MapdSpacing.sm) {
                    ForEach(interests.prefix(4), id: \.self) { interest in
                        InterestRecommendationCard(interest: interest)
                    }
                }
            }
        }
    }
}

struct InterestRecommendationCard: View {
    let interest: TravelInterest
    
    var body: some View {
        Button(action: {
            // Navigate to interest-based places
        }) {
            HStack(spacing: MapdSpacing.sm) {
                Image(systemName: interest.icon)
                    .font(.title3)
                    .foregroundColor(interest.color)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: MapdSpacing.xs) {
                    Text(interest.rawValue)
                        .font(MapdTypography.caption)
                        .fontWeight(.medium)
                        .foregroundColor(MapdColors.darkText)
                        .lineLimit(1)
                    
                    Text("Explore")
                        .font(MapdTypography.small)
                        .foregroundColor(MapdColors.mediumGray)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(MapdColors.mediumGray)
            }
            .padding(MapdSpacing.md)
            .background(MapdColors.cardBackground)
            .cornerRadius(MapdRadius.card)
            .overlay(
                RoundedRectangle(cornerRadius: MapdRadius.card)
                    .stroke(MapdColors.lightGray, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Loading and Empty States
struct LoadingPlacesView: View {
    var body: some View {
        HStack(spacing: MapdSpacing.md) {
            ForEach(0..<3, id: \.self) { _ in
                RoundedRectangle(cornerRadius: MapdRadius.card)
                    .fill(MapdColors.lightGray)
                    .frame(width: 200, height: 120)
                    .redacted(reason: .placeholder)
            }
        }
    }
}

struct LoadingDestinationsView: View {
    var body: some View {
        VStack(spacing: MapdSpacing.sm) {
            ForEach(0..<3, id: \.self) { _ in
                RoundedRectangle(cornerRadius: MapdRadius.card)
                    .fill(MapdColors.lightGray)
                    .frame(height: 80)
                    .redacted(reason: .placeholder)
            }
        }
    }
}

struct EmptyNearbyPlacesView: View {
    let onRefresh: () -> Void
    
    var body: some View {
        MapdCard {
            VStack(spacing: MapdSpacing.md) {
                Image(systemName: "location.slash")
                    .font(.title2)
                    .foregroundColor(MapdColors.mediumGray)
                
                Text("No nearby places found")
                    .font(MapdTypography.caption)
                    .foregroundColor(MapdColors.mediumGray)
                
                ChipButton("Try Again", isSelected: false, action: onRefresh)
            }
            .padding(MapdSpacing.lg)
        }
    }
}

struct EmptyDestinationsView: View {
    let onRefresh: () -> Void
    
    var body: some View {
        MapdCard {
            VStack(spacing: MapdSpacing.md) {
                Image(systemName: "globe.asia.australia")
                    .font(.title2)
                    .foregroundColor(MapdColors.mediumGray)
                
                Text("Discover amazing destinations")
                    .font(MapdTypography.caption)
                    .foregroundColor(MapdColors.mediumGray)
                
                ChipButton("Get Suggestions", isSelected: true, action: onRefresh)
            }
            .padding(MapdSpacing.lg)
        }
    }
}

struct EmptyInterestsView: View {
    var body: some View {
        MapdCard {
            VStack(spacing: MapdSpacing.md) {
                Image(systemName: "heart.circle")
                    .font(.title2)
                    .foregroundColor(MapdColors.mediumGray)
                
                Text("Add interests to get personalized recommendations")
                    .font(MapdTypography.caption)
                    .foregroundColor(MapdColors.mediumGray)
                    .multilineTextAlignment(.center)
                
                ChipButton("Update Interests", isSelected: false) {
                    // Navigate to interests settings
                }
            }
            .padding(MapdSpacing.lg)
        }
    }
}

// MARK: - Random Destination Model
struct RandomDestination {
    let name: String
    let country: String
    let description: String
    let icon: String
    let color: Color
    let coordinate: CLLocationCoordinate2D
    let interests: [TravelInterest]
}

#Preview {
    RecommendationsSection(
        userInterests: [.culture, .food, .nature],
        locationManager: LocationManager()
    )
    .padding()
}