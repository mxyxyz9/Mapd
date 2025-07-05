//
//  TripsView.swift
//  Mapd
//
//  Created by Pala Rushil on 7/5/25.
//

import SwiftUI

struct TripsView: View {
    @ObservedObject var userManager: UserManager
    @ObservedObject var locationManager: LocationManager
    
    @State private var selectedTab = 0
    @State private var searchText = ""
    @State private var selectedFilter: TripFilter = .all
    @State private var showingAddTrip = false
    @State private var selectedTrip: Trip?
    
    private var upcomingTrips: [Trip] {
        userManager.user.trips.filter { trip in
            trip.startDate > Date() || (trip.startDate <= Date() && trip.endDate >= Date())
        }
    }
    
    private var pastTrips: [Trip] {
        userManager.user.trips.filter { trip in
            trip.endDate < Date()
        }
    }
    
    private var filteredUpcomingTrips: [Trip] {
        filterTrips(upcomingTrips)
    }
    
    private var filteredPastTrips: [Trip] {
        filterTrips(pastTrips)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with stats
                TripsHeader(
                    upcomingCount: upcomingTrips.count,
                    pastCount: pastTrips.count
                )
                
                // Search and Filter
                TripsSearchAndFilterSection(
                    searchText: $searchText,
                    selectedFilter: $selectedFilter
                )
                
                // Tab Selector
                TripsTabSelector(selectedTab: $selectedTab)
                
                // Content
                TabView(selection: $selectedTab) {
                    // Upcoming Trips
                    TripsListView(
                        trips: filteredUpcomingTrips,
                        emptyStateConfig: TripEmptyStateConfig(
                            icon: "airplane",
                            title: "No Upcoming Trips",
                            subtitle: searchText.isEmpty ? "Plan your next adventure and add your first trip!" : "No upcoming trips match your search.",
                            actionTitle: searchText.isEmpty ? "Plan Trip" : nil,
                            action: searchText.isEmpty ? { showingAddTrip = true } : nil
                        ),
                        onTripTap: { trip in selectedTrip = trip }
                    )
                    .tag(0)
                    
                    // Past Trips
                    TripsListView(
                        trips: filteredPastTrips,
                        emptyStateConfig: TripEmptyStateConfig(
                            icon: "clock",
                            title: "No Past Trips",
                            subtitle: searchText.isEmpty ? "Your completed trips will appear here." : "No past trips match your search.",
                            actionTitle: nil,
                            action: nil
                        ),
                        onTripTap: { trip in selectedTrip = trip }
                    )
                    .tag(1)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .background(MapdColors.background)
            .navigationTitle("Trips")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddTrip = true }) {
                        Image(systemName: "plus")
                            .font(.title3)
                            .foregroundColor(MapdColors.accent)
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddTrip) {
            AddTripView(
                userManager: userManager,
                locationManager: locationManager
            )
        }
        .sheet(item: $selectedTrip) { trip in
            TripDetailView(
                trip: trip,
                userManager: userManager
            )
        }
    }
    
    private func filterTrips(_ trips: [Trip]) -> [Trip] {
        var filtered = trips
        
        // Apply search filter
        if !searchText.isEmpty {
            filtered = filtered.filter { trip in
                trip.name.localizedCaseInsensitiveContains(searchText) ||
                trip.destination.localizedCaseInsensitiveContains(searchText) ||
                trip.travelers.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
        
        // Apply category filter
        switch selectedFilter {
        case .all:
            break
        case .solo:
            filtered = filtered.filter { $0.travelers.count <= 1 }
        case .group:
            filtered = filtered.filter { $0.travelers.count > 1 }
        case .business:
            filtered = filtered.filter { $0.type == .business }
        case .leisure:
            filtered = filtered.filter { $0.type == .leisure }
        case .adventure:
            filtered = filtered.filter { $0.type == .adventure }
        }
        
        // Sort by start date
        return filtered.sorted { $0.startDate < $1.startDate }
    }
}

// MARK: - Trips Header
struct TripsHeader: View {
    let upcomingCount: Int
    let pastCount: Int
    
    var body: some View {
        VStack(spacing: MapdSpacing.md) {
            HStack(spacing: MapdSpacing.lg) {
                // Upcoming Stats
                StatCard(
                    title: "Upcoming",
                    value: "\(upcomingCount)",
                    icon: "airplane",
                    color: MapdColors.accent
                )
                
                // Past Stats
                StatCard(
                    title: "Completed",
                    value: "\(pastCount)",
                    icon: "checkmark.circle.fill",
                    color: MapdColors.success
                )
                
                // Total Stats
                StatCard(
                    title: "Total",
                    value: "\(upcomingCount + pastCount)",
                    icon: "list.bullet",
                    color: MapdColors.mediumGray
                )
            }
        }
        .padding(.horizontal, MapdSpacing.screenPadding)
        .padding(.bottom, MapdSpacing.md)
    }
}

// MARK: - Search and Filter Section
struct TripsSearchAndFilterSection: View {
    @Binding var searchText: String
    @Binding var selectedFilter: TripFilter
    
    var body: some View {
        VStack(spacing: MapdSpacing.md) {
            // Search Bar
            HStack(spacing: MapdSpacing.md) {
                HStack(spacing: MapdSpacing.sm) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(MapdColors.mediumGray)
                    
                    TextField("Search trips...", text: $searchText)
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
                    ForEach(TripFilter.allCases, id: \.self) { filter in
                        TripFilterChip(
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

// MARK: - Trips Tab Selector
struct TripsTabSelector: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        HStack(spacing: 0) {
            // Upcoming Tab
            Button(action: { selectedTab = 0 }) {
                VStack(spacing: MapdSpacing.xs) {
                    Text("Upcoming")
                        .font(MapdTypography.bodyBold)
                        .foregroundColor(selectedTab == 0 ? MapdColors.accent : MapdColors.mediumGray)
                    
                    Rectangle()
                        .fill(selectedTab == 0 ? MapdColors.accent : Color.clear)
                        .frame(height: 2)
                }
            }
            .frame(maxWidth: .infinity)
            
            // Past Tab
            Button(action: { selectedTab = 1 }) {
                VStack(spacing: MapdSpacing.xs) {
                    Text("Past")
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

// MARK: - Trips List View
struct TripsListView: View {
    let trips: [Trip]
    let emptyStateConfig: TripEmptyStateConfig
    let onTripTap: (Trip) -> Void
    
    var body: some View {
        if trips.isEmpty {
            TripsEmptyState(config: emptyStateConfig)
        } else {
            ScrollView {
                LazyVStack(spacing: MapdSpacing.md) {
                    ForEach(trips) { trip in
                        TripRowCard(
                            trip: trip,
                            onTap: { onTripTap(trip) }
                        )
                    }
                }
                .padding(.horizontal, MapdSpacing.screenPadding)
                .padding(.vertical, MapdSpacing.md)
            }
        }
    }
}

// MARK: - Trip Row Card
struct TripRowCard: View {
    let trip: Trip
    let onTap: () -> Void
    
    private var daysUntilTrip: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: trip.startDate).day ?? 0
    }
    
    private var tripDuration: Int {
        Calendar.current.dateComponents([.day], from: trip.startDate, to: trip.endDate).day ?? 0
    }
    
    private var isActive: Bool {
        Date() >= trip.startDate && Date() <= trip.endDate
    }
    
    private var isPast: Bool {
        Date() > trip.endDate
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: MapdSpacing.md) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: MapdSpacing.xs) {
                        Text(trip.name)
                            .font(MapdTypography.bodyBold)
                            .foregroundColor(MapdColors.darkText)
                            .lineLimit(1)
                        
                        Text(trip.destination)
                            .font(MapdTypography.small)
                            .foregroundColor(MapdColors.mediumGray)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: MapdSpacing.xs) {
                        TripStatusBadge(trip: trip)
                        
                        HStack(spacing: MapdSpacing.xs) {
                            Image(systemName: trip.type.icon)
                                .font(.caption)
                                .foregroundColor(trip.type.color)
                            
                            Text(trip.type.rawValue.capitalized)
                                .font(MapdTypography.caption)
                                .foregroundColor(MapdColors.mediumGray)
                        }
                    }
                }
                
                // Dates and Duration
                HStack {
                    VStack(alignment: .leading, spacing: MapdSpacing.xs) {
                        Text("Dates")
                            .font(MapdTypography.caption)
                            .foregroundColor(MapdColors.mediumGray)
                        
                        Text("\(trip.startDate.formatted(date: .abbreviated, time: .omitted)) - \(trip.endDate.formatted(date: .abbreviated, time: .omitted))")
                            .font(MapdTypography.small)
                            .foregroundColor(MapdColors.darkText)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: MapdSpacing.xs) {
                        if !isPast {
                            Text(isActive ? "Active" : "\(daysUntilTrip) days")
                                .font(MapdTypography.caption)
                                .foregroundColor(MapdColors.mediumGray)
                            
                            Text(isActive ? "Now" : "to go")
                                .font(MapdTypography.small)
                                .foregroundColor(isActive ? MapdColors.success : MapdColors.darkText)
                        } else {
                            Text("Duration")
                                .font(MapdTypography.caption)
                                .foregroundColor(MapdColors.mediumGray)
                            
                            Text("\(tripDuration) days")
                                .font(MapdTypography.small)
                                .foregroundColor(MapdColors.darkText)
                        }
                    }
                }
                
                // Travelers and Progress
                HStack {
                    // Travelers
                    HStack(spacing: MapdSpacing.xs) {
                        Image(systemName: "person.2")
                            .font(.caption)
                            .foregroundColor(MapdColors.mediumGray)
                        
                        Text("\(trip.travelers.count) traveler\(trip.travelers.count == 1 ? "" : "s")")
                            .font(MapdTypography.small)
                            .foregroundColor(MapdColors.mediumGray)
                    }
                    
                    Spacer()
                    
                    // Checklist Progress
                    if !trip.checklist.isEmpty {
                        let completedItems = trip.checklist.filter { $0.isCompleted }.count
                        let totalItems = trip.checklist.count
                        
                        HStack(spacing: MapdSpacing.xs) {
                            Image(systemName: "checkmark.circle")
                                .font(.caption)
                                .foregroundColor(completedItems == totalItems ? MapdColors.success : MapdColors.mediumGray)
                            
                            Text("\(completedItems)/\(totalItems)")
                                .font(MapdTypography.small)
                                .foregroundColor(MapdColors.mediumGray)
                        }
                    }
                }
                
                // Progress Bar (for upcoming trips)
                if !isPast && !trip.checklist.isEmpty {
                    let progress = Double(trip.checklist.filter { $0.isCompleted }.count) / Double(trip.checklist.count)
                    
                    VStack(alignment: .leading, spacing: MapdSpacing.xs) {
                        HStack {
                            Text("Preparation")
                                .font(MapdTypography.caption)
                                .foregroundColor(MapdColors.mediumGray)
                            
                            Spacer()
                            
                            Text("\(Int(progress * 100))%")
                                .font(MapdTypography.caption)
                                .foregroundColor(MapdColors.mediumGray)
                        }
                        
                        ProgressView(value: progress)
                            .progressViewStyle(LinearProgressViewStyle(tint: MapdColors.accent))
                            .scaleEffect(x: 1, y: 0.8)
                    }
                }
            }
            .padding(MapdSpacing.md)
            .background(MapdColors.cardBackground)
            .cornerRadius(MapdRadius.card)
            .shadow(color: MapdShadows.card.color, radius: MapdShadows.card.radius, x: MapdShadows.card.x, y: MapdShadows.card.y)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Trip Status Badge
struct TripStatusBadge: View {
    let trip: Trip
    
    private var status: (text: String, color: Color) {
        let now = Date()
        
        if now < trip.startDate {
            return ("Upcoming", MapdColors.accent)
        } else if now >= trip.startDate && now <= trip.endDate {
            return ("Active", MapdColors.success)
        } else {
            return ("Completed", MapdColors.mediumGray)
        }
    }
    
    var body: some View {
        Text(status.text)
            .font(MapdTypography.caption)
            .padding(.horizontal, MapdSpacing.sm)
            .padding(.vertical, 2)
            .background(status.color.opacity(0.1))
            .foregroundColor(status.color)
            .cornerRadius(MapdRadius.button)
    }
}

// MARK: - Trip Filter Chip
struct TripFilterChip: View {
    let filter: TripFilter
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
struct TripEmptyStateConfig {
    let icon: String
    let title: String
    let subtitle: String
    let actionTitle: String?
    let action: (() -> Void)?
}

struct TripsEmptyState: View {
    let config: TripEmptyStateConfig
    
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
                        title: actionTitle,
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

// MARK: - Trip Filter Enum
enum TripFilter: CaseIterable, Equatable {
    case all
    case solo
    case group
    case business
    case leisure
    case adventure
    
    var title: String {
        switch self {
        case .all: return "All"
        case .solo: return "Solo"
        case .group: return "Group"
        case .business: return "Business"
        case .leisure: return "Leisure"
        case .adventure: return "Adventure"
        }
    }
    
    var icon: String {
        switch self {
        case .all: return "list.bullet"
        case .solo: return "person"
        case .group: return "person.2"
        case .business: return "briefcase"
        case .leisure: return "sun.max"
        case .adventure: return "mountain.2"
        }
    }
}

// MARK: - TripType Extensions
extension TripType {
    var icon: String {
        switch self {
        case .leisure: return "sun.max"
        case .business: return "briefcase"
        case .adventure: return "mountain.2"
        case .family: return "house"
        case .romantic: return "heart"
        case .solo: return "person"
        case .group: return "person.2"
        case .other: return "airplane"
        }
    }
    
    var color: Color {
        switch self {
        case .leisure: return MapdColors.warning
        case .business: return MapdColors.mediumGray
        case .adventure: return MapdColors.success
        case .family: return MapdColors.accent
        case .romantic: return MapdColors.error
        case .solo: return MapdColors.accent
        case .group: return MapdColors.success
        case .other: return MapdColors.mediumGray
        }
    }
}

// MARK: - Placeholder Views
struct AddTripView: View {
    @ObservedObject var userManager: UserManager
    @ObservedObject var locationManager: LocationManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Add Trip")
                    .font(MapdTypography.heading1)
                
                Text("Trip planning coming soon")
                    .font(MapdTypography.body)
                    .foregroundColor(MapdColors.mediumGray)
                
                Spacer()
            }
            .padding()
            .navigationTitle("New Trip")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        dismiss()
                    }
                    .disabled(true)
                }
            }
        }
    }
}

struct TripDetailView: View {
    let trip: Trip
    @ObservedObject var userManager: UserManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: MapdSpacing.lg) {
                    // Header
                    VStack(alignment: .leading, spacing: MapdSpacing.md) {
                        Text(trip.name)
                            .font(MapdTypography.heading1)
                            .foregroundColor(MapdColors.darkText)
                        
                        Text(trip.destination)
                            .font(MapdTypography.body)
                            .foregroundColor(MapdColors.mediumGray)
                        
                        HStack {
                            Text("\(trip.startDate.formatted(date: .abbreviated, time: .omitted)) - \(trip.endDate.formatted(date: .abbreviated, time: .omitted))")
                                .font(MapdTypography.body)
                                .foregroundColor(MapdColors.darkText)
                            
                            Spacer()
                            
                            TripStatusBadge(trip: trip)
                        }
                    }
                    
                    // Travelers
                    if !trip.travelers.isEmpty {
                        VStack(alignment: .leading, spacing: MapdSpacing.sm) {
                            Text("Travelers")
                                .font(MapdTypography.heading2)
                                .foregroundColor(MapdColors.darkText)
                            
                            ForEach(trip.travelers, id: \.self) { traveler in
                                HStack {
                                    Image(systemName: "person.circle")
                                        .foregroundColor(MapdColors.accent)
                                    
                                    Text(traveler)
                                        .font(MapdTypography.body)
                                        .foregroundColor(MapdColors.darkText)
                                    
                                    Spacer()
                                }
                                .padding(.vertical, MapdSpacing.xs)
                            }
                        }
                    }
                    
                    // Checklist
                    if !trip.checklist.isEmpty {
                        VStack(alignment: .leading, spacing: MapdSpacing.sm) {
                            Text("Checklist")
                                .font(MapdTypography.heading2)
                                .foregroundColor(MapdColors.darkText)
                            
                            ForEach(trip.checklist) { item in
                                HStack {
                                    Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(item.isCompleted ? MapdColors.success : MapdColors.lightGray)
                                    
                                    Text(item.title)
                                        .font(MapdTypography.body)
                                        .foregroundColor(MapdColors.darkText)
                                        .strikethrough(item.isCompleted)
                                    
                                    Spacer()
                                }
                                .padding(.vertical, MapdSpacing.xs)
                            }
                        }
                    }
                    
                    Spacer()
                }
                .padding(MapdSpacing.screenPadding)
            }
            .background(MapdColors.background)
            .navigationTitle("Trip Details")
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
    TripsView(
        userManager: UserManager(),
        locationManager: LocationManager()
    )
}