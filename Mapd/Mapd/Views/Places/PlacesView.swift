//
//  PlacesView.swift
//  Mapd
//
//  Created by Pala Rushil on 7/5/25.
//

import SwiftUI
import MapKit
import Foundation

struct PlacesView: View {
    @ObservedObject var userManager: UserManager
    @ObservedObject var locationManager: LocationManager
    
    @State private var selectedTab = 0
    @State private var searchText = ""
    @State private var selectedFilter: PlaceFilter = .all
    @State private var showingAddPlace = false
    @State private var showingMapView = false
    @State private var selectedPlace: Place?
    
    private var visitedPlaces: [Place] {
        userManager.currentUser.visitedPlaces
    }
    
    private var bucketListPlaces: [Place] {
        userManager.currentUser.bucketList
    }
    
    private var filteredVisitedPlaces: [Place] {
        filterPlaces(visitedPlaces)
    }
    
    private var filteredBucketListPlaces: [Place] {
        filterPlaces(bucketListPlaces)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with stats
                PlacesHeader(
                    visitedCount: visitedPlaces.count,
                    bucketListCount: bucketListPlaces.count,
                    onMapTap: { showingMapView = true }
                )
                
                // Search and Filter
                SearchAndFilterSection(
                    searchText: $searchText,
                    selectedFilter: $selectedFilter
                )
                
                // Tab Selector
                PlacesTabSelector(selectedTab: $selectedTab)
                
                // Content
                TabView(selection: $selectedTab) {
                    // Visited Places
                    PlacesListView(
                        places: filteredVisitedPlaces,
                        emptyStateConfig: EmptyStateConfig(
                            icon: "checkmark.circle",
                            title: "No Visited Places",
                            subtitle: searchText.isEmpty ? "Start exploring and add your first visited place!" : "No visited places match your search.",
                            actionTitle: searchText.isEmpty ? "Add Place" : nil,
                            action: searchText.isEmpty ? { showingAddPlace = true } : nil
                        ),
                        onPlaceTap: { place in selectedPlace = place }
                    )
                    .tag(0)
                    
                    // Bucket List
                    PlacesListView(
                        places: filteredBucketListPlaces,
                        emptyStateConfig: EmptyStateConfig(
                            icon: "heart",
                            title: "No Bucket List Places",
                            subtitle: searchText.isEmpty ? "Add places you want to visit to your bucket list!" : "No bucket list places match your search.",
                            actionTitle: searchText.isEmpty ? "Add Place" : nil,
                            action: searchText.isEmpty ? { showingAddPlace = true } : nil
                        ),
                        onPlaceTap: { place in selectedPlace = place }
                    )
                    .tag(1)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .background(MapdColors.background)
            .navigationTitle("Places")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddPlace = true }) {
                        Image(systemName: "plus")
                            .font(.title3)
                            .foregroundColor(MapdColors.accent)
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddPlace) {
            AddPlaceView(
                userManager: userManager,
                locationManager: locationManager
            )
        }
        .sheet(isPresented: $showingMapView) {
            PlacesMapView(
                visitedPlaces: visitedPlaces,
                bucketListPlaces: bucketListPlaces
            )
        }
        .sheet(item: $selectedPlace) { place in
            PlaceDetailView(
                place: place,
                userManager: userManager
            )
        }
    }
    
    private func filterPlaces(_ places: [Place]) -> [Place] {
        var filtered = places
        
        // Apply search filter
        if !searchText.isEmpty {
            filtered = filtered.filter { place in
                place.name.localizedCaseInsensitiveContains(searchText) ||
                place.city.localizedCaseInsensitiveContains(searchText) ||
                place.country.localizedCaseInsensitiveContains(searchText) ||
                place.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
        
        // Apply category filter
        switch selectedFilter {
        case .all:
            break
        case .recent:
            filtered = filtered.filter { place in
                guard let dateVisited = place.dateVisited else { return false }
                return Calendar.current.isDate(dateVisited, equalTo: Date(), toGranularity: .month)
            }
        case .highRated:
            filtered = filtered.filter { place in
                guard let rating = place.rating else { return false }
                return rating >= 4.0
            }
        case .tag(let tagName):
            filtered = filtered.filter { $0.tags.contains(tagName) }
        }
        
        // Sort by date visited (most recent first) or by name
        return filtered.sorted { place1, place2 in
            if let date1 = place1.dateVisited, let date2 = place2.dateVisited {
                return date1 > date2
            } else if place1.dateVisited != nil {
                return true
            } else if place2.dateVisited != nil {
                return false
            } else {
                return place1.name < place2.name
            }
        }
    }
}

// MARK: - Places Header
struct PlacesHeader: View {
    let visitedCount: Int
    let bucketListCount: Int
    let onMapTap: () -> Void
    
    var body: some View {
        VStack(spacing: MapdSpacing.md) {
            HStack(spacing: MapdSpacing.lg) {
                // Visited Stats
                StatCard(
                    title: "Visited",
                    value: "\(visitedCount)",
                    icon: "checkmark.circle.fill",
                    color: MapdColors.success
                )
                
                // Bucket List Stats
                StatCard(
                    title: "Bucket List",
                    value: "\(bucketListCount)",
                    icon: "heart.fill",
                    color: MapdColors.error
                )
                
                // Map Button
                Button(action: onMapTap) {
                    VStack(spacing: MapdSpacing.xs) {
                        Image(systemName: "map.fill")
                            .font(.title2)
                            .foregroundColor(MapdColors.accent)
                        
                        Text("Map")
                            .font(MapdTypography.caption)
                            .foregroundColor(MapdColors.mediumGray)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, MapdSpacing.md)
                    .background(MapdColors.cardBackground)
                    .cornerRadius(MapdRadius.card)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, MapdSpacing.screenPadding)
        .padding(.bottom, MapdSpacing.md)
    }
}

// MARK: - Search and Filter Section
struct SearchAndFilterSection: View {
    @Binding var searchText: String
    @Binding var selectedFilter: PlaceFilter
    
    var body: some View {
        VStack(spacing: MapdSpacing.md) {
            // Search Bar
            HStack(spacing: MapdSpacing.md) {
                HStack(spacing: MapdSpacing.sm) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(MapdColors.mediumGray)
                    
                    TextField("Search places...", text: $searchText)
                        .font(MapdTypography.body)
                }
                .padding(MapdSpacing.md)
                .background(MapdColors.cardBackground)
                .cornerRadius(MapdRadius.input)
                
                if !searchText.isEmpty {
                    Button("Cancel") {
                        searchText = ""
                        hideKeyboard()
                    }
                    .font(MapdTypography.body)
                    .foregroundColor(MapdColors.accent)
                }
            }
            
            // Filter Chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: MapdSpacing.sm) {
                    ForEach(PlaceFilter.allCases, id: \.self) { filter in
                        FilterChip(
                            filter: filter,
                            isSelected: selectedFilter == filter
                        ) {
                            selectedFilter = filter
                        }
                    }
                }
                .padding(.horizontal, MapdSpacing.screenPadding)
            }
        }
        .padding(.horizontal, MapdSpacing.screenPadding)
        .padding(.bottom, MapdSpacing.md)
    }
}

// MARK: - Places Tab Selector
struct PlacesTabSelector: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        HStack(spacing: 0) {
            // Visited Tab
            Button(action: { selectedTab = 0 }) {
                VStack(spacing: MapdSpacing.xs) {
                    Text("Visited")
                        .font(MapdTypography.bodyBold)
                        .foregroundColor(selectedTab == 0 ? MapdColors.accent : MapdColors.mediumGray)
                    
                    Rectangle()
                        .fill(selectedTab == 0 ? MapdColors.accent : Color.clear)
                        .frame(height: 2)
                }
            }
            .frame(maxWidth: .infinity)
            
            // Bucket List Tab
            Button(action: { selectedTab = 1 }) {
                VStack(spacing: MapdSpacing.xs) {
                    Text("Bucket List")
                        .font(MapdTypography.bodyBold)
                        .foregroundColor(selectedTab == 1 ? MapdColors.accent : MapdColors.mediumGray)
                    
                    Rectangle()
                        .fill(selectedTab == 1 ? MapdColors.accent : Color.clear)
                        .frame(height: 2)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .background(MapdColors.cardBackground)
    }
}

// MARK: - Places List View
struct PlacesListView: View {
    let places: [Place]
    let emptyStateConfig: EmptyStateConfig
    let onPlaceTap: (Place) -> Void
    
    var body: some View {
        if places.isEmpty {
            PlacesEmptyState(config: emptyStateConfig)
        } else {
            ScrollView {
                LazyVStack(spacing: MapdSpacing.md) {
                    ForEach(places) { place in
                        PlaceRowCard(
                            place: place,
                            onTap: { onPlaceTap(place) }
                        )
                    }
                }
                .padding(.horizontal, MapdSpacing.screenPadding)
                .padding(.vertical, MapdSpacing.md)
            }
        }
    }
}

// MARK: - Place Row Card
struct PlaceRowCard: View {
    let place: Place
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: MapdSpacing.md) {
                // Place Image Placeholder
                ZStack {
                    RoundedRectangle(cornerRadius: MapdRadius.card)
                        .fill(MapdColors.lightGray.opacity(0.3))
                        .frame(width: 80, height: 80)
                    
                    if place.photos.isEmpty {
                        Image(systemName: "photo")
                            .font(.title2)
                            .foregroundColor(MapdColors.mediumGray)
                    } else {
                        // TODO: Load actual image
                        Image(systemName: "photo.fill")
                            .font(.title2)
                            .foregroundColor(MapdColors.accent)
                    }
                }
                
                // Place Info
                VStack(alignment: .leading, spacing: MapdSpacing.xs) {
                    HStack {
                        Text(place.name)
                            .font(MapdTypography.bodyBold)
                            .foregroundColor(MapdColors.darkText)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        if place.isFavorite {
                            Image(systemName: "heart.fill")
                                .font(.caption)
                                .foregroundColor(MapdColors.error)
                        }
                    }
                    
                    Text("\(place.city), \(place.country)")
                        .font(MapdTypography.small)
                        .foregroundColor(MapdColors.mediumGray)
                        .lineLimit(1)
                    
                    HStack {
                        // Rating or Status
                        if let rating = place.rating {
                            HStack(spacing: MapdSpacing.xs) {
                                Image(systemName: "star.fill")
                                    .font(.caption)
                                    .foregroundColor(MapdColors.warning)
                                
                                Text("\(rating, specifier: "%.1f")")
                                    .font(MapdTypography.caption)
                                    .foregroundColor(MapdColors.mediumGray)
                            }
                        } else if !place.isVisited {
                            HStack(spacing: MapdSpacing.xs) {
                                Image(systemName: "heart")
                                    .font(.caption)
                                    .foregroundColor(MapdColors.warning)
                                
                                Text("Want to visit")
                                    .font(MapdTypography.caption)
                                    .foregroundColor(MapdColors.mediumGray)
                            }
                        }
                        
                        Spacer()
                        
                        // Date
                        if let dateVisited = place.dateVisited {
                            Text(dateVisited.formatted(date: .abbreviated, time: .omitted))
                                .font(MapdTypography.caption)
                                .foregroundColor(MapdColors.mediumGray)
                        }
                    }
                    
                    // Tags
                    if !place.tags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: MapdSpacing.xs) {
                                ForEach(place.tags.prefix(3), id: \.self) { tag in
                                    Text(tag)
                                        .font(MapdTypography.caption)
                                        .padding(.horizontal, MapdSpacing.xs)
                                        .padding(.vertical, 2)
                                        .background(MapdColors.accent.opacity(0.1))
                                        .foregroundColor(MapdColors.accent)
                                        .cornerRadius(MapdRadius.button)
                                }
                                
                                if place.tags.count > 3 {
                                    Text("+\(place.tags.count - 3)")
                                        .font(MapdTypography.caption)
                                        .foregroundColor(MapdColors.mediumGray)
                                }
                            }
                        }
                    }
                }
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(MapdColors.mediumGray)
            }
            .padding(MapdSpacing.md)
            .background(MapdColors.cardBackground)
            .cornerRadius(MapdRadius.card)
                                        .shadow(color: MapdShadows.light.color, radius: MapdShadows.light.radius, x: MapdShadows.light.x, y: MapdShadows.light.y)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Filter Chip
struct FilterChip: View {
    let filter: PlaceFilter
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: MapdSpacing.xs) {
                Image(systemName: filter.icon)
                    .font(.caption)
                
                Text(filter.title)
                    .font(MapdTypography.small)
            }
            .padding(.horizontal, MapdSpacing.md)
            .padding(.vertical, MapdSpacing.sm)
            .background(isSelected ? MapdColors.accent : MapdColors.cardBackground)
            .foregroundColor(isSelected ? .white : MapdColors.mediumGray)
            .cornerRadius(MapdRadius.button)
            .overlay(
                RoundedRectangle(cornerRadius: MapdRadius.button)
                    .stroke(isSelected ? Color.clear : MapdColors.lightGray, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Empty State
struct EmptyStateConfig {
    let icon: String
    let title: String
    let subtitle: String
    let actionTitle: String?
    let action: (() -> Void)?
}

struct PlacesEmptyState: View {
    let config: EmptyStateConfig
    
    var body: some View {
        VStack(spacing: MapdSpacing.lg) {
            Spacer()
            
            VStack(spacing: MapdSpacing.md) {
                Image(systemName: config.icon)
                    .font(.system(size: 60))
                    .foregroundColor(MapdColors.lightGray)
                
                VStack(spacing: MapdSpacing.sm) {
                    Text(config.title)
                        .font(MapdTypography.heading2)
                        .foregroundColor(MapdColors.darkText)
                    
                    Text(config.subtitle)
                        .font(MapdTypography.body)
                        .foregroundColor(MapdColors.mediumGray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, MapdSpacing.xl)
                }
                
                if let actionTitle = config.actionTitle, let action = config.action {
                    MapdButton(
                        actionTitle,
                        style: .primary,
                        size: .medium,
                        action: action
                    )
                    .padding(.top, MapdSpacing.md)
                }
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(MapdColors.background)
    }
}

// MARK: - Place Filter Enum
enum PlaceFilter: CaseIterable, Equatable, Hashable {
    case all
    case favorites
    case recent
    case highRated
    case tag(String)
    
    static var allCases: [PlaceFilter] {
        [.all, .favorites, .recent, .highRated]
    }
    
    var title: String {
        switch self {
        case .all: return "All"
        case .favorites: return "Favorites"
        case .recent: return "Recent"
        case .highRated: return "High Rated"
        case .tag(let name): return name
        }
    }
    
    var icon: String {
        switch self {
        case .all: return "list.bullet"
        case .favorites: return "heart.fill"
        case .recent: return "clock"
        case .highRated: return "star.fill"
        case .tag: return "tag.fill"
        }
    }
}

// MARK: - Helper Extensions
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Placeholder Views
struct PlacesMapView: View {
    let visitedPlaces: [Place]
    let bucketListPlaces: [Place]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Places Map")
                    .font(MapdTypography.heading1)
                
                Text("Map integration coming soon")
                    .font(MapdTypography.body)
                    .foregroundColor(MapdColors.mediumGray)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Map")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct PlaceDetailView: View {
    let place: Place
    @ObservedObject var userManager: UserManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: MapdSpacing.lg) {
                    // Header
                    VStack(alignment: .leading, spacing: MapdSpacing.md) {
                        Text(place.name)
                            .font(MapdTypography.heading1)
                            .foregroundColor(MapdColors.darkText)
                        
                        Text("\(place.city), \(place.country)")
                            .font(MapdTypography.body)
                            .foregroundColor(MapdColors.mediumGray)
                        
                        if let rating = place.rating {
                            HStack(spacing: MapdSpacing.sm) {
                                ForEach(1...5, id: \.self) { star in
                                    Image(systemName: Double(star) <= rating ? "star.fill" : "star")
                                        .foregroundColor(Double(star) <= rating ? MapdColors.warning : MapdColors.lightGray)
                                }
                                
                                Text("\(rating, specifier: "%.1f")/5")
                                    .font(MapdTypography.body)
                                    .foregroundColor(MapdColors.mediumGray)
                            }
                        }
                    }
                    
                    // Notes
                    if !place.notes.isEmpty {
                        VStack(alignment: .leading, spacing: MapdSpacing.sm) {
                            Text("Notes")
                                .font(MapdTypography.heading2)
                                .foregroundColor(MapdColors.darkText)
                            
                            Text(place.notes)
                                .font(MapdTypography.body)
                                .foregroundColor(MapdColors.mediumGray)
                        }
                    }
                    
                    // Tags
                    if !place.tags.isEmpty {
                        VStack(alignment: .leading, spacing: MapdSpacing.sm) {
                            Text("Tags")
                                .font(MapdTypography.heading2)
                                .foregroundColor(MapdColors.darkText)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: MapdSpacing.sm) {
                                ForEach(place.tags, id: \.self) { tag in
                                    Text(tag)
                                        .font(MapdTypography.small)
                                        .padding(.horizontal, MapdSpacing.sm)
                                        .padding(.vertical, MapdSpacing.xs)
                                        .background(MapdColors.accent.opacity(0.1))
                                        .foregroundColor(MapdColors.accent)
                                        .cornerRadius(MapdRadius.button)
                                }
                            }
                        }
                    }
                    
                    Spacer()
                }
                .padding(MapdSpacing.screenPadding)
            }
            .background(MapdColors.background)
            .navigationTitle("Place Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    PlacesView(
        userManager: UserManager(),
        locationManager: LocationManager()
    )
}