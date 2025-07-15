//
//  DashboardView.swift
//  Mapd
//
//  Created by Pala Rushil on 7/5/25.
//

import SwiftUI
import MapKit
import Foundation

struct DashboardView: View {
    @StateObject private var userManager = UserManager()
    @StateObject private var locationManager = LocationManager()
    @State private var showingProfile = false
    @State private var showingSearch = false
    @State private var showingAddPlace = false
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            ZStack {
                MapdColors.background
                    .ignoresSafeArea()
                
                ScrollView {
                    LazyVStack(spacing: MapdSpacing.lg) {
                        // Header
                        DashboardHeader(
                            user: userManager.currentUser,
                            onProfileTap: { showingProfile = true },
                            onSearchTap: { showingSearch = true }
                        )
                        
                        // Quick Stats
                        QuickStatsSection(user: userManager.currentUser)
                        
                        // Current Location & Weather
                        if locationManager.hasLocationPermission {
                            CurrentLocationSection(locationManager: locationManager)
                        }
                        
                        // Recent Activity
                        RecentActivitySection(user: userManager.currentUser)
                        
                        // Quick Actions
                        QuickActionsSection(
                            onAddPlace: { showingAddPlace = true },
                            onPlanTrip: { /* Navigate to trip planning */ },
                            onExplore: { /* Navigate to explore */ },
                            onBucketList: { /* Navigate to bucket list */ }
                        )
                        
                        // Upcoming Trips
                        UpcomingTripsSection(trips: userManager.getUpcomingTrips())
                        
                        // Recommendations
                        RecommendationsSection(
                            userInterests: userManager.currentUser.interests,
                            locationManager: locationManager
                        )
                        
                        // Bottom Padding
                        Spacer()
                            .frame(height: 100)
                    }
                    .padding(.horizontal, MapdSpacing.screenPadding)
                }
                
                // Floating Action Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        FloatingActionButton(icon: "plus") {
                            showingAddPlace = true
                        }
                        .padding(.trailing, MapdSpacing.screenPadding)
                        .padding(.bottom, 100)
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingProfile) {
            ProfileView(userManager: userManager)
        }
        .sheet(isPresented: $showingSearch) {
            SearchView(locationManager: locationManager)
        }
        .sheet(isPresented: $showingAddPlace) {
            AddPlaceView(userManager: userManager, locationManager: locationManager)
        }
    }
}

// MARK: - Dashboard Header
struct DashboardHeader: View {
    let user: User
    let onProfileTap: () -> Void
    let onSearchTap: () -> Void
    
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<22: return "Good evening"
        default: return "Good night"
        }
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: MapdSpacing.xs) {
                Text(greeting)
                    .font(MapdTypography.caption)
                    .foregroundColor(MapdColors.mediumGray)
                
                Text(user.name.isEmpty ? "Traveler" : user.name)
                    .font(MapdTypography.heading1)
                    .foregroundColor(MapdColors.darkText)
            }
            
            Spacer()
            
            HStack(spacing: MapdSpacing.md) {
                IconButton(icon: "magnifyingglass", size: .medium) {
                    onSearchTap()
                }
                
                Button(action: onProfileTap) {
                    if let profileImage = user.profileImageName {
                        AsyncImage(url: URL(string: profileImage)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Image(systemName: "person.circle.fill")
                                .foregroundColor(MapdColors.mediumGray)
                        }
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                    } else {
                        Image(systemName: "person.circle.fill")
                            .font(.title2)
                            .foregroundColor(MapdColors.mediumGray)
                            .frame(width: 40, height: 40)
                    }
                }
            }
        }
        .padding(.top, MapdSpacing.md)
    }
}

// MARK: - Quick Stats Section
struct QuickStatsSection: View {
    let user: User
    
    var body: some View {
        VStack(alignment: .leading, spacing: MapdSpacing.md) {
            Text("Your Journey")
                .font(MapdTypography.heading2)
                .foregroundColor(MapdColors.darkText)
            
            HStack(spacing: MapdSpacing.md) {
                StatCard(
                    title: "Places Visited",
                    value: "\(user.visitedPlaces.count)",
                    icon: "location.fill",
                    color: MapdColors.accent
                )
                
                StatCard(
                    title: "Countries",
                    value: "\(Set(user.visitedPlaces.map { $0.country }).count)",
                    icon: "globe",
                    color: MapdColors.success
                )
                
                StatCard(
                    title: "Bucket List",
                    value: "\(user.bucketList.count)",
                    icon: "heart.fill",
                    color: MapdColors.warning
                )
            }
        }
    }
}

// MARK: - Current Location Section
struct CurrentLocationSection: View {
    @ObservedObject var locationManager: LocationManager
    @State private var locationName: String? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: MapdSpacing.md) {
            Text("Current Location")
                .font(MapdTypography.heading2)
                .foregroundColor(MapdColors.darkText)
            
            MapdCard(variant: .standard) {
                HStack(spacing: MapdSpacing.md) {
                    Image(systemName: "location.circle.fill")
                        .font(.title2)
                        .foregroundColor(MapdColors.accent)
                    
                    VStack(alignment: .leading, spacing: MapdSpacing.xs) {
                        if let locationName = locationName {
                            Text(locationName)
                                .font(MapdTypography.bodyBold)
                                .foregroundColor(MapdColors.darkText)
                        } else {
                            Text("Locating...")
                                .font(MapdTypography.body)
                                .foregroundColor(MapdColors.mediumGray)
                        }
                        
                        if let coordinate = locationManager.currentLocation?.coordinate {
                            Text("\(coordinate.latitude, specifier: "%.4f"), \(coordinate.longitude, specifier: "%.4f")")
                                .font(MapdTypography.small)
                                .foregroundColor(MapdColors.mediumGray)
                        }
                    }
                    
                    Spacer()
                    
                    ChipButton(title: "Explore", isSelected: false) {
                        // Navigate to nearby places
                    }
                }
            }
            .onAppear {
                Task {
                    if let coordinate = locationManager.location?.coordinate {
                        locationName = await locationManager.reverseGeocode(coordinate: coordinate)
                    }
                }
            }
        }
    }
}

// MARK: - Recent Activity Section
struct RecentActivitySection: View {
    let user: User
    
    private var recentPlaces: [Place] {
        user.visitedPlaces
            .sorted { $0.dateVisited ?? Date.distantPast > $1.dateVisited ?? Date.distantPast }
            .prefix(3)
            .map { $0 }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: MapdSpacing.md) {
            HStack {
                Text("Recent Activity")
                    .font(MapdTypography.heading2)
                    .foregroundColor(MapdColors.darkText)
                
                Spacer()
                
                Button("View All") {
                    // Navigate to full activity list
                }
                .font(MapdTypography.caption)
                .foregroundColor(MapdColors.accent)
            }
            
            if recentPlaces.isEmpty {
                EmptyStateCard(
                    icon: "clock",
                    title: "No Recent Activity",
                    description: "Start exploring and your recent visits will appear here",
                    actionTitle: "Add Your First Place",
                    action: { /* Add place action */ }
                )
            } else {
                VStack(spacing: MapdSpacing.sm) {
                    ForEach(recentPlaces, id: \.id) { place in
                        RecentActivityRow(place: place)
                    }
                }
            }
        }
    }
}

struct RecentActivityRow: View {
    let place: Place
    
    var body: some View {
        HStack(spacing: MapdSpacing.md) {
            AsyncImage(url: place.photos.first.flatMap(URL.init)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Image(systemName: "photo")
                    .foregroundColor(MapdColors.mediumGray)
            }
            .frame(width: 50, height: 50)
            .clipShape(RoundedRectangle(cornerRadius: MapdRadius.small))
            
            VStack(alignment: .leading, spacing: MapdSpacing.xs) {
                Text(place.name)
                    .font(MapdTypography.bodyBold)
                    .foregroundColor(MapdColors.darkText)
                    .lineLimit(1)
                
                Text("\(place.city), \(place.country)")
                    .font(MapdTypography.caption)
                    .foregroundColor(MapdColors.mediumGray)
                    .lineLimit(1)
                
                if let date = place.dateVisited {
                    Text(date, style: .relative)
                        .font(MapdTypography.small)
                        .foregroundColor(MapdColors.mediumGray)
                }
            }
            
            Spacer()
            
            if let rating = place.rating {
                HStack(spacing: MapdSpacing.xs) {
                    Image(systemName: "star.fill")
                        .font(.caption)
                        .foregroundColor(MapdColors.warning)
                    Text("\(rating, specifier: "%.1f")")
                        .font(MapdTypography.small)
                        .foregroundColor(MapdColors.mediumGray)
                }
            }
        }
        .padding(MapdSpacing.md)
        .background(MapdColors.cardBackground)
        .cornerRadius(MapdRadius.card)
    }
}

// MARK: - Quick Actions Section
struct QuickActionsSection: View {
    let onAddPlace: () -> Void
    let onPlanTrip: () -> Void
    let onExplore: () -> Void
    let onBucketList: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: MapdSpacing.md) {
            Text("Quick Actions")
                .font(MapdTypography.heading2)
                .foregroundColor(MapdColors.darkText)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: MapdSpacing.md) {
                QuickActionButton(
                    title: "Add Place",
                    icon: "plus.circle.fill",
                    color: MapdColors.accent,
                    action: onAddPlace
                )
                
                QuickActionButton(
                    title: "Plan Trip",
                    icon: "calendar",
                    color: MapdColors.success,
                    action: onPlanTrip
                )
                
                QuickActionButton(
                    title: "Explore",
                    icon: "safari",
                    color: MapdColors.warning,
                    action: onExplore
                )
                
                QuickActionButton(
                    title: "Bucket List",
                    icon: "heart.fill",
                    color: MapdColors.error,
                    action: onBucketList
                )
            }
        }
    }
}

// MARK: - Empty State Card
struct EmptyStateCard: View {
    let icon: String
    let title: String
    let description: String
    let actionTitle: String
    let action: () -> Void
    
    var body: some View {
        MapdCard {
            VStack(spacing: MapdSpacing.md) {
                Image(systemName: icon)
                    .font(.title)
                    .foregroundColor(MapdColors.mediumGray)
                
                VStack(spacing: MapdSpacing.xs) {
                    Text(title)
                        .font(MapdTypography.bodyBold)
                        .foregroundColor(MapdColors.darkText)
                    
                    Text(description)
                        .font(MapdTypography.caption)
                        .foregroundColor(MapdColors.mediumGray)
                        .multilineTextAlignment(.center)
                }
                
                MapdButton(actionTitle, style: .secondary, size: .small, action: action)
            }
            .padding(MapdSpacing.lg)
        }
    }
}

#Preview {
    DashboardView()
}