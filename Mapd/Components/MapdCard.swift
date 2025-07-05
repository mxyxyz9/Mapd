//
//  MapdCard.swift
//  Mapd
//
//  Created by Pala Rushil on 7/5/25.
//

import SwiftUI

struct MapdCard<Content: View>: View {
    let content: Content
    let variant: CardVariant
    let padding: CGFloat
    
    init(variant: CardVariant = .standard, padding: CGFloat? = nil, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.variant = variant
        self.padding = padding ?? (variant == .compact ? MapdSpacing.md : MapdSpacing.cardPadding)
    }
    
    var body: some View {
        content
            .padding(padding)
            .background(MapdColors.cardBackground)
            .cornerRadius(variant.cornerRadius)
            .shadow(
                color: variant.shadowColor,
                radius: variant.shadowRadius,
                x: 0,
                y: variant.shadowY
            )
    }
}

enum CardVariant {
    case standard
    case compact
    case hero
    
    var cornerRadius: CGFloat {
        switch self {
        case .standard, .compact: return MapdRadius.card
        case .hero: return MapdRadius.xlarge
        }
    }
    
    var shadowColor: Color {
        switch self {
        case .standard: return MapdShadows.light.color
        case .compact: return MapdShadows.light.color
        case .hero: return MapdShadows.medium.color
        }
    }
    
    var shadowRadius: CGFloat {
        switch self {
        case .standard: return MapdShadows.light.radius
        case .compact: return MapdShadows.light.radius
        case .hero: return MapdShadows.medium.radius
        }
    }
    
    var shadowY: CGFloat {
        switch self {
        case .standard: return MapdShadows.light.y
        case .compact: return MapdShadows.light.y
        case .hero: return MapdShadows.medium.y
        }
    }
}

// MARK: - Stat Card Component
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        MapdCard(variant: .compact) {
            HStack(spacing: MapdSpacing.md) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: MapdSpacing.xs) {
                    Text(value)
                        .font(MapdTypography.heading2)
                        .foregroundColor(MapdColors.darkText)
                    
                    Text(title)
                        .font(MapdTypography.caption)
                        .foregroundColor(MapdColors.mediumGray)
                }
                
                Spacer()
            }
        }
    }
}

// MARK: - Place Card Component
struct PlaceCard: View {
    let place: Place
    let showDate: Bool
    let onTap: (() -> Void)?
    
    init(place: Place, showDate: Bool = true, onTap: (() -> Void)? = nil) {
        self.place = place
        self.showDate = showDate
        self.onTap = onTap
    }
    
    var body: some View {
        Button(action: { onTap?() }) {
            MapdCard {
                VStack(alignment: .leading, spacing: MapdSpacing.md) {
                    HStack {
                        VStack(alignment: .leading, spacing: MapdSpacing.xs) {
                            Text(place.name)
                                .font(MapdTypography.heading2)
                                .foregroundColor(MapdColors.darkText)
                                .multilineTextAlignment(.leading)
                            
                            Text("\(place.city), \(place.country)")
                                .font(MapdTypography.caption)
                                .foregroundColor(MapdColors.mediumGray)
                        }
                        
                        Spacer()
                        
                        if place.isVisited {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(MapdColors.success)
                                .font(.title3)
                        } else if place.isInBucketList {
                            Image(systemName: "heart.fill")
                                .foregroundColor(MapdColors.accent)
                                .font(.title3)
                        }
                    }
                    
                    if showDate, let dateVisited = place.dateVisited {
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(MapdColors.mediumGray)
                                .font(.caption)
                            
                            Text(dateVisited, style: .date)
                                .font(MapdTypography.caption)
                                .foregroundColor(MapdColors.mediumGray)
                        }
                    }
                    
                    if let rating = place.rating, place.isVisited {
                        HStack(spacing: MapdSpacing.xs) {
                            ForEach(1...5, id: \.self) { star in
                                Image(systemName: star <= rating ? "star.fill" : "star")
                                    .foregroundColor(star <= rating ? MapdColors.warning : MapdColors.lightGray)
                                    .font(.caption)
                            }
                        }
                    }
                    
                    if !place.tags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: MapdSpacing.sm) {
                                ForEach(place.tags, id: \.self) { tag in
                                    Text(tag)
                                        .mapdChipStyle()
                                }
                            }
                            .padding(.horizontal, 1)
                        }
                    }
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Trip Card Component
struct TripCard: View {
    let trip: Trip
    let onTap: (() -> Void)?
    
    init(trip: Trip, onTap: (() -> Void)? = nil) {
        self.trip = trip
        self.onTap = onTap
    }
    
    var body: some View {
        Button(action: { onTap?() }) {
            MapdCard {
                VStack(alignment: .leading, spacing: MapdSpacing.md) {
                    HStack {
                        VStack(alignment: .leading, spacing: MapdSpacing.xs) {
                            Text(trip.name)
                                .font(MapdTypography.heading2)
                                .foregroundColor(MapdColors.darkText)
                            
                            Text(trip.destination.name)
                                .font(MapdTypography.caption)
                                .foregroundColor(MapdColors.mediumGray)
                        }
                        
                        Spacer()
                        
                        Image(systemName: trip.tripType.icon)
                            .foregroundColor(MapdColors.accent)
                            .font(.title3)
                    }
                    
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(MapdColors.mediumGray)
                            .font(.caption)
                        
                        Text("\(trip.startDate, style: .date) - \(trip.endDate, style: .date)")
                            .font(MapdTypography.caption)
                            .foregroundColor(MapdColors.mediumGray)
                    }
                    
                    // Progress bar
                    VStack(alignment: .leading, spacing: MapdSpacing.xs) {
                        HStack {
                            Text("Checklist Progress")
                                .font(MapdTypography.caption)
                                .foregroundColor(MapdColors.mediumGray)
                            
                            Spacer()
                            
                            Text("\(Int(trip.checklistProgress * 100))%")
                                .font(MapdTypography.caption)
                                .foregroundColor(MapdColors.darkText)
                        }
                        
                        ProgressView(value: trip.checklistProgress)
                            .progressViewStyle(LinearProgressViewStyle(tint: MapdColors.accent))
                            .scaleEffect(x: 1, y: 0.8)
                    }
                    
                    if trip.daysUntilDeparture > 0 {
                        HStack {
                            Image(systemName: "clock")
                                .foregroundColor(MapdColors.info)
                                .font(.caption)
                            
                            Text("\(trip.daysUntilDeparture) days until departure")
                                .font(MapdTypography.caption)
                                .foregroundColor(MapdColors.info)
                        }
                    }
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    VStack(spacing: MapdSpacing.md) {
        StatCard(
            title: "Places Visited",
            value: "12",
            icon: "mappin.circle.fill",
            color: MapdColors.accent
        )
        
        PlaceCard(place: Place.samplePlaces[0])
        
        TripCard(trip: Trip.sampleTrips[0])
    }
    .padding()
    .background(MapdColors.background)
}