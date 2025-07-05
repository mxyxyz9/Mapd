//
//  UpcomingTripsSection.swift
//  Mapd
//
//  Created by Pala Rushil on 7/5/25.
//

import SwiftUI

struct UpcomingTripsSection: View {
    let trips: [Trip]
    
    private var upcomingTrips: [Trip] {
        trips.filter { trip in
            trip.startDate > Date() || (trip.startDate <= Date() && trip.endDate >= Date())
        }
        .sorted { $0.startDate < $1.startDate }
        .prefix(3)
        .map { $0 }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: MapdSpacing.md) {
            HStack {
                Text("Upcoming Trips")
                    .font(MapdTypography.heading2)
                    .foregroundColor(MapdColors.darkText)
                
                Spacer()
                
                if !upcomingTrips.isEmpty {
                    Button("View All") {
                        // Navigate to trips list
                    }
                    .font(MapdTypography.caption)
                    .foregroundColor(MapdColors.accent)
                }
            }
            
            if upcomingTrips.isEmpty {
                EmptyTripsCard()
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: MapdSpacing.md) {
                        ForEach(upcomingTrips, id: \.id) { trip in
                            TripCard(trip: trip)
                                .frame(width: 280)
                        }
                    }
                    .padding(.horizontal, MapdSpacing.screenPadding)
                }
                .padding(.horizontal, -MapdSpacing.screenPadding)
            }
        }
    }
}

struct EmptyTripsCard: View {
    var body: some View {
        MapdCard {
            VStack(spacing: MapdSpacing.md) {
                Image(systemName: "airplane.circle")
                    .font(.title)
                    .foregroundColor(MapdColors.mediumGray)
                
                VStack(spacing: MapdSpacing.xs) {
                    Text("No Upcoming Trips")
                        .font(MapdTypography.bodyBold)
                        .foregroundColor(MapdColors.darkText)
                    
                    Text("Start planning your next adventure")
                        .font(MapdTypography.caption)
                        .foregroundColor(MapdColors.mediumGray)
                        .multilineTextAlignment(.center)
                }
                
                MapdButton("Plan a Trip", icon: "plus", style: .secondary, size: .small) {
                    // Navigate to trip planning
                }
            }
            .padding(MapdSpacing.lg)
        }
    }
}

struct TripCard: View {
    let trip: Trip
    
    private var daysUntilTrip: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: trip.startDate).day ?? 0
    }
    
    private var isActive: Bool {
        Date() >= trip.startDate && Date() <= trip.endDate
    }
    
    private var tripDuration: Int {
        Calendar.current.dateComponents([.day], from: trip.startDate, to: trip.endDate).day ?? 0
    }
    
    var body: some View {
        MapdCard(variant: .elevated) {
            VStack(alignment: .leading, spacing: MapdSpacing.md) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: MapdSpacing.xs) {
                        Text(trip.name)
                            .font(MapdTypography.bodyBold)
                            .foregroundColor(MapdColors.darkText)
                            .lineLimit(1)
                        
                        Text(trip.destination)
                            .font(MapdTypography.caption)
                            .foregroundColor(MapdColors.mediumGray)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    TripTypeIcon(type: trip.type)
                }
                
                // Status Badge
                HStack {
                    if isActive {
                        StatusBadge(text: "Active", color: MapdColors.success)
                    } else if daysUntilTrip <= 7 {
                        StatusBadge(text: "\(daysUntilTrip)d left", color: MapdColors.warning)
                    } else {
                        StatusBadge(text: "\(daysUntilTrip) days", color: MapdColors.accent)
                    }
                    
                    Spacer()
                    
                    Text("\(tripDuration + 1) days")
                        .font(MapdTypography.small)
                        .foregroundColor(MapdColors.mediumGray)
                }
                
                // Dates
                VStack(alignment: .leading, spacing: MapdSpacing.xs) {
                    HStack {
                        Image(systemName: "calendar")
                            .font(.caption)
                            .foregroundColor(MapdColors.mediumGray)
                        
                        Text(trip.startDate, style: .date)
                            .font(MapdTypography.small)
                            .foregroundColor(MapdColors.mediumGray)
                        
                        Text("→")
                            .font(MapdTypography.small)
                            .foregroundColor(MapdColors.mediumGray)
                        
                        Text(trip.endDate, style: .date)
                            .font(MapdTypography.small)
                            .foregroundColor(MapdColors.mediumGray)
                    }
                    
                    if !trip.travelers.isEmpty {
                        HStack {
                            Image(systemName: "person.2")
                                .font(.caption)
                                .foregroundColor(MapdColors.mediumGray)
                            
                            Text("\(trip.travelers.count) traveler\(trip.travelers.count == 1 ? "" : "s")")
                                .font(MapdTypography.small)
                                .foregroundColor(MapdColors.mediumGray)
                        }
                    }
                }
                
                // Progress
                if !trip.checklist.isEmpty {
                    TripProgressBar(trip: trip)
                }
                
                // Action Button
                MapdButton(
                    isActive ? "View Trip" : "Manage",
                    style: .secondary,
                    size: .small
                ) {
                    // Navigate to trip details
                }
            }
        }
    }
}

struct TripTypeIcon: View {
    let type: TripType
    
    var body: some View {
        Image(systemName: type.icon)
            .font(.title3)
            .foregroundColor(type.color)
            .frame(width: 24, height: 24)
    }
}

struct StatusBadge: View {
    let text: String
    let color: Color
    
    var body: some View {
        Text(text)
            .font(MapdTypography.small)
            .fontWeight(.medium)
            .foregroundColor(color)
            .padding(.horizontal, MapdSpacing.sm)
            .padding(.vertical, MapdSpacing.xs)
            .background(color.opacity(0.1))
            .cornerRadius(MapdRadius.button)
    }
}

struct TripProgressBar: View {
    let trip: Trip
    
    private var completedItems: Int {
        trip.checklist.filter { $0.isCompleted }.count
    }
    
    private var totalItems: Int {
        trip.checklist.count
    }
    
    private var progress: Double {
        totalItems > 0 ? Double(completedItems) / Double(totalItems) : 0
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: MapdSpacing.xs) {
            HStack {
                Text("Checklist Progress")
                    .font(MapdTypography.small)
                    .foregroundColor(MapdColors.mediumGray)
                
                Spacer()
                
                Text("\(completedItems)/\(totalItems)")
                    .font(MapdTypography.small)
                    .foregroundColor(MapdColors.mediumGray)
            }
            
            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: MapdColors.accent))
                .scaleEffect(x: 1, y: 1.5)
        }
    }
}

// MARK: - Trip Type Extensions
extension TripType {
    var icon: String {
        switch self {
        case .leisure: return "beach.umbrella"
        case .business: return "briefcase"
        case .adventure: return "mountain.2"
        case .cultural: return "building.columns"
        case .family: return "figure.2.and.child.holdinghands"
        case .romantic: return "heart"
        case .solo: return "figure.walk"
        case .group: return "person.3"
        }
    }
    
    var color: Color {
        switch self {
        case .leisure: return MapdColors.success
        case .business: return MapdColors.darkText
        case .adventure: return MapdColors.warning
        case .cultural: return MapdColors.accent
        case .family: return MapdColors.success
        case .romantic: return MapdColors.error
        case .solo: return MapdColors.mediumGray
        case .group: return MapdColors.accent
        }
    }
}

#Preview {
    UpcomingTripsSection(trips: Trip.sampleTrips)
        .padding()
}