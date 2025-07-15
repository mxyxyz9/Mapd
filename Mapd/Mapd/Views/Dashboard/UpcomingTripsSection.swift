//
//  UpcomingTripsSection.swift
//  Mapd
//
//  Created by Pala Rushil on 7/5/25.
//

import SwiftUI
import Foundation

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





#Preview {
    UpcomingTripsSection(trips: Trip.sampleTrips)
        .padding()
}